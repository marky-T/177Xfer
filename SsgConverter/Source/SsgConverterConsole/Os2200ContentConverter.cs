using System;
using System.Collections.Generic;
using Avanade.LtCoE.MigSupport;
using Ecl.Parser;
using Ecl.Parser.Os2200;
using Ecl.SsgConverter;
using Ecl.ToAst;
using Ecl.ToAst.Os2200;
using PowerShell.Generator;

namespace SsgConverterConsole {

  /// <summary>
  /// Converts non-directive content lines (embedded ECL/SQL) found within SSG templates
  /// by running them through the OS2200 ECL lexer/parser/migrator pipeline.
  /// </summary>
  public sealed class Os2200ContentConverter : IContentLineConverter {

    private IMigLogger m_LogObject;
    private ScriptLanguageVocabulary m_Vocabulary;
    private EclConversionOptions m_Options;

    public Os2200ContentConverter (IMigLogger logObject) {
      m_LogObject = logObject;
      m_Vocabulary = new ScriptLanguageVocabulary(EclTarget.Powershell);
      m_Options = new EclConversionOptions(true, false, new List<String>(), new List<String>());
    }

    public PsAstInstrBlock Convert (IReadOnlyList<String> lines, String containingFile) {
      if (lines == null || lines.Count == 0) { return null; }

      // Replace leading #'s with @'s (SSG uses # as ECL prefix instead of @)
      // but not inside IPF sessions
      Boolean inIpf = false;
      List<String> eclLines = new List<String>(lines.Count);
      foreach (String line in lines) {
        if (line.StartsWith("LOGOFF", StringComparison.OrdinalIgnoreCase)) {
          inIpf = false;
        }

        if (line.StartsWith("#") && !inIpf) {
          eclLines.Add(line.Length > 1 ? "@" + line.Substring(1) : "@");
        } else {
          eclLines.Add(line);
        }

        if (line.StartsWith("#IPF") && (line.Length == 4 || !Char.IsLetter(line[4]))) {
          inIpf = true;
        }
      }

      // Parse through ECL pipeline
      EclParserOs2200 parser = new EclParserOs2200(m_LogObject);
      EclObjectOs2200 eclObject;
      try {
        eclObject = parser.Parse(eclLines, EclObjectType.Runstream);
      } catch (Exception ex) {
        m_LogObject.Warning(0, String.Format("ECL parse failed for content block in '{0}': {1} — content skipped.", containingFile, ex.Message));
        return null;
      }

      if (eclObject.Statements.Count == 0) { return null; }

      // Migrate to PowerShell AST
      PsAstClass psClass = new PsAstClass();
      EclMigrateSummaryOs2200 summary = new EclMigrateSummaryOs2200();
      summary.InitSummary(false, String.Empty);
      EclMigrateOs2200 migrator = new EclMigrateOs2200(m_Vocabulary, psClass, m_LogObject, m_Options, summary, eclObject);
      try {
        migrator.MigrateStatements();
      } catch (Exception ex) {
        m_LogObject.Warning(0, String.Format("ECL migration failed for content block in '{0}': {1} — content skipped.", containingFile, ex.Message));
        return null;
      }

      return psClass.Body;
    }
  }
}
