---
mode: ask
description: Plan an AMT175 install phase using authoritative AMT references
---

Plan Phase ${input:phaseName} for AMT175 (parallel lane alongside AMT172).

Use only these authorities unless I explicitly attach another reference, in
priority order:
1. `C:\Amt\AMT_ReferenceDocuments\AMT157_Online_help`
2. `C:\Amt\AMT_ReferenceDocuments\AMT_LionReferenceDocs` (AICL, ALPD, LincToLion, migration specs)
3. Other folders under `C:\Amt\AMT_ReferenceDocuments`
4. AMT175 release notes / `AMT .Net 8 upgrade to .Net 10 Report.docx`

Do not use AMT172 implementation details as authority.

Return:
1. Required inputs
2. Expected outputs
3. Step blocks
4. Verification commands
5. Risks
6. Guardrail checks
7. Stop/go criteria

Every step must carry exactly one Citation (highest-priority matching source),
or `Citation: <em>n.cite</em>`.

Do not suggest direct SQL on AMTSYS* tables.
Do not assume role IDs.
Prefer Setup.exe, AmtReorganize, Control Center, Keycloak, and LincToLion
documented workflows.

## Parallel-run addendum

Before proposing any change, confirm in the plan:
- Which lane does this affect (AMT172, AMT175, or both)?
- What is the AMTSYSTEM value expected to be after this change?
- Which IIS virtual folder is targeted, and does it collide with the other lane?
- Which Windows service is affected (LIONDEVNETSERVICENAME), and is it lane-unique?
- Which port range is affected (5172/7172 vs 5175/7175 vs 8080)?
- Does this step invoke the AMT VS Generator? If yes, note it explicitly and
  confirm VS 2026 is available; if no, do not add VS 2026 as a prerequisite.
