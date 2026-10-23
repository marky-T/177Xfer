using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using Avanade.LtCoE.MigSupport;
using Ecl.SsgConverter;
using PowerShell.Generator;
using PowerShellWriter;

namespace SsgConverterConsole {

  /// <summary>
  /// Console entry point for the SSG to PowerShell converter.
  /// Reads SSG source files (collected by the ECL converter) and converts them to PowerShell scripts.
  /// </summary>
  public sealed class Program {

    private Program () { }

    public static Int32 Main (String[] args) {
      Environment.ExitCode = 1;

      if (args == null || args.Length == 0) {
        WriteHelp();
        return Environment.ExitCode;
      }

      SsgConversionSettings settings = SsgSettingsSupport.ReadStartupArguments(args);

      if (String.IsNullOrEmpty(settings.InputFolder)) {
        Console.WriteLine("ERROR: Please specify input folder with /INPUT:<path>");
        return Environment.ExitCode;
      }
      if (String.IsNullOrEmpty(settings.OutputFolder)) {
        Console.WriteLine("ERROR: Please specify output folder with /OUTPUT:<path>");
        return Environment.ExitCode;
      }
      if (!Directory.Exists(settings.InputFolder)) {
        Console.WriteLine($"ERROR: Input folder does not exist: {settings.InputFolder}");
        return Environment.ExitCode;
      }

      return RunConversion(settings) ? 0 : 1;
    }

    /// <summary>
    /// Run the SSG conversion with the given settings and logger.
    /// Extracted so both the console and GUI can call it.
    /// </summary>
    /// <param name="settings">Conversion settings</param>
    /// <param name="logger">Optional logger (if null, a console logger is created)</param>
    /// <returns>True if all conversions succeeded</returns>
    public static Boolean RunConversion (SsgConversionSettings settings, IMigLogger logger = null) {
      Boolean ownLogger = logger == null;

      if (ownLogger) {
        logger = new MigLogger();
        ConsoleLogAppender logAppender = new ConsoleLogAppender();
        logAppender.Verbose = (MigLogVerbose)settings.VerboseLevel;
        logger.AddAppender(logAppender);
      }

      // Add file log appender if enabled
      if (settings.EnableLogFile && !String.IsNullOrEmpty(settings.LogFile)) {
        String logPath = settings.LogFile;
        if (Directory.Exists(logPath) || !Path.HasExtension(logPath)) {
          logPath = Path.Combine(logPath, $"SsgConversion_{DateTime.Now:yyyyMMdd_HHmmss}.log");
        }
        String logDir = Path.GetDirectoryName(logPath);
        if (!String.IsNullOrEmpty(logDir) && !Directory.Exists(logDir)) {
          Directory.CreateDirectory(logDir);
        }
        MigFileAppender fileAppender = new MigFileAppender(logPath);
        fileAppender.Verbose = MigLogVerbose.Normal;
        logger.AddAppender(fileAppender);
      }

      if (ownLogger) {
        logger.Start(1);
        logger.ThreadStarted(0);
      }

      try {
        logger.Phase(0, "SSG to PowerShell Converter");
        logger.Log(0, $"Input folder : {settings.InputFolder}");
        logger.Log(0, $"Output folder: {settings.OutputFolder}");

        // Ensure output folder exists
        if (!Directory.Exists(settings.OutputFolder)) {
          Directory.CreateDirectory(settings.OutputFolder);
        }

        // Clear output if requested
        if (settings.ClearOutputFolder && Directory.Exists(settings.OutputFolder)) {
          foreach (String file in Directory.GetFiles(settings.OutputFolder, "*.ps1")) {
            File.Delete(file);
          }
        }

        // Collect SSG source files (pick up all files in the folder — the folder should only contain SSG sources)
        String[] ssgFiles = Directory.GetFiles(settings.InputFolder, "*.*", SearchOption.TopDirectoryOnly);
        logger.Log(0, $"SSG source files found: {ssgFiles.Length}");

        if (ssgFiles.Length == 0) {
          logger.Warning(0, "No SSG files found in the input folder.");
          return true;
        }

        // Create processor
        Os2200ContentConverter contentConverter = new Os2200ContentConverter(logger);
        SymstreamProcessor processor = new SymstreamProcessor(logger, contentConverter);

        Int32 successCount = 0;
        Int32 errorCount = 0;

        foreach (String ssgFile in ssgFiles) {
          String fileName = Path.GetFileNameWithoutExtension(ssgFile);
          try {
            IReadOnlyList<String> lines = File.ReadAllLines(ssgFile);

            // Skip files that don't look like SSG (first non-empty line should start with # or *)
            if (!LooksLikeSsg(lines)) {
              logger.Warning(0, $"  Skipped (not SSG): {Path.GetFileName(ssgFile)}");
              continue;
            }

            // Convert SSG to PowerShell AST
            PsAstInstrBlock block = processor.Convert(lines, fileName);

            // Write AST to PowerShell text
            PowerShellAstWriter writer = new PowerShellAstWriter();
            block.Visit(writer);
            StringBuilder source = writer.Source();

            // Add header
            StringBuilder output = new StringBuilder();
            output.AppendLine("# Converted from SSG source: " + fileName);
            output.AppendLine("# Generated by SsgConverter");
            output.AppendLine("param([string[]]$Parameters)");
            output.AppendLine();
            output.Append(source);

            // Write output file
            String outputPath = Path.Combine(settings.OutputFolder, fileName + ".ps1");
            File.WriteAllText(outputPath, output.ToString());

            successCount++;
            logger.Debug(0, $"  Converted: {fileName}");
          } catch (Exception ex) {
            errorCount++;
            logger.Error(0, $"  Error converting {fileName}: {ex.Message}");
            if (!settings.ContinueOnException) {
              break;
            }
          }
        }

        logger.Log(0, String.Empty);
        logger.Log(0, $"Conversion complete: {successCount} succeeded, {errorCount} failed");

        return errorCount == 0;
      } catch (Exception ex) {
        logger.Error(0, ex.Message);
        return false;
      }
    }

    private static void WriteHelp () {
      Console.WriteLine("SSG Converter - Converts SSG (Symbiont Stream Generator) source to PowerShell scripts");
      Console.WriteLine();
      Console.WriteLine("Usage:");
      Console.WriteLine("  /INPUT:<path>              - Input folder containing SSG source files");
      Console.WriteLine("  /OUTPUT:<path>             - Output folder for generated .ps1 scripts");
      Console.WriteLine("  /SETTINGSFILE:<path>       - Load settings from XML file");
      Console.WriteLine("  /CLEAROUTPUT:TRUE|FALSE    - Clear output folder before conversion");
      Console.WriteLine("  /CONTINUEONERROR:TRUE|FALSE- Continue when a file fails");
      Console.WriteLine("  /VERBOSE:<0-3>             - Verbose level (0=Minimal, 3=Diagnostic)");
      Console.WriteLine("  /LOGFILE:<path>            - Log file path");
      Console.WriteLine("  /ENABLELOGFILE:TRUE|FALSE  - Enable log file output");
      Console.WriteLine();
      Console.WriteLine("Example:");
      Console.WriteLine("  SsgConverterConsole /INPUT:\"Output\\SsgSource\" /OUTPUT:\"Output\\Ssg\"");
      Console.WriteLine("  SsgConverterConsole /SETTINGSFILE:\"MySsg.settings\"");
    }

    private static Boolean LooksLikeSsg (IReadOnlyList<String> lines) {
      Int32 linesToCheck = Math.Min(lines.Count, 20);
      for (Int32 i = 0; i < linesToCheck; i++) {
        String trimmed = lines[i].TrimStart();
        if (trimmed.Length == 0) { continue; }
        if (trimmed[0] == '#' || trimmed[0] == '*') { return true; }
      }
      return false;
    }

  }

}
