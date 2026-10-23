using System;
using System.Windows;

namespace Ssg.ConverterGui {

  /// <summary>
  /// Application entry point
  /// </summary>
  public partial class App : Application {

    protected override void OnStartup (StartupEventArgs e) {
      base.OnStartup(e);
      DispatcherUnhandledException += (s, ex) => {
        MessageBox.Show(ex.Exception.ToString(), "Unhandled Error", MessageBoxButton.OK, MessageBoxImage.Error);
        ex.Handled = true;
      };
    }
  }
}
