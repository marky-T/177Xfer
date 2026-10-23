using System;
using System.Diagnostics;
using Avanade.LtCoE.MigSupport;

namespace Ssg.ConverterGui {

  /// <summary>
  /// Log appender that dispatches log messages to the WPF UI.
  /// </summary>
  internal sealed class UiLogAppender : IMigLogAppender {

    private readonly MainWindow m_Window;
    private MigLogVerbose m_Verbose;
    private Boolean m_BlockLogging;

    /// <summary>
    /// Constructor
    /// </summary>
    /// <param name="window">Main window reference for dispatching</param>
    public UiLogAppender (MainWindow window) {
      m_Window = window;
    }

    /// <inheritdoc/>
    public Boolean BlockLogging { [DebuggerStepThrough()] get { return m_BlockLogging; } set { m_BlockLogging = value; } }

    /// <inheritdoc/>
    public MigLogVerbose Verbose { [DebuggerStepThrough()] get { return m_Verbose; } set { m_Verbose = value; } }

    /// <inheritdoc/>
    public void Start () { }

    /// <inheritdoc/>
    public void Phase (MigLogData data) {
      LogToUi(MigLogDataKind.Phase, data.Message);
    }

    /// <inheritdoc/>
    public void Log (MigLogData data) {
      if (m_Verbose >= MigLogVerbose.Normal) {
        LogToUi(MigLogDataKind.Log, data.Message);
      }
    }

    /// <inheritdoc/>
    public void Error (MigLogData data) {
      if (m_Verbose >= MigLogVerbose.Minimal) {
        LogToUi(MigLogDataKind.Error, data.Message);
      }
    }

    /// <inheritdoc/>
    public void Warning (MigLogData data) {
      if (m_Verbose >= MigLogVerbose.Normal) {
        LogToUi(MigLogDataKind.Warning, data.Message);
      }
    }

    /// <inheritdoc/>
    public void Todo (MigLogData data) {
      if (m_Verbose >= MigLogVerbose.Normal) {
        LogToUi(MigLogDataKind.Todo, data.Message);
      }
    }

    /// <inheritdoc/>
    public void Debug (MigLogData data) {
      if (m_Verbose >= MigLogVerbose.Diagnostic) {
        LogToUi(MigLogDataKind.Debug, data.Message);
      }
    }

    /// <inheritdoc/>
    public void Exception (MigLogData data) {
      String message = data.Message;
      if (data.ExtraObject is Exception ex) {
        message += Environment.NewLine + ex.ToString();
      }
      LogToUi(MigLogDataKind.Exception, message);
    }

    /// <inheritdoc/>
    public void Done (MigLogData data) {
      LogToUi(MigLogDataKind.Done, "Conversion finished.");
    }

    /// <inheritdoc/>
    public void StatusBar (MigLogData data) { }

    /// <inheritdoc/>
    public void Percentage (MigLogData data) { }

    /// <inheritdoc/>
    public void ThreadStarted (MigLogData data) { }

    /// <inheritdoc/>
    public void ThreadFinished (MigLogData data) { }

    private void LogToUi (MigLogDataKind kind, String message) {
      if (m_BlockLogging) { return; }
      m_Window.AddLogItem(new LogItem(kind, message));
    }

  }

}
