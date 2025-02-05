#######################################################################################################
#   Abaqus script for calcualting prestress in an imperfect Bend-Formed truss after closing defects   #
#                                           Harsh Bhundiya                                            #
#                                             07/13/2022                                              #
#######################################################################################################

####################
# IMPORT LIBRARIES #
####################
from abaqus import *
from abaqusConstants import *
import __main__
import section
import regionToolset
import displayGroupMdbToolset as dgm
import part
import material
import assembly
import step
import interaction
import load
import mesh
import optimization
import job
import sketch
import visualization
import xyPlot
import displayGroupOdbToolset as dgo
import connectorBehavior
import odbAccess
from odbAccess import *
import os
import numpy as np
os.chdir(r"C:\\Users\\harsh\\Documents\\Wire Bending\\Accuracy Model\\AbaqusFiles") # Set working directory

#######################################
#            FUNCTIONS                #
#######################################

# Import IGES file, assign material, beam sections, material orientations, beam orientations, and mesh geometry using seed size
def geometry_mesh(IGESfilename,MESHseedsizefilename):
    iges = mdb.openIges(IGESfilename, msbo=False, trimCurve=DEFAULT, topology=WIRE, scaleFromFile=OFF)
    mdb.models['Model-1'].PartFromGeometryFile(name='impgeometry', 
        geometryFile=iges, combine=False, stitchTolerance=1.0, 
        dimensionality=THREE_D, type=DEFORMABLE_BODY, topology=WIRE, 
        convertToAnalytical=1, stitchEdges=1, scale=0.001)                          # scale IGES file by 1/1000 to convert from [mm] to [m]
    p = mdb.models['Model-1'].parts['impgeometry']
    mdb.models['Model-1'].Material(name='SteelWire')
    mdb.models['Model-1'].materials['SteelWire'].Density(table=((7800.0, ), ))      # steel wire density
    mdb.models['Model-1'].materials['SteelWire'].Elastic(table=((200000000000.0,    # steel wire Young's modulus and Poisson ratio
        0.29), ))
    mdb.models['Model-1'].CircularProfile(name='CircularWire', r=0.00045)           # radius of wire cross section
    mdb.models['Model-1'].BeamSection(name='CircularWire', 
        integration=DURING_ANALYSIS, poissonRatio=0.0, profile='CircularWire', 
        material='SteelWire', temperatureVar=LINEAR, 
        consistentMassMatrix=False)
    region = p.Set(edges=p.edges, name='AllNodes')                                  # Select all edges to be part of a set called "AllNodes"
    p.SectionAssignment(region=region, sectionName='CircularWire', offset=0.0, 
        offsetType=MIDDLE_SURFACE, offsetField='', 
        thicknessAssignment=FROM_SECTION)
    region=p.sets['AllNodes']
    mdb.models['Model-1'].parts['impgeometry'].MaterialOrientation(region=region, 
        orientationType=GLOBAL, axis=AXIS_1, 
        additionalRotationType=ROTATION_NONE, localCsys=None, fieldName='', 
        stackDirection=STACK_3)
    p.assignBeamSectionOrientation(region=region, method=N1_COSINES, n1=(0.0, 0.0, 
        -1.0))
    with open(MESHseedsizefilename) as MESHseedsizefile:
        MESHseedsize = float(MESHseedsizefile.read())
    p.seedPart(size=MESHseedsize, deviationFactor=0.1, minSizeFactor=0.1)                  # Set global seed size and mesh part
    p.generateMesh()

def assembly_and_clampBC(filename):
    # Set up sequential alignment steps
    with open(filename) as file:
        for line_num, line in enumerate(file,1):
            # Parse text file to get coordinate of imperfect node and x,y,z displacements to move it to perfect node
            strip_line = line.strip(' ')
            line_list = strip_line.split()
            PrevStep = str(line_list[0])
            NewStep = str(line_list[1])
            mdb.models['Model-1'].StaticStep(name=NewStep, previous=PrevStep, maxNumInc=10000, nlgeom=ON)
    mdb.models['Model-1'].StaticRiksStep(name=NewStep+'Riks', previous=NewStep, maxLPF=1.0, maxNumInc=1000, minArcInc = 1e-08, maxArcInc = 0.05, initialArcInc=1e-08)
    # Set up clamped BC at origin node
    a = mdb.models['Model-1'].rootAssembly
    a.DatumCsysByDefault(CARTESIAN)
    p = mdb.models['Model-1'].parts['impgeometry']
    a.Instance(name='impgeometry-1', part=p, dependent=ON)
    v = a.instances['impgeometry-1'].vertices
    verts = v.findAt(coordinates=((0, 0, 0), ))
    region = a.Set(vertices=verts, name='NODE1')
    mdb.models['Model-1'].EncastreBC(name='OriginClamp', createStepName='Initial', 
        region=region, localCsys=None)

def apply_AXconnectors(filename):
    a = mdb.models['Model-1'].rootAssembly
    v = a.instances['impgeometry-1'].vertices
    with open(filename) as file:
        for line_num, line in enumerate(file,1):
            # Parse text file to get coordinates of the two nodes, name of the connector, and reference length
            strip_line = line.strip(' ')
            line_list = strip_line.split()
            vert1coord = []
            vert2coord = []
            for x in range(0,3): vert1coord.append(float(line_list[x]))
            for y in range(3,6): vert2coord.append(float(line_list[y]))
            connectorname = str(line_list[6])
            connectreflength = float(line_list[7])
            # Assign axial connector between the two nodes with the appropriate reference length
            wire = a.WirePolyLine(points=((v.findAt(coordinates=vert1coord), v.findAt(coordinates=vert2coord)), ), mergeType=IMPRINT, meshable=OFF)
            oldName = wire.name
            mdb.models['Model-1'].rootAssembly.features.changeKey(fromName=oldName, toName=connectorname+'_WIRE')
            e1 = a.edges
            edgemidpoint = []
            for j in range(0,3): edgemidpoint.append((vert1coord[j]+vert2coord[j])/2)
            edges1 = e1.findAt((edgemidpoint, ))
            a.Set(edges=edges1, name=connectorname+'_SET')
            mdb.models['Model-1'].ConnectorSection(name=connectorname, u1ReferenceLength=connectreflength, translationalType=AXIAL)
            region=a.sets[connectorname+'_SET']
            csa = a.SectionAssignment(sectionName=connectorname, region=region)
            # Output force for each connector
            mdb.models['Model-1'].FieldOutputRequest(name=connectorname+'_FORCE', 
                createStepName='Align1', variables=('CTF', ), region=region, 
                sectionPoints=DEFAULT, position=INTEGRATION_POINTS, rebar=EXCLUDE)
            mdb.models['Model-1'].HistoryOutputRequest(name=connectorname+'_FORCE', 
                createStepName='Align1', variables=('CTF1', ), region=region, 
                sectionPoints=DEFAULT, position=INTEGRATION_POINTS, rebar=EXCLUDE)

def apply_LOCKdisplacements(filename):
    a = mdb.models['Model-1'].rootAssembly
    with open(filename) as file:
        for line_num, line in enumerate(file,1):
            if (line_num > 1):
                # Parse text file to get name of connectors to lock (i.e. connectors which are closed after the first align step)
                strip_line = line.strip(' ')
                line_list = strip_line.split()
                stepname = str(line_list[1])
                for x in range(2,len(line_list),2):
                    connectorname = str(line_list[x])
                    # Apply LOCK onto connector
                    region=a.sets[connectorname+'_SET']
                    mdb.models['Model-1'].ConnDisplacementBC(name=connectorname+'_LOCK', 
                        createStepName='Align1', region=region, u1=0.0, u2=UNSET, u3=UNSET, 
                        ur1=UNSET, ur2=UNSET, ur3=UNSET, amplitude=UNSET, fixed=OFF, 
                        distributionType=UNIFORM)

def apply_CONdisplacements(filename,stopratio):
    a = mdb.models['Model-1'].rootAssembly
    with open(filename) as file:
        for line_num, line in enumerate(file,1):
            # Parse text file to get connector displacement and step name to apply it to
            strip_line = line.strip(' ')
            line_list = strip_line.split()
            stepname = str(line_list[1])
            for x in range(2,len(line_list),2):
                connectorname = str(line_list[x])
                connectordisp = float(line_list[x+1])
                region=a.sets[connectorname+'_SET']
                # Add connector displacement at appropriate align general step and Riks step afterwards
                mdb.models['Model-1'].ConnDisplacementBC(name=connectorname, createStepName=stepname, region=region, u1=connectordisp*stopratio, u2=UNSET, 
                    u3=UNSET, ur1=UNSET, ur2=UNSET, ur3=UNSET, amplitude=UNSET, fixed=OFF, distributionType=UNIFORM)
                mdb.models['Model-1'].ConnDisplacementBC(name=connectorname+'_Riks', createStepName=stepname+'Riks', region=region, u1=connectordisp, u2=UNSET, 
                    u3=UNSET, ur1=UNSET, ur2=UNSET, ur3=UNSET, amplitude=UNSET, fixed=OFF, distributionType=UNIFORM)
                if (line_num > 1):
                    # Deactivate lock on connector displacement at the same step (for all but )
                    mdb.models['Model-1'].boundaryConditions[connectorname+'_LOCK'].deactivate(stepname)   

# Set up radial and vertical loading models and jobs
def setup_and_run_job():
    mdb.Job(name='TrussAlignAllConnect', model='Model-1', description='', type=ANALYSIS, 
        atTime=None, waitMinutes=0, waitHours=0, queue=None, memory=90, 
        memoryUnits=PERCENTAGE, getMemoryFromAnalysis=True, 
        explicitPrecision=SINGLE, nodalOutputPrecision=SINGLE, echoPrint=OFF, 
        modelPrint=OFF, contactPrint=OFF, historyPrint=OFF, userSubroutine='', 
        scratch='', resultsFormat=ODB, multiprocessingMode=DEFAULT, numCpus=1, 
        numGPUs=0)
    # mdb.jobs['TrussAlignAllConnect'].submit(consistencyChecking=OFF)

# Extract forces in connectors to calculate total work to close defects
def extract_CONwork(odbfile,filename_forces,filename_disps):
    odb = openOdb(odbfile)
    CONforces = []
    CONdisps = []
    step_for_extraction = odb.steps['Align1']
    frame = step_for_extraction.frames[-1]
    Variable = frame.fieldOutputs['CTF']
    with open(AXconnectorfile) as file:
        for line_num, line in enumerate(file,1):
            # Loop through each connector in model and get axial force at end of alignment
            strip_line = line.strip(' ')
            line_list = strip_line.split()
            connectorname = str(line_list[6])
            connectorset = odb.rootAssembly.elementSets[connectorname+'_SET']
            forcevar = Variable.getSubset(region=connectorset)
            # Save all connector forces in one list
            for j in forcevar.values:
                forceval = [j.data[0]]
                CONforces = CONforces + forceval
            # Save all connector disps in one list
            connectordisp = float(line_list[8])
            CONdisps = CONdisps + [connectordisp]
    np.savetxt(filename_forces,CONforces)
    np.savetxt(filename_disps,CONdisps)

# Extract Mises stress for all beam elements in structure after alignment (i.e. self-stress from closing defects)
def extract_selfstress(odbfile,filename):
    odb = openOdb(odbfile)
    MaxMises = 0
    MaxElem = 0
    step_for_extraction = odb.steps['Align1']
    frame = step_for_extraction.frames[-1]
    Variable = frame.fieldOutputs['S']
    for j in Variable.values:
        if (j.mises > MaxMises):
            MaxMises = j.mises
    np.savetxt(filename,[MaxMises])

#######################################
#           RUN FUNCTIONS             #
#######################################
AXconnectorfile = "C:\\Users\\harsh\\Documents\\Wire Bending\\Accuracy Model\\AbaqusFiles\\Code\\AllConnectors\\AXconnectors.txt"
CLsequencefile = "C:\\Users\\harsh\\Documents\\Wire Bending\\Accuracy Model\\AbaqusFiles\\Code\\AllConnectors\\CLsequence.txt"
geometry_mesh("C:\\Users\\harsh\\Desktop\\impgeometry.iges", "C:\\Users\\harsh\\Documents\\Wire Bending\\Accuracy Model\\AbaqusFiles\\Code\\MESHseedsize.txt")
assembly_and_clampBC(CLsequencefile)
apply_AXconnectors(AXconnectorfile)
# apply_LOCKdisplacements(CLsequencefile)
apply_CONdisplacements(CLsequencefile, 0.5)
mdb.saveAs(pathName="C:\Users\harsh\Documents\Wire Bending\Accuracy Model\AbaqusFiles\TrussAlignAllConnect") # save CAE file for future reference
setup_and_run_job()
mdb.saveAs(pathName="C:\Users\harsh\Documents\Wire Bending\Accuracy Model\AbaqusFiles\TrussAlignAllConnect") # save CAE file for future reference
# Post-processing
# extract_CONwork("C:\\Users\\harsh\\Documents\\Wire Bending\\Accuracy Model\\AbaqusFiles\\TrussAlignAllConnect.odb", "C:\\Users\\harsh\\Documents\\Wire Bending\\Accuracy Model\\AbaqusFiles\\Code\\AllConnectors\\CONforces.txt","C:\\Users\\harsh\\Documents\\Wire Bending\\Accuracy Model\\AbaqusFiles\\Code\\AllConnectors\\CONdisps.txt")
# extract_selfstress("C:\\Users\\harsh\\Documents\\Wire Bending\\Accuracy Model\\AbaqusFiles\\TrussAlignAllConnect.odb", "C:\\Users\\harsh\\Documents\\Wire Bending\\Accuracy Model\\AbaqusFiles\\Code\\AllConnectors\\MAXStress.txt")