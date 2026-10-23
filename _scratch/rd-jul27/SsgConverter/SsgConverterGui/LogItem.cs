using System;
using System.Windows.Media;
using Avanade.LtCoE.MigSupport;

namespace Ssg.ConverterGui {

  /// <summary>
  /// Represents a single log entry displayed in the log list.
  /// </summary>
  internal sealed class LogItem {

    /// <summary>
    /// The kind of log message
    /// </summary>
    public MigLogDataKind DataKind { get; set; }

    /// <summary>
    /// The display text for the log entry
    /// </summary>
    public String DisplayText { get; set; }

    /// <summary>
    /// Color brush for the log entry based on severity
    /// </summary>
    public Brush Color {
      get {
        return DataKind switch {
          MigLogDataKind.Phase => Brushes.DodgerBlue,
          MigLogDataKind.Error => Brushes.Red,
          MigLogDataKind.Exception => Brushes.DarkRed,
          MigLogDataKind.Warning => Brushes.DarkOrange,
          MigLogDataKind.Todo => Brushes.Purple,
          MigLogDataKind.Debug => Brushes.Gray,
          _ => Brushes.Black
        };
      }
    }

    /// <summary>
    /// Constructor
    /// </summary>
    /// <param name="dataKind">Kind of message</param>
    /// <param name="message">Message text</param>
    public LogItem (MigLogDataKind dataKind, String message) {
      DataKind = dataKind;
      DisplayText = $"[{dataKind,-10}] {message}";
    }

  }

}
