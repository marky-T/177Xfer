# 15 — Docs-as-Guardrails: Can amt-go-net adopt the AmtNextGen approach?

Related: [README](./README.md) · [Architecture — Two Layers](./02-architecture-two-layers.md) · [Authoring Standard](./08-authoring-standard.md) · [Status & Decisions](./09-status-decisions-roadmap.md) · [What Goes Where](./12-what-goes-where.md)

> Status: **analysis / proposal**. Nothing in here has been built yet. Date: 2026-10-09.

## 1. Short answer

**Yes, it can be done, but only part of it should be copied as-is.** The AmtNextGen
model has two halves:

1. **Durable guardrail docs.** ADRs, standards, agent guardrails, runbooks, Definition
   of Done. Agents and humans read them, and `.github/` artifacts link to them instead
   of repeating them. This half suits amt-go-net well and fits AMITY's own design
   (the "one fact, one place" principle and the plan to make `AGENTS.md` canonical).
2. **A markdown backlog plus the Story Quality Gate.** Epics, features and stories live
   as markdown, and the state lives in Azure DevOps. **This half does not suit
   amt-go-net.** amt-go-net is a large brownfield product with many teams. Its work
   lives only in ADO (`AMT_Products`), it handles customer issues such as Federale
   Issues, and the existing PR validation pipeline already enforces work-item rules
   (the Release Notes field).

Recommendation: adopt half 1 under `AMITY/`, change it to fit AMITY's two-layer model,
and **leave out** the markdown backlog. If a Definition of Ready is needed, define it
against ADO work items instead.

## 2. What AmtNextGen does (reference model)

| Layer | AmtNextGen artifact | Role |
|---|---|---|
| Manifest | `docs/README.md` | Index plus the **durable vs throwaway** lifecycle rule |
| Architecture | `docs/01-architecture/adr/ADR-NNNN-*.md` + `_template.md` (MADR) | Binding decisions. `Accepted` ADRs constrain code |
| Requirements | `docs/02-requirements/use-cases/` | Permanent functional specification |
| Backlog | `docs/03-backlog/{epics,features,user-stories,enablers,bugs}` | Throwaway content. State lives in ADO |
| Standards | `docs/04-standards/*` (coding, git, testing, documentation, backlog, DoR) | Vocabulary shared by humans and agents |
| Agent guardrails | `docs/05-agent-guardrails/README.md` | Roles, human checkpoints, ADO write boundaries, quality gates |
| Security | `docs/06-security/{attack-surface,threat-model}.md` | Input to the `security-review` skill and instruction |
| Runbooks | `docs/09-runbooks/*` (DoD, refinement, security scanning, ADO integration) | Procedures that people and agents follow |
| Steering | `AGENTS.md` → `.github/copilot-instructions.md` → links into `docs/` | **Link, don't duplicate** |
| Personas | `.github/agents/{dev,qe,architect,refinement}-agent.agent.md` | Each persona reads specific docs and refuses work that breaks them |
| Skills | `create-adr`, `run-pre-merge-checks`, `security-review`, `story-quality-gate`, … | Procedures that read or write the docs |
| Enforcement | `scripts/pre-merge.ps1`, `scripts/story-quality-gate.ps1`, `azure-pipelines.yml` | Mechanical gates that report criterion IDs (`DOR-*`) and scan results |

The main idea: **guardrails are executable contracts.** Docs carry stable IDs (ADR-NNNN,
DOR-xNN). Scripts and skills report those IDs, and agents refuse work that breaks an
`Accepted` ADR or a gate.

## 3. What amt-go-net has today

| Area | Current state | Location |
|---|---|---|
| Steering | One large `copilot-instructions.md` (coding standards, build, naming, tests). No `AGENTS.md` | [.github/copilot-instructions.md](../../.github/copilot-instructions.md) |
| Always-on rules | `amt-tooling`, `lion-repository-mcp`, `amt-playwright-tests` instructions | [.github/instructions/](../../.github/instructions/) |
| Skills / agents | 7 skills (AMITY-style), 1 agent (`amt-debug-online`), 1 prompt | [.github/](../../.github/) |
| Design decisions | 4 records in a lightweight MADR-like format, in the ADO code wiki | [Wiki/AMT.NET-Wiki/Design-decisions/](../../Wiki/AMT.NET-Wiki/Design-decisions/) |
| Product docs | ADO wiki (Developer Suite, Runtime Platform, Transform Suite, env setup) | [Wiki/AMT.NET-Wiki/](../../Wiki/AMT.NET-Wiki/) |
| Code-style enforcement | `.editorconfig` with Asysco rules at `error` severity | [.editorconfig](../../.editorconfig) |
| CI | Nightly `develop` build, SonarQube (debug build + tests). No Semgrep or Trivy | [azure-pipelines.yml](../../azure-pipelines.yml) |
| PR gate | Linked Bug/User Story must have a populated `Custom.ReleaseNotes` field | [azure-validation-pipeline.yml](../../azure-validation-pipeline.yml) |
| Backlog | ADO only (`avanade-lt-coe` / `AMT_Products`) | — |
| Missing | Definition of Done, Definition of Ready, agent guardrails doc, git-workflow doc, testing-strategy doc, PR template, docs manifest, pre-merge script | — |

### Problems already visible (they show why "link, don't duplicate" matters)

- **The .NET version has drifted.** `copilot-instructions.md` says *.NET SDK 8.0.415
  EXACTLY / net8.0*, but `azure-pipelines.yml` installs **10.0.302**. The same fact is
  kept in two places and nobody owns it.
- **Instructions conflict about ADO tooling.** The global user instruction says *use
  `az boards/repos/pipelines` and set `AgentPowered=true`*. `amt-tooling.instructions.md`
  says *never `az`; only the `*-ado` MCP*. No document decides which rule applies, or
  whether `AgentPowered` applies in `AMT_Products`.
- **External standards source.** `copilot-instructions.md` points to an `amt-kb`
  repository for "extended standards". Its relation to any new standards docs must be
  decided, or it becomes a third copy.

## 4. Fit/gap per AmtNextGen element

| AmtNextGen element | Verdict | Reason / required adaptation |
|---|---|---|
| `docs/README.md` lifecycle manifest | **Adopt** | Becomes `AMITY/README.md`: index, lifecycle and **layer** (generic vs project) per folder |
| ADRs (MADR, `ADR-NNNN`, statuses, supersession) | **Adopt and adapt** | One home only. See [§6 decision D2](#6-decisions-needed-before-building). Migrate the 4 wiki records or point to them |
| ADR review artifact (`adr-review-YYYY.md`) | **Adopt later** | Useful once there are more than about 10 ADRs |
| Use cases / requirements | **Skip** | Product behaviour is already documented in the ADO wiki. Link to it and do not duplicate it |
| Markdown backlog (EPIC/FR/US/ENB/BUG) | **Skip** | ADO-only process, many teams, customer-issue flow, release-notes gate |
| Definition of Ready / Story Quality Gate | **Adapt (optional)** | Write the criteria as `DOR-*` IDs against **ADO fields**, not markdown sections. The gate becomes a skill that reads the work item through the `*-ado` MCP. The mechanical script would have to be rewritten |
| Definition of Done | **Adopt** | Content: builds, unit tests in a sibling `UnitTests` folder, Sonar clean on new code, release notes filled, no edits to generated code, PR to `develop` |
| Coding standards doc | **Adopt and distill** | Move the body of `copilot-instructions.md` into `04-standards/coding-standards.md` plus a `coding-standards.instructions.md` with `applyTo: '**/*.cs'`. This matches AMITY open decision 2 |
| Git workflow | **Adopt and adapt** | `develop` (not `main`), `feature/<dev>/<id>-<desc>`, `epic/*`, `branch-from-<ver>/*`, ADO work-item linking. No Conventional Commits unless the team agrees |
| Testing strategy | **Adopt and adapt** | MSTest/`*Tests.dll`, Pester, Playwright smoke tests (existing skill). Coverage target applies to **new code** (Sonar new-code period), not to the whole codebase |
| Documentation standards | **Adopt** | Merge with AMITY [08](./08-authoring-standard.md) and [12](./12-what-goes-where.md). Do not create a third placement document |
| Agent guardrails | **Adopt and extend** | Add the AMT-specific rules: fix upstream and never edit generated code, Lion repository only through MCP and never in parallel, ADO only through the `*-ado` MCP, no secrets (the AMITY hard rule) |
| Security (attack surface, threat model) | **Adopt later** | A useful but large piece of work for the runtime and web tiers (Blazor, ControlCenter, Keycloak). Not a prerequisite |
| Runbooks (DoD, ADO integration, security scanning) | **Adopt selectively** | `ado-integration` points to the existing `install-amt-mcp-servers` skill. Add security scanning only if D5 adds scanners |
| `AGENTS.md` → thin `copilot-instructions.md` | **Adopt** | Already AMITY open decision 1 |
| Personas: Dev, QE, Architect, Refinement | **Partial** | Architect (ADR conformance) and Reviewer (wraps `devops-pr-review`) add value. Refinement only if D4 = yes. AMITY rule: agents are optional |
| Skills `create-adr`, `run-pre-merge-checks`, `security-review` | **Port and adapt** | Change the paths and the scan set. `security-review` already exists in AmtNextGen as an instruction |
| Skills `write-user-story`, `refine-story`, `refresh-backlog-priority`, `scaffold-feature` | **Skip** | Tied to the markdown backlog and the Angular/Orleans stack |
| `scripts/pre-merge.ps1` | **Adapt** | The full `AmtAll.sln` build is too slow to run locally on every change. Scope it to changed projects: `dotnet format --verify-no-changes`, build, then the related `*Tests` projects |
| `scripts/story-quality-gate.ps1` | **Skip / rewrite** | Only if D4 = yes, and only as an ADO-based check |

## 5. Two-layer constraint (AMITY-specific)

AmtNextGen is a single repo with a single audience. amt-go-net serves **two audiences**,
and the guardrail docs must state which one each rule is for:

| Audience | Example rules | Home |
|---|---|---|
| **A. Developers working on the AMT product itself** | Asysco coding standards, DoD, git workflow, Sonar, release notes, ADRs about the runtime and generators | `amt-go-net/AMITY/…` (generic layer, product scope) |
| **B. Engineers using AMT on a migration project** | Fix upstream and never edit generated code, Lion MCP rules, debug procedures, no secrets, ADO through MCP | `amt-go-net/AMITY/…` (generic layer, *toolchain* scope) and inherited by every `<Project>_Migration` |
| **C. Project-specific** | Federale ADO project, customer DoD additions, project ADRs | `<Project>_Migration/` (**not** in amt-go-net) |

Consequences:

- Every guardrail or standard doc gets a **Scope** line: `product` | `toolchain` | `both`.
- A project may **add** guardrails in its own `_Migration` repo (for example
  `docs/guardrails.md` or `memory/continuity.md`) but must not weaken generic ones.
- **Multi-root leakage risk.** In a multi-root workspace, amt-go-net instructions with
  `applyTo: '**'` are also loaded when an agent works in other folders. This was seen in
  this analysis session, where amt-go-net instructions loaded alongside AmtNextGen.
  Product-only rules such as the Asysco C# style (`Int32`, `m_`) **must not** go into an
  `applyTo: '**'` instruction, because they contradict AmtNextGen's C# 14 standard.
  Keep them in the folder-local `copilot-instructions.md`/`AGENTS.md`, or scope them with
  narrow globs. **Verify** how VS Code resolves `applyTo` across workspace folders
  before distilling.

## 6. Decisions needed before building

| # | Decision | Options | Recommendation |
|---|---|---|---|
| D1 | Folder layout under `AMITY/` | (a) Add numbered folders at the `AMITY/` root that mirror AmtNextGen (`01-architecture/`, `04-standards/`, `05-agent-guardrails/`, `09-runbooks/`). The current `Documentation/` stays as the AMITY *design* set. (b) Put everything inside `AMITY/Documentation/` as docs 16+ | **(a)**. The vocabulary matches AmtNextGen, so agents and people can move between repos, and the AMITY design set stays separate from the rules it produces |
| D2 | Home of ADRs | (a) Move the 4 wiki design decisions into `AMITY/01-architecture/adr/` as ADR-0001..0004 (MADR) and leave wiki stubs that point to them. (b) Keep `Wiki/AMT.NET-Wiki/Design-decisions/` as the home, upgrade its template to MADR (add *Decision Drivers* and *Pros/Cons*), and link to it from AMITY | **(b) if the ADO wiki is the team's main reading surface, otherwise (a).** Either way: **one home**, `ADR-NNNN` numbering, `Accepted` = binding, explicit `Superseded by`. Also decide who approves ADRs, because many teams contribute |
| D3 | Steering canonical source | `AGENTS.md` (≤200 lines) + thin `copilot-instructions.md` | **Yes** (AMITY open decisions 1 and 2) |
| D4 | Definition of Ready | None / doc only / doc + ADO-based gate skill | **Doc only at first**. Add the gate skill if story quality becomes a problem |
| D5 | Extra scanners | Keep SonarQube only, or add Semgrep + Trivy (as AmtNextGen does) | Start by documenting the existing Sonar plus release-notes gates. Decide on Semgrep and Trivy separately with whoever owns the pipeline |
| D6 | ADO tool rule | `*-ado` MCP only, or `az` allowed. Whether `AgentPowered=true` applies in `AMT_Products` | Record the decision in `05-agent-guardrails` so the conflicting instructions are settled |
| D7 | `amt-kb` relation | Retire it, link to it, or absorb it | Survey `amt-kb`, then absorb or link. Do not keep a parallel copy |
| D8 | Source vs mirror | This repo is described as a mirror of the ADO repo | Commit the docs to the **ADO source repo** (`AMT_Products/amt-go-net`) so the mirror does not overwrite them |

## 7. Proposed target structure (assuming D1 = a)

```text
AMITY/
├── README.md                         ← NEW manifest: index, lifecycle, layer and scope per folder
├── Documentation/                    ← EXISTING AMITY design set (01–15), unchanged
├── 01-architecture/
│   └── adr/
│       ├── README.md                 ← index: number, title, status, scope (optional)
│       ├── _template.md              ← MADR (copied from AmtNextGen, plus a "Scope" field)
│       └── ADR-0001-…md              ← migrated from Wiki, or pointer README if D2 = b
├── 04-standards/
│   ├── coding-standards.md           ← distilled from copilot-instructions + .editorconfig
│   ├── git-workflow.md               ← develop, branch patterns, PR + work-item linking
│   ├── testing-strategy.md           ← UnitTests sibling projects, MSTest, Pester, Playwright
│   ├── documentation-standards.md    ← link-don't-duplicate; points to Documentation/08 + 12
│   ├── work-item-standards.md        ← ADO AMT_Products: types, Release Notes, linking
│   └── definition-of-ready.md        ← optional (D4)
├── 05-agent-guardrails/
│   └── README.md                     ← roles, human checkpoints, ADO boundaries, AMT hard rules
└── 09-runbooks/
    ├── definition-of-done.md
    ├── pre-merge-checks.md           ← how to run scripts/pre-merge.ps1 (if built)
    └── ado-integration.md            ← short; points to install-amt-mcp-servers skill
```

Changes outside `AMITY/`:

| File | Change |
|---|---|
| `AGENTS.md` (new, repo root) | Non-negotiables plus links into `AMITY/04-standards`, `05-agent-guardrails`, ADRs |
| `.github/copilot-instructions.md` | Becomes a thin pointer to `AGENTS.md` (fixes the .NET 8 vs 10 drift by making one place the authority) |
| `.github/instructions/coding-standards.instructions.md` | New. Narrowly scoped (`**/*.cs`). Links to `04-standards/coding-standards.md` |
| `.github/skills/create-adr/` | Port from AmtNextGen. Template path and next-number scan point to the chosen ADR home |
| `.github/skills/run-pre-merge-checks/` + `scripts/pre-merge.ps1` | Optional (D5). Scoped to changed projects |
| `.github/agents/architect.agent.md` | Optional. Reads `Accepted` ADRs and checks a change for conformance |
| `.github/pull_request_template.md` (or the ADO PR template) | Optional. DoD checklist |
| `Wiki/AMT.NET-Wiki/Design-decisions/` | Per D2: either pointer pages or the upgraded template |

## 8. Agent guardrails: draft content for amt-go-net

The AmtNextGen file is the starting point. Changes for amt-go-net:

**Human checkpoints (require approval):** merging to `develop` or `branch-from-*`;
changing the generators, runtime contracts or Lion repository schema; adding external
NuGet or npm packages (`Directory.Packages.props`); pipeline changes; deleting branches
or data; closing or deleting ADO work items.

**ADO boundaries:** same table as AmtNextGen (state changes only on items assigned to the
invoking user, never assign/close/delete), plus: all operations go through the `*-ado` MCP
(D6), and a linked Bug/User Story must carry release notes before a PR is raised.

**AMT hard rules (already spread across instructions and skills; collect pointers here):**

- Fix upstream (generator, converter, Lion source) and regenerate. **Never edit generated code.**
- All Lion repository access goes through the `lion-repository` MCP. Never call it in
  parallel. Never use write tools to work around a read problem.
- No secrets, credentials, logins or PATs in committed files (AMITY hard rule, [12](./12-what-goes-where.md)).
- Never commit or push for the user. Never use `--no-verify`.

**Quality gates (only those that actually exist):**

| Gate | Criteria | Enforced by |
|---|---|---|
| Code style | `.editorconfig` errors = 0 | Build / `dotnet format` |
| Code quality | Sonar quality gate on new code | `azure-pipelines.yml` (currently nightly; check whether it is a PR policy) |
| Tests | Unit tests exist and pass for changed code | DoD + review (`devops-pr-review`) |
| Release notes | `Custom.ReleaseNotes` populated | `azure-validation-pipeline.yml` (PR policy) |
| Architecture | Conforms to `Accepted` ADRs | Architect agent / review |

## 9. Work plan

Order matters. Each step can be done on its own and reverted.

1. **Decide D1–D8.** Record the outcome in [09 — Status, Decisions & Roadmap](./09-status-decisions-roadmap.md).
2. **Manifest and guardrails first.** Write `AMITY/README.md` and `05-agent-guardrails/README.md`.
   These give the most value for the least effort, and they settle the ADO-tool conflict.
3. **Distill steering.** Write `AGENTS.md`, `04-standards/coding-standards.md`, a scoped
   `coding-standards.instructions.md`, and reduce `copilot-instructions.md` to a pointer.
   Settle the .NET version in one place.
4. **Standards set.** Write `git-workflow.md`, `testing-strategy.md`, `work-item-standards.md`,
   and `documentation-standards.md` (as a pointer to AMITY 08/12).
5. **ADRs.** Set up the template and home (D2), migrate or link the 4 existing records,
   and port the `create-adr` skill.
6. **Definition of Done.** Write `09-runbooks/definition-of-done.md`, plus an optional PR
   template.
7. **Optional enforcement.** Add `scripts/pre-merge.ps1` + the `run-pre-merge-checks` skill,
   an Architect agent, and DoR (D4/D5).
8. **Validate.** Run one real PR and one ADR end to end through the new docs with an agent.
   Confirm the agent cites the docs and does not restate rules from memory.

## 10. Risks

| Risk | Mitigation |
|---|---|
| Docs drift from code or pipeline (already happened with the .NET version) | One owner per fact. Steering only links. Add drift checks to `devops-pr-review` |
| Two ADR homes (wiki + AMITY) | D2: one home and a pointer in the other place |
| Product-only rules leak into other repos through `applyTo: '**'` in multi-root workspaces | Scope instructions narrowly. Keep product rules in folder-local steering. Verify the behaviour |
| Governance across many teams (who approves ADRs and standards) | Name approvers in `documentation-standards.md`. ADRs start as `Proposed` until approved |
| Brownfield coverage targets cannot be met | Measure coverage on new code only (Sonar new-code period) |
| Mirror overwrites | Commit to the ADO source repo (D8) |
| Docs get heavy, agents stop reading them | Keep documents small and focused (AMITY content principle). `AGENTS.md` ≤ 200 lines |
