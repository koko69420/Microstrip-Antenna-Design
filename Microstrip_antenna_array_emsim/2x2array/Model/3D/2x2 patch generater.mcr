' ==============================================================================
' Dassault CST Studio Suite 2024 - VBA Macro
' 2x2 Microstrip Patch Array Antenna (Broadside Conical Beam)
' Operating Frequency: 868 MHz (ISM / LoRa Band)
' Substrate: FR-4 (eps_r = 4.45, h = 1.6 mm, tan_d = 0.02)
' Metallization: Annealed Copper (t = 35 um)
' Feed: Single-Port Corporate Feed Network (Zero Geometry Collisions)
' ==============================================================================

Option Explicit

Sub Main()
    ' --------------------------------------------------------------------------
    ' 1. Project Units & Solver Settings
    ' --------------------------------------------------------------------------
    With Units
        .Geometry "mm"
        .Frequency "MHz"
        .Time "ns"
        .TemperatureUnit "Kelvin"
        .Voltage "V"
        .Current "A"
    End With

    Solver.FrequencyRange "750", "1000"

    With Boundary
        .Xmin "expanded open"
        .Xmax "expanded open"
        .Ymin "expanded open"
        .Ymax "expanded open"
        .Zmin "expanded open"
        .Zmax "expanded open"
    End With

    ' --------------------------------------------------------------------------
    ' 2. Parameter List Initialization
    ' --------------------------------------------------------------------------
    StoreDoubleParameter "fc", 868.0
    StoreDoubleParameter "eps_r", 4.45
    StoreDoubleParameter "h_sub", 1.6
    StoreDoubleParameter "t_cu", 0.035

    ' Patch Dimensions
    StoreDoubleParameter "W_p", 104.7
    StoreDoubleParameter "L_p", 82.0

    ' Array Grid Spacing (~0.52 lambda_0)
    StoreDoubleParameter "dx", 180.0
    StoreDoubleParameter "dy", 180.0

    ' Feed Network Widths
    StoreDoubleParameter "W_50", 3.06      ' 50-Ohm line
    StoreDoubleParameter "W_70", 1.62      ' 70.7-Ohm transformer
    StoreDoubleParameter "L_q", 47.0       ' Quarter-wave length

    ' Inset Dimensions
    StoreDoubleParameter "y_inset", 24.0
    StoreDoubleParameter "w_notch", 6.0

    ' Substrate & Ground Bounds
    StoreDoubleParameter "W_sub", 440.0
    StoreDoubleParameter "L_sub", 480.0

    Rebuild

    ' --------------------------------------------------------------------------
    ' 3. Material Definitions
    ' --------------------------------------------------------------------------
    With Material
        .Reset
        .Name "FR4"
        .Folder ""
        .FrqType "all"
        .Type "Normal"
        .Epsilon "4.45"
        .Mu "1.0"
        .Kappa "0.0"
        .TanD "0.02"
        .TanDFreq "868.0"
        .TanDGiven "True"
        .TanDModel "ConstTanD"
        .Colour "0.2", "0.55", "0.25"
        .Wireframe "False"
        .Create
    End With

    With Material
        .Reset
        .Name "Copper"
        .Folder ""
        .FrqType "all"
        .Type "Lossy metal"
        .Mu "1.0"
        .Kappa "5.8e7"
        .Colour "0.85", "0.55", "0.2"
        .Wireframe "False"
        .Create
    End With

    ' --------------------------------------------------------------------------
    ' 4. Substrate & Ground Plane
    ' --------------------------------------------------------------------------
    With Brick
        .Reset
        .Name "Substrate"
        .Component "Dielectric"
        .Material "FR4"
        .Xrange "-W_sub/2", "W_sub/2"
        .Yrange "-L_sub/2", "L_sub/2"
        .Zrange "0", "h_sub"
        .Create
    End With

    With Brick
        .Reset
        .Name "GroundPlane"
        .Component "Conductor"
        .Material "Copper"
        .Xrange "-W_sub/2", "W_sub/2"
        .Yrange "-L_sub/2", "L_sub/2"
        .Zrange "-t_cu", "0"
        .Create
    End With

    ' --------------------------------------------------------------------------
    ' 5. Constructing 2x2 Patches with Inset Notches
    ' --------------------------------------------------------------------------
    ' Patch 1: Top-Right (+dx/2, +dy/2) - Fed from bottom
    Call BuildPatchWithNotch("Patch1", "dx/2", "dy/2", True)

    ' Patch 2: Top-Left (-dx/2, +dy/2) - Fed from bottom
    Call BuildPatchWithNotch("Patch2", "-dx/2", "dy/2", True)

    ' Patch 3: Bottom-Left (-dx/2, -dy/2) - Fed from top
    Call BuildPatchWithNotch("Patch3", "-dx/2", "-dy/2", False)

    ' Patch 4: Bottom-Right (+dx/2, -dy/2) - Fed from top
    Call BuildPatchWithNotch("Patch4", "dx/2", "-dy/2", False)

    ' --------------------------------------------------------------------------
    ' 6. Corporate Feed Network (Clear Central Corridor Routing)
    ' --------------------------------------------------------------------------
    ' Main 50-Ohm Input Line (Central corridor X=0 from Y_min up to Y=0)
    With Brick
        .Reset
        .Name "feed_main"
        .Component "Conductor"
        .Material "Copper"
        .Xrange "-W_50/2", "W_50/2"
        .Yrange "-L_sub/2", "0"
        .Zrange "h_sub", "h_sub + t_cu"
        .Create
    End With

    ' Primary Splitter at Y=0: Quarter-wave 70.7-Ohm transformers
    With Brick
        .Reset
        .Name "div_qtr_R"
        .Component "Conductor"
        .Material "Copper"
        .Xrange "0", "L_q"
        .Yrange "-W_70/2", "W_70/2"
        .Zrange "h_sub", "h_sub + t_cu"
        .Create
    End With

    With Brick
        .Reset
        .Name "div_qtr_L"
        .Component "Conductor"
        .Material "Copper"
        .Xrange "-L_q", "0"
        .Yrange "-W_70/2", "W_70/2"
        .Zrange "h_sub", "h_sub + t_cu"
        .Create
    End With

    ' 50-Ohm Interconnects to Secondary Junctions (X = +/- 65 mm)
    With Brick
        .Reset
        .Name "div_line_R"
        .Component "Conductor"
        .Material "Copper"
        .Xrange "L_q", "65"
        .Yrange "-W_50/2", "W_50/2"
        .Zrange "h_sub", "h_sub + t_cu"
        .Create
    End With

    With Brick
        .Reset
        .Name "div_line_L"
        .Component "Conductor"
        .Material "Copper"
        .Xrange "-65", "-L_q"
        .Yrange "-W_50/2", "W_50/2"
        .Zrange "h_sub", "h_sub + t_cu"
        .Create
    End With

    ' Upper Feed Arms (Direct Feeds into Patch 1 and Patch 2)
    With Brick
        .Reset
        .Name "feed_top_h_R"
        .Component "Conductor"
        .Material "Copper"
        .Xrange "65", "dx/2"
        .Yrange "-W_50/2", "W_50/2"
        .Zrange "h_sub", "h_sub + t_cu"
        .Create
    End With

    With Brick
        .Reset
        .Name "feed_top_v_R"
        .Component "Conductor"
        .Material "Copper"
        .Xrange "dx/2 - W_50/2", "dx/2 + W_50/2"
        .Yrange "-W_50/2", "dy/2 - L_p/2 + y_inset"
        .Zrange "h_sub", "h_sub + t_cu"
        .Create
    End With

    With Brick
        .Reset
        .Name "feed_top_h_L"
        .Component "Conductor"
        .Material "Copper"
        .Xrange "-dx/2", "-65"
        .Yrange "-W_50/2", "W_50/2"
        .Zrange "h_sub", "h_sub + t_cu"
        .Create
    End With

    With Brick
        .Reset
        .Name "feed_top_v_L"
        .Component "Conductor"
        .Material "Copper"
        .Xrange "-dx/2 - W_50/2", "-dx/2 + W_50/2"
        .Yrange "-W_50/2", "dy/2 - L_p/2 + y_inset"
        .Zrange "h_sub", "h_sub + t_cu"
        .Create
    End With

    ' Lower Feed Arms with 180-deg Phase Delay (In-Phase Excitation for Patches 3 & 4)
    With Brick
        .Reset
        .Name "del_v1_R"
        .Component "Conductor"
        .Material "Copper"
        .Xrange "65 - W_50/2", "65 + W_50/2"
        .Yrange "-24", "0"
        .Zrange "h_sub", "h_sub + t_cu"
        .Create
    End With

    With Brick
        .Reset
        .Name "del_h1_R"
        .Component "Conductor"
        .Material "Copper"
        .Xrange "18", "65 + W_50/2"
        .Yrange "-24 - W_50/2", "-24 + W_50/2"
        .Zrange "h_sub", "h_sub + t_cu"
        .Create
    End With

    With Brick
        .Reset
        .Name "del_v2_R"
        .Component "Conductor"
        .Material "Copper"
        .Xrange "18 - W_50/2", "18 + W_50/2"
        .Yrange "-45", "-24"
        .Zrange "h_sub", "h_sub + t_cu"
        .Create
    End With

    With Brick
        .Reset
        .Name "del_h2_R"
        .Component "Conductor"
        .Material "Copper"
        .Xrange "18 - W_50/2", "dx/2"
        .Yrange "-45 - W_50/2", "-45 + W_50/2"
        .Zrange "h_sub", "h_sub + t_cu"
        .Create
    End With

    With Brick
        .Reset
        .Name "feed_bot_v_R"
        .Component "Conductor"
        .Material "Copper"
        .Xrange "dx/2 - W_50/2", "dx/2 + W_50/2"
        .Yrange "-dy/2 + L_p/2 - y_inset", "-45 + W_50/2"
        .Zrange "h_sub", "h_sub + t_cu"
        .Create
    End With

    With Brick
        .Reset
        .Name "del_v1_L"
        .Component "Conductor"
        .Material "Copper"
        .Xrange "-65 - W_50/2", "-65 + W_50/2"
        .Yrange "-24", "0"
        .Zrange "h_sub", "h_sub + t_cu"
        .Create
    End With

    With Brick
        .Reset
        .Name "del_h1_L"
        .Component "Conductor"
        .Material "Copper"
        .Xrange "-65 - W_50/2", "-18"
        .Yrange "-24 - W_50/2", "-24 + W_50/2"
        .Zrange "h_sub", "h_sub + t_cu"
        .Create
    End With

    With Brick
        .Reset
        .Name "del_v2_L"
        .Component "Conductor"
        .Material "Copper"
        .Xrange "-18 - W_50/2", "-18 + W_50/2"
        .Yrange "-45", "-24"
        .Zrange "h_sub", "h_sub + t_cu"
        .Create
    End With

    With Brick
        .Reset
        .Name "del_h2_L"
        .Component "Conductor"
        .Material "Copper"
        .Xrange "-dx/2", "-18 + W_50/2"
        .Yrange "-45 - W_50/2", "-45 + W_50/2"
        .Zrange "h_sub", "h_sub + t_cu"
        .Create
    End With

    With Brick
        .Reset
        .Name "feed_bot_v_L"
        .Component "Conductor"
        .Material "Copper"
        .Xrange "-dx/2 - W_50/2", "-dx/2 + W_50/2"
        .Yrange "-dy/2 + L_p/2 - y_inset", "-45 + W_50/2"
        .Zrange "h_sub", "h_sub + t_cu"
        .Create
    End With

    ' --------------------------------------------------------------------------
    ' 7. Waveguide Port (Single 50-Ohm Input at Y_min)
    ' --------------------------------------------------------------------------
    With Port
        .Reset
        .PortNumber "1"
        .Label "Port1"
        .NumberOfModes "1"
        .AdjustPolarization "False"
        .PolarizationAngle "0.0"
        .ReferencePlaneDistance "0"
        .Coordinates "Free"
        .Orientation "ymin"
        .PortOnBound "False"
        .Xrange "-5*W_50", "5*W_50"
        .Yrange "-L_sub/2", "-L_sub/2"
        .Zrange "-t_cu", "6*h_sub"
        .Create
    End With

    ' --------------------------------------------------------------------------
    ' 8. Farfield Monitor at 868 MHz
    ' --------------------------------------------------------------------------
    With Monitor
        .Reset
        .Name "farfield (f=868)"
        .Dimension "Volume"
        .Domain "Frequency"
        .FieldType "Farfield"
        .Frequency "868.0"
        .Create
    End With

    Plot.DrawBox True
End Sub

' ------------------------------------------------------------------------------
' Subroutine: Monolithic Patch Solid with Clean Subtracted Inset Notch
' ------------------------------------------------------------------------------
Sub BuildPatchWithNotch(pName As String, xC As String, yC As String, feedFromBottom As Boolean)
    With Brick
        .Reset
        .Name pName
        .Component "Conductor"
        .Material "Copper"
        .Xrange xC & " - W_p/2", xC & " + W_p/2"
        .Yrange yC & " - L_p/2", yC & " + L_p/2"
        .Zrange "h_sub", "h_sub + t_cu"
        .Create
    End With

    With Brick
        .Reset
        .Name pName & "_cut"
        .Component "Conductor"
        .Material "Copper"
        .Xrange xC & " - w_notch/2", xC & " + w_notch/2"
        If feedFromBottom Then
            .Yrange yC & " - L_p/2", yC & " - L_p/2 + y_inset"
        Else
            .Yrange yC & " + L_p/2 - y_inset", yC & " + L_p/2"
        End If
        .Zrange "h_sub", "h_sub + t_cu"
        .Create
    End With

    Solid.Subtract "Conductor:" & pName, "Conductor:" & pName & "_cut"
End Sub
