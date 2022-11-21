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

iges = mdb.openIges('C:/Users/harsh/Desktop/impgeometry.iges', msbo=False, 
    trimCurve=DEFAULT, topology=WIRE, scaleFromFile=OFF)
mdb.models['Model-1'].PartFromGeometryFile(name='impgeometry', 
    geometryFile=iges, combine=False, stitchTolerance=1.0, 
    dimensionality=THREE_D, type=DEFORMABLE_BODY, topology=WIRE, 
    convertToAnalytical=1, stitchEdges=1, scale=0.001)
p = mdb.models['Model-1'].parts['impgeometry']
mdb.models['Model-1'].Material(name='SteelWire')
mdb.models['Model-1'].materials['SteelWire'].Density(table=((7800.0, ), ))
mdb.models['Model-1'].materials['SteelWire'].Elastic(table=((200000000000.0, 
    0.29), ))
mdb.models['Model-1'].CircularProfile(name='CircularWire', r=0.00045)
mdb.models['Model-1'].BeamSection(name='CircularWire', 
    integration=DURING_ANALYSIS, poissonRatio=0.0, profile='CircularWire', 
    material='SteelWire', temperatureVar=LINEAR, 
    consistentMassMatrix=False)
p = mdb.models['Model-1'].parts['impgeometry']
e = p.edges
edges = e.getSequenceFromMask(mask=('[#7f ]', ), )
region = p.Set(edges=edges, name='AllNodes')
p = mdb.models['Model-1'].parts['impgeometry']
p.SectionAssignment(region=region, sectionName='CircularWire', offset=0.0, 
    offsetType=MIDDLE_SURFACE, offsetField='', 
    thicknessAssignment=FROM_SECTION)
p = mdb.models['Model-1'].parts['impgeometry']
e = p.edges
edges = e.getSequenceFromMask(mask=('[#7f ]', ), )
region = regionToolset.Region(edges=edges)
orientation=None
mdb.models['Model-1'].parts['impgeometry'].MaterialOrientation(region=region, 
    orientationType=GLOBAL, axis=AXIS_1, 
    additionalRotationType=ROTATION_NONE, localCsys=None, fieldName='', 
    stackDirection=STACK_3)
p = mdb.models['Model-1'].parts['impgeometry']
region=p.sets['AllNodes']
p = mdb.models['Model-1'].parts['impgeometry']
p.assignBeamSectionOrientation(region=region, method=N1_COSINES, n1=(0.0, 0.0, 
    -1.0))
p = mdb.models['Model-1'].parts['impgeometry']
p.seedPart(size=0.003, deviationFactor=0.1, minSizeFactor=0.1)
p = mdb.models['Model-1'].parts['impgeometry']
p.generateMesh()


a = mdb.models['Model-1'].rootAssembly
mdb.models['Model-1'].StaticStep(name='Alignment', previous='Initial', 
    maxNumInc=1000, nlgeom=ON)
mdb.models['Model-1'].StaticStep(name='Relax', previous='Alignment', 
    maxNumInc=1000)
a = mdb.models['Model-1'].rootAssembly
a.DatumCsysByDefault(CARTESIAN)
p = mdb.models['Model-1'].parts['impgeometry']
a.Instance(name='impgeometry-1', part=p, dependent=ON)
a = mdb.models['Model-1'].rootAssembly
v1 = a.instances['impgeometry-1'].vertices
verts1 = v1.getSequenceFromMask(mask=('[#1 ]', ), )
region = a.Set(vertices=verts1, name='OriginNode')
mdb.models['Model-1'].PinnedBC(name='OriginPin', createStepName='Relax', 
    region=region, localCsys=None)
a = mdb.models['Model-1'].rootAssembly
v1 = a.instances['impgeometry-1'].vertices
verts1 = v1.getSequenceFromMask(mask=('[#1 ]', ), )
region1=regionToolset.Region(vertices=verts1)
a = mdb.models['Model-1'].rootAssembly
v1 = a.instances['impgeometry-1'].vertices
verts1 = v1.getSequenceFromMask(mask=('[#8 ]', ), )
region2=regionToolset.Region(vertices=verts1)
mdb.models['Model-1'].MultipointConstraint(name='Constraint-1', 
    controlPoint=region1, surface=region2, mpcType=USER_MPC, 
    userMode=NODE_MODE_MPC, userType=0, csys=None)
a = mdb.models['Model-1'].rootAssembly
v1 = a.instances['impgeometry-1'].vertices
verts1 = v1.getSequenceFromMask(mask=('[#2 ]', ), )
region1=regionToolset.Region(vertices=verts1)
a = mdb.models['Model-1'].rootAssembly
v1 = a.instances['impgeometry-1'].vertices
verts1 = v1.getSequenceFromMask(mask=('[#20 ]', ), )
region2=regionToolset.Region(vertices=verts1)
mdb.models['Model-1'].MultipointConstraint(name='Constraint-2', 
    controlPoint=region1, surface=region2, mpcType=USER_MPC, 
    userMode=NODE_MODE_MPC, userType=0, csys=None)
a = mdb.models['Model-1'].rootAssembly
v1 = a.instances['impgeometry-1'].vertices
verts1 = v1.getSequenceFromMask(mask=('[#4 ]', ), )
region1=regionToolset.Region(vertices=verts1)
a = mdb.models['Model-1'].rootAssembly
v1 = a.instances['impgeometry-1'].vertices
verts1 = v1.getSequenceFromMask(mask=('[#80 ]', ), )
region2=regionToolset.Region(vertices=verts1)
mdb.models['Model-1'].MultipointConstraint(name='Constraint-3', 
    controlPoint=region1, surface=region2, mpcType=USER_MPC, 
    userMode=DOF_MODE_MPC, userType=0, csys=None)
a = mdb.models['Model-1'].rootAssembly
v1 = a.instances['impgeometry-1'].vertices
verts1 = v1.getSequenceFromMask(mask=('[#10 ]', ), )
region1=regionToolset.Region(vertices=verts1)
a = mdb.models['Model-1'].rootAssembly
v1 = a.instances['impgeometry-1'].vertices
verts1 = v1.getSequenceFromMask(mask=('[#40 ]', ), )
region2=regionToolset.Region(vertices=verts1)
mdb.models['Model-1'].MultipointConstraint(name='Constraint-4', 
    controlPoint=region1, surface=region2, mpcType=USER_MPC, 
    userMode=NODE_MODE_MPC, userType=0, csys=None)


a = mdb.models['Model-1'].rootAssembly
v1 = a.instances['impgeometry-1'].vertices
verts1 = v1.getSequenceFromMask(mask=('[#2 ]', ), )
region = regionToolset.Region(vertices=verts1)
mdb.models['Model-1'].DisplacementBC(name='BC-2', createStepName='Relax', 
    region=region, u1=0.0, u2=0.001, u3=0.0, ur1=UNSET, ur2=UNSET, 
    ur3=UNSET, amplitude=UNSET, fixed=OFF, distributionType=UNIFORM, 
    fieldName='', localCsys=None)
a = mdb.models['Model-1'].rootAssembly
v1 = a.instances['impgeometry-1'].vertices
verts1 = v1.getSequenceFromMask(mask=('[#4 ]', ), )
region = regionToolset.Region(vertices=verts1)
mdb.models['Model-1'].DisplacementBC(name='BC-3', createStepName='Relax', 
    region=region, u1=-0.0006228, u2=-0.0022422, u3=0.0, ur1=UNSET, 
    ur2=UNSET, ur3=UNSET, amplitude=UNSET, fixed=OFF, 
    distributionType=UNIFORM, fieldName='', localCsys=None)
a = mdb.models['Model-1'].rootAssembly
v1 = a.instances['impgeometry-1'].vertices
verts1 = v1.getSequenceFromMask(mask=('[#8 ]', ), )
region = a.Set(vertices=verts1, name='Node4')
mdb.models['Model-1'].DisplacementBC(name='BC-4', createStepName='Relax', 
    region=region, u1=-0.0048866, u2=0.0024898, u3=0.0, ur1=UNSET, 
    ur2=UNSET, ur3=UNSET, amplitude=UNSET, fixed=OFF, 
    distributionType=UNIFORM, fieldName='', localCsys=None)
a = mdb.models['Model-1'].rootAssembly
v1 = a.instances['impgeometry-1'].vertices
verts1 = v1.getSequenceFromMask(mask=('[#10 ]', ), )
region = a.Set(vertices=verts1, name='Node5')
mdb.models['Model-1'].DisplacementBC(name='BC-5', createStepName='Relax', 
    region=region, u1=0.0011215, u2=0.002565, u3=-0.0005872, ur1=UNSET, 
    ur2=UNSET, ur3=UNSET, amplitude=UNSET, fixed=OFF, 
    distributionType=UNIFORM, fieldName='', localCsys=None)
a = mdb.models['Model-1'].rootAssembly
v1 = a.instances['impgeometry-1'].vertices
verts1 = v1.getSequenceFromMask(mask=('[#20 ]', ), )
region = a.Set(vertices=verts1, name='Node6')
mdb.models['Model-1'].DisplacementBC(name='BC-6', createStepName='Relax', 
    region=region, u1=0.0022533, u2=0.0012949, u3=-0.0030714, ur1=UNSET, 
    ur2=UNSET, ur3=UNSET, amplitude=UNSET, fixed=OFF, 
    distributionType=UNIFORM, fieldName='', localCsys=None)
a = mdb.models['Model-1'].rootAssembly
v1 = a.instances['impgeometry-1'].vertices
verts1 = v1.getSequenceFromMask(mask=('[#40 ]', ), )
region = a.Set(vertices=verts1, name='Node7')
mdb.models['Model-1'].DisplacementBC(name='BC-7', createStepName='Relax', 
    region=region, u1=0.000969, u2=-9.55e-05, u3=-0.0022104, ur1=UNSET, 
    ur2=UNSET, ur3=UNSET, amplitude=UNSET, fixed=OFF, 
    distributionType=UNIFORM, fieldName='', localCsys=None)
a = mdb.models['Model-1'].rootAssembly
v1 = a.instances['impgeometry-1'].vertices
verts1 = v1.getSequenceFromMask(mask=('[#80 ]', ), )
region = a.Set(vertices=verts1, name='Node8')
mdb.models['Model-1'].DisplacementBC(name='BC-8', createStepName='Relax', 
    region=region, u1=-0.0022729, u2=-0.0041103, u3=-0.0061428, ur1=UNSET, 
    ur2=UNSET, ur3=UNSET, amplitude=UNSET, fixed=OFF, 
    distributionType=UNIFORM, fieldName='', localCsys=None)
mdb.models['Model-1'].boundaryConditions['BC-2'].move('Relax', 'Alignment')
mdb.models['Model-1'].boundaryConditions['BC-3'].move('Relax', 'Alignment')
mdb.models['Model-1'].boundaryConditions['BC-4'].move('Relax', 'Alignment')
mdb.models['Model-1'].boundaryConditions['BC-5'].move('Relax', 'Alignment')
mdb.models['Model-1'].boundaryConditions['BC-6'].move('Relax', 'Alignment')
mdb.models['Model-1'].boundaryConditions['BC-7'].move('Relax', 'Alignment')
mdb.models['Model-1'].boundaryConditions['BC-8'].move('Relax', 'Alignment')
mdb.models['Model-1'].boundaryConditions['OriginPin'].move('Relax', 
    'Alignment')
mdb.models['Model-1'].boundaryConditions['OriginPin'].move('Alignment', 
    'Initial')
mdb.models['Model-1'].boundaryConditions['BC-8'].deactivate('Relax')
mdb.models['Model-1'].boundaryConditions['BC-7'].deactivate('Relax')
mdb.models['Model-1'].boundaryConditions['BC-6'].deactivate('Relax')
mdb.models['Model-1'].boundaryConditions['BC-5'].deactivate('Relax')
mdb.models['Model-1'].boundaryConditions['BC-4'].deactivate('Relax')
mdb.models['Model-1'].boundaryConditions['BC-3'].deactivate('Relax')
mdb.models['Model-1'].boundaryConditions['BC-2'].deactivate('Relax')




mdb.Job(name='TrussAlignment', model='Model-1', description='', type=ANALYSIS, 
    atTime=None, waitMinutes=0, waitHours=0, queue=None, memory=90, 
    memoryUnits=PERCENTAGE, getMemoryFromAnalysis=True, 
    explicitPrecision=SINGLE, nodalOutputPrecision=SINGLE, echoPrint=OFF, 
    modelPrint=OFF, contactPrint=OFF, historyPrint=OFF, 
    userSubroutine='C:\\Users\\harsh\\Documents\\Wire Bending\\Accuracy Model\\AbaqusFiles\\Constraint Subroutine\\MPC.f', 
    scratch='', resultsFormat=ODB, multiprocessingMode=DEFAULT, numCpus=1, 
    numGPUs=0)
mdb.jobs['TrussAlignment'].submit(consistencyChecking=OFF)
session.mdbData.summary()
o3 = session.openOdb(
    name='C:/Users/harsh/Documents/Wire Bending/Accuracy Model/AbaqusFiles/TrussAlignment.odb')