# Federale wiki — rules that apply to our work (read 2026-11-10)

Source pages (Federale project wiki, author Allard Peper, edited 2026-11-10):
- Developer Workflow — https://dev.azure.com/avanade-lt-coe/Federale/_wiki/wikis/Project%20Federale%20Wiki/3134/Developer-Workflow
- ADO Ways Of Working — https://dev.azure.com/avanade-lt-coe/Federale/_wiki/wikis/Project%20Federale%20Wiki/3077/ADO-Ways-Of-Working
- Project Memory — https://dev.azure.com/avanade-lt-coe/Federale/_wiki/wikis/Project%20Federale%20Wiki/3132/Project-Memory
Not yet read: Sandbox Environments, Skills And Wiki Sync.

## Two boards, two audiences
- Federale project: **Issue** = customer-facing (symptom, where seen, evidence, expected result; no code pointers).
- AMT_Products: **Bug** (defect, the usual case; use Bug when unsure) or **User Story** (missing feature) = engineering item,
  **product-neutral**: no customer/application names, screen or transaction codes, real program/object/field names, customer data.
  Root cause, where to fix, minimal repro with neutral sample objects. Must be complete on its own (the Federale board may be archived).
- Pattern: **Issue -> Bug / User Story -> Task(s)**; the Federale Issue is the **parent** of the engineering item (new pairs from Nov 2026).

## Creating the engineering item from a Federale Issue
1. No engineering item exists yet (check Issue links, search AMT_Products).
2. A product fix is needed (not Federale\Technical Services\Defect, not Federale\Client).
3. Root cause confirmed (else the Issue goes to Federale\RCA first).
4. Type: Bug (usual) or User Story.
5. Product-neutral content: title, description as product behaviour, enough context without the Issue, repro steps with expected/actual
   (Bug) or acceptance criteria (Story), root cause and where to fix.
6. Fields: area path = product component owning the root cause (e.g. AMT_Products\Software Engineering\Source Converters\CobolToAmt);
   iteration = AMT_Products\<year>\Short Term Backlog; tags: Federale + drop tag (e.g. FET1-R6) + Smoketest only for smoke-test findings;
   Release Notes: one non-technical sentence for problem and solution.
7. Link: Federale Issue = parent. Tasks: investigation, development, testing (same area + iteration).
8. Align owner and state on both. Skills in Federale_Migration: create-product-workitem, create-federale-issue (review drafts first).
- New problem found while working on another ticket: discuss with the Migration Lead before creating a project-board item.

## States
- Bug/Story: New, Ready, Active, On Hold, Resolved (PR ready, awaits 2nd developer + QA), Closed (merged to develop = released for Federale).
- Developer Workflow: set Resolved when the PR is created; Closed when the PR is completed.

## Developer Workflow (from the Federale backlog)
- Pick up: Boards -> Backlogs, team Federale Team, iteration = current FET release (FET1-R6 week of 9-13 Nov 2026), top unassigned Issue.
- RCA on sandbox or locally; the AI needs input (Federale_Received), settings (Federale_Migration), output (generated C#).
- **Fix structurally** in converters / generator / runtime; **never fix generated C# by hand**; regenerate.
- Repro locally in **INTEGRATED_OS2200** (COBOL-INTEGRATED-OS2200, LION-INTEGRATED-OS2200; see INTEGRATED_OS2200/README.md in
  Federale_Migration), neutral names incl. the work item number (REPRO-<id>), attach e.g. as .LionSource; must show the defect.
- Branch in amt-go-net from up-to-date develop: **feature/federale/<ticket-id>-<description>**.
- After: update project memory; short status on the Federale Issue in customer language.

## Project Memory
- memory/continuity.md in **Federale_Migration** (main), read at the start of every AI session (amity-memory.instructions.md,
  amity.project.json). Pull before working.
- After a fix: add durable facts (one per bullet, footer `<!-- id: ... | tier: ... -->`, ADO id where useful), correct/archive old
  ones, close Open Threads. PR to main titled `memory: <fact> (ADO <id>)`. No secrets, personal data, status, or long procedures
  (procedures -> skills). refine-memory skill (amt-go-net) curates it.

## What this means for SSG-4 (our notes)
- MT-055 (T3-059 ticket) drafts: re-parent to a Federale Issue (create-federale-issue), make product-neutral (no CONDIS2/CC-Trial/
  AFBUS/runstream names), repro as REPRO-<id> in INTEGRATED_OS2200; tags Federale + drop tag; iteration Short Term Backlog.
- MT-058 converter merge / old PR 15584: branch feature/federale/<ticket-id>-..., tied to an AMT_Products Bug/Story.
- rc.02/rc.03 placement edits generated C# (relative refs, base(...) date): check with R&D against "never fix generated C# by hand".
- We have no clone of Federale_Migration (project memory, skills, INTEGRATED_OS2200).

---

## Sandbox Environments (read 261110)
- Each team member has a personal Azure VM sandbox, VMFEDPE01..09; use your own (ours: **VMFEDPE08**).
- Sandboxes cost money while running. They auto-stop, but turn yours off yourself (Azure portal → Stop) when done, e.g. end of day.
- Implication for us: long CC runs / LionDev generates must be planned within the working day; after a restart, Keycloak + Manage-FederaleServices must be restarted (already in our runbook).

## Skills And Wiki Sync (read 261110)
- **The wiki leads, the skills follow.** A skill must not introduce process rules that are not in the wiki; when they disagree the wiki wins (tell the Scrum Master / Migration Lead).
- Federale_Migration `.github/skills/`: `create-federale-issue` (Issue for a new finding, intake-alignment check, RCA path), `create-product-workitem` (product-neutral Bug/User Story with the Issue as parent, plus Tasks), `cobol-generator-error-analysis` (analyses COBOL generation errors, builds repros, raises items through the two skills).
- Own finding fixed straight away: run `create-federale-issue` first, then `create-product-workitem`. Issue from Fédérale: only `create-product-workitem`.
- amt-go-net `.github/skills/`: `online-smoketest-playwright`, `devops-pr-review`, `board-insights`.
- Memory: `memory/continuity.md`, kept lean by `refine-memory`; `.github/instructions/amity-memory.instructions.md` checks the memory is newest and offers updates after a fix.
- Smoke-test runbooks with work-item rules: `SmokeTest/SmokeTest-Online-Execute/{Troubleshooting-and-Ticketing.md,_AI-RUNBOOK.online.md}`, `SmokeTest/SmokeTests-Runs-Execute/{Troubleshooting-and-Ticketing.md,_AI-RUNBOOK.batch.md}`, `SmokeTest/REPORT-Generate-Instructions.md`.
- Sync checklist topics: work item types + parent link, area/iteration paths, states, tags (incl. tags never to set), audience split, Tasks.

### Implications for SSG-4
- Our `/ssg-*` prompts that draft ADO tickets (MT-055 drafts, `docs/RnD-Tickets/`) must defer to the wiki and, ideally, hand off to `create-federale-issue` → `create-product-workitem` rather than carry their own rules.
- `cobol-generator-error-analysis` is the team's route for converter/generator root causes; T3-052/T3-054/T3-059 style findings should go that way.
- Still needed: a local clone of `Federale_Migration` (owner fetch) to read those skills and the memory.
