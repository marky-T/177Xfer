---
mode: ask
description: Review completed AMT175 phase against reference docs
---

Review Phase ${input:phaseName}.

Compare:
1. Actions actually taken
2. Reference-doc workflow
3. Verification evidence
4. Deviations
5. Open risks
6. Corrections required before next phase

Rules:
- Do not introduce new implementation ideas unless required to correct a deviation.
- Do not re-open already verified steps unless evidence contradicts them.
- Focus on reducing rework and preventing cyclic prompting.
- If no correction is required, say: "Phase accepted — proceed."

## Parallel-run addendum

Include a Parallel-lane checks block in every review log:
- [ ] AMTSYSTEM still lists both lane paths, no spaces
- [ ] AMT172 still reachable at http://localhost/Working/ControlCenter
- [ ] AMT175 reachable at http://localhost/AMT175/ControlCenter (after Phase 3)
- [ ] Ports 5172/7172 owned by AMT172 process only
- [ ] Ports 5175/7175 owned by AMT175 process only
- [ ] Keycloak on 8080 responds; both realms exist
- [ ] No Sys.ini exists above the lane root of either lane
- [ ] No new AMT VS Generator invocation was required for this phase
      (unless the phase explicitly scaffolds a new AMT project)
