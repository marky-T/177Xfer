# 14 — Use Cases (end-to-end)

Related: [Mechanisms & Catalog](./13-mechanisms-and-catalog.md) · [Skills](./05-skills.md) · [Instructions](./11-instructions.md) · [Memory](./06-memory.md) · [What Goes Where](./12-what-goes-where.md)

Worked scenarios that show the AMITY pieces — **agent + skill + instruction +
profile + MCP + memory** — cooperating. **Use Case A is built end-to-end** and is
the reference example; B–E are the target workflows.

## A — Online transaction defect  *(flagship — built)*

**Trigger:** "after a screen switch the field comes back empty."

1. The engineer selects the **AMT Debug (Online)** agent
   (`amt-go-net/.github/agents/amt-debug-online.agent.md`). Its **tool set** keeps
   the session focused on `amt-config` + `amt-script` + `net-debug` +
   `lion-repository`.
2. The agent follows the **`debug-transaction-server`** skill and **resolves the
   target from the profile** — `Federale_Migration/amity.project.json` ->
   `runtime.applications[]` (`AFBUS_AMT`, `WorkingAfbusTransactionServer`,
   `debugPort`, `sysIni`, `controllerPool`).
3. **Instructions apply automatically:** `lion-repository-mcp` (never parallel),
   `amt-tooling` (pool-down check), `amity-memory` (session context).
4. Stop controller → start in debug → `net-debug` attaches → breakpoints in the
   generated C# → reproduce → `inspect_amt`.
5. Root cause found; the **fix-upstream rule** blocks editing generated code and
   points to the Lion/COBOL source or generation settings.
6. **Capture:** a durable finding goes to `continuity.md` (project) or, if generic,
   `refine-memory` promotes it into a skill/instruction.

**Pieces exercised:** agent · toolset · skill · profile · 3 instructions · 4 MCP
servers · memory · refine. *This is the full stack in one flow.*

## B — Batch job failure

Select **AMT Debug (Batch)** → the **`debug-batch`** skill → target from
`runtime.batch[]` in the manifest → `amt-script` (job) + `amt-config` (batch
controller) + `net-debug` → root cause → upstream fix → capture. *(skill + agent
planned.)*

## C — Generation errors after the nightly regen

The **`cobol-generator-error-analysis`** project skill parses the filtered log,
builds minimal repros, confirms the errors, and raises a **Federale ADO issue**
(via the `ado` MCP). If the defect is a product-level generator bug,
**`issue-to-product-story`** raises the linked AMT_Products item. A one-line note
lands in `continuity.md`.

**Pieces:** project skill · ADO MCP · cross-project promotion · memory.

## D — New-engineer onboarding

Open the `Federale.code-workspace`. **Instructions auto-load** and pull in
`amity.project.json` + `continuity.md` (the engineer inherits the team brain).
The **`install-amt-mcp-servers`** skill wires the MCP servers. The engineer is
productive without tribal knowledge.

**Pieces:** instructions (passive load) · memory · skill · manifest.

## E — Close a ticket / capture knowledge

At the end of a session: *"update AMITY with these findings"* → a reviewed
one-line fact in `continuity.md`. If it is a repeatable procedure or a recurring
pattern, **`refine-memory`** promotes it into a skill (via `author-amity-skill`),
leaving a pointer. Generic findings route to `amt-go-net`; project findings stay.

**Pieces:** memory write · refine-memory · author-amity-skill · the two-layer split.

## What each use case proves

| Use case | Proves |
|---|---|
| A | agent + skill + profile + instructions + MCP + memory compose into one workflow |
| B | the same pattern generalises to another task (batch) with just a new skill + profile |
| C | project skills + ADO MCP + project→product promotion |
| D | passive instruction load + shared memory = zero-friction onboarding |
| E | the learning loop: finding → memory → skill |
