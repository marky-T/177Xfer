using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.IO;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using Avanade.LtCoE.MigSupport;
using Microsoft.Win32;
using SsgConverterConsole;

namespace Ssg.ConverterGui {

  /// <summary>
  /// Main window for the SSG Converter GUI.
  /// Layout: Settings (top) → Convert button + log filter (middle) → Log output (bottom)
  /// </summary>
  public partial class MainWindow : Window {

    private ObservableCollection<LogItem> m_LogItems;
    private Boolean m_IsConverting;

    /// <summary>
    /// Constructor
    /// </summary>
    public MainWindow () {
      InitializeComponent();
      InitializeControls();
      // load settings from command-line arg after controls are ready
      String[] args = Environment.GetCommandLineArgs();
      if (args.Length > 1) {
        LoadSettingsFromFile(args[1]);
      }
    }

    /// <summary>
    /// Load a settings file by path — called from App.xaml.cs for command-line args.
    /// </summary>
    internal void LoadSettingsFromFile (String path) {
      SsgConversionSettings settings = SsgSettingsSupport.LoadSettings(path, out String error);
      if (settings != null) {
        ApplySettingsToUi(settings);
        StatusText.Text = $"Loaded: {System.IO.Path.GetFileName(path)}";
      } else {
        MessageBox.Show(error ?? $"Could not load: {path}", "Load Error", MessageBoxButton.OK, MessageBoxImage.Error);
      }
    }

    private void InitializeControls () {
      // Verbose combo
      foreach (MigLogVerbose level in Enum.GetValues(typeof(MigLogVerbose))) {
        VerboseComboBox.Items.Add(level);
      }
      VerboseComboBox.SelectedItem = MigLogVerbose.Normal;

      // Log filter combo
      LogFilterComboBox.Items.Add("All");
      LogFilterComboBox.Items.Add("Phase");
      LogFilterComboBox.Items.Add("Log");
      LogFilterComboBox.Items.Add("Warning");
      LogFilterComboBox.Items.Add("Error");
      LogFilterComboBox.Items.Add("Todo");
      LogFilterComboBox.Items.Add("Exception");
      LogFilterComboBox.Items.Add("Debug");
      LogFilterComboBox.SelectedIndex = 0;

      // Log items collection with filtering
      m_LogItems = new ObservableCollection<LogItem>();
      LogListView.ItemsSource = m_LogItems;
      CollectionView view = (CollectionView)CollectionViewSource.GetDefaultView(LogListView.ItemsSource);
      view.Filter = LogItemFilter;
    }

    // ─────────────────────────────────────────────────────────────────
    // CONVERT
    // ─────────────────────────────────────────────────────────────────

    private async void ConvertButton_Click (Object sender, RoutedEventArgs e) {
      if (m_IsConverting) { return; }

      // Validate required fields
      if (String.IsNullOrWhiteSpace(InputFolderTextBox.Text) || String.IsNullOrWhiteSpace(OutputFolderTextBox.Text)) {
        MessageBox.Show("Please specify both an Input Folder and an Output Folder.", "Validation", MessageBoxButton.OK, MessageBoxImage.Warning);
        return;
      }

      SsgConversionSettings settings = BuildSettings();
      SetConverting(true);

      try {
        Boolean success = await Task.Run(() => RunConversion(settings));
        SetConverting(false);
        StatusText.Text = success ? "Conversion completed successfully." : "Conversion completed with errors.";
      } catch (Exception ex) {
        SetConverting(false);
        StatusText.Text = "Conversion failed with an exception.";
        MessageBox.Show(ex.ToString(), "Conversion Error", MessageBoxButton.OK, MessageBoxImage.Error);
      }
    }

    private Boolean RunConversion (SsgConversionSettings settings) {
      MigLogger logger = new MigLogger();

      // Add UI log appender — Start is called by Program.RunConversion after all appenders are added
      UiLogAppender uiAppender = new UiLogAppender(this);
      uiAppender.Verbose = (MigLogVerbose)settings.VerboseLevel;
      logger.AddAppender(uiAppender);

      // Delegate to the shared conversion logic in SsgConverterConsole
      return Program.RunConversion(settings, logger);
    }

    private SsgConversionSettings BuildSettings () {
      SsgConversionSettings settings = new SsgConversionSettings();
      settings.InputFolder = InputFolderTextBox.Text.Trim();
      settings.OutputFolder = OutputFolderTextBox.Text.Trim();
      settings.LogFile = LogFileTextBox.Text.Trim();
      settings.VerboseLevel = (Int32)(MigLogVerbose)VerboseComboBox.SelectedItem;
      settings.ClearOutputFolder = ClearOutputCheckBox.IsChecked == true;
      settings.ContinueOnException = ContinueOnErrorCheckBox.IsChecked == true;
      settings.EnableLogFile = EnableLogFileCheckBox.IsChecked == true;
      return settings;
    }

    private void SetConverting (Boolean converting) {
      m_IsConverting = converting;
      ConvertButton.IsEnabled = !converting;
      ProgressBar.Visibility = converting ? Visibility.Visible : Visibility.Collapsed;
      ProgressBar.IsIndeterminate = converting;
      StatusText.Text = converting ? "Converting..." : "Ready";
    }

    // ─────────────────────────────────────────────────────────────────
    // LOG
    // ─────────────────────────────────────────────────────────────────

    /// <summary>
    /// Add a log item (thread-safe, dispatches to UI thread)
    /// </summary>
    internal void AddLogItem (LogItem item) {
      if (!Dispatcher.CheckAccess()) {
        Dispatcher.Invoke(() => AddLogItem(item));
        return;
      }
      m_LogItems.Add(item);
      // Auto-scroll to bottom
      if (m_LogItems.Count > 0) {
        LogListView.ScrollIntoView(m_LogItems[m_LogItems.Count - 1]);
      }
    }

    private Boolean LogItemFilter (Object obj) {
      if (LogFilterComboBox.SelectedIndex == 0) { return true; } // "All"
      if (obj is LogItem item) {
        String filter = LogFilterComboBox.SelectedItem as String;
        return item.DataKind.ToString().Equals(filter, StringComparison.OrdinalIgnoreCase);
      }
      return true;
    }

    private void LogFilter_Changed (Object sender, SelectionChangedEventArgs e) {
      if (LogListView?.ItemsSource != null) {
        CollectionViewSource.GetDefaultView(LogListView.ItemsSource).Refresh();
      }
    }

    private void ClearLog_Click (Object sender, RoutedEventArgs e) {
      m_LogItems.Clear();
    }

    // ─────────────────────────────────────────────────────────────────
    // BROWSE BUTTONS
    // ─────────────────────────────────────────────────────────────────

    private void BrowseFolder_Click (Object sender, RoutedEventArgs e) {
      if (sender is Button button && button.Tag is String targetName) {
        TextBox target = FindName(targetName) as TextBox;
        if (target == null) { return; }

        var dialog = new OpenFolderDialog();
        if (!String.IsNullOrEmpty(target.Text) && Directory.Exists(target.Text)) {
          dialog.InitialDirectory = target.Text;
        }
        if (dialog.ShowDialog() == true) {
          target.Text = dialog.FolderName;
        }
      }
    }

    private void BrowseSaveFile_Click (Object sender, RoutedEventArgs e) {
      if (sender is Button button && button.Tag is String targetName) {
        TextBox target = FindName(targetName) as TextBox;
        if (target == null) { return; }

        SaveFileDialog dialog = new SaveFileDialog();
        dialog.Filter = "Log Files (*.log)|*.log|All Files (*.*)|*.*";
        if (dialog.ShowDialog() == true) {
          target.Text = dialog.FileName;
        }
      }
    }

    // ─────────────────────────────────────────────────────────────────
    // SETTINGS LOAD / SAVE
    // ─────────────────────────────────────────────────────────────────

    private void LoadSettings_Click (Object sender, RoutedEventArgs e) {
      OpenFileDialog dialog = new OpenFileDialog();
      dialog.Filter = "Settings Files (*.settings)|*.settings|XML Files (*.xml)|*.xml|All Files (*.*)|*.*";
      if (dialog.ShowDialog() == true) {
        SsgConversionSettings settings = SsgSettingsSupport.LoadSettings(dialog.FileName, out String error);
        if (settings != null) {
          ApplySettingsToUi(settings);
          StatusText.Text = $"Loaded: {Path.GetFileName(dialog.FileName)}";
        } else {
          MessageBox.Show(error, "Load Error", MessageBoxButton.OK, MessageBoxImage.Error);
        }
      }
    }

    private void SaveSettings_Click (Object sender, RoutedEventArgs e) {
      SaveFileDialog dialog = new SaveFileDialog();
      dialog.Filter = "Settings Files (*.settings)|*.settings|All Files (*.*)|*.*";
      if (dialog.ShowDialog() == true) {
        SsgConversionSettings settings = BuildSettings();
        SsgSettingsSupport.SaveSettings(dialog.FileName, settings);
        StatusText.Text = $"Saved: {Path.GetFileName(dialog.FileName)}";
      }
    }

    private void ApplySettingsToUi (SsgConversionSettings settings) {
      InputFolderTextBox.Text = settings.InputFolder ?? String.Empty;
      OutputFolderTextBox.Text = settings.OutputFolder ?? String.Empty;
      LogFileTextBox.Text = settings.LogFile ?? String.Empty;
      VerboseComboBox.SelectedItem = (MigLogVerbose)settings.VerboseLevel;
      ClearOutputCheckBox.IsChecked = settings.ClearOutputFolder;
      ContinueOnErrorCheckBox.IsChecked = settings.ContinueOnException;
      EnableLogFileCheckBox.IsChecked = settings.EnableLogFile;
    }

    // ─────────────────────────────────────────────────────────────────
    // WINDOW
    // ─────────────────────────────────────────────────────────────────

    private void Window_Closing (Object sender, CancelEventArgs e) {
      if (m_IsConverting) {
        MessageBoxResult result = MessageBox.Show("A conversion is in progress. Close anyway?", "SSG Converter", MessageBoxButton.YesNo, MessageBoxImage.Question);
        if (result == MessageBoxResult.No) {
          e.Cancel = true;
        }
      }
    }

  }

}
