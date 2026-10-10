---
mode: ask
description: Flag guardrail violations in a candidate AMT175 step
---

You will be given a candidate step:

${selection}

Flag violations of any of:
- AMT hard rules (AMTSYS* SQL, ROLEID hard-coding, component rights via SQL,
  bypass of Setup.exe or AmtReorganize).
- Parallel-run rules (AMTSYSTEM single-path overwrite, machine-scope
  ASPNETCORE_URLS, port reuse, realm/virtual folder/service name collision).
- AMT VS Generator misuse (treating it as required for runtime, Control Center,
  Keycloak, Sys.ini, AMTSYSTEM, or database setup).
- Citation rule (missing or multi-source citation).

For each violation return:
- rule id
- quoted offending line
- the required correction
