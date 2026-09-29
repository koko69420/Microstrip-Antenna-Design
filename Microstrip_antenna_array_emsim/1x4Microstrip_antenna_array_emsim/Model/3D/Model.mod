'# MWS Version: Version 2024.1 - Oct 16 2023 - ACIS 33.0.1 -

'# length = mm
'# frequency = MHz
'# time = ns
'# frequency range: fmin = 818 fmax = 918
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
     .Point "-(N-1)*d/2-W/2-15", "-Lg/2" 
     .LineTo "(N-1)*d/2+W/2+15", "-Lg/2" 
     .LineTo "(N-1)*d/2+W/2+15", "Lg/2+fnet_depth" 
     .LineTo "-(N-1)*d/2-W/2-15", "Lg/2+fnet_depth" 
     .Create 
End With

'@ define brick: component1:Substrate

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Brick
     .Reset 
     .Name "Substrate" 
     .Component "component1" 
     .Material "Copper (annealed)" 
     .Xrange "-(N-1)*d/2-W/2-15", "(N-1)*d/2+W/2+15" 
     .Yrange "-Lg/2", "Lg/2+fnet_depth" 
     .Zrange "0", "h" 
     .Create
End With

'@ delete shape: component1:Substrate

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.Delete "component1:Substrate"

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

'@ define brick: component1:Substrate

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Brick
     .Reset 
     .Name "Substrate" 
     .Component "component1" 
     .Material "Folder1/FR4" 
     .Xrange "-(N-1)*d/2-W/2-15", "(N-1)*d/2+W/2+15" 
     .Yrange "-Lg/2", "Lg/2+fnet_depth" 
     .Zrange "0", "h" 
     .Create
End With

'@ define extrude: component1:Patch_1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Extrude 
     .Reset 
     .Name "Patch_1" 
     .Component "component1" 
     .Material "Copper (annealed)" 
     .Mode "Pointlist" 
     .Height "0.0" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "h" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "X1-W/2", "-L/2" 
     .LineTo "X1+W/2", "-L/2" 
     .LineTo "X1+W/2", "L/2" 
     .LineTo "X1+wf/2+g", "L/2" 
     .LineTo "X1+wf/2+g", "L/2-y0" 
     .LineTo "X1+wf/2", "L/2-y0" 
     .LineTo "X1+wf/2", "L/2" 
     .LineTo "X1-wf/2", "L/2" 
     .LineTo "X1-wf/2", "L/2-y0" 
     .LineTo "X1-wf/2-g", "L/2-y0" 
     .LineTo "X1-wf/2-g", "L/2" 
     .LineTo "X1-W/2", "L/2" 
     .Create 
End With

'@ define extrude: component1:FeedLine_1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Extrude 
     .Reset 
     .Name "FeedLine_1" 
     .Component "component1" 
     .Material "Copper (annealed)" 
     .Mode "Pointlist" 
     .Height "0.0" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "h" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "X1-wf/2", "L/2-y0" 
     .LineTo "X1+wf/2", "L/2-y0" 
     .LineTo "X1+wf/2", "Lg/2" 
     .LineTo "X1-wf/2", "Lg/2" 
     .Create 
End With

'@ define bondwire: Folder1:ShortingVia_1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Wire
     .Reset 
     .Name "ShortingVia_1" 
     .Folder "Folder1" 
     .Type "BondWire" 
     .Height "0" 
     .Radius "via_r" 
     .Point1 "X1", "-L/2", "0.0", "False"
     .Point2 "X1", "-L/2", "h", "False" 
     .BondWireType "Spline" 
     .Alpha "75" 
     .Beta "35" 
     .RelativeCenterPosition "0.5" 
     .Material "PEC" 
     .SolidWireModel "False" 
     .Termination "Extended" 
     .Add
End With

'@ new component: X1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Component.New "X1"

'@ change component: component1:FeedLine_1 to: X1:FeedLine_1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.ChangeComponent "component1:FeedLine_1", "X1"

'@ change component: component1:Patch_1 to: X1:Patch_1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.ChangeComponent "component1:Patch_1", "X1"

'@ rename wire folder: Folder1 to: X1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Wire.RenameFolder "Folder1", "X1"

'@ transform: translate selected

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Transform 
     .Reset 
     .Name "solid$X1:FeedLine_1" 
     .AddName "solid$X1:Patch_1" 
     .AddName "wireitem$X1:ShortingVia_1" 
     .Vector "d", "0", "0" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "True" 
     .GroupObjects "False" 
     .Repetitions "3" 
     .MultipleSelection "False" 
     .Transform "Mixed", "Translate" 
End With

'@ new component: X2

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Component.New "X2"

'@ new component: X3

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Component.New "X3"

'@ new component: X4

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Component.New "X4"

'@ change component: X1:FeedLine_1_1 to: X2:FeedLine_1_1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.ChangeComponent "X1:FeedLine_1_1", "X2"

'@ change component: X1:Patch_1_1 to: X2:Patch_1_1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.ChangeComponent "X1:Patch_1_1", "X2"

'@ change component: X1:FeedLine_1_2 to: X3:FeedLine_1_2

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.ChangeComponent "X1:FeedLine_1_2", "X3"

'@ change component: X1:Patch_1_2 to: X3:Patch_1_2

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.ChangeComponent "X1:Patch_1_2", "X3"

'@ change component: X1:FeedLine_1_3 to: X4:FeedLine_1_3

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.ChangeComponent "X1:FeedLine_1_3", "X4"

'@ change component: X1:Patch_1_3 to: X4:Patch_1_3

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.ChangeComponent "X1:Patch_1_3", "X4"

'@ rename block: X2:FeedLine_1_1 to: X2:FeedLine_2

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.Rename "X2:FeedLine_1_1", "FeedLine_2"

'@ rename block: X2:Patch_1_1 to: X2:Patch_2

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.Rename "X2:Patch_1_1", "Patch_2"

'@ rename block: X3:FeedLine_1_2 to: X3:FeedLine_3

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.Rename "X3:FeedLine_1_2", "FeedLine_3"

'@ rename block: X3:Patch_1_2 to: X3:Patch_3

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.Rename "X3:Patch_1_2", "Patch_3"

'@ rename block: X4:FeedLine_1_3 to: X4:FeedLine_4

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.Rename "X4:FeedLine_1_3", "FeedLine_4"

'@ rename block: X4:Patch_1_3 to: X4:Patch_4

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.Rename "X4:Patch_1_3", "Patch_4"

'@ new wire folder: X2

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Wire.NewFolder "X2"

'@ new wire folder: X3

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Wire.NewFolder "X3"

'@ new wire folder: X4

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Wire.NewFolder "X4"

'@ rename wire: X1:ShortingVia_1_1 to: X1:ShortingVia_2

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Wire.Rename "X1:ShortingVia_1_1", "X1:ShortingVia_2"

'@ rename wire: X1:ShortingVia_1_2 to: X1:ShortingVia_3

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Wire.Rename "X1:ShortingVia_1_2", "X1:ShortingVia_3"

'@ rename wire: X1:ShortingVia_1_3 to: X1:ShortingVia_4

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Wire.Rename "X1:ShortingVia_1_3", "X1:ShortingVia_4"

'@ rename wire: X1:ShortingVia_2 to: X2:ShortingVia_2

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Wire.Rename "X1:ShortingVia_2", "X2:ShortingVia_2"

'@ rename wire: X1:ShortingVia_3 to: X3:ShortingVia_3

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Wire.Rename "X1:ShortingVia_3", "X3:ShortingVia_3"

'@ rename wire: X1:ShortingVia_4 to: X4:ShortingVia_4

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Wire.Rename "X1:ShortingVia_4", "X4:ShortingVia_4"

'@ new component: WilkinsonDivider

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Component.New "WilkinsonDivider"

'@ define extrude: WilkinsonDivider:Input_Trace

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Extrude 
     .Reset 
     .Name "Input_Trace" 
     .Component "WilkinsonDivider" 
     .Material "Copper (annealed)" 
     .Mode "Pointlist" 
     .Height "0.0" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "h" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "-wf/2", "0" 
     .LineTo "wf/2", "0" 
     .LineTo "wf/2", "stub_len" 
     .LineTo "-wf/2", "stub_len" 
     .Create 
End With

'@ define extrude: WilkinsonDivider:Right_Arm1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Extrude 
     .Reset 
     .Name "Right_Arm1" 
     .Component "WilkinsonDivider" 
     .Material "Copper (annealed)" 
     .Mode "Pointlist" 
     .Height "0.0" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "h" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "0", "-w70/2" 
     .LineTo "Lx", "-w70/2" 
     .LineTo "Lx", "w70/2" 
     .LineTo "0", "w70/2" 
     .Create 
End With

'@ define extrude: WilkinsonDivider:Right_Arm2

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Extrude 
     .Reset 
     .Name "Right_Arm2" 
     .Component "WilkinsonDivider" 
     .Material "Copper (annealed)" 
     .Mode "Pointlist" 
     .Height "0.0" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "h" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "Lx-w70/2", "-Ly" 
     .LineTo "Lx+w70/2", "-Ly" 
     .LineTo "Lx+w70/2", "w70/2" 
     .LineTo "Lx-w70/2", "w70/2" 
     .Create 
End With

'@ boolean add shapes: WilkinsonDivider:Right_Arm1, WilkinsonDivider:Right_Arm2

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.Add "WilkinsonDivider:Right_Arm1", "WilkinsonDivider:Right_Arm2"

'@ transform: mirror WilkinsonDivider:Right_Arm1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Transform 
     .Reset 
     .Name "WilkinsonDivider:Right_Arm1" 
     .Origin "Free" 
     .Center "0", "0", "0" 
     .PlaneNormal "1", "0", "0" 
     .MultipleObjects "True" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .Destination "" 
     .Material "" 
     .AutoDestination "True" 
     .Transform "Shape", "Mirror" 
End With

'@ rename block: WilkinsonDivider:Right_Arm1_1 to: WilkinsonDivider:Left_Arm1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.Rename "WilkinsonDivider:Right_Arm1_1", "Left_Arm1"

'@ define extrude: WilkinsonDivider:Stage1_InputTrace

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Extrude 
     .Reset 
     .Name "Stage1_InputTrace" 
     .Component "WilkinsonDivider" 
     .Material "Copper (annealed)" 
     .Mode "Pointlist" 
     .Height "0.0" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "h" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "-wf/2", "Y_s1" 
     .LineTo "wf/2", "Y_s1" 
     .LineTo "wf/2", "Lg/2+fnet_depth" 
     .LineTo "-wf/2", "Lg/2+fnet_depth" 
     .Create 
End With

'@ define extrude: WilkinsonDivider:Stage1_ArmR

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Extrude 
     .Reset 
     .Name "Stage1_ArmR" 
     .Component "WilkinsonDivider" 
     .Material "Copper (annealed)" 
     .Mode "Pointlist" 
     .Height "0.0" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "h" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "0", "Y_s1+w70/2" 
     .LineTo "Lx+w70/2", "Y_s1+w70/2" 
     .LineTo "Lx+w70/2", "Y1num" 
     .LineTo "Lx-w70/2", "Y1num" 
     .LineTo "Lx-w70/2", "Y_s1-w70/2" 
     .LineTo "0", "Y_s1-w70/2" 
     .Create 
End With

'@ define extrude: WilkinsonDivider:Stage1_ArmL

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Extrude 
     .Reset 
     .Name "Stage1_ArmL" 
     .Component "WilkinsonDivider" 
     .Material "Copper (annealed)" 
     .Mode "Pointlist" 
     .Height "0.0" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "h" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "0", "Y_s1+w70/2" 
     .LineTo "-Lx-w70/2", "Y_s1+w70/2" 
     .LineTo "-Lx-w70/2", "Y1num" 
     .LineTo "-Lx+w70/2", "Y1num" 
     .LineTo "-Lx+w70/2", "Y_s1-w70/2" 
     .LineTo "0", "Y_s1-w70/2" 
     .Create 
End With

'@ define lumped element: Folder1:Stage1_Riso

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With LumpedElement
     .Reset 
     .SetName "Stage1_Riso" 
     .Folder "Folder1" 
     .SetType "RLCSerial"
     .SetR "Riso"
     .SetL "0"
     .SetC "0"
     .SetGs "0"
     .SetI0 "1e-14"
     .SetT "300"
     .SetMonitor "True"
     .SetRadius "0.0"
     .CircuitFileName ""
     .CircuitId "1"
     .UseCopyOnly "True"
     .UseRelativePath "False"
     .SetP1 "False", "-res_gap/2", "Y1num", "h" 
     .SetP2 "False", "res_gap/2", "Y1num", "h" 
     .SetInvert "False" 
     .Wire "" 
     .Position "end1" 
     .Create
End With

'@ define extrude: WilkinsonDivider:Stage2L_InputTrace

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Extrude 
     .Reset 
     .Name "Stage2L_InputTrace" 
     .Component "WilkinsonDivider" 
     .Material "Copper (annealed)" 
     .Mode "Pointlist" 
     .Height "0.0" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "h" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "X_s2L-wf/2", "Y_s2" 
     .LineTo "X_s2L+wf/2", "Y_s2" 
     .LineTo "X_s2L+wf/2", "Y_s2+stub_s2" 
     .LineTo "X_s2L-wf/2", "Y_s2+stub_s2" 
     .Create 
End With

'@ define extrude: WilkinsonDivider:Stage2L_ArmR

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Extrude 
     .Reset 
     .Name "Stage2L_ArmR" 
     .Component "WilkinsonDivider" 
     .Material "Copper (annealed)" 
     .Mode "Pointlist" 
     .Height "0.0" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "h" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "X_s2L", "Y_s2+w70/2" 
     .LineTo "X_s2L+Lx+w70/2", "Y_s2+w70/2" 
     .LineTo "X_s2L+Lx+w70/2", "Y2num" 
     .LineTo "X_s2L+Lx-w70/2", "Y2num" 
     .LineTo "X_s2L+Lx-w70/2", "Y_s2-w70/2" 
     .LineTo "X_s2L", "Y_s2-w70/2" 
     .Create 
End With

'@ define extrude: WilkinsonDivider:Stage2L_ArmL.txt

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Extrude 
     .Reset 
     .Name "Stage2L_ArmL.txt" 
     .Component "WilkinsonDivider" 
     .Material "Copper (annealed)" 
     .Mode "Pointlist" 
     .Height "0.0" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "h" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "X_s2L", "Y_s2+w70/2" 
     .LineTo "X_s2L-Lx-w70/2", "Y_s2+w70/2" 
     .LineTo "X_s2L-Lx-w70/2", "Y2num" 
     .LineTo "X_s2L-Lx+w70/2", "Y2num" 
     .LineTo "X_s2L-Lx+w70/2", "Y_s2-w70/2" 
     .LineTo "X_s2L", "Y_s2-w70/2" 
     .Create 
End With

'@ define lumped element: Folder1:Stage2L_Riso

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With LumpedElement
     .Reset 
     .SetName "Stage2L_Riso" 
     .Folder "Folder1" 
     .SetType "RLCSerial"
     .SetR "Riso"
     .SetL "0"
     .SetC "0"
     .SetGs "0"
     .SetI0 "1e-14"
     .SetT "300"
     .SetMonitor "True"
     .SetRadius "0.0"
     .CircuitFileName ""
     .CircuitId "1"
     .UseCopyOnly "True"
     .UseRelativePath "False"
     .SetP1 "False", "X_s2L-res_gap/2", "Y2num", "h" 
     .SetP2 "False", "X_s2L+res_gap/2", "Y2num", "h" 
     .SetInvert "False" 
     .Wire "" 
     .Position "end1" 
     .Create
End With

'@ create group: Stage_1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.Add "Stage_1", "normal"

'@ add items to group: "Stage_1"

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.AddItem "solid$WilkinsonDivider:Stage1_ArmL", "Stage_1"
Group.AddItem "solid$WilkinsonDivider:Stage1_ArmR", "Stage_1"
Group.AddItem "solid$WilkinsonDivider:Stage1_InputTrace", "Stage_1"

'@ add items to group: "Stage_1"

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.AddItem "lumpeditem$Folder1:Stage1_Riso", "Stage_1"

'@ create group: group1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.Add "group1", "normal"

'@ rename group: group1 to Stage_2L

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.Rename "group1", "Stage_2L"

'@ rename block: WilkinsonDivider:Stage2L_ArmL.txt to: WilkinsonDivider:Stage2L_ArmL

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.Rename "WilkinsonDivider:Stage2L_ArmL.txt", "Stage2L_ArmL"

'@ add items to group: "Stage_2L"

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.AddItem "solid$WilkinsonDivider:Stage2L_ArmL", "Stage_2L"
Group.AddItem "solid$WilkinsonDivider:Stage2L_ArmR", "Stage_2L"
Group.AddItem "solid$WilkinsonDivider:Stage2L_InputTrace", "Stage_2L"

'@ add items to group: "Stage_2L"

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.AddItem "lumpeditem$Folder1:Stage2L_Riso", "Stage_2L"

'@ create group: Stage_2R

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.Add "Stage_2R", "normal"

'@ rename lumped folder: Folder1 to: WilkinsonDivider

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
LumpedElement.RenameFolder "Folder1", "WilkinsonDivider"

'@ define extrude: WilkinsonDivider:Stage2R_InputTrace

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Extrude 
     .Reset 
     .Name "Stage2R_InputTrace" 
     .Component "WilkinsonDivider" 
     .Material "Copper (annealed)" 
     .Mode "Pointlist" 
     .Height "0.0" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "h" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "X_s2R-wf/2", "Y_s2" 
     .LineTo "X_s2R+wf/2", "Y_s2" 
     .LineTo "X_s2R+wf/2", "Y_s2+stub_s2" 
     .LineTo "X_s2R-wf/2", "Y_s2+stub_s2" 
     .Create 
End With

'@ define extrude: WilkinsonDivider:Stage2R_ArmR

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Extrude 
     .Reset 
     .Name "Stage2R_ArmR" 
     .Component "WilkinsonDivider" 
     .Material "Copper (annealed)" 
     .Mode "Pointlist" 
     .Height "0.0" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "h" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "X_s2R", "Y_s2+w70/2" 
     .LineTo "X_s2R+Lx+w70/2", "Y_s2+w70/2" 
     .LineTo "X_s2R+Lx+w70/2", "Y2num" 
     .LineTo "X_s2R+Lx-w70/2", "Y2num" 
     .LineTo "X_s2R+Lx-w70/2", "Y_s2-w70/2" 
     .LineTo "X_s2R", "Y_s2-w70/2" 
     .Create 
End With

'@ define extrude: WilkinsonDivider:Stage2R_ArmL

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Extrude 
     .Reset 
     .Name "Stage2R_ArmL" 
     .Component "WilkinsonDivider" 
     .Material "Copper (annealed)" 
     .Mode "Pointlist" 
     .Height "0.0" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "h" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "X_s2R", "Y_s2+w70/2" 
     .LineTo "X_s2R-Lx-w70/2", "Y_s2+w70/2" 
     .LineTo "X_s2R-Lx-w70/2", "Y2num" 
     .LineTo "X_s2R-Lx+w70/2", "Y2num" 
     .LineTo "X_s2R-Lx+w70/2", "Y_s2-w70/2" 
     .LineTo "X_s2R", "Y_s2-w70/2" 
     .Create 
End With

'@ define lumped element: WilkinsonDivider:Stage2R_Riso

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With LumpedElement
     .Reset 
     .SetName "Stage2R_Riso" 
     .Folder "WilkinsonDivider" 
     .SetType "RLCSerial"
     .SetR "Riso"
     .SetL "0"
     .SetC "0"
     .SetGs "0"
     .SetI0 "1e-14"
     .SetT "300"
     .SetMonitor "True"
     .SetRadius "0.0"
     .CircuitFileName ""
     .CircuitId "1"
     .UseCopyOnly "True"
     .UseRelativePath "False"
     .SetP1 "False", "X_s2R-res_gap/2", "Y2num", "h" 
     .SetP2 "False", "X_s2R+res_gap/2", "Y2num", "h" 
     .SetInvert "False" 
     .Wire "" 
     .Position "end1" 
     .Create
End With

'@ add items to group: "Stage_2R"

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.AddItem "solid$WilkinsonDivider:Stage2R_ArmL", "Stage_2R"
Group.AddItem "solid$WilkinsonDivider:Stage2R_ArmR", "Stage_2R"
Group.AddItem "solid$WilkinsonDivider:Stage2R_InputTrace", "Stage_2R"

'@ add items to group: "Stage_2R"

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.AddItem "lumpeditem$WilkinsonDivider:Stage2R_Riso", "Stage_2R"

'@ new component: Routing

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Component.New "Routing"

'@ rename component: component1 to: Base

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Component.Rename "component1", "Base"

'@ define extrude: Routing:Route_L_FL1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Extrude 
     .Reset 
     .Name "Route_L_FL1" 
     .Component "Routing" 
     .Material "Copper (annealed)" 
     .Mode "Pointlist" 
     .Height "0.0" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "h" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "X1-wf/2", "Y2num+wf/2" 
     .LineTo "X_s2L-Lx", "Y2num+wf/2" 
     .LineTo "X_s2L-Lx", "Y2num-wf/2" 
     .LineTo "X1+wf/2", "Y2num-wf/2" 
     .LineTo "X1+wf/2", "Lg/2" 
     .LineTo "X1-wf/2", "Lg/2" 
     .Create 
End With

'@ define extrude: Routing:Inter_L

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Extrude 
     .Reset 
     .Name "Inter_L" 
     .Component "Routing" 
     .Material "Copper (annealed)" 
     .Mode "Pointlist" 
     .Height "0.0" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "h" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "-Lx", "Y1num+wf/2" 
     .LineTo "X_s2L-wf/2", "Y1num+wf/2" 
     .LineTo "X_s2L-wf/2", "Y1num-wf/2" 
     .LineTo "-Lx", "Y1num-wf/2" 
     .Create 
End With

'@ define extrude: Routing:Route_L_FL2

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Extrude 
     .Reset 
     .Name "Route_L_FL2" 
     .Component "Routing" 
     .Material "Copper (annealed)" 
     .Mode "Pointlist" 
     .Height "0.0" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "h" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "X_s2L+Lx", "Y2num+wf/2" 
     .LineTo "X2+wf/2", "Y2num+wf/2" 
     .LineTo "X2+wf/2", "Lg/2" 
     .LineTo "X2-wf/2", "Lg/2" 
     .LineTo "X2-wf/2", "Y2num-wf/2" 
     .LineTo "X_s2L+Lx", "Y2num-wf/2" 
     .Create 
End With

'@ transform: mirror Routing:Inter_L

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Transform 
     .Reset 
     .Name "Routing:Inter_L" 
     .Origin "Free" 
     .Center "0", "0", "0" 
     .PlaneNormal "1", "0", "0" 
     .MultipleObjects "True" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "True" 
     .Destination "" 
     .Material "" 
     .AutoDestination "True" 
     .Transform "Shape", "Mirror" 
End With

'@ transform: mirror Routing:Route_L_FL1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Transform 
     .Reset 
     .Name "Routing:Route_L_FL1" 
     .Origin "Free" 
     .Center "0", "0", "0" 
     .PlaneNormal "1", "0", "0" 
     .MultipleObjects "True" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "True" 
     .Destination "" 
     .Material "" 
     .AutoDestination "True" 
     .Transform "Shape", "Mirror" 
End With

'@ transform: mirror Routing:Route_L_FL2

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Transform 
     .Reset 
     .Name "Routing:Route_L_FL2" 
     .Origin "Free" 
     .Center "0", "0", "0" 
     .PlaneNormal "1", "0", "0" 
     .MultipleObjects "True" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .Destination "" 
     .Material "" 
     .AutoDestination "True" 
     .Transform "Shape", "Mirror" 
End With

'@ delete shapes

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.Delete "WilkinsonDivider:Input_Trace" 
Solid.Delete "WilkinsonDivider:Left_Arm1" 
Solid.Delete "WilkinsonDivider:Right_Arm1"

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
     .SetP1 "False", "0.0", "Lg/2+fnet_depth", "0.0"
     .SetP2 "False", "0.0", "Lg/2+fnet_depth", "h"
     .InvertDirection "False"
     .LocalCoordinates "False"
     .Wire ""
     .Position "end1"
     .Create 
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
          .Set "EdgeRefinementStep", "0.5"
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
Group.AddItem "solid$Routing:Inter_L", "meshgroup1"
Group.AddItem "solid$Routing:Inter_L_1", "meshgroup1"
Group.AddItem "solid$Routing:Route_L_FL1", "meshgroup1"
Group.AddItem "solid$Routing:Route_L_FL1_1", "meshgroup1"
Group.AddItem "solid$Routing:Route_L_FL2", "meshgroup1"
Group.AddItem "solid$Routing:Route_L_FL2_1", "meshgroup1"
Group.AddItem "solid$X1:FeedLine_1", "meshgroup1"
Group.AddItem "solid$X1:Patch_1", "meshgroup1"
Group.AddItem "solid$X2:FeedLine_2", "meshgroup1"
Group.AddItem "solid$X2:Patch_2", "meshgroup1"
Group.AddItem "solid$X3:FeedLine_3", "meshgroup1"
Group.AddItem "solid$X3:Patch_3", "meshgroup1"
Group.AddItem "solid$X4:FeedLine_4", "meshgroup1"
Group.AddItem "solid$X4:Patch_4", "meshgroup1"

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
          .Set "EdgeRefinementStep", "0.5"
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
          .Set "VolumeRefinementStep", "w70/4", "w70/4", "w70/4"
          .Set "VolumeRefinementType", "ABS_VALUE"
          .Set "VolumeRefinementValueUseSameXYZ", 1
     End With
End With

'@ add items to group: "meshgroup2"

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.AddItem "solid$WilkinsonDivider:Stage1_ArmL", "meshgroup2"
Group.AddItem "solid$WilkinsonDivider:Stage1_ArmR", "meshgroup2"
Group.AddItem "solid$WilkinsonDivider:Stage1_InputTrace", "meshgroup2"
Group.AddItem "solid$WilkinsonDivider:Stage2L_ArmL", "meshgroup2"
Group.AddItem "solid$WilkinsonDivider:Stage2L_ArmR", "meshgroup2"
Group.AddItem "solid$WilkinsonDivider:Stage2L_InputTrace", "meshgroup2"
Group.AddItem "solid$WilkinsonDivider:Stage2R_ArmL", "meshgroup2"
Group.AddItem "solid$WilkinsonDivider:Stage2R_ArmR", "meshgroup2"
Group.AddItem "solid$WilkinsonDivider:Stage2R_InputTrace", "meshgroup2"

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
     .Set "StepsPerWaveNear", "20" 
     .Set "StepsPerWaveFar", "20" 
     .Set "WavelengthRefinementSameAsNear", "1" 
     'MAX CELL - GEOMETRY REFINEMENT 
     .Set "StepsPerBoxNear", "20" 
     .Set "StepsPerBoxFar", "3" 
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
     .SetCADProcessingMethod "SingleThread21", "1" 
     .SetGPUForMatrixCalculationDisabled "False" 
End With

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
          .Set "EdgeRefinementStep", "3"
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
          .Set "VolumeRefinementStep", "wf/4", "wf/4", "0"
          .Set "VolumeRefinementType", "ABS_VALUE"
          .Set "VolumeRefinementValueUseSameXYZ", 0
     End With
End With

'@ remove items from group: "meshgroup1"

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.RemoveItem "solid$Routing:Inter_L", "meshgroup1"
Group.RemoveItem "solid$Routing:Inter_L_1", "meshgroup1"
Group.RemoveItem "solid$Routing:Route_L_FL1", "meshgroup1"
Group.RemoveItem "solid$Routing:Route_L_FL1_1", "meshgroup1"
Group.RemoveItem "solid$Routing:Route_L_FL2", "meshgroup1"
Group.RemoveItem "solid$Routing:Route_L_FL2_1", "meshgroup1"

'@ create group: meshgroup3

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.Add "meshgroup3", "mesh"

'@ set local mesh properties for: meshgroup3

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With MeshSettings
     With .ItemMeshSettings ("group$meshgroup3")
          .SetMeshType "Hex"
          .Set "ConsiderGlobalEdgeRefinement", 1
          .Set "ConsiderGlobalFaceRefinement", 1
          .Set "ConsiderGlobalMaterialRefinement", 1
          .Set "ConsiderGlobalRefinement", 1
          .Set "ConsiderGlobalSnapping", 1
          .Set "EdgeRefinementBufferLines", 3
          .Set "EdgeRefinementRatio", "2"
          .Set "EdgeRefinementStep", "0"
          .Set "EdgeRefinementType", "NONE"
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
          .Set "VolumeRefinementStep", "w70/4", "w70/4", "0"
          .Set "VolumeRefinementType", "ABS_VALUE"
          .Set "VolumeRefinementValueUseSameXYZ", 0
     End With
End With

'@ add items to group: "meshgroup3"

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.AddItem "solid$WilkinsonDivider:Stage1_ArmL", "meshgroup3"
Group.AddItem "solid$WilkinsonDivider:Stage1_ArmR", "meshgroup3"
Group.AddItem "solid$WilkinsonDivider:Stage2L_ArmL", "meshgroup3"
Group.AddItem "solid$WilkinsonDivider:Stage2L_ArmR", "meshgroup3"
Group.AddItem "solid$WilkinsonDivider:Stage2R_ArmL", "meshgroup3"
Group.AddItem "solid$WilkinsonDivider:Stage2R_ArmR", "meshgroup3"
Group.AddItem "solid$Routing:Inter_L", "meshgroup3"
Group.AddItem "solid$Routing:Inter_L_1", "meshgroup3"
Group.AddItem "solid$Routing:Route_L_FL1", "meshgroup3"
Group.AddItem "solid$Routing:Route_L_FL1_1", "meshgroup3"
Group.AddItem "solid$Routing:Route_L_FL2", "meshgroup3"
Group.AddItem "solid$Routing:Route_L_FL2_1", "meshgroup3"

'@ add items to group: "meshgroup1"

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.AddItem "solid$WilkinsonDivider:Stage1_InputTrace", "meshgroup1"
Group.AddItem "solid$WilkinsonDivider:Stage2L_InputTrace", "meshgroup1"
Group.AddItem "solid$WilkinsonDivider:Stage2R_InputTrace", "meshgroup1"

'@ remove items from group: "meshgroup3"

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.RemoveItem "solid$Routing:Inter_L", "meshgroup3"
Group.RemoveItem "solid$Routing:Inter_L_1", "meshgroup3"
Group.RemoveItem "solid$Routing:Route_L_FL1", "meshgroup3"
Group.RemoveItem "solid$Routing:Route_L_FL1_1", "meshgroup3"
Group.RemoveItem "solid$Routing:Route_L_FL2", "meshgroup3"
Group.RemoveItem "solid$Routing:Route_L_FL2_1", "meshgroup3"

'@ add items to group: "meshgroup1"

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.AddItem "solid$Routing:Inter_L", "meshgroup1"
Group.AddItem "solid$Routing:Inter_L_1", "meshgroup1"
Group.AddItem "solid$Routing:Route_L_FL1", "meshgroup1"
Group.AddItem "solid$Routing:Route_L_FL1_1", "meshgroup1"
Group.AddItem "solid$Routing:Route_L_FL2", "meshgroup1"
Group.AddItem "solid$Routing:Route_L_FL2_1", "meshgroup1"

'@ delete group: meshgroup2

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.Delete "meshgroup2"

'@ rename group: meshgroup3 to meshgroup2

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Group.Rename "meshgroup3", "meshgroup2"

'@ change problem type

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
ChangeProblemType "High Frequency"

'@ define pml specials

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Boundary
     .ReflectionLevel "0.0001" 
     .MinimumDistanceType "Fraction" 
     .MinimumDistancePerWavelengthNewMeshEngine "4" 
     .MinimumDistanceReferenceFrequencyType "Center" 
     .FrequencyForMinimumDistance "850" 
     .SetAbsoluteDistance "0.0" 
End With

'@ define boundaries

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
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
     .ApplyInAllDirections "True"
     .OpenAddSpaceFactor "0.5"
End With

'@ delete monitor: loss (f=700)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Monitor.Delete "loss (f=700)"

'@ delete monitor: power (f=700)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Monitor.Delete "power (f=700)"

'@ delete monitor: h-field (f=700)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Monitor.Delete "h-field (f=700)"

'@ delete monitor: e-field (f=700)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Monitor.Delete "e-field (f=700)"

'@ delete monitor: farfield (f=700)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Monitor.Delete "farfield (f=700)"

'@ delete monitor: farfield (f=1000)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Monitor.Delete "farfield (f=1000)"

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

'@ farfield plot options

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With FarfieldPlot 
     .Plottype "3D" 
     .Vary "angle1" 
     .Theta "90" 
     .Phi "90" 
     .Step "5" 
     .Step2 "5" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "-1" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "True" 
     .ShowStructureProfile "True" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .AspectRatio "Free" 
     .ShowGridlines "True" 
     .InvertAxes "False", "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Directivity" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .IncludeUnitCellSidewalls "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .SetMaxReferenceMode "abs" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1.0" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "directional_linear" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Slant" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  

     .StoreSettings
End With

'@ farfield array properties

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With FarfieldArray
     .Reset 
     .UseArray "TRUE" 
     .Arraytype "Rectangular" 
     .XSet "1", "0.0", "0.0" 
     .YSet "1", "0.0", "0.0" 
     .ZSet "1", "0.0", "0.0" 
     .AutoPhaseFromBoundary "FALSE"
     .SetList
End With

'@ define frequency range

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solver.FrequencyRange "500", "1500"

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

'@ define frequency range

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solver.FrequencyRange "500", "1500"

'@ define sensitivity analysis parameter

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With SensitivityAnalysis 
     .ResetParameterList 
     .Create 
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
     .MeshAdaption "False"
     .AutoNormImpedance "False"
     .NormingImpedance "50"
     .CalculateModesOnly "False"
     .SParaSymmetry "False"
     .StoreTDResultsInCache  "False"
     .RunDiscretizerOnly "False"
     .FullDeembedding "False"
     .SuperimposePLWExcitation "False"
     .UseSensitivityAnalysis "True"
End With

'@ define frequency range

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solver.FrequencyRange "818", "918"

