# 4-Element 868 MHz Beamforming Array — CST Walkthrough
### Fixed broadside beam, uniform amplitude/phase, Wilkinson corporate feed

This builds directly on your validated single-element patch (Wg=126, Lg=102.4, W=105, L=87, h=1.6, t=0.035, wf=3, g=1, y0=12, via_r=0.4). Start a **new project** (or duplicate your single-element one) rather than editing your validated single-element file in place — you'll want that one preserved as a reference/fallback.

## New parameters to add (Parameter List)

```
N     = 4        (number of elements)
d     = 130      (element spacing, mm)
w70   = 1.58     (70.7 ohm line width)
l70   = 48.3     (70.7 ohm quarter-wave arm length)
Riso  = 100      (Wilkinson isolation resistor, ohms)
fnet_depth = 100 (extra board length reserved for the feed network, mm)
X1    = -1.5*d   (Element 1 center X)
X2    = -0.5*d   (Element 2 center X)
X3    = 0.5*d    (Element 3 center X)
X4    = 1.5*d    (Element 4 center X)
```

Keep every dimension referencing these parameters (not typed numbers) so the whole array can be re-tuned or re-spaced later by changing one value.

## Part 1 — Array board (shared ground plane and substrate)

Unlike the single-element design, the array uses **one continuous board**, not four separate ones abutted together.

1. **Ground plane** (Extrude Profile, Orientation=Z, Height=0, Zmin=0), Points as a rectangle:
   - (`-(N-1)*d/2-W/2-15`, `-Lg/2`)
   - (`(N-1)*d/2+W/2+15`, `-Lg/2`)
   - (`(N-1)*d/2+W/2+15`, `Lg/2+fnet_depth`)
   - (`-(N-1)*d/2-W/2-15`, `Lg/2+fnet_depth`)
   - Name: `GroundPlane`. Material: `Copper (annealed)`.
   
   This spans the full array width (all 4 element positions plus margin) and extends in +Y past the original single-element feed edge to cover the feed-network region.

2. **Substrate** (ordinary 3D brick, same footprint as GroundPlane, Zmin=0, Zmax=h): same X/Y point expressions as above. Material: your FR4 definition (εr=4.45).

## Part 2 — Replicate the patch element 4 times

Every point below is the base single-element shape (Patch 12-point profile, FeedLine 4-point profile, ShortingVia), with the element's `X1`/`X2`/`X3`/`X4` parameter added to every X-coordinate. All expressions — no fixed numbers.

### Element 1 — center X1

**Patch_1** (12 points, Zmin=`h`):
```
(X1-W/2,      -L/2)
(X1+W/2,      -L/2)
(X1+W/2,       L/2)
(X1+wf/2+g,    L/2)
(X1+wf/2+g,    L/2-y0)
(X1+wf/2,      L/2-y0)
(X1+wf/2,      L/2)
(X1-wf/2,      L/2)
(X1-wf/2,      L/2-y0)
(X1-wf/2-g,    L/2-y0)
(X1-wf/2-g,    L/2)
(X1-W/2,       L/2)
```
**FeedLine_1** (4 points, Zmin=`h`):
```
(X1-wf/2, L/2-y0)
(X1+wf/2, L/2-y0)
(X1+wf/2, Lg/2)
(X1-wf/2, Lg/2)
```
**ShortingVia_1**: X1(pt)=X2(pt)=`X1`, Y1=Y2=`-L/2`, Z1=`0`, Z2=`h`, radius=`via_r`

### Element 2 — center X2

**Patch_2**:
```
(X2-W/2,      -L/2)
(X2+W/2,      -L/2)
(X2+W/2,       L/2)
(X2+wf/2+g,    L/2)
(X2+wf/2+g,    L/2-y0)
(X2+wf/2,      L/2-y0)
(X2+wf/2,      L/2)
(X2-wf/2,      L/2)
(X2-wf/2,      L/2-y0)
(X2-wf/2-g,    L/2-y0)
(X2-wf/2-g,    L/2)
(X2-W/2,       L/2)
```
**FeedLine_2**:
```
(X2-wf/2, L/2-y0)
(X2+wf/2, L/2-y0)
(X2+wf/2, Lg/2)
(X2-wf/2, Lg/2)
```
**ShortingVia_2**: X1(pt)=X2(pt)=`X2`, Y1=Y2=`-L/2`, Z1=`0`, Z2=`h`, radius=`via_r`

### Element 3 — center X3

**Patch_3**:
```
(X3-W/2,      -L/2)
(X3+W/2,      -L/2)
(X3+W/2,       L/2)
(X3+wf/2+g,    L/2)
(X3+wf/2+g,    L/2-y0)
(X3+wf/2,      L/2-y0)
(X3+wf/2,      L/2)
(X3-wf/2,      L/2)
(X3-wf/2,      L/2-y0)
(X3-wf/2-g,    L/2-y0)
(X3-wf/2-g,    L/2)
(X3-W/2,       L/2)
```
**FeedLine_3**:
```
(X3-wf/2, L/2-y0)
(X3+wf/2, L/2-y0)
(X3+wf/2, Lg/2)
(X3-wf/2, Lg/2)
```
**ShortingVia_3**: X1(pt)=X2(pt)=`X3`, Y1=Y2=`-L/2`, Z1=`0`, Z2=`h`, radius=`via_r`

### Element 4 — center X4

**Patch_4**:
```
(X4-W/2,      -L/2)
(X4+W/2,      -L/2)
(X4+W/2,       L/2)
(X4+wf/2+g,    L/2)
(X4+wf/2+g,    L/2-y0)
(X4+wf/2,      L/2-y0)
(X4+wf/2,      L/2)
(X4-wf/2,      L/2)
(X4-wf/2,      L/2-y0)
(X4-wf/2-g,    L/2-y0)
(X4-wf/2-g,    L/2)
(X4-W/2,       L/2)
```
**FeedLine_4**:
```
(X4-wf/2, L/2-y0)
(X4+wf/2, L/2-y0)
(X4+wf/2, Lg/2)
(X4-wf/2, Lg/2)
```
**ShortingVia_4**: X1(pt)=X2(pt)=`X4`, Y1=Y2=`-L/2`, Z1=`0`, Z2=`h`, radius=`via_r`

All 4 patches, feed lines and vias use **Material: Copper (annealed)**, same Zmin/Height=0 (Extrude Profile) conventions as the single-element build. Note that each element's block is identical except for which `X1`–`X4` parameter it references — double-check that each block actually points at its own `Xi` and not a copy-paste leftover from a neighboring element, since that's exactly the kind of error that's easy to introduce when duplicating four nearly-identical blocks and one of the most likely real mistakes here, more so than a wrong number.

## Part 3 — Build one Wilkinson divider cell (as a reusable template)

Build this once at a **local origin** (split point at X=0, Y=0) — you'll Transform-copy the finished cell to Stage 1 and both Stage 2 locations afterward, the same translate-and-copy method as the patches in Part 2.

**New parameters to add:**
```
res_gap = 2                  (gap between the two arm outputs, for the isolation resistor pad)
Lx      = (res_gap+w70)/2    (horizontal offset of each arm from center)
Ly      = l70-Lx             (remaining vertical run per arm, so horizontal+vertical ≈ l70)
```
`Lx+Ly = l70` by construction — the two-segment path approximates the electrical quarter-wave length; treat this as your starting point and confirm/nudge it against the trace's actual reported length once drawn (a small right-angle bend adds a little extra effective length beyond the straight-segment sum, same "verify before trusting" caveat as before).

**1. Input trace** (Extrude Profile, Orientation=Z, Height=0, Zmin=`h`) — a simple rectangle running from the split point upward (+Y), `wf` wide by construction from the points below (there's no separate width field — the width comes entirely from how far apart the X-values of the points are):
```
(-wf/2, 0)
(wf/2, 0)
(wf/2, stub_len)
(-wf/2, stub_len)
```
Add one more parameter: `stub_len = 10` (a placeholder length just for building the template). **This one piece is genuinely instance-specific** — after you Transform-copy this whole divider cell to Stage 1 and each Stage 2 location in Part 4, come back and stretch each copy's input trace (just edit its two far-Y points) until it actually reaches that instance's real connection point: for Stage 1, up to the port at the board edge; for each Stage 2 divider, up to Stage 1's corresponding output. There's no single formula for this length since it depends on the physical distance between stages, which you'll read off the actual geometry once the cells are placed.

**2. Right arm — Segment 1 (horizontal)** — `w70` wide by construction (the points' Y-span), running from the split point outward to X=`Lx`:
```
(0, -w70/2)
(Lx, -w70/2)
(Lx, w70/2)
(0, w70/2)
```

**3. Right arm — Segment 2 (vertical)** — `w70` wide by construction (the points' X-span), dropping from the horizontal segment down to the output Y-level `-Ly`:
```
(Lx-w70/2, -Ly)
(Lx+w70/2, -Ly)
(Lx+w70/2, w70/2)
(Lx-w70/2, w70/2)
```
Select Segment 1 and Segment 2 → **Modeling tab → Boolean → Add** (union, not subtract — this merges the two rectangles into one continuous L-shaped arm; unlike the earlier Notch subtraction, both pieces are meant to be consumed into the merged result here). Name the result `ArmRight`.

**4. Left arm — mirror `ArmRight` rather than re-entering points:** select `ArmRight` → **Modeling tab → Transform → Mirror**. Set the mirror plane normal to **(1, 0, 0)** (mirrors across the Y-Z plane, flipping X → -X) passing through the origin (X=0, the split point). Set mode = **Copy** (not Move) so `ArmRight` is preserved. Rename the result `ArmLeft`.

Each arm's final output point (centerline) sits at (`Lx`, `-Ly`) and (`-Lx`, `-Ly`) — this is where the connecting stub to the next stage or patch attaches.

**5. Isolation resistor:** Navigation Tree → **Modeling → Lumped Element** (or "Discrete Face Element"). Place it bridging the two arm outputs directly across the gap:
- Point 1: (`-res_gap/2`, `-Ly`)
- Point 2: (`res_gap/2`, `-Ly`)
- Type = Resistor, R = `Riso` (100 Ω)

All conductor pieces (input trace, both arms): Material = `Copper (annealed)`, same Zmin/Height=0 Extrude Profile conventions as everything else in this build.

## Part 4 — Assemble the binary tree

**Honest caveat before the coordinates below:** unlike the ground plane, substrate, patches, feed lines and vias above — which are simple rectilinear shapes I can specify exactly — the Wilkinson tree's arms need to hit a precise *electrical* quarter-wavelength (l70=48.3mm of actual trace path, not straight-line distance) while also physically routing between points that aren't in a straight line. Giving you fixed bend coordinates here would mean fabricating a routing solution I haven't actually verified sums to the right electrical length — that's a real risk of quietly handing you a wrong number dressed up as a precise one. What I can give you confidently is the **topology and anchor points**; the actual bend path between them is something to route and verify (via the trace's reported length property, or S11/phase-balance in simulation) once you're in CST looking at the real geometry.

**Anchor points (all at Y-level matching each stage, Zmin=`h`), all as expressions:**
- **Stage 1 divider**, centered at **X = `0`**. Its input point sits at the board's outer edge — **(`0`, `Lg/2+fnet_depth`)** — and its two outputs head toward Stage 2's locations below.
- **Stage 2, left**, centered at **X = `(X1+X2)/2`** (midpoint of Element 1 and Element 2), at an intermediate Y between the board edge and the patches — suggest **(`(X1+X2)/2`, `Lg/2+l70`)** as a working starting point (roughly one l70 arm-length in from the patches' feed level).
- **Stage 2, right**, centered at **X = `(X3+X4)/2`**, mirrored — suggest **(`(X3+X4)/2`, `Lg/2+l70`)**.
- Stage 2 left's two outputs connect to `FeedLine_1`'s far end (**X between `X1-wf/2` and `X1+wf/2`**, Y=`Lg/2`) and `FeedLine_2`'s far end (**X between `X2-wf/2` and `X2+wf/2`**, Y=`Lg/2`).
- Stage 2 right's two outputs connect to `FeedLine_3`'s far end (**X between `X3-wf/2` and `X3+wf/2`**, Y=`Lg/2`) and `FeedLine_4`'s far end (**X between `X4-wf/2` and `X4+wf/2`**, Y=`Lg/2`).

1. **Stage 1 (first divider):** place at the array's centerline (X=0), input coming from the board edge (this is where your final array port will go), splitting into two branches heading toward X<0 and X>0.
2. **Stage 2 (two dividers):** one on each branch from Stage 1, each splitting again — the left one feeding `FeedLine_1` and `FeedLine_2`, the right one feeding `FeedLine_3` and `FeedLine_4`.
3. **Symmetric routing:** lay out Stage 2's branches so the path length from Stage 1's output to each of the 4 FeedLines is identical — mirror the left and right halves of the tree exactly. If a geometric offset makes one path longer, add a small meander (a zig-zag in the trace) to the shorter path until lengths match, rather than leaving them unequal. Use CST's trace/curve length readout (or check phase balance in a quick S-parameter test) to confirm each arm is genuinely at l70's electrical length before trusting the layout — don't rely on the suggested anchor points above being exactly right on the first try.

## Part 5 — Port

1. Place a single **Discrete Port** at the Stage 1 divider's input, at the board's outer edge (**`0`, `Lg/2+fnet_depth`**), same style as your single-element port (Z1=`0` on GroundPlane, Z2=`h` on the input trace, impedance 50 Ω, radius = `wf/2`).

## Part 6 — Monitors

Same as before: Farfield monitor at 868 MHz (this is the one you actually care about now — it'll show the array's combined beam pattern, not a single element's pattern), plus an E-field/surface-current monitor at 868 MHz to visually confirm all 4 elements are exciting properly and the feed network isn't leaking power asymmetrically.

## Part 7 — Mesh and solve

1. Local mesh refinement on `Patch_1`–`Patch_4` and all `FeedLine` segments (same wf/4 lateral sizing as before), plus the divider arms (use `w70`/4 as the local size there, since they're narrower than the main feed lines).
2. Each `ShortingVia_i` needs no local mesh (thin-wire, same as before) — but re-apply the coarser mesh floor (~1.0–1.2mm volume refinement, no edge refinement) you added to fix the earlier mesh-radius warning, to each of the 4 vias this time.
3. Time Domain solver, Accuracy -40dB, AMR on (2-3 passes to start, same reasoning as the single-element coarse-first approach).
4. Run. Check S11 at the single array input port first — confirm it's still well-matched near 868 MHz (a badly matched Wilkinson tree will show up here even before you look at the beam pattern).
5. Check the Farfield plot at 868 MHz — compare against your Path-1 computational Farfield Combine prediction (~+6 dB directivity over one element, ~-13 dB sidelobes, main lobe broadside). A large mismatch points to a feed-network phase/amplitude imbalance rather than an element problem, since each element was already validated individually.

## Notes on failure modes specific to this array (things to check if results look wrong)
- **Beam squinted off broadside:** almost always a path-length mismatch somewhere in the feed tree — go back and verify all 4 input-to-patch paths are truly equal length.
- **S11 poor at the array port but each branch's dividers look fine individually:** check the isolation resistor value and placement — a missing or misplaced Riso is a classic silent bug that degrades match without an obvious visual defect.
- **One element's local field looks much weaker than the others:** check that element's specific FeedLine/Patch X-offset didn't get typo'd during the four-times repetition in Part 2 — this is the same class of parameter-drift bug you already caught twice in the single-element build.
