# Handover to the ticket session — the team's ticket process (2026-11-13)

> **Owner decision 261113 10:15 — overrides points 1, 2 and the iteration/tag parts of 3 below.** SSG-4 findings are fixed
> before the Federale test pipeline, so **no Federale Issue**: our AMT_Products Bugs hang under **User Story 119872**. Iteration =
> 119872's sprint (Bugs and Tasks follow it); Tags `Federale` only; the Migration Lead gets the batch list as a **courtesy, no
> gate**. Everything else (neutral content, ReproSteps sections, Severity 2 - High, no Priority, three Tasks, repro zip, Release
> Notes) stands. Rules now in `ssg-todo-issues.instructions.md` › *Team board tickets* and `/ssg-board-ticket`. Candidates
> rechecked 10:30: `docs/RnD-Tickets/board-candidates.md`.

From the update thread. Read before you continue with `docs/RnD-Tickets/SSG4-RnD-tickets-261113.md`.

**Where the process now lives.** Allard's "ticket process" update is in the **skills** of `Federale_Migration`
(PR 16507 and PR 16515, 10 Nov), not in new wiki pages; the wiki itself has had no change since 10 Nov 13:12.
- Summary with every field: `docs/Reference Docs/Federale-Team/Federale-Wiki-Rules.md`, sections
  "Setting up a ticket" and "The team's ticket skills".
- Copies of the skills: `docs/Reference Docs/Federale-Team/federale-migration-copy/_github/skills/`
  (`create-federale-issue`, `create-product-workitem`).

**Check the drafts against it:**
1. **Parent** = a Federale **Issue** (create it with `create-federale-issue`, after aligning with the Migration
   Lead), not User Story 119872. Three drafts still say `Parent: 119872`.
2. **Issue fields:** Area `Federale\Product Engineering\Initial Conversion\ECL`; Iteration `Federale\Backlog`
   (or `Federale\Initial Conversion`; `Federale\RCA` if the root cause is not confirmed); unassigned; `New`;
   Priority 4; **Original Estimate required**; `Custom.AgentPowered = true`; no tags. Title `[<Area>] …`;
   description opens with "In plain language (what this ticket is)", then Summary, Environment, Steps,
   Actual, Expected, Evidence. Customer language, no source pointers.
3. **Bug fields:** Area `AMT_Products\Software Engineering\Source Converters\EclToPowerShell` for SSG/ECL
   converter defects (runtime defects → `AMT Runtime Platform .NET\…`); Iteration
   `AMT_Products\2026\Short Term Backlog`; `New`; **Severity `2 - High`**; ValueArea `Business`;
   `AgentPowered = true`; Tags `Federale` + drop tag **only if the Issue is in a `FET…-R…` iteration**. The skill
   sets no Priority, so drop "Priority 99" unless the team asks for it.
4. **Release Notes** field: `[FIX]` / `INC No.:` / `Description of Problem:` / `Solution to Problem:`, one plain
   sentence each.
5. **Tasks:** investigation, development, testing; same Area and Iteration; `AgentPowered = true`.
6. **Repro** for a converter defect: original source + settings + `run.ps1` that shows the wrong output, zipped
   and attached to the Bug; object names postfixed with the ADO number; it must actually reproduce the defect.
   The T3-059 repro folder is close to this.
7. **Product-neutral** Bug, Tasks, comments and Release Notes: no CONDIS2, CC-Trial, AFBUS, runstream or
   utility names.
8. **Content:** the Bug body goes in `ReproSteps` with Summary, Stacktrace, Source pointers (every layer), Reproduction, Steps, Actual, Expected, Root cause, Fix options. No "Open questions" section. One parent only (the Issue), with no extra `Related` link. Task titles `Investigation — …` / `Development — …` / `Testing — …`. Full table: Federale-Wiki-Rules.md, "Content of the two items".
9. The skills create items through the `federale-ado` MCP server (AMITY, MT-060, not set up yet). Until then,
   the drafts are created by hand.
