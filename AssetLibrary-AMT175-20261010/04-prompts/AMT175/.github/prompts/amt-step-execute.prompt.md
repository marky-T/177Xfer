---
mode: ask
description: Execute one AMT175 guide step safely
---

For this AMT175 step:

${selection}

Check:
- What reference document authorizes it? (exactly one citation)
- Is it tool/manual/script?
- What exact verification proves it worked?
- Does it violate any guardrail?
- Does it suggest direct SQL into AMTSYS*?
- Does it bypass Setup.exe or AmtReorganize?

Return:
- Status marker
- Corrected action block
- Verification block
- Any deviation log entry

## Parallel-run addendum

Refuse to execute any step that:
- overwrites AMTSYSTEM with a single-lane value
- runs setx / Set-ItemProperty against AMTSYSTEM
- starts kc.bat with --http-port 8081
- reuses an existing IIS virtual folder name across lanes
- reuses an existing LIONDEVNETSERVICENAME across lanes
- treats the AMT VS Generator as required for runtime/CC/Keycloak/Sys.ini/
  AMTSYSTEM/DB configuration (it is a scaffolder only, per .NET 10 Report §2)

Every command must be preceded by a short justification and exactly one citation.
