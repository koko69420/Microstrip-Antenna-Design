'# MWS Version: Version 2024.1 - Oct 16 2023 - ACIS 33.0.1 -

'# length = mm
'# frequency = MHz
'# time = ns
'# frequency range: fmin = 768 fmax = 968
'# created = '[VERSION]2024.1|33.0.1|20231016[/VERSION]


'@ use template: Antenna - Planar.cfg

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
'set the units
With Units
    .SetUnit "Length", "mm"
    .SetUnit "Frequency", "MHz"
    .SetUnit "Voltage", "V"
    .SetUnit "Resistance", "Ohm"
    .SetUnit "Inductance", "nH"
    .SetUnit "Temperature",  "degC"
    .SetUnit "Time", "ns"
    .SetUnit "Current", "A"
    .SetUnit "Conductance", "S"
    .SetUnit "Capacitance", "pF"
End With

ThermalSolver.AmbientTemperature "0"

'----------------------------------------------------------------------------

'set the frequency range
Solver.FrequencyRange "700", "1000"

'----------------------------------------------------------------------------

Plot.DrawBox True

With Background
     .Type "Normal"
     .Epsilon "1.0"
     .Mu "1.0"
     .XminSpace "0.0"
     .XmaxSpace "0.0"
     .YminSpace "0.0"
     .YmaxSpace "0.0"
     .ZminSpace "0.0"
     .ZmaxSpace "0.0"
End With

With Boundary
     .Xmin "expanded open"
     .Xmax "expanded open"
     .Ymin "expanded open"
     .Ymax "expanded open"
     .Zmin "expanded open"
     .Zmax "expanded open"
     .Xsymmetry "none"
     .Ysymmetry "none"
     .Zsymmetry "none"
End With

' optimize mesh settings for planar structures

With Mesh
     .MergeThinPECLayerFixpoints "True"
     .RatioLimit "20"
     .AutomeshRefineAtPecLines "True", "6"
     .FPBAAvoidNonRegUnite "True"
     .ConsiderSpaceForLowerMeshLimit "False"
     .MinimumStepNumber "5"
     .AnisotropicCurvatureRefinement "True"
     .AnisotropicCurvatureRefinementFSM "True"
End With

With MeshSettings
     .SetMeshType "Hex"
     .Set "RatioLimitGeometry", "20"
     .Set "EdgeRefinementOn", "1"
     .Set "EdgeRefinementRatio", "6"
End With

With MeshSettings
     .SetMeshType "HexTLM"
     .Set "RatioLimitGeometry", "20"
End With

With MeshSettings
     .SetMeshType "Tet"
     .Set "VolMeshGradation", "1.5"
     .Set "SrfMeshGradation", "1.5"
End With

' change mesh adaption scheme to energy
' 		(planar structures tend to store high energy
'     	 locally at edges rather than globally in volume)

MeshAdaption3D.SetAdaptionStrategy "Energy"

' switch on FD-TET setting for accurate farfields

FDSolver.ExtrudeOpenBC "True"

PostProcess1D.ActivateOperation "vswr", "true"
PostProcess1D.ActivateOperation "yz-matrices", "true"

With FarfieldPlot
	.ClearCuts ' lateral=phi, polar=theta
	.AddCut "lateral", "0", "1"
	.AddCut "lateral", "90", "1"
	.AddCut "polar", "90", "1"
End With

'----------------------------------------------------------------------------

Dim sDefineAt As String
sDefineAt = "700;800;868;900;1000"
Dim sDefineAtName As String
sDefineAtName = "700;800;868;900;1000"
Dim sDefineAtToken As String
sDefineAtToken = "f="
Dim aFreq() As String
aFreq = Split(sDefineAt, ";")
Dim aNames() As String
aNames = Split(sDefineAtName, ";")

Dim nIndex As Integer
For nIndex = LBound(aFreq) To UBound(aFreq)

Dim zz_val As String
zz_val = aFreq (nIndex)
Dim zz_name As String
zz_name = sDefineAtToken & aNames (nIndex)

' Define E-Field Monitors
With Monitor
    .Reset
    .Name "e-field ("& zz_name &")"
    .Dimension "Volume"
    .Domain "Frequency"
    .FieldType "Efield"
    .MonitorValue  zz_val
    .Create
End With

' Define H-Field Monitors
With Monitor
    .Reset
    .Name "h-field ("& zz_name &")"
    .Dimension "Volume"
    .Domain "Frequency"
    .FieldType "Hfield"
    .MonitorValue  zz_val
    .Create
End With

' Define Power flow Monitors
With Monitor
    .Reset
    .Name "power ("& zz_name &")"
    .Dimension "Volume"
    .Domain "Frequency"
    .FieldType "Powerflow"
    .MonitorValue  zz_val
    .Create
End With

' Define Power loss Monitors
With Monitor
    .Reset
    .Name "loss ("& zz_name &")"
    .Dimension "Volume"
    .Domain "Frequency"
    .FieldType "Powerloss"
    .MonitorValue  zz_val
    .Create
End With

' Define Farfield Monitors
With Monitor
    .Reset
    .Name "farfield ("& zz_name &")"
    .Domain "Frequency"
    .FieldType "Farfield"
    .MonitorValue  zz_val
    .ExportFarfieldSource "False"
    .Create
End With

Next

'----------------------------------------------------------------------------

With MeshSettings
     .SetMeshType "Hex"
     .Set "Version", 1%
End With

With Mesh
     .MeshType "PBA"
End With

'set the solver type
ChangeSolverType("HF Time Domain")

'----------------------------------------------------------------------------

'@ define material: Copper (annealed)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Material
     .Reset
     .Name "Copper (annealed)"
     .Folder ""
     .FrqType "static"
     .Type "Normal"
     .SetMaterialUnit "Hz", "mm"
     .Epsilon "1"
     .Mu "1.0"
     .Kappa "5.8e+007"
     .TanD "0.0"
     .TanDFreq "0.0"
     .TanDGiven "False"
     .TanDModel "ConstTanD"
     .KappaM "0"
     .TanDM "0.0"
     .TanDMFreq "0.0"
     .TanDMGiven "False"
     .TanDMModel "ConstTanD"
     .DispModelEps "None"
     .DispModelMu "None"
     .DispersiveFittingSchemeEps "Nth Order"
     .DispersiveFittingSchemeMu "Nth Order"
     .UseGeneralDispersionEps "False"
     .UseGeneralDispersionMu "False"
     .FrqType "all"
     .Type "Lossy metal"
     .SetMaterialUnit "GHz", "mm"
     .Mu "1.0"
     .Kappa "5.8e+007"
     .Rho "8930.0"
     .ThermalType "Normal"
     .ThermalConductivity "401.0"
     .SpecificHeat "390", "J/K/kg"
     .MetabolicRate "0"
     .BloodFlow "0"
     .VoxelConvection "0"
     .MechanicsType "Isotropic"
     .YoungsModulus "120"
     .PoissonsRatio "0.33"
     .ThermalExpansionRate "17"
     .Colour "1", "1", "0"
     .Wireframe "False"
     .Reflection "False"
     .Allowoutline "True"
     .Transparentoutline "False"
     .Transparency "0"
     .Create
End With

'@ new component: component1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Component.New "component1"

'@ define extrude: component1:GroundPlane

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Extrude 
     .Reset 
     .Name "GroundPlane" 
     .Component "component1" 
     .Material "Copper (annealed)" 
     .Mode "Pointlist" 
     .Height "0.0" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "0.0" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "-Wg/2", "-Lg/2" 
     .LineTo "Wg/2", "-Lg/2" 
     .LineTo "Wg/2", "Lg/2" 
     .LineTo "-Wg/2", "Lg/2" 
     .Create 
End With

'@ define material: Folder1/FR4

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Material
     .Reset
     .Name "FR4"
     .Folder "Folder1"
     .Rho "1850"
     .ThermalType "Anisotropic"
     .ThermalReferenceCoordSystem "Global"
     .ThermalCoordSystemType "Cartesian"
     .ThermalConductivityX "0.4"
     .ThermalConductivityY "0.4"
     .ThermalConductivityZ "0.3"
     .ThermalExpansionRateVolume "14"
     .SpecificHeat "1125", "J/K/kg"
     .DynamicViscosity "0"
     .UseEmissivity "False"
     .Emissivity "0"
     .MetabolicRate "0.0"
     .VoxelConvection "0.0"
     .BloodFlow "0"
     .Absorptance "0"
     .MechanicsType "Isotropic"
     .YoungsModulus "23"
     .PoissonsRatio "0.15"
     .ThermalExpansionRate "14"
     .IntrinsicCarrierDensity "0"
     .FrqType "all"
     .Type "Anisotropic"
     .MaterialUnit "Frequency", "MHz"
     .MaterialUnit "Geometry", "mm"
     .MaterialUnit "Time", "ns"
     .MaterialUnit "Temperature", "degC"
     .EpsilonX "4.55"
     .EpsilonY "4.55"
     .EpsilonZ "4.45"
     .MuX "1"
     .MuY "1"
     .MuZ "1"
     .SigmaX "0.0"
     .SigmaY "0.0"
     .SigmaZ "0.0"
     .TanDX "0.015"
     .TanDY "0.015"
     .TanDZ "0.02"
     .TanDFreq "0.0"
     .TanDGiven "True"
     .TanDModel "ConstTanD"
     .SetConstTanDStrategyEps "AutomaticOrder"
     .ConstTanDModelOrderEpsX "3"
     .ConstTanDModelOrderEpsY "3"
     .ConstTanDModelOrderEpsZ "3"
     .DjordjevicSarkarUpperFreqEps "0"
     .SetElParametricConductivity "False"
     .ReferenceCoordSystem "Global"
     .CoordSystemType "Cartesian"
     .SigmaMX "0"
     .SigmaMY "0"
     .SigmaMZ "0"
     .TanDMX "0.0"
     .TanDMY "0.0"
     .TanDMZ "0.0"
     .TanDMFreq "0.0"
     .TanDMGiven "False"
     .TanDMModel "ConstTanD"
     .SetConstTanDStrategyMu "AutomaticOrder"
     .ConstTanDModelOrderMuX "3"
     .ConstTanDModelOrderMuY "3"
     .ConstTanDModelOrderMuZ "3"
     .DjordjevicSarkarUpperFreqMu "0"
     .SetMagParametricConductivity "False"
     .DispModelEps "None"
     .DispModelMu "None"
     .DispersiveFittingSchemeEps "Nth Order"
     .MaximalOrderNthModelFitEps "10"
     .ErrorLimitNthModelFitEps "0.1"
     .DispersiveFittingSchemeMu "Nth Order"
     .MaximalOrderNthModelFitMu "10"
     .ErrorLimitNthModelFitMu "0.1"
     .UseGeneralDispersionEps "False"
     .UseGeneralDispersionMu "False"
     .NLAnisotropy "False"
     .NLAStackingFactor "1"
     .NLADirectionX "1"
     .NLADirectionY "0"
     .NLADirectionZ "0"
     .Colour "0", "0.501961", "0.25098" 
     .Wireframe "False" 
     .Reflection "False" 
     .Allowoutline "True" 
     .Transparentoutline "False" 
     .Transparency "35" 
     .Create
End With

'@ define brick: component1:solid1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Brick
     .Reset 
     .Name "solid1" 
     .Component "component1" 
     .Material "Folder1/FR4" 
     .Xrange "-Wg/2", "Wg/2" 
     .Yrange "-Lg/2", "Lg/2" 
     .Zrange "0", "h" 
     .Create
End With

'@ define extrude: component1:Patch

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Extrude 
     .Reset 
     .Name "Patch" 
     .Component "component1" 
     .Material "Copper (annealed)" 
     .Mode "Pointlist" 
     .Height "0.0" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "h" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "-W/2", "-L/2" 
     .LineTo "W/2", "-L/2" 
     .LineTo "W/2", "L/2" 
     .LineTo "wf/2+g", "L/2" 
     .LineTo "wf/2+g", "L/2-y0" 
     .LineTo "wf/2", "L/2-y0" 
     .LineTo "wf/2", "L/2" 
     .LineTo "-wf/2", "L/2" 
     .LineTo "-wf/2", "L/2-y0" 
     .LineTo "-wf/2-g", "L/2-y0" 
     .LineTo "-wf/2-g", "L/2" 
     .LineTo "-W/2", "L/2" 
     .Create 
End With

'@ define extrude: component1:FeedLine

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Extrude 
     .Reset 
     .Name "FeedLine" 
     .Component "component1" 
     .Material "Copper (annealed)" 
     .Mode "Pointlist" 
     .Height "0.0" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "h" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "-wf/2", "L/2-y0" 
     .LineTo "wf/2", "L/2-y0" 
     .LineTo "wf/2", "Lg/2" 
     .LineTo "-wf/2", "Lg/2" 
     .Create 
End With

'@ define bondwire: Folder1:ShortingVia

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Wire
     .Reset 
     .Name "ShortingVia" 
     .Folder "Folder1" 
     .Type "BondWire" 
     .Height "0" 
     .Radius "via_r" 
     .Point1 "0.0", "-L/2", "0", "False"
     .Point2 "0.0", "-L/2", "h", "False" 
     .BondWireType "Spline" 
     .Alpha "75" 
     .Beta "35" 
     .RelativeCenterPosition "0.5" 
     .Material "Copper (annealed)" 
     .SolidWireModel "False" 
     .Termination "Extended" 
     .Add
End With

'@ define discrete port: 1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With DiscretePort 
     .Reset 
     .PortNumber "1" 
     .Type "SParameter"
     .Label ""
     .Folder ""
     .Impedance "50.0"
     .Voltage "1.0"
     .Current "1.0"
     .Monitor "True"
     .Radius "wf/2"
     .SetP1 "False", "0.0", "Lg/2", "0.0"
     .SetP2 "False", "0.0", "Lg/2", "h"
     .InvertDirection "False"
     .LocalCoordinates "False"
     .Wire ""
     .Position "end1"
     .Create 
End With

'@ set mesh properties (Hexahedral)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Mesh 
     .MeshType "PBA" 
     .SetCreator "High Frequency"
End With 
With MeshSettings 
     .SetMeshType "Hex" 
     .Set "Version", 1%
     'MAX CELL - WAVELENGTH REFINEMENT 
     .Set "StepsPerWaveNear", "15" 
     .Set "StepsPerWaveFar", "15" 
     .Set "WavelengthRefinementSameAsNear", "1" 
     'MAX CELL - GEOMETRY REFINEMENT 
     .Set "StepsPerBoxNear", "20" 
     .Set "StepsPerBoxFar", "1" 
     .Set "MaxStepNear", "0" 
     .Set "MaxStepFar", "0" 
     .Set "ModelBoxDescrNear", "maxedge" 
     .Set "ModelBoxDescrFar", "maxedge" 
     .Set "UseMaxStepAbsolute", "0" 
     .Set "GeometryRefinementSameAsNear", "0" 
     'MIN CELL 
     .Set "UseRatioLimitGeometry", "1" 
     .Set "RatioLimitGeometry", "20" 
     .Set "MinStepGeometryX", "0" 
     .Set "MinStepGeometryY", "0" 
     .Set "MinStepGeometryZ", "0" 
     .Set "UseSameMinStepGeometryXYZ", "1" 
End With 
With MeshSettings 
     .Set "PlaneMergeVersion", "2" 
End With 
With MeshSettings 
     .SetMeshType "Hex" 
     .Set "FaceRefinementType", "NONE" 
     .Set "FaceRefinementRatio", "2" 
     .Set "FaceRefinementStep", "0" 
     .Set "FaceRefinementNSteps", "2" 
     .Set "EllipseRefinementType", "NONE" 
     .Set "EllipseRefinementRatio", "2" 
     .Set "EllipseRefinementStep", "0" 
     .Set "EllipseRefinementNSteps", "2" 
     .Set "FaceRefinementBufferLines", "3" 
     .Set "EdgeRefinementType", "RATIO" 
     .Set "EdgeRefinementRatio", "6" 
     .Set "EdgeRefinementStep", "0" 
     .Set "EdgeRefinementBufferLines", "3" 
     .Set "RefineEdgeMaterialGlobal", "0" 
     .Set "RefineAxialEdgeGlobal", "0" 
     .Set "BufferLinesNear", "3" 
     .Set "UseDielectrics", "1" 
     .Set "EquilibrateOn", "1" 
     .Set "Equilibrate", "1.5" 
     .Set "IgnoreThinPanelMaterial", "0" 
End With 
With MeshSettings 
     .SetMeshType "Hex" 
     .Set "SnapToAxialEdges", "1"
     .Set "SnapToPlanes", "1"
     .Set "SnapToSpheres", "1"
     .Set "SnapToEllipses", "1"
     .Set "SnapToCylinders", "1"
     .Set "SnapToCylinderCenters", "1"
     .Set "SnapToEllipseCenters", "1"
     .Set "SnapToTori", "1"
End With 
With Mesh 
     .ConnectivityCheck "True"
     .UsePecEdgeModel "True" 
     .PointAccEnhancement "0" 
     .TSTVersion "0"
	  .PBAVersion "2023101624" 
     .SetCADProcessingMethod "MultiThread22", "-1" 
     .SetGPUForMatrixCalculationDisabled "False" 
End With

'@ create group: meshgroup1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.Add "meshgroup1", "mesh"

'@ set local mesh properties for: meshgroup1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With MeshSettings
     With .ItemMeshSettings ("group$meshgroup1")
          .SetMeshType "Hex"
          .Set "ConsiderGlobalEdgeRefinement", 1
          .Set "ConsiderGlobalFaceRefinement", 1
          .Set "ConsiderGlobalMaterialRefinement", 1
          .Set "ConsiderGlobalRefinement", 1
          .Set "ConsiderGlobalSnapping", 1
          .Set "EdgeRefinementBufferLines", 3
          .Set "EdgeRefinementRatio", "2"
          .Set "EdgeRefinementStep", "4"
          .Set "EdgeRefinementType", "ABS_VALUE"
          .Set "EllipseRefinementNSteps", 2
          .Set "EllipseRefinementRatio", 2
          .Set "EllipseRefinementStep", 0
          .Set "EllipseRefinementType", "NONE"
          .Set "FaceRefinementBufferLines", 3
          .Set "FaceRefinementNSteps", 2
          .Set "FaceRefinementRatio", 2
          .Set "FaceRefinementStep", 0
          .Set "FaceRefinementType", "NONE"
          .Set "SnappingIntervals", 0, 0, 0
          .Set "SnappingPriority", 0
          .Set "SnapToAxialEdges", 1
          .Set "SnapToCylinderCenters", 1
          .Set "SnapToCylinders", 1
          .Set "SnapToEllipseCenters", 1
          .Set "SnapToEllipses", 1
          .Set "SnapToObjectBoundaries", 0
          .Set "SnapToPlanes", 1
          .Set "SnapToSpheres", 1
          .Set "SnapToTori", 1
          .Set "SnapXYZ", "1", "1", "1"
          .Set "UseMaterialRefinement", 1
          .Set "UseSnappingPriority", 0
          .Set "VolumeRefinementExtentNumSteps", 3, 3, 3
          .Set "VolumeRefinementExtentStep", 0, 0, 0
          .Set "VolumeRefinementExtentType", "STEPS_PER_DIM"
          .Set "VolumeRefinementExtentValueUseSameXYZ", 1
          .Set "VolumeRefinementNumSteps", "0", "0", "0"
          .Set "VolumeRefinementRatio", "2", "2", "2"
          .Set "VolumeRefinementScopeType", "ALL"
          .Set "VolumeRefinementStep", "wf/4", "wf/4", "wf/4"
          .Set "VolumeRefinementType", "ABS_VALUE"
          .Set "VolumeRefinementValueUseSameXYZ", 1
     End With
End With

'@ add items to group: "meshgroup1"

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.AddItem "solid$component1:Patch", "meshgroup1"

'@ create group: meshgroup2

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.Add "meshgroup2", "mesh"

'@ set local mesh properties for: meshgroup2

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With MeshSettings
     With .ItemMeshSettings ("group$meshgroup2")
          .SetMeshType "Hex"
          .Set "ConsiderGlobalEdgeRefinement", 1
          .Set "ConsiderGlobalFaceRefinement", 1
          .Set "ConsiderGlobalMaterialRefinement", 1
          .Set "ConsiderGlobalRefinement", 1
          .Set "ConsiderGlobalSnapping", 1
          .Set "EdgeRefinementBufferLines", 3
          .Set "EdgeRefinementRatio", "2"
          .Set "EdgeRefinementStep", "4"
          .Set "EdgeRefinementType", "ABS_VALUE"
          .Set "EllipseRefinementNSteps", 2
          .Set "EllipseRefinementRatio", 2
          .Set "EllipseRefinementStep", 0
          .Set "EllipseRefinementType", "NONE"
          .Set "FaceRefinementBufferLines", 3
          .Set "FaceRefinementNSteps", 2
          .Set "FaceRefinementRatio", 2
          .Set "FaceRefinementStep", 0
          .Set "FaceRefinementType", "NONE"
          .Set "SnappingIntervals", 0, 0, 0
          .Set "SnappingPriority", 0
          .Set "SnapToAxialEdges", 1
          .Set "SnapToCylinderCenters", 1
          .Set "SnapToCylinders", 1
          .Set "SnapToEllipseCenters", 1
          .Set "SnapToEllipses", 1
          .Set "SnapToObjectBoundaries", 0
          .Set "SnapToPlanes", 1
          .Set "SnapToSpheres", 1
          .Set "SnapToTori", 1
          .Set "SnapXYZ", "1", "1", "1"
          .Set "UseMaterialRefinement", 1
          .Set "UseSnappingPriority", 0
          .Set "VolumeRefinementExtentNumSteps", 3, 3, 3
          .Set "VolumeRefinementExtentStep", 0, 0, 0
          .Set "VolumeRefinementExtentType", "STEPS_PER_DIM"
          .Set "VolumeRefinementExtentValueUseSameXYZ", 1
          .Set "VolumeRefinementNumSteps", "0", "0", "0"
          .Set "VolumeRefinementRatio", "2", "2", "2"
          .Set "VolumeRefinementScopeType", "ALL"
          .Set "VolumeRefinementStep", "wf/2", "wf/2", "wf/2"
          .Set "VolumeRefinementType", "ABS_VALUE"
          .Set "VolumeRefinementValueUseSameXYZ", 1
     End With
End With

'@ add items to group: "meshgroup2"

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.AddItem "solid$component1:FeedLine", "meshgroup2"

'@ set 3d mesh adaptation properties

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With MeshAdaption3D
    .SetType "Time" 
    .SetAdaptionStrategy "Energy" 
    .MinPasses "2" 
    .MaxPasses "3" 
    .SkipPulses "0" 
    .CellIncreaseFactor "0.7" 
    .WeightE "1.0" 
    .WeightB "1.0" 
    .RefineX "True" 
    .RefineY "True" 
    .RefineZ "True" 
    .ClearStopCriteria
    .AddSParameterStopCriterion "True", "700", "1000", "0.02", "1", "True" 
    .Add0DResultStopCriterion "", "0.02", "1", "False" 
End With

'@ define time domain solver acceleration

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Solver 
     .UseParallelization "True"
     .MaximumNumberOfThreads "1024"
     .MaximumNumberOfCPUDevices "2"
     .RemoteCalculation "False"
     .UseDistributedComputing "False"
     .MaxNumberOfDistributedComputingPorts "64"
     .DistributeMatrixCalculation "True"
     .MPIParallelization "False"
     .AutomaticMPI "False"
     .ConsiderOnly0D1DResultsForMPI "False"
     .HardwareAcceleration "True"
     .MaximumNumberOfGPUs "1"
End With
UseDistributedComputingForParameters "False"
MaxNumberOfDistributedComputingParameters "2"
UseDistributedComputingMemorySetting "False"
MinDistributedComputingMemoryLimit "0"
UseDistributedComputingSharedDirectory "False"
OnlyConsider0D1DResultsForDC "False"

'@ define time domain solver parameters

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Mesh.SetCreator "High Frequency" 

With Solver 
     .Method "Hexahedral"
     .CalculationType "TD-S"
     .StimulationPort "All"
     .StimulationMode "All"
     .SteadyStateLimit "-40"
     .MeshAdaption "True"
     .AutoNormImpedance "False"
     .NormingImpedance "50"
     .CalculateModesOnly "False"
     .SParaSymmetry "False"
     .StoreTDResultsInCache  "False"
     .RunDiscretizerOnly "False"
     .FullDeembedding "False"
     .SuperimposePLWExcitation "False"
     .UseSensitivityAnalysis "False"
End With

'@ rename block: component1:solid1 to: component1:Substrate

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.Rename "component1:solid1", "Substrate"

'@ define frequency range

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solver.FrequencyRange "700", "1700"

'@ define farfield monitor: farfield (f=1430)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Monitor 
     .Reset 
     .Name "farfield (f=1430)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .MonitorValue "1430" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-57.8", "57.8", "-25.6", "25.6", "0", "1.6" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeInflateWithOffset "False" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .EnableNearfieldCalculation "True" 
     .Create 
End With

'@ define monitor: h-field (f=1430)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Monitor 
     .Reset 
     .Name "h-field (f=1430)" 
     .Dimension "Volume" 
     .Domain "Frequency" 
     .FieldType "Hfield" 
     .MonitorValue "1430" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-57.8", "57.8", "-25.6", "25.6", "0", "1.6" 
     .SetSubvolumeOffset "0.0", "0.0", "0.0", "0.0", "0.0", "0.0" 
     .SetSubvolumeInflateWithOffset "False" 
     .Create 
End With

'@ define monitor: e-field (f=1430)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Monitor 
     .Reset 
     .Name "e-field (f=1430)" 
     .Dimension "Volume" 
     .Domain "Frequency" 
     .FieldType "Efield" 
     .MonitorValue "1430" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-57.8", "57.8", "-25.6", "25.6", "0", "1.6" 
     .SetSubvolumeOffset "0.0", "0.0", "0.0", "0.0", "0.0", "0.0" 
     .SetSubvolumeInflateWithOffset "False" 
     .Create 
End With

'@ define time domain solver acceleration

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Solver 
     .UseParallelization "True"
     .MaximumNumberOfThreads "1024"
     .MaximumNumberOfCPUDevices "2"
     .RemoteCalculation "False"
     .UseDistributedComputing "False"
     .MaxNumberOfDistributedComputingPorts "64"
     .DistributeMatrixCalculation "True"
     .MPIParallelization "False"
     .AutomaticMPI "False"
     .ConsiderOnly0D1DResultsForMPI "False"
     .HardwareAcceleration "True"
     .MaximumNumberOfGPUs "1"
End With
UseDistributedComputingForParameters "False"
MaxNumberOfDistributedComputingParameters "2"
UseDistributedComputingMemorySetting "False"
MinDistributedComputingMemoryLimit "0"
UseDistributedComputingSharedDirectory "False"
OnlyConsider0D1DResultsForDC "False"

'@ define time domain solver parameters

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Mesh.SetCreator "High Frequency" 

With Solver 
     .Method "Hexahedral"
     .CalculationType "TD-S"
     .StimulationPort "All"
     .StimulationMode "All"
     .SteadyStateLimit "-40"
     .MeshAdaption "False"
     .AutoNormImpedance "False"
     .NormingImpedance "50"
     .CalculateModesOnly "False"
     .SParaSymmetry "False"
     .StoreTDResultsInCache  "False"
     .RunDiscretizerOnly "False"
     .FullDeembedding "False"
     .SuperimposePLWExcitation "False"
     .UseSensitivityAnalysis "False"
End With

'@ define time domain solver acceleration

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Solver 
     .UseParallelization "True"
     .MaximumNumberOfThreads "1024"
     .MaximumNumberOfCPUDevices "2"
     .RemoteCalculation "False"
     .UseDistributedComputing "False"
     .MaxNumberOfDistributedComputingPorts "64"
     .DistributeMatrixCalculation "True"
     .MPIParallelization "False"
     .AutomaticMPI "False"
     .ConsiderOnly0D1DResultsForMPI "False"
     .HardwareAcceleration "True"
     .MaximumNumberOfGPUs "1"
End With
UseDistributedComputingForParameters "False"
MaxNumberOfDistributedComputingParameters "2"
UseDistributedComputingMemorySetting "False"
MinDistributedComputingMemoryLimit "0"
UseDistributedComputingSharedDirectory "False"
OnlyConsider0D1DResultsForDC "False"

'@ define frequency range

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solver.FrequencyRange "768", "968"

'@ set 3d mesh adaptation properties

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With MeshAdaption3D
    .SetType "Time" 
    .SetAdaptionStrategy "Energy" 
    .MinPasses "2" 
    .MaxPasses "3" 
    .SkipPulses "0" 
    .CellIncreaseFactor "0.7" 
    .WeightE "1.0" 
    .WeightB "1.0" 
    .RefineX "True" 
    .RefineY "True" 
    .RefineZ "True" 
    .ClearStopCriteria
    .AddSParameterStopCriterion "True", "700", "1000", "0.02", "1", "True" 
    .Add0DResultStopCriterion "", "0.02", "1", "False" 
End With

'@ define time domain solver parameters

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Mesh.SetCreator "High Frequency" 

With Solver 
     .Method "Hexahedral"
     .CalculationType "TD-S"
     .StimulationPort "All"
     .StimulationMode "All"
     .SteadyStateLimit "-40"
     .MeshAdaption "True"
     .AutoNormImpedance "False"
     .NormingImpedance "50"
     .CalculateModesOnly "False"
     .SParaSymmetry "False"
     .StoreTDResultsInCache  "False"
     .RunDiscretizerOnly "False"
     .FullDeembedding "False"
     .SuperimposePLWExcitation "False"
     .UseSensitivityAnalysis "False"
End With

'@ delete monitor: farfield (f=1430)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Monitor.Delete "farfield (f=1430)"

'@ delete monitor: farfield (f=1000)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Monitor.Delete "farfield (f=1000)"

'@ delete monitor: farfield (f=700)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Monitor.Delete "farfield (f=700)"

'@ delete monitor: e-field (f=1430)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Monitor.Delete "e-field (f=1430)"

'@ delete monitor: h-field (f=1430)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Monitor.Delete "h-field (f=1430)"

'@ delete monitor: loss (f=1000)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Monitor.Delete "loss (f=1000)"

'@ delete monitor: power (f=1000)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Monitor.Delete "power (f=1000)"

'@ delete monitor: h-field (f=1000)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Monitor.Delete "h-field (f=1000)"

'@ delete monitor: e-field (f=1000)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Monitor.Delete "e-field (f=1000)"

'@ define special time domain solver parameters

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
'STEADY STATE
With Solver
     .SteadyStateDurationType "Number of pulses"
     .NumberOfPulseWidths "20"
     .SteadyStateDurationTime "19.9128"
     .SteadyStateDurationTimeAsDistance "5973.83"
     .StopCriteriaShowExcitation "False"
     .RemoveAllStopCriteria
     .AddStopCriterion "All S-Parameters", "0.004", "1", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.004", "1", "False"
     .AddStopCriterion "Reflection S-Parameters", "0.004", "1", "False"
     .AddStopCriterion "All Probes", "0.004", "1", "False"
     .AddStopCriterion "All Radiated Powers", "0.004", "1", "False"
     .AddStopCriterion "All Voltage-Current Monitors", "0.004", "1", "False"
End With

'GENERAL
With Solver
     .TimeStepStabilityFactor "1.0"
     .RestartAfterInstabilityAbort "True"
     .AutomaticTimeSignalSampling "True"
     .SuppressTimeSignalStorage "False"
     .ConsiderExcitationForFreqSamplingRate "False"
     .UseBroadBandPhaseShift "False"
     .SetBroadBandPhaseShiftLowerBoundFac "0.1"
     .SetPortShieldingType "NONE"
     .FrequencySamples "1001"
     .FrequencyLogSamples "0"
     .ConsiderTwoPortReciprocity "True"
     .EnergyBalanceLimit "0.03"
     .TDRComputation "False"
     .TDRShift50Percent "False"
     .AutoDetectIdenticalPorts "False"
End With

'HEXAHEDRAL
With Solver
     .SetPMLType "CONVPML"
     .UseVariablePMLLayerSizeStandard "False"
     .KeepPMLDepthDuringMeshAdaptationWithVariablePMLLayerSize "False"
     .SetSubcycleState "Automatic"
     .NormalizeToReferenceSignal "False"
     .SetEnhancedPMLStabilization "Automatic"
     .SimplifiedPBAMethod "False"
     .SParaAdjustment "True"
     .PrepareFarfields "True"
     .MonitorFarFieldsNearToModel "True"
     .DiscreteItemUpdate "Distributed"
End With

'MATERIAL
With Solver
     .SurfaceImpedanceOrder "10"
     .ActivatePowerLoss1DMonitor "True"
     .PowerLoss1DMonitorPerSolid "False"
     .Use3DFieldMonitorForPowerLoss1DMonitor "True"
     .UseFarFieldMonitorForPowerLoss1DMonitor "False"
     .UseExtraFreqForPowerLoss1DMonitor "False"
     .ResetPowerLoss1DMonitorExtraFreq
     .SetDispNonLinearMaterialMonitor "False"
     .ActivateDispNonLinearMaterialMonitor "0.0",  "0.2",  "0.0",  "False"
     .SetTimePowerLossSIMaterialMonitor "False"
     .ActivateTimePowerLossSIMaterialMonitor "0.0",  "0.2",  "0.0",  "False"
     .SetTimePowerLossSIMaterialMonitorAverage "False"
     .SetTimePowerLossSIMaterialMonitorAverageRepPeriod "0.0"
     .TimePowerLossSIMaterialMonitorPerSolid "False"
     .ActivateSpaceMaterial3DMonitor "False"
     .Use3DFieldMonitorForSpaceMaterial3DMonitor "True"
     .UseExtraFreqForSpaceMaterial3DMonitor "False"
     .ResetSpaceMaterial3DMonitorExtraFreq
     .SetHFTDDispUpdateScheme "Automatic"
End With

'AR-FILTER
With Solver
     .UseArfilter "False"
     .ArMaxEnergyDeviation "0.1"
     .ArPulseSkip "1"
End With

'WAVEGUIDE
With Solver
     .WaveguidePortGeneralized "True"
     .WaveguidePortModeTracking "False"
     .WaveguidePortROM "False"
     .DispEpsFullDeembedding "False"
     .SetSamplesFullDeembedding "20"
     .AbsorbUnconsideredModeFields "Automatic"
     .SetModeFreqFactor "0.5"
     .AdaptivePortMeshing "True"
     .AccuracyAdaptivePortMeshing "1"
     .PassesAdaptivePortMeshing "4"
End With

'HEXAHEDRAL TLM
With Solver
     .AnisotropicSheetSurfaceType "0"
     .MultiStrandedCableRoute "False"
     .UseAbsorbingBoundary "True"
     .UseDoublePrecision "False"
     .AllowMaterialOverlap "True"
     .ExcitePlanewaveNearModel "False"
     .SetGroundPlane "False"
     .GroundPlane "x", "0.0"
     .NumberOfLayers "5"
     .AverageFieldProbe "False"
     .NormalizeToGaussian "True"
     .TimeSignalSamplingFactor "1"
     .SurfaceCurrentOnMesh "False"
     .LossyMetalAsTranslucent "False"
End With

'TLM POSTPROCESSING
With Solver
     .ResetSettings
     .CalculateNearFieldOnCylindricalSurfaces "false", "Coarse" 
     .CylinderGridCustomStep "1" 
     .CalculateNearFieldOnCircularCuts "false" 
     .CylinderBaseCenter "0", "0", "0" 
     .CylinderRadius "3" 
     .CylinderHeight "3" 
     .CylinderSpacing "1" 
     .CylinderResolution "2.0" 
     .CylinderAllPolarization "true" 
     .CylinderRadialAngularVerticalComponents "false" 
     .CylinderMagnitudeOfTangentialConponent "false" 
     .CylinderVm "true" 
     .CylinderDBVm "false" 
     .CylinderDBUVm "false" 
     .CylinderAndFrontAxes "+y", "+z" 
     .ApplyLinearPrediction "false" 
     .Windowing "None" 
     .LogScaleFrequency "false" 
     .AutoFreqStep "true", "1"
     .SetExcitationSignal "" 
     .SaveSettings
End With

'@ set 3d mesh adaptation properties

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With MeshAdaption3D
    .SetType "Time" 
    .SetAdaptionStrategy "Energy" 
    .MinPasses "2" 
    .MaxPasses "4" 
    .SkipPulses "0" 
    .CellIncreaseFactor "0.7" 
    .WeightE "1.0" 
    .WeightB "1.0" 
    .RefineX "True" 
    .RefineY "True" 
    .RefineZ "True" 
    .ClearStopCriteria
    .AddSParameterStopCriterion "True", "700", "1000", "0.02", "1", "True" 
    .Add0DResultStopCriterion "", "0.02", "1", "False" 
End With

'@ define special time domain solver parameters

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
'STEADY STATE
With Solver
     .SteadyStateDurationType "Number of pulses"
     .NumberOfPulseWidths "20"
     .SteadyStateDurationTime "19.9128"
     .SteadyStateDurationTimeAsDistance "5973.83"
     .StopCriteriaShowExcitation "False"
     .RemoveAllStopCriteria
     .AddStopCriterion "All S-Parameters", "0.004", "1", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.004", "1", "False"
     .AddStopCriterion "Reflection S-Parameters", "0.004", "1", "False"
     .AddStopCriterion "All Probes", "0.004", "1", "False"
     .AddStopCriterion "All Radiated Powers", "0.004", "1", "False"
     .AddStopCriterion "All Voltage-Current Monitors", "0.004", "1", "False"
End With

'GENERAL
With Solver
     .TimeStepStabilityFactor "1.0"
     .RestartAfterInstabilityAbort "True"
     .AutomaticTimeSignalSampling "True"
     .SuppressTimeSignalStorage "False"
     .ConsiderExcitationForFreqSamplingRate "False"
     .UseBroadBandPhaseShift "False"
     .SetBroadBandPhaseShiftLowerBoundFac "0.1"
     .SetPortShieldingType "NONE"
     .FrequencySamples "1001"
     .FrequencyLogSamples "0"
     .ConsiderTwoPortReciprocity "True"
     .EnergyBalanceLimit "0.03"
     .TDRComputation "False"
     .TDRShift50Percent "False"
     .AutoDetectIdenticalPorts "False"
End With

'HEXAHEDRAL
With Solver
     .SetPMLType "CONVPML"
     .UseVariablePMLLayerSizeStandard "False"
     .KeepPMLDepthDuringMeshAdaptationWithVariablePMLLayerSize "False"
     .SetSubcycleState "Automatic"
     .NormalizeToReferenceSignal "False"
     .SetEnhancedPMLStabilization "Automatic"
     .SimplifiedPBAMethod "False"
     .SParaAdjustment "True"
     .PrepareFarfields "True"
     .MonitorFarFieldsNearToModel "True"
     .DiscreteItemUpdate "Distributed"
End With

'MATERIAL
With Solver
     .SurfaceImpedanceOrder "10"
     .ActivatePowerLoss1DMonitor "True"
     .PowerLoss1DMonitorPerSolid "False"
     .Use3DFieldMonitorForPowerLoss1DMonitor "True"
     .UseFarFieldMonitorForPowerLoss1DMonitor "False"
     .UseExtraFreqForPowerLoss1DMonitor "False"
     .ResetPowerLoss1DMonitorExtraFreq
     .SetDispNonLinearMaterialMonitor "False"
     .ActivateDispNonLinearMaterialMonitor "0.0",  "0.2",  "0.0",  "False"
     .SetTimePowerLossSIMaterialMonitor "False"
     .ActivateTimePowerLossSIMaterialMonitor "0.0",  "0.2",  "0.0",  "False"
     .SetTimePowerLossSIMaterialMonitorAverage "False"
     .SetTimePowerLossSIMaterialMonitorAverageRepPeriod "0.0"
     .TimePowerLossSIMaterialMonitorPerSolid "False"
     .ActivateSpaceMaterial3DMonitor "False"
     .Use3DFieldMonitorForSpaceMaterial3DMonitor "True"
     .UseExtraFreqForSpaceMaterial3DMonitor "False"
     .ResetSpaceMaterial3DMonitorExtraFreq
     .SetHFTDDispUpdateScheme "Automatic"
End With

'AR-FILTER
With Solver
     .UseArfilter "False"
     .ArMaxEnergyDeviation "0.1"
     .ArPulseSkip "1"
End With

'WAVEGUIDE
With Solver
     .WaveguidePortGeneralized "True"
     .WaveguidePortModeTracking "False"
     .WaveguidePortROM "False"
     .DispEpsFullDeembedding "False"
     .SetSamplesFullDeembedding "20"
     .AbsorbUnconsideredModeFields "Automatic"
     .SetModeFreqFactor "0.5"
     .AdaptivePortMeshing "True"
     .AccuracyAdaptivePortMeshing "1"
     .PassesAdaptivePortMeshing "4"
End With

'HEXAHEDRAL TLM
With Solver
     .AnisotropicSheetSurfaceType "0"
     .MultiStrandedCableRoute "False"
     .UseAbsorbingBoundary "True"
     .UseDoublePrecision "False"
     .AllowMaterialOverlap "True"
     .ExcitePlanewaveNearModel "False"
     .SetGroundPlane "False"
     .GroundPlane "x", "0.0"
     .NumberOfLayers "5"
     .AverageFieldProbe "False"
     .NormalizeToGaussian "True"
     .TimeSignalSamplingFactor "1"
     .SurfaceCurrentOnMesh "False"
     .LossyMetalAsTranslucent "False"
End With

'TLM POSTPROCESSING
With Solver
     .ResetSettings
     .CalculateNearFieldOnCylindricalSurfaces "false", "Coarse" 
     .CylinderGridCustomStep "1" 
     .CalculateNearFieldOnCircularCuts "false" 
     .CylinderBaseCenter "0", "0", "0" 
     .CylinderRadius "3" 
     .CylinderHeight "3" 
     .CylinderSpacing "1" 
     .CylinderResolution "2.0" 
     .CylinderAllPolarization "true" 
     .CylinderRadialAngularVerticalComponents "false" 
     .CylinderMagnitudeOfTangentialConponent "false" 
     .CylinderVm "true" 
     .CylinderDBVm "false" 
     .CylinderDBUVm "false" 
     .CylinderAndFrontAxes "+y", "+z" 
     .ApplyLinearPrediction "false" 
     .Windowing "None" 
     .LogScaleFrequency "false" 
     .AutoFreqStep "true", "1"
     .SetExcitationSignal "" 
     .SaveSettings
End With

