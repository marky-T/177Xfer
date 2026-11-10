using System;
using System.Diagnostics;
using Avanade.LtCoE.MigSupport;

namespace SsgConverterConsole {

  /// <summary>
  /// Console log appender for the ECL converter.
  /// </summary>
  internal sealed class ConsoleLogAppender : IMigLogAppender {

    private MigLogVerbose m_Verbose;
    private Boolean m_BlockLogging;

    /// <summary>
    /// Block logging
    /// </summary>
    public Boolean BlockLogging { [DebuggerStepThrough()] get { return m_BlockLogging; } set { m_BlockLogging = value; } }

    /// <summary>
    /// Verbose level
    /// </summary>
    public MigLogVerbose Verbose { [DebuggerStepThrough()] get { return m_Verbose; } set { m_Verbose = value; } }

    public void Error (MigLogData data) {
      Console.ForegroundColor = ConsoleColor.Red;
      LogMessage("--Error: " + data.Message);
      Console.ResetColor();
    }

    public void Exception (MigLogData data) {
      if (m_Verbose >= MigLogVerbose.Quiet) {
        Console.ForegroundColor = ConsoleColor.Red;
        LogMessage("--Exception: " + data.Message);
        if (data.ExtraObject is Exception exception) {
          LogMessage(exception.Message);
          String[] lines = exception.ToString().Split(Environment.NewLine);
          foreach (String line in lines) {
            LogMessage(line);
          }
        }
        Console.ResetColor();
      }
    }

    public void Log (MigLogData data) {
      if (m_Verbose >= MigLogVerbose.Quiet) {
        Console.ForegroundColor = ConsoleColor.White;
        LogMessage(data.Message);
        Console.ResetColor();
      }
    }

    public void Warning (MigLogData data) {
      if (m_Verbose >= MigLogVerbose.Quiet) {
        Console.ForegroundColor = ConsoleColor.Yellow;
        LogMessage("--Warning: " + data.Message);
        Console.ResetColor();
      }
    }

    public void Debug (MigLogData data) {
      if (m_Verbose >= MigLogVerbose.Diagnostic) {
        Console.ForegroundColor = ConsoleColor.Gray;
        LogMessage(data.Message);
        Console.ResetColor();
      }
    }

    public void Phase (MigLogData data) {
      Console.ForegroundColor = ConsoleColor.Cyan;
      LogMessage("=== " + data.Message + " ===");
      Console.ResetColor();
    }

    public void Todo (MigLogData data) {
      if (m_Verbose >= MigLogVerbose.Quiet) {
        Console.ForegroundColor = ConsoleColor.Magenta;
        LogMessage("--Todo: " + data.Message);
        Console.ResetColor();
      }
    }

    public void Done (MigLogData data) {
      LogMessage("Done.");
    }

    public void Start () { }
    public void StatusBar (MigLogData data) { }
    public void Percentage (MigLogData data) { }
    public void ThreadStarted (MigLogData data) { }
    public void ThreadFinished (MigLogData data) { }

    private void LogMessage (String message) {
      if (!m_BlockLogging) {
        Console.WriteLine(message);
      }
    }

  }

}
