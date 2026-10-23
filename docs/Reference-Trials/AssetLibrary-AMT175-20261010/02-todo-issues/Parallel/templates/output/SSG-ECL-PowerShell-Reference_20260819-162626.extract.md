# Extract of embedded bug / issue log

Source: `01-docs-html/Parallel/templates/output/SSG-ECL-PowerShell-Reference_20260819-162626.html` (original: `C:\Amt\Parallel\templates\output\SSG-ECL-PowerShell-Reference_20260819-162626.html`)

Original IDs from the HTML are preserved.

### Bug 14 — candidate filename must match PROGRAM-ID

      The candidate `.TXT` filename must equal the PROGRAM-ID in the
      COBOL source, not the SSG element name. SSG element `LECTIS_MULT` has
      `PROGRAM-ID. LECTIS.` → the candidate must be named `LECTIS.TXT`.

    The generator indexes by `PROGRAM-ID` (`CobolApp.Sources.Find(objNameWm)`).
    A mismatch fails generation with Could not find source with name: <ID> even after
    the suffix is cleaned up.

### Bug 15 — parse before generate

      After importing the `.LionSource` into LionDev, always run
      Logic Status → Select All → F7 (Parse) before clicking Generate.
      Skipping this leaves `REVGENSETDATA` empty and generates empty C# files.