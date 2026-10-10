---
description: "Federale OS 2200 Phase 1 forensic migration workflow for ECL, SSG, COBOL and AMT converter analysis. Use this prompt before analysing or modifying Federale conversion behaviour."
---

# Federale OS 2200 Phase 1 — Forensic Migration Prompt

You are assisting with the **Federale OS 2200 → AMT migration**.

Your objective is to preserve the **original intended behaviour** of the Federale ECL, SSG and COBOL programs when converting them to:

```text
C#
PowerShell
AMT libraries
AMT Control Center


Do not treat the existing converters or their generated C#/PowerShell as the definition of correct behaviour.

Evidence Hierarchy

Use evidence in this order:

Official Unisys OS 2200 manuals
Actual Federale ECL / SSG / COBOL source
Actual Federale runstreams and invocation evidence
Existing ECL / SSG / COBOL converter implementation
Existing internal documentation
Explicitly labelled inference

For every important semantic conclusion classify it as:

PROVEN_BY_UNISYS_MANUAL
OBSERVED_IN_FEDERALE_SOURCE
DERIVED_WORKING_MODEL
ASSUMPTION
UNKNOWN


Never silently convert an assumption into a fact.

If evidence is insufficient, use:

UNKNOWN


or:

ASSUMPTION


Do not invent missing Unisys behaviour.

Evidence Citation Rule

For claims about OS 2200 behaviour, record:

Manual
Edition / Release
Section
Page
Relevant statement
Confidence


For Federale-specific behaviour record:

Source file
Source location
Relevant statement
Confidence


Do not invent page numbers.

Current Working Execution Model

IMPORTANT

This is a research-derived engineering model.

It is NOT a diagram copied from a Unisys manual.

Every transition must ultimately be supported by official Unisys documentation or actual Federale source evidence.

SSG Skeleton / Symstream
        |
        v
SSG Interpreter
        |
        | generation-time processing
        |
        | *SET
        | *DEFINE
        | *PROCESS
        | *INCREMENT
        | SGS references
        | variable substitution
        |
        v
Generated Symbolic Stream
        |
        +----------------------+
        |                      |
        v                      v
Generated COBOL          Generated ECL
        |                      |
        +----------+-----------+
                   |
                   v
             COBOL BUILD
                   |
          +--------+--------+
          |                 |
          v                 v

        ACOB              UCOB
          |                 |
          v                 v
    Relocatable           Object
      Element             Module
          |
          v
         MAP
          |
          v
    Absolute Element

          \                 /
           +-------+-------+
                   |
                   v
                  XQT
                   |
                   v
            Program Runtime
                   |
                   v
       COBOL OPEN / READ /
          PROCESS / WRITE
                   |
                   v
        Business Output Files

Critical Architecture Rule

Do NOT assume the lifecycle is:

SSG
→ UCOB
→ MAP
→ ACOB
→ Execute


The current evidence indicates that this is incorrect.

Treat the following as separate working compiler paths unless program-specific evidence proves otherwise.

ACOB Path
COBOL
  ↓
ACOB
  ↓
Relocatable Element
  ↓
MAP
  ↓
Absolute Element
  ↓
XQT

UCOB Path
COBOL
  ↓
UCOB
  ↓
Object Module
  ↓
Applicable Link / Load / Execution Mechanism
  ↓
XQT


Current working interpretation:

ACOB = COBOL compiler

UCOB = COBOL compiler

MAP = collection / linking stage

XQT = execution boundary


Do NOT assume:

UCOB → MAP


is mandatory.

Do NOT model:

MAP → ACOB → execution


unless official evidence for the specific program proves it.

Mandatory Generation-Time vs Runtime Separation

Always determine when a construct operates.

Use these stages:

SSG_GENERATION_TIME

GENERATED_ECL

GENERATED_COBOL

COMPILATION

COLLECTION_OR_LINKING

FILE_RESOURCE_BINDING

PROGRAM_EXECUTION

BUSINESS_RUNTIME

SSG Generation-Time Behaviour

Examples include:

*SET
*DEFINE
*PROCESS
*INCREMENT
SGS lookup
variable substitution
conditional generation
generated COBOL
generated ECL


These operations affect what source or runstream is generated.

Do NOT automatically convert SSG variables into runtime C# or PowerShell variables.

Always ask:

Does this happen while SSG constructs the symbolic stream, or when the generated program executes?

Runtime Behaviour

Examples include COBOL operations such as:

OPEN
READ
MOVE
COMPUTE
WRITE
CLOSE


These belong to the executing business program.

Do not confuse them with SSG generation behaviour.

# Statement Rule

Federale SSG source may contain:

#UCOB
#ACOB
#MAP
#XQT


Do NOT assume these are independent commands literally named:

#UCOB
#ACOB
#MAP
#XQT


The current manual-backed working model indicates that SSG can transform a leading:

#


into:

@


in generated output under the applicable SSG sign-character configuration.

Therefore:

#ACOB


may generate:

@ACOB


and:

#XQT


may generate:

@XQT


Do NOT implement this as an unconditional:

# → @


text replacement.

Reproduce the actual SSG semantics.

File Assignment Model

Keep these concepts separate:

SSG-generated filename

logical/internal program filename

physical OS 2200 file/resource


Current working model:

ASG
 ↓
Assigned File / Resource
 ↓
USE
 ↓
Internal / Logical Filename
 ↓
XQT
 ↓
Executing Program
 ↓
OPEN / READ / WRITE


Do not confuse:

resource assignment


with:

business file I/O

Generation-Time File Resolution

SSG may generate something conceptually equivalent to:

SELECT FILEIN ASSIGN TO DISC SOME-NAME


where:

SOME-NAME


was obtained from an SGS parameter.

That is:

GENERATION-TIME SUBSTITUTION

Runtime File Resolution

ECL may subsequently associate the logical/internal filename with an assigned physical resource.

That is:

RUNTIME FILE BINDING


Therefore do NOT automatically treat:

SSG parameter resolution


and:

physical file resolution


as the same operation.

Migration Principle

Do NOT mechanically translate every OS 2200 command into a PowerShell function.

Commands such as:

@ASG
@USE
@MAP
@XQT


represent OS 2200 facilities.

Determine their semantic responsibility first.

The AMT implementation may reproduce those semantics through:

AMT libraries
Control Center
.NET runtime behaviour
PowerShell orchestration
generated C#


The target implementation does not need to look syntactically like OS 2200.

It needs to reproduce the required observable behaviour.

Reference Oracle Principle

Never use the existing converters as the definition of correctness.

Incorrect:

Converter Output
      ↓
Assume Output Is Correct
      ↓
Test Converter Against Itself


Correct:

Official Unisys Manuals
        +
Actual Federale Source
        |
        v
Independent Semantic Reconstruction
        |
        v
Reference Implementation
        |
        v
Known Expected Behaviour


The independent implementation becomes the:

REFERENCE ORACLE

Differential Validation Model

Run two independent paths using identical inputs.

                 IDENTICAL INPUTS
                       |
            +----------+----------+
            |                     |
            v                     v

     Reference Oracle       Converter Pipeline
            |                     |
            |              ECL Converter
            |              SSG Converter
            |              COBOL Converter
            |                     |
            |                     v
            |               C# / PS1 /
            |               AMT Libraries
            |                     |
            |                     v
            |              AMT Control Center
            |                     |
            +----------+----------+
                       |
                       v
              Differential Compare


Both paths must receive equivalent:

parameters
mocked files
record layouts
logical bindings
test conditions

What Must Be Compared

Do NOT test only:

Did it run?

Generation Behaviour

Compare:

resolved parameters
field counts
field offsets
field widths
generated structures
generated program calls
logical filenames
generated execution instructions

Runtime Behaviour

Compare:

input records consumed
output records produced
record lengths
field values
unchanged bytes
output file creation
exit status
errors
relevant logs

Intermediate Behaviour

Where practical compare:

generation manifest
file-binding trace
program invocation trace
record-processing trace

Initial Reference Program

Use:

ASSURFED_UTILIT_MONTANT_SIGNE(P).TXT


as the initial proving candidate unless stronger source evidence identifies a better program.

It is useful because it exercises:

SSG parameters
*DEFINE
*SET
*INCREMENT
generated COBOL
generated record layouts
field offsets
field widths
input/output files
UCOB compilation
runtime record processing


This allows:

SSG generation correctness


to be tested separately from:

COBOL runtime correctness

MONTANT_SIGNE Working Flow
SSG Parameters
     |
     +-- INPUT
     +-- OUTPUT
     +-- MONTANT
     |
     v
SSG Generation
     |
     +-- calculate filler lengths
     +-- calculate field positions
     +-- generate COBOL declarations
     +-- generate amount overlays
     |
     v
Generated COBOL
     |
     v
UCOB
     |
     v
Runtime Program
     |
     v
XQT
     |
     v
OPEN INPUT
OPEN OUTPUT
     |
     v
READ RECORD
     |
     v
COPY RECORD
     |
     v
PROCESS CONFIGURED
AMOUNT FIELDS
     |
     v
WRITE RECORD
     |
     v
REPEAT
     |
     v
CLOSE FILES


Treat this as a working model until every transition is verified.

Reference Implementation Structure

Build the reference independently of the production converters.

Suggested structure:

Reference/
|
+-- Parameters/
|   +-- SsgParameterModel
|
+-- Generation/
|   +-- SsgGenerationModel
|   +-- GenerationManifest
|
+-- Files/
|   +-- LogicalFileBinding
|   +-- FixedRecordReader
|   +-- FixedRecordWriter
|
+-- CobolSemantics/
|   +-- SignedDisplayCodec
|   +-- RecordOverlay
|
+-- Runtime/
|   +-- MontantReferenceProgram
|
+-- Tests/
    +-- MockInputs
    +-- ExpectedOutputs
    +-- DifferentialTests


These names are implementation suggestions.

They are NOT Unisys terminology.

Generation Manifest

The reference implementation should produce a machine-readable description of the resolved SSG model.

Example only:

{
  "program": "MONTANT",
  "input": {
    "logicalName": "FILEIN",
    "recordLength": 80
  },
  "output": {
    "logicalName": "FILEOUT",
    "recordLength": 80
  },
  "amountFields": [
    {
      "offset": 10,
      "length": 8
    },
    {
      "offset": 30,
      "length": 8
    }
  ]
}


The values above are examples only.

Never copy example values into implementation logic unless they are proven from actual Federale source or parameters.

Converter Responsibilities
SSG Converter

Responsible for reproducing:

parameter resolution
SGS lookup
variable evaluation
conditional generation
iteration
process expansion
generated source
generated ECL


Do NOT automatically convert every SSG variable into a runtime PowerShell variable.

ECL Converter

Responsible for reproducing the intent of:

resource assignment
logical file binding
execution ordering
program invocation
status handling
cleanup


AMT equivalents may replace literal OS 2200 commands.

COBOL Converter

Responsible for reproducing:

record layouts
REDEFINES
numeric representation
OPEN
READ
WRITE
EOF behaviour
business calculations
record preservation

AMT Libraries

Before creating new C#, PowerShell or runtime emulation:

Search existing AMT libraries.
Search existing project assets.
Search existing reusable converter functionality.
Determine whether equivalent behaviour already exists.
Reuse existing functionality where semantics genuinely match.

Do not create custom emulation before checking existing AMT capability.

Mandatory Investigation Workflow

Before modifying any converter:

Step 1 — Identify Source

Identify the exact original Federale construct.

Record:

source file
source location
surrounding context

Step 2 — Classify Execution Stage

Classify the construct as one or more of:

SSG_GENERATION_TIME
GENERATED_ECL
GENERATED_COBOL
COMPILATION
COLLECTION_OR_LINKING
FILE_RESOURCE_BINDING
PROGRAM_EXECUTION
BUSINESS_RUNTIME

Step 3 — Establish Evidence

For every semantic claim produce:

Claim	Evidence Classification	Source	Manual/Page or Federale Location	Confidence

Do not invent evidence.

Step 4 — Describe Original Behaviour

Describe only behaviour supported by evidence.

Separate:

PROVEN
OBSERVED
DERIVED
ASSUMED
UNKNOWN

Step 5 — Inspect Current Converter

Determine what the converter currently produces.

Do NOT assume that output is correct.

Step 6 — Compare Semantics

Compare:

ORIGINAL INTENDED BEHAVIOUR


against:

CURRENT CONVERTER BEHAVIOUR


Identify the smallest semantic difference.

Step 7 — Check Existing AMT Capability

Before implementing anything new, search for reusable:

AMT libraries
C# helpers
PowerShell helpers
converter components
runtime services
existing tests

Step 8 — Compare Against Oracle

Use the independent reference implementation.

Run identical:

parameters
mock files
bindings
test conditions

Step 9 — Classify Difference

Use exactly one primary classification:

NO_CHANGE_REQUIRED

CONVERTER_DEFECT

AMT_PLATFORM_ADAPTATION

UNSUPPORTED_SOURCE_CONSTRUCT

REFERENCE_IMPLEMENTATION_DEFECT

UNRESOLVED_UNISYS_SEMANTIC

FEDERALE_SOURCE_AMBIGUITY

Step 10 — Propose Smallest Change

Do not perform a broad rewrite.

Prefer:

small
reversible
testable
auditable
isolated


changes.

Define tests before implementation.

Mock Test Set

Use synthetic fixed-width records.

Do not use production-sensitive data.

Minimum tests:

Test	PurposeBaseline	Normal record transformation
Multiple fields	Verify repeated generated overlays
Zero	Verify zero representation
Negative	Verify signed representation
Boundary width	Verify maximum field width
Invalid numeric	Verify deterministic failure
Empty file	Verify EOF behaviour
Generation variation	Change SGS parameters and verify generated model changes
Binding variation	Change physical file while logical model remains unchanged
Invalid offset	Verify generation-time validation
Difference Handling

Never silently change expected output to make the converter pass.

Every mismatch must be investigated.

Possible classifications:

CONVERTER_DEFECT

AMT_PLATFORM_ADAPTATION

UNSUPPORTED_SOURCE_CONSTRUCT

REFERENCE_IMPLEMENTATION_DEFECT

UNRESOLVED_UNISYS_SEMANTIC

FEDERALE_SOURCE_AMBIGUITY

Open Evidence Items

Do not invent answers for these.

XQT

Authoritative evidence is still required for:

parameter passing
completion behaviour
synchronous/asynchronous semantics
return/status behaviour

COBOL Signed Numeric Representation

Authoritative Unisys COBOL evidence is required for:

signed DISPLAY
sign / overpunch representation
positive values
negative values
zero


Do not invent the codec.

MONTANT_SIGNE Production Invocation

Still required:

actual @SSG invocation
SGS parameter block
INPUT parameters
OUTPUT parameters
MONTANT parameters
ASG / USE bindings


Controlled test parameters may be used for the reference oracle, but they must be labelled as test data.

Platform Version

Establish the actual Federale:

OS 2200 release
SSG version
COBOL compiler/version


Version-sensitive behaviour must be checked against the appropriate official manual.

Implementation Guardrails

Do NOT:

rewrite large converter areas without evidence

infer Unisys behaviour from generated PowerShell

invent missing runtime semantics

hard-code example values

merge generation-time and runtime behaviour

assume ACOB executes programs

assume UCOB always requires MAP

replace unknown behaviour with plausible .NET behaviour

create new AMT emulation before checking existing libraries

change expected test output merely because the converter differs

Required Analysis Output

When investigating a construct, return:

## Source

File:
Location:
Construct:

## Execution Stage

Classification:

## Evidence

| Claim | Classification | Source | Location | Confidence |
|---|---|---|---|---|

## Original Intended Behaviour

...

## Current Converter Behaviour

...

## Semantic Difference

...

## Existing AMT / Reusable Capability

...

## Reference Oracle Behaviour

...

## Classification

...

## Recommended Change

...

## Tests Required

...

## Remaining Unknowns

...

Definition of Done

A migrated program is NOT proven merely because:

conversion completed

C# compiled

PowerShell executed

Control Center launched the program


A program is proven when:

Relevant original semantics are understood.
Official manual evidence exists where applicable.
Actual Federale source behaviour is understood.
Assumptions are explicitly recorded.
An independent reference implementation exists.
Mocked inputs produce deterministic expected outputs.
Converter-generated output runs in AMT Control Center.
Reference and converted paths receive equivalent inputs.
Observable outputs match.
Remaining differences are explained and classified.
Core Principle

Always work in this direction:

Official Unisys Semantics
        ↓
Federale Source Behaviour
        ↓
Independent Reference Behaviour
        ↓
Converter Behaviour
        ↓
AMT Control Center Behaviour


Never reverse the evidence chain into:

Current Converter Behaviour
        ↓
Assumed Original Behaviour


The reference oracle exists specifically to prevent that mistake.

Start Every Investigation With This Question

What did the original Federale program actually do, at which execution stage did it do it, and what evidence proves that behaviour?

Only after answering that question should converter implementation be changed.


### Save as

For a **direct GitHub Copilot prompt file**, save it as:

```text
.github/
└── prompts/
    └── federale-os2200-phase1.prompt.md


Then invoke it from Copilot Chat as the Federale OS 2200 Phase 1 prompt.

For your existing gated workflow, I would keep the full pack there and keep .github/copilot-instructions.md much smaller, with the permanent instruction simply requiring this prompt whenever work touches:

ECL
SSG
Symstream
COBOL
UCOB
ACOB
MAP
XQT
AMT converter behaviour