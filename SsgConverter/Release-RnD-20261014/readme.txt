Date: 2026-10-14. From the SSG-4 trial team. Read CHANGELIST.md first.

Purpose:
  Source changes to the stand-alone SsgConverter (SSG to PowerShell), made on top of R&D's
  27 July source (SsgConverter Jul27 from AMT178release.zip).

Contents:
  readme.txt                     - this file
  CHANGELIST.md                  - the 18 changes C-01..C-18 (origin, reason, evidence), the
                                   test evidence, questions for R&D (section 4) and the next
                                   updates (section 5)
  SsgConverter-vs-develop.patch  - the same changes as a patch against R&D develop
  Migration Tools/SsgConverter/  - the 7 changed files, at R&D's paths:
    SsgConverter/                - SymstreamProcessor.cs, SymstreamExpressionMigrator.cs,
                                   SymstreamExpressionParser.cs  (library)
    SsgConverterConsole/         - Os2200ContentConverter.cs, Program.cs
    SsgConverterGui/             - App.xaml.cs, MainWindow.xaml.cs

Not included:
  - the .csproj files
  - the ECL converter: not changed, but linked to the SsgConverter. The SsgConverterConsole
    project references EclParserOs2200 and EclToAstOs2200, and the ECL converter references the
    SsgConverter library project
  - the example skeletons and their converted output (they come from customer source);
    the regression results are summarised in CHANGELIST.md section 3

Workflow:
  1. Take the changes, either way:
       - copy the 7 files from Migration Tools/SsgConverter/ over the same paths in your tree, or
       - from Migration Tools/SsgConverter in your tree run:
           git apply -p1 --ignore-whitespace <path to this folder>/SsgConverter-vs-develop.patch
     The files use CRLF line endings. Applying the patch to a copy of develop reproduces the
     7 files byte for byte.
  2. Build the SsgConverter library (and console / GUI) as usual. The ECL converter references
     the SsgConverter library project, so it picks the changes up on its next build.
  3. Convert your SSG files again. Expect: files that failed with "DirectiveId: End" now convert;
     output (data) lines are literal text; blank lines in a skeleton are now written to the
     output (CHANGELIST.md, "Blank lines").
  4. Record questions and decisions on the points in CHANGELIST.md sections 4 and 5.

Note:
  Treat the changes marked B in the 'Origin' column of the changes table (CHANGELIST.md, C-06 to
  C-12) with care: they are not described in any earlier fix log.
