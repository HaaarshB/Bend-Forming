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

mdb.models['Model-1'].steps.changeKey(fromName='Alignment', 
    toName='Alignment1')
mdb.models['Model-1'].StaticStep(name='Alignment2', previous='Alignment1', 
    maxNumInc=1000, initialInc=1e-05)
mdb.models['Model-1'].StaticStep(name='Alignment3', previous='Alignment2', 
    maxNumInc=1000, initialInc=1e-05)
mdb.models['Model-1'].StaticStep(name='Alignment4', previous='Alignment3', 
    initialInc=1e-05)
mdb.models['Model-1'].StaticStep(name='Alignment5', previous='Alignment4', 
    maxNumInc=1000, initialInc=1e-05)
del mdb.models['Model-1'].steps['Relax']

# SETTING UP CONNECTORS
mdb.models['Model-1'].ConnectorSection(name='NODE1_NODE7', 
    u1ReferenceLength=0.0013876, translationalType=AXIAL)
v1 = a.instances['impgeometry-1'].vertices
dtm2 = a.DatumCsysByThreePoints(origin=v1[6], coordSysType=CARTESIAN, line1=(
    1.0, 0.0, 0.0), line2=(0.0, 1.0, 0.0))
dtmid2 = a.datums[dtm2.id]
a = mdb.models['Model-1'].rootAssembly
v11 = a.instances['impgeometry-1'].vertices
wire = a.WirePolyLine(points=((v11[0], v11[6]), ), mergeType=IMPRINT, 
    meshable=False)
oldName = wire.name
mdb.models['Model-1'].rootAssembly.features.changeKey(fromName=oldName, 
    toName='NODE1_NODE7')
a = mdb.models['Model-1'].rootAssembly
e1 = a.edges
edges1 = e1.getSequenceFromMask(mask=('[#1 ]', ), )
a.Set(edges=edges1, name='NODE1_NODE7-Set-1')
region = mdb.models['Model-1'].rootAssembly.sets['NODE1_NODE7-Set-1']
csa = a.SectionAssignment(sectionName='NODE1_NODE7', region=region)
a.ConnectorOrientation(region=csa.getSet(), orient2sameAs1=False, 
    localCsys2=dtmid2)


mdb.models['Model-1'].ConnectorSection(name='NODE2_NODE9', 
    u1ReferenceLength=0.0020704, translationalType=AXIAL)
dtm2 = a.DatumCsysByThreePoints(origin=v11[8], coordSysType=CARTESIAN, line1=(
    1.0, 0.0, 0.0), line2=(0.0, 1.0, 0.0))
dtmid2 = a.datums[dtm2.id]
a = mdb.models['Model-1'].rootAssembly
v1 = a.instances['impgeometry-1'].vertices
wire = a.WirePolyLine(points=((v1[1], v1[8]), ), mergeType=IMPRINT, 
    meshable=False)
oldName = wire.name
mdb.models['Model-1'].rootAssembly.features.changeKey(fromName=oldName, 
    toName='NODE2_NODE9')
a = mdb.models['Model-1'].rootAssembly
e1 = a.edges
edges1 = e1.getSequenceFromMask(mask=('[#1 ]', ), )
a.Set(edges=edges1, name='NODE2_NODE9-Set-1')
region = mdb.models['Model-1'].rootAssembly.sets['NODE2_NODE9-Set-1']
csa = a.SectionAssignment(sectionName='NODE2_NODE9', region=region)
a.ConnectorOrientation(region=csa.getSet(), orient2sameAs1=False, 
    localCsys2=dtmid2)


mdb.models['Model-1'].ConnectorSection(name='NODE3_NODE6', 
    u1ReferenceLength=0.0007166, translationalType=AXIAL)
dtm2 = a.DatumCsysByThreePoints(origin=v1[5], coordSysType=CARTESIAN, line1=(
    1.0, 0.0, 0.0), line2=(0.0, 1.0, 0.0))
dtmid2 = a.datums[dtm2.id]
a = mdb.models['Model-1'].rootAssembly
v11 = a.instances['impgeometry-1'].vertices
wire = a.WirePolyLine(points=((v11[2], v11[5]), ), mergeType=IMPRINT, 
    meshable=False)
oldName = wire.name
mdb.models['Model-1'].rootAssembly.features.changeKey(fromName=oldName, 
    toName='NODE3_NODE6')
a = mdb.models['Model-1'].rootAssembly
e1 = a.edges
edges1 = e1.getSequenceFromMask(mask=('[#1 ]', ), )
a.Set(edges=edges1, name='NODE3_NODE6-Set-1')
region = mdb.models['Model-1'].rootAssembly.sets['NODE3_NODE6-Set-1']
csa = a.SectionAssignment(sectionName='NODE3_NODE6', region=region)
a.ConnectorOrientation(region=csa.getSet(), orient2sameAs1=False, 
    localCsys2=dtmid2)

    
mdb.models['Model-1'].ConnectorSection(name='NODE4_NODE10', 
    u1ReferenceLength=0.0016225, translationalType=AXIAL)
dtm2 = a.DatumCsysByThreePoints(origin=v11[9], coordSysType=CARTESIAN, line1=(
    1.0, 0.0, 0.0), line2=(0.0, 1.0, 0.0))
dtmid2 = a.datums[dtm2.id]
a = mdb.models['Model-1'].rootAssembly
v1 = a.instances['impgeometry-1'].vertices
wire = a.WirePolyLine(points=((v1[3], v1[9]), ), mergeType=IMPRINT, 
    meshable=False)
oldName = wire.name
mdb.models['Model-1'].rootAssembly.features.changeKey(fromName=oldName, 
    toName='NODE4_NODE10')
a = mdb.models['Model-1'].rootAssembly
e1 = a.edges
edges1 = e1.getSequenceFromMask(mask=('[#1 ]', ), )
a.Set(edges=edges1, name='NODE4_NODE10-Set-1')
region = mdb.models['Model-1'].rootAssembly.sets['NODE4_NODE10-Set-1']
csa = a.SectionAssignment(sectionName='NODE4_NODE10', region=region)
a.ConnectorOrientation(region=csa.getSet(), orient2sameAs1=False, 
    localCsys2=dtmid2)


mdb.models['Model-1'].ConnectorSection(name='NODE5_NODE8', 
    u1ReferenceLength=0.0010052, translationalType=AXIAL)
dtm2 = a.DatumCsysByThreePoints(origin=v1[7], coordSysType=CARTESIAN, line1=(
    1.0, 0.0, 0.0), line2=(0.0, 1.0, 0.0))
dtmid2 = a.datums[dtm2.id]
a = mdb.models['Model-1'].rootAssembly
v11 = a.instances['impgeometry-1'].vertices
wire = a.WirePolyLine(points=((v11[4], v11[7]), ), mergeType=IMPRINT, 
    meshable=False)
oldName = wire.name
mdb.models['Model-1'].rootAssembly.features.changeKey(fromName=oldName, 
    toName='NODE5_NODE8')
a = mdb.models['Model-1'].rootAssembly
e1 = a.edges
edges1 = e1.getSequenceFromMask(mask=('[#1 ]', ), )
a.Set(edges=edges1, name='NODE5_NODE8-Set-1')
region = mdb.models['Model-1'].rootAssembly.sets['NODE5_NODE8-Set-1']
csa = a.SectionAssignment(sectionName='NODE5_NODE8', region=region)
a.ConnectorOrientation(region=csa.getSet(), orient2sameAs1=False, 
    localCsys2=dtmid2)


# SETTING UP CONNECTOR DISPLACEMENTS
a = mdb.models['Model-1'].rootAssembly
e1 = a.edges
edges1 = e1.getSequenceFromMask(mask=('[#10 ]', ), )
region=regionToolset.Region(edges=edges1)
mdb.models['Model-1'].ConnDisplacementBC(name='NODE1_NODE7', 
    createStepName='Alignment1', region=region, u1=-0.0013737, u2=UNSET, 
    u3=UNSET, ur1=UNSET, ur2=UNSET, ur3=UNSET, amplitude=UNSET, fixed=OFF, 
    distributionType=UNIFORM)
a = mdb.models['Model-1'].rootAssembly
region=a.sets['NODE2_NODE9-Set-1']
mdb.models['Model-1'].ConnDisplacementBC(name='NODE2_NODE9', 
    createStepName='Alignment1', region=region, u1=-0.0020497, u2=UNSET, 
    u3=UNSET, ur1=UNSET, ur2=UNSET, ur3=UNSET, amplitude=UNSET, fixed=OFF, 
    distributionType=UNIFORM)
a = mdb.models['Model-1'].rootAssembly
region=a.sets['NODE3_NODE6-Set-1']
mdb.models['Model-1'].ConnDisplacementBC(name='NODE3_NODE6', 
    createStepName='Alignment1', region=region, u1=-0.0007095, u2=UNSET, 
    u3=UNSET, ur1=UNSET, ur2=UNSET, ur3=UNSET, amplitude=UNSET, fixed=OFF, 
    distributionType=UNIFORM)
a = mdb.models['Model-1'].rootAssembly
region=a.sets['NODE4_NODE10-Set-1']
mdb.models['Model-1'].ConnDisplacementBC(name='NODE4_NODE10', 
    createStepName='Alignment1', region=region, u1=-0.0016063, u2=UNSET, 
    u3=UNSET, ur1=UNSET, ur2=UNSET, ur3=UNSET, amplitude=UNSET, fixed=OFF, 
    distributionType=UNIFORM)
a = mdb.models['Model-1'].rootAssembly
region=a.sets['NODE5_NODE8-Set-1']
mdb.models['Model-1'].ConnDisplacementBC(name='NODE5_NODE8', 
    createStepName='Alignment1', region=region, u1=-0.0009952, u2=UNSET, 
    u3=UNSET, ur1=UNSET, ur2=UNSET, ur3=UNSET, amplitude=UNSET, fixed=OFF, 
    distributionType=UNIFORM)
session.viewports['Viewport: 1'].view.setValues(nearPlane=0.134464, 
    farPlane=0.23467, width=0.147485, height=0.0712076, 
    viewOffsetX=0.0155433, viewOffsetY=0.00279429)
a = mdb.models['Model-1'].rootAssembly
region=a.sets['NODE2_NODE9-Set-1']
mdb.models['Model-1'].ConnDisplacementBC(name='NODE2_NODE9_LOCK', 
    createStepName='Alignment1', region=region, u1=0.0, u2=UNSET, u3=UNSET, 
    ur1=UNSET, ur2=UNSET, ur3=UNSET, amplitude=UNSET, fixed=OFF, 
    distributionType=UNIFORM)
a = mdb.models['Model-1'].rootAssembly
region=a.sets['NODE3_NODE6-Set-1']
mdb.models['Model-1'].ConnDisplacementBC(name='NODE3_NODE6_LOCK', 
    createStepName='Alignment1', region=region, u1=0.0, u2=UNSET, u3=UNSET, 
    ur1=UNSET, ur2=UNSET, ur3=UNSET, amplitude=UNSET, fixed=OFF, 
    distributionType=UNIFORM)
a = mdb.models['Model-1'].rootAssembly
region=a.sets['NODE4_NODE10-Set-1']
mdb.models['Model-1'].ConnDisplacementBC(name='NODE4_NODE10_LOCK', 
    createStepName='Alignment1', region=region, u1=0.0, u2=UNSET, u3=UNSET, 
    ur1=UNSET, ur2=UNSET, ur3=UNSET, amplitude=UNSET, fixed=OFF, 
    distributionType=UNIFORM)
a = mdb.models['Model-1'].rootAssembly
region=a.sets['NODE5_NODE8-Set-1']
mdb.models['Model-1'].ConnDisplacementBC(name='NODE5_NODE8_LOCK', 
    createStepName='Alignment1', region=region, u1=0.0, u2=UNSET, u3=UNSET, 
    ur1=UNSET, ur2=UNSET, ur3=UNSET, amplitude=UNSET, fixed=OFF, 
    distributionType=UNIFORM)


# MOVING DISPLACEMENTS AROUND TO ALIGN WITH ALIGNMENT STEPS
mdb.models['Model-1'].boundaryConditions['NODE2_NODE9'].move('Alignment1', 
    'Alignment2')
mdb.models['Model-1'].boundaryConditions['NODE2_NODE9_LOCK'].move('Alignment1', 
    'Alignment2')
mdb.models['Model-1'].boundaryConditions['NODE2_NODE9_LOCK'].move('Alignment2', 
    'Alignment1')
mdb.models['Model-1'].boundaryConditions['NODE2_NODE9_LOCK'].deactivate(
    'Alignment2')
mdb.models['Model-1'].boundaryConditions['NODE3_NODE6'].move('Alignment1', 
    'Alignment2')
mdb.models['Model-1'].boundaryConditions['NODE3_NODE6'].move('Alignment2', 
    'Alignment3')
mdb.models['Model-1'].boundaryConditions['NODE3_NODE6_LOCK'].deactivate(
    'Alignment3')
mdb.models['Model-1'].boundaryConditions['NODE4_NODE10'].move('Alignment1', 
    'Alignment2')
mdb.models['Model-1'].boundaryConditions['NODE4_NODE10'].move('Alignment2', 
    'Alignment3')
mdb.models['Model-1'].boundaryConditions['NODE4_NODE10'].move('Alignment3', 
    'Alignment4')
mdb.models['Model-1'].boundaryConditions['NODE4_NODE10_LOCK'].deactivate(
    'Alignment4')
mdb.models['Model-1'].boundaryConditions['NODE5_NODE8'].move('Alignment1', 
    'Alignment2')
mdb.models['Model-1'].boundaryConditions['NODE5_NODE8'].move('Alignment2', 
    'Alignment3')
mdb.models['Model-1'].boundaryConditions['NODE5_NODE8'].move('Alignment3', 
    'Alignment4')
mdb.models['Model-1'].boundaryConditions['NODE5_NODE8'].move('Alignment4', 
    'Alignment5')
mdb.models['Model-1'].boundaryConditions['NODE5_NODE8_LOCK'].deactivate(
    'Alignment5')


mdb.save()
mdb.Job(name='TrussAlignDisp', model='Model-1', description='', type=ANALYSIS, 
    atTime=None, waitMinutes=0, waitHours=0, queue=None, memory=90, 
    memoryUnits=PERCENTAGE, getMemoryFromAnalysis=True, 
    explicitPrecision=SINGLE, nodalOutputPrecision=SINGLE, echoPrint=OFF, 
    modelPrint=OFF, contactPrint=OFF, historyPrint=OFF, userSubroutine='', 
    scratch='', resultsFormat=ODB, multiprocessingMode=DEFAULT, numCpus=1, 
    numGPUs=0)
mdb.jobs['TrussAlignDisp'].submit(consistencyChecking=OFF)