###############################################################################################################
#       Abaqus script for calculating an imperfect Bend-Formed tetrahedral truss after closing defects        #
#                                                   Harsh Bhundiya                                            #
#                                                     11/20/2022                                              #
###############################################################################################################

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
    mdb.models['Model-1'].StaticStep(name='Alignment', previous='Initial', 
        maxNumInc=10000, nlgeom=ON)
    mdb.models['Model-1'].StaticStep(name='Relax', previous='Alignment', 
        maxNumInc=10000)
    a.DatumCsysByDefault(CARTESIAN)
    p = mdb.models['Model-1'].parts['impgeometry']
    a.Instance(name='impgeometry-1', part=p, dependent=ON)
    v = a.instances['impgeometry-1'].vertices
    verts = v.findAt(coordinates=((0, 0, 0), ))
    region = a.Set(vertices=verts, name='Origin')
    mdb.models['Model-1'].PinnedBC(name='OriginPin', createStepName='Initial', 
        region=region, localCsys=None)

def field_output_coords(filename):
    # Extract top and bottom vertices from text file
    vtoplist = []
    vbottomlist = []
    with open(filename) as file:
        for line_num, line in enumerate(file,1):
            # Parse text file to get coordinates of the two nodes and name of the constraint
            strip_line = line.strip(' ')
            line_list = strip_line.split()
            if line_num == 1:
                for x in range(0,len(line_list),3):
                    vtopcoord = []
                    vtopcoord.append(float(line_list[x]))
                    vtopcoord.append(float(line_list[x+1]))
                    vtopcoord.append(float(line_list[x+2]))
                    vtoplist.append(tuple(vtopcoord))
            else:
                for y in range(0,len(line_list),3):
                    vbottomcoord = []
                    vbottomcoord.append(float(line_list[y]))
                    vbottomcoord.append(float(line_list[y+1]))
                    vbottomcoord.append(float(line_list[y+2]))
                    vbottomlist.append(tuple(vbottomcoord))
    vtop = tuple(vtoplist)
    vbottom = tuple(vbottomlist)
    # Create sets for top and bottom vertices
    a = mdb.models['Model-1'].rootAssembly
    v = a.instances['impgeometry-1'].vertices
    vertsTOP = v.findAt(coordinates=vtop)
    regionTOP = a.Set(vertices=vertsTOP, name='TopNodes')
    vertsBOTTOM = v.findAt(coordinates=vbottom)
    regionBOTTOM = a.Set(vertices=vertsBOTTOM, name='BottomNodes')
    # Set up field outputs for getting accuracy and member forces after closing defects
    mdb.models['Model-1'].fieldOutputRequests['F-Output-1'].setValuesInStep(
        stepName='Relax', variables=('S', 'PE', 'PEEQ', 'PEMAG', 'LE', 'U', 
        'RF', 'CF', 'SF', 'NFORCSO', 'BF', 'CSTRESS', 'CDISP')) # preselected defaults plus section forces SF, beam element nodal forces NFORCSO, and body forces BF
    mdb.models['Model-1'].FieldOutputRequest(name='TopNodes', 
        createStepName='Relax', variables=('COORD', ), 
        region=regionTOP, sectionPoints=DEFAULT, rebar=EXCLUDE) # deformed coordinates of top nodes
    mdb.models['Model-1'].FieldOutputRequest(name='BottomNodes', 
        createStepName='Relax', variables=('COORD', ), 
        region=regionBOTTOM, sectionPoints=DEFAULT, rebar=EXCLUDE) # deformed coordinates of bottom nodes

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


def apply_BCdisplacements(filename):
    a = mdb.models['Model-1'].rootAssembly
    v = a.instances['impgeometry-1'].vertices
    with open(filename) as file:
        for line_num, line in enumerate(file,1):
            # Parse text file to get coordinate of imperfect node and x,y,z displacements to move it to perfect node
            strip_line = line.strip(' ')
            line_list = strip_line.split()
            r1 = []
            for x in range(0,3): r1.append(float(line_list[x]))
            r1convert = []
            r1convert.append(tuple(r1))
            r1final = tuple(r1convert)
            dispx = float(line_list[3])
            dispy = float(line_list[4])
            dispz = float(line_list[5])
            BCname = str(line_list[6])
            NODEname = str(line_list[7])
            # Find imperfect node in the assembly
            verts1 = v.findAt(coordinates=r1final)
            region1 = a.Set(vertices=verts1, name=NODEname)
            # Apply displacements as BCs
            mdb.models['Model-1'].DisplacementBC(name=BCname, createStepName='Alignment', 
                region=region1, u1=dispx, u2=dispy, u3=dispz, ur1=UNSET, ur2=UNSET, 
                ur3=UNSET, amplitude=UNSET, fixed=OFF, distributionType=UNIFORM, 
                fieldName='', localCsys=None)
            # Deactivate BCs in relax step
            mdb.models['Model-1'].boundaryConditions[BCname].deactivate('Relax')
    

# Set up radial and vertical loading models and jobs
def setup_and_run_job():
    mdb.Job(name='TetraTrussAlignDispStandard', model='Model-1', description='', type=ANALYSIS, 
        atTime=None, waitMinutes=0, waitHours=0, queue=None, memory=90, 
        memoryUnits=PERCENTAGE, getMemoryFromAnalysis=True, 
        explicitPrecision=SINGLE, nodalOutputPrecision=SINGLE, echoPrint=OFF, 
        modelPrint=OFF, contactPrint=OFF, historyPrint=OFF, 
        userSubroutine='C:\\Users\\harsh\\Documents\\Github\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Constraint Subroutine\\MPC.f', 
        scratch='', resultsFormat=ODB, multiprocessingMode=DEFAULT, numCpus=1, 
        numGPUs=0)
    mdb.jobs['TetraTrussAlignDispStandard'].submit(consistencyChecking=OFF)

# Extract deformed coordinates of top and bottom nodes and save in text file
def extract_topbottomfacenodes(odbfile,filenameTOP,filenameBOTTOM):
    odb = openOdb(odbfile)
    step_for_extraction = odb.steps['Relax']
    last_frame = step_for_extraction.frames[-1]
    coordvariable = last_frame.fieldOutputs['COORD']
    topnodeset = odb.rootAssembly.nodeSets['TOPNODES']
    bottomnodeset = odb.rootAssembly.nodeSets['BOTTOMNODES']
    # Extract COORD variable both top and bottom node at end of relax step
    topcoordsdata = coordvariable.getSubset(region = topnodeset)
    bottomcoordsdata = coordvariable.getSubset(region = bottomnodeset)
    # Save COORD varialbe in two separate files: one for top nodes and one for bottom nodes
    deformedcoordsTOP = []
    deformedcoordsBOTTOM = []
    for t in topcoordsdata.values:
        topcoordvalues = [t.data[0:3]]
        deformedcoordsTOP = deformedcoordsTOP + topcoordvalues
    for b in bottomcoordsdata.values:
        bottomcoordvalues = [b.data[0:3]]
        deformedcoordsBOTTOM = deformedcoordsBOTTOM + bottomcoordvalues
    # Save coordinates in two text files
    np.savetxt(filenameTOP,deformedcoordsTOP)
    np.savetxt(filenameBOTTOM,deformedcoordsBOTTOM)

def extract_avgselfstress(odbfile,filename):
    # Extract member forces and moments after closing defects
    odb = openOdb(odbfile)
    step_for_extraction = odb.steps['Relax']
    last_frame = step_for_extraction.frames[-1]
    # Extract Mises stress from field output
    Sout = last_frame.fieldOutputs['S'] # defined as shown here: https://www.eng-tips.com/viewthread.cfm?qid=415548, http://130.149.89.49:2080/v6.11/books/ver/default.htm?startat=ch05s02abv340.html
    Smises = []
    for val in Sout.values:
        Smises = Smises + [val.mises]
    # Save Mises stress to a text file
    np.savetxt(filename,Smises) # [Pa]

def extract_memberforces(odbfile,filename1,filename2,filename3,filename4,filename5,filename6):
    # Extract member forces and moments after closing defects
    odb = openOdb(odbfile)
    step_for_extraction = odb.steps['Relax']
    last_frame = step_for_extraction.frames[-1]
    # Extract member forces and moments from field output
    NFORCSO1out = last_frame.fieldOutputs['NFORCSO1'] # defined as shown here: https://www.eng-tips.com/viewthread.cfm?qid=415548, http://130.149.89.49:2080/v6.11/books/ver/default.htm?startat=ch05s02abv340.html
    NFORCSO2out = last_frame.fieldOutputs['NFORCSO2']
    NFORCSO3out = last_frame.fieldOutputs['NFORCSO3']
    NFORCSO4out = last_frame.fieldOutputs['NFORCSO4']
    NFORCSO5out = last_frame.fieldOutputs['NFORCSO5']
    NFORCSO6out = last_frame.fieldOutputs['NFORCSO6']
    NFORCSO1 = []
    for val in NFORCSO1out.values:
        NFORCSO1 = NFORCSO1 + [val.data]
    NFORCSO2 = []
    for val in NFORCSO2out.values:
        NFORCSO2 = NFORCSO2 + [val.data]
    NFORCSO3 = []
    for val in NFORCSO3out.values:
        NFORCSO3 = NFORCSO3 + [val.data]
    NFORCSO4 = []
    for val in NFORCSO4out.values:
        NFORCSO4 = NFORCSO4 + [val.data]
    NFORCSO5 = []
    for val in NFORCSO5out.values:
        NFORCSO5 = NFORCSO5 + [val.data]
    NFORCSO6 = []
    for val in NFORCSO6out.values:
        NFORCSO6 = NFORCSO6 + [val.data]
    # Save all six beam forces/moments to text files
    np.savetxt(filename1,NFORCSO1) # Output average axial force in all beam elements [N]
    np.savetxt(filename2,NFORCSO2)
    np.savetxt(filename3,NFORCSO3)
    np.savetxt(filename4,NFORCSO4)
    np.savetxt(filename5,NFORCSO5)
    np.savetxt(filename6,NFORCSO6)


#######################################
#           RUN FUNCTIONS             #
#######################################
geometry_mesh("C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\impgeometry.iges", "C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\MESHseedsize.txt")
assembly_and_pinBC()
field_output_coords("C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\TetrahedralTruss\\TOPBOTnodes.txt")
apply_MPCconstraints("C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\FixedDisplacements\\MPCconstraints.txt")
apply_BCdisplacements("C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\FixedDisplacements\\BCdisplacements.txt")
setup_and_run_job()
mdb.saveAs(pathName="C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\TetraTrussAlignDispStandard") # save CAE file for future reference
extract_topbottomfacenodes("C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\TetraTrussAlignDispStandard.odb","C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\TetrahedralTruss\\DeformedCoordsTOP.txt","C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\TetrahedralTruss\\DeformedCoordsBOTTOM.txt")
extract_avgselfstress("C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\TetraTrussAlignDispStandard.odb","C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\TetrahedralTruss\\Smises.txt")
extract_memberforces("C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\TetraTrussAlignDispStandard.odb","C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\TetrahedralTruss\\NFORCSO1.txt","C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\TetrahedralTruss\\NFORCSO2.txt","C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\TetrahedralTruss\\NFORCSO3.txt","C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\TetrahedralTruss\\NFORCSO4.txt","C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\TetrahedralTruss\\NFORCSO5.txt","C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\TetrahedralTruss\\NFORCSO6.txt")