#######################################################################################################
#   Abaqus script for calcualting natural frequency of an imperfect Bend-Formed tetrahedral truss     #
#                                           Harsh Bhundiya                                            #
#                                             11/20/2022                                              #
#######################################################################################################

####################
# IMPORT LIBRARIES #
####################
from re import S
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
os.chdir(r"C:\\Users\\harsh\\Documents\\Github\\Bend-Forming\\Accuracy Model\\AbaqusFiles") # Set working directory

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
    p.setValues(geometryValidity=True)                                              # MAKE ALL GEOMTRY VALID
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
    p.assignBeamSectionOrientation(region=region, method=N1_COSINES, n1=(1.0, 1.0, 1.0))
    with open(MESHseedsizefilename) as MESHseedsizefile:
        MESHseedsize = float(MESHseedsizefile.read())
    p.seedPart(size=MESHseedsize, deviationFactor=0.1, minSizeFactor=0.1)                  # Set global seed size and mesh part
    p.generateMesh()

def assembly_and_pinBC():
    a = mdb.models['Model-1'].rootAssembly
    mdb.models['Model-1'].FrequencyStep(name='Frequency', previous='Initial', 
        numEigen=15)
    a.DatumCsysByDefault(CARTESIAN)
    p = mdb.models['Model-1'].parts['impgeometry']
    a.Instance(name='impgeometry-1', part=p, dependent=ON)
    # DO NOT PIN THE NODE AT THE ORIGIN WHEN CALCUALTING NATURAL FREQUENCY (otherwise it measures PINNED-FREE frquency instead of FREE-FREE)
    # v = a.instances['impgeometry-1'].vertices
    # verts = v.findAt(coordinates=((0, 0, 0), ))
    # region = a.Set(vertices=verts, name='Origin')
    # mdb.models['Model-1'].PinnedBC(name='OriginPin', createStepName='Initial', 
    #     region=region, localCsys=None)

def apply_MPCconstraints(filename):
    a = mdb.models['Model-1'].rootAssembly
    v = a.instances['impgeometry-1'].vertices
    with open(filename) as file:
        for line_num, line in enumerate(file,1):
            # Parse text file to get coordinates of the two nodes and name of the constraint
            strip_line = line.strip(' ')
            line_list = strip_line.split()
            r1 = []
            r2 = []
            for x in range(0,3): r1.append(float(line_list[x]))
            for y in range(3,6): r2.append(float(line_list[y]))
            r1convert = []
            r2convert = []
            r1convert.append(tuple(r1))
            r2convert.append(tuple(r2))
            r1final = tuple(r1convert)
            r2final = tuple(r2convert)
            constraintname = str(line_list[6])
            # Find nodes in the assembly which correspond to the two coordinates
            verts1 = v.findAt(coordinates=r1final)
            verts2 = v.findAt(coordinates=r2final)
            region1=regionToolset.Region(vertices=verts1)
            region2=regionToolset.Region(vertices=verts2)
            # Apply user-defined MPC constraint
            mdb.models['Model-1'].MultipointConstraint(name=constraintname, 
                controlPoint=region1, surface=region2, mpcType=USER_MPC, 
                userMode=NODE_MODE_MPC, userType=0, csys=None)
    

# Set up radial and vertical loading models and jobs
def setup_and_run_job():
    mdb.Job(name='TetraTrussNaturalFrequency', model='Model-1', description='', type=ANALYSIS, 
        atTime=None, waitMinutes=0, waitHours=0, queue=None, memory=90, 
        memoryUnits=PERCENTAGE, getMemoryFromAnalysis=True, 
        explicitPrecision=SINGLE, nodalOutputPrecision=SINGLE, echoPrint=OFF, 
        modelPrint=OFF, contactPrint=OFF, historyPrint=OFF, 
        userSubroutine='C:\\Users\\harsh\\Documents\\Github\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Constraint Subroutine\\MPC_natfreq.f', 
        scratch='', resultsFormat=ODB, multiprocessingMode=DEFAULT, numCpus=1, 
        numGPUs=0)
    mdb.jobs['TetraTrussNaturalFrequency'].submit(consistencyChecking=OFF)

# Extract natural frequencies of truss and save in text file
def extract_naturalfrequency(odbfile,filename):
    odb = openOdb(odbfile)
    step_for_extraction = odb.steps['Frequency']
    region = step_for_extraction.historyRegions['Assembly ASSEMBLY']
    freqdata = region.historyOutputs['EIGFREQ'].data
    # Save all ten natural frequencies in a text file
    np.savetxt(filename,freqdata)

#######################################
#           RUN FUNCTIONS             #
#######################################
geometry_mesh("C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\impgeometry.iges", "C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\MESHseedsize.txt")
assembly_and_pinBC()
apply_MPCconstraints("C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\FixedDisplacements\\MPCconstraints.txt")
setup_and_run_job()
mdb.saveAs(pathName="C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\TetraTrussNaturalFrequency") # save CAE file for future reference
extract_naturalfrequency("C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\TetraTrussNaturalFrequency.odb","C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\TetrahedralTruss\\\NatFREQ.txt")