using System;
using System.IO;
using System.Xml.Serialization;

namespace SsgConverterConsole {

  /// <summary>
  /// Support class for handling SSG Conversion Settings (load/save/parse arguments).
  /// </summary>
  public static class SsgSettingsSupport {

    /// <summary>
    /// Load SsgConversionSettings from XML file.
    /// </summary>
    /// <param name="fileName">File name</param>
    /// <param name="error">Error message if loading fails</param>
    /// <returns>SsgConversionSettings or null on failure</returns>
    public static SsgConversionSettings LoadSettings (String fileName, out String error) {
      SsgConversionSettings settings = null;
      error = String.Empty;
      try {
        XmlSerializer xmlSerializer = new XmlSerializer(typeof(SsgConversionSettings));
        using (FileStream fs = new FileStream(fileName, FileMode.Open)) {
          settings = xmlSerializer.Deserialize(fs) as SsgConversionSettings;
        }
        if (settings != null) {
          settings.FileName = fileName;
        }
      } catch (Exception ex) {
        error = "Error loading settings file '" + fileName + "': " + ex.Message;
      }
      return settings;
    }

    /// <summary>
    /// Save SsgConversionSettings to XML file.
    /// </summary>
    /// <param name="fileName">File name</param>
    /// <param name="settings">Settings to save</param>
    public static void SaveSettings (String fileName, SsgConversionSettings settings) {
      XmlSerializer xmlSerializer = new XmlSerializer(typeof(SsgConversionSettings));
      using (FileStream fs = new FileStream(fileName, FileMode.OpenOrCreate)) {
        fs.SetLength(0);
        xmlSerializer.Serialize(fs, settings);
      }
    }

    /// <summary>
    /// Read startup arguments and return SsgConversionSettings.
    /// </summary>
    /// <param name="arguments">Command line arguments</param>
    /// <returns>SsgConversionSettings</returns>
    public static SsgConversionSettings ReadStartupArguments (String[] arguments) {
      SsgConversionSettings settings = new SsgConversionSettings();

      if (arguments == null) {
        return settings;
      }

      // First pass: load settings file if specified
      foreach (String argument in arguments) {
        ParseArgument(argument, settings, true);
      }

      // Second pass: override with explicit arguments
      foreach (String argument in arguments) {
        ParseArgument(argument, settings, false);
      }

      return settings;
    }

    private static void ParseArgument (String argument, SsgConversionSettings settings, Boolean settingsFileOnly) {
      Int32 index = argument.IndexOf(':');
      if (index <= 0) { return; }

      String key = argument.Substring(0, index + 1).ToUpperInvariant();
      String value = argument.Substring(index + 1).Trim('"');

      if (settingsFileOnly) {
        if (key == "/SETTINGSFILE:") {
          String error;
          SsgConversionSettings loaded = LoadSettings(value, out error);
          if (loaded != null) {
            settings.InputFolder = loaded.InputFolder;
            settings.OutputFolder = loaded.OutputFolder;
            settings.ClearOutputFolder = loaded.ClearOutputFolder;
            settings.ContinueOnException = loaded.ContinueOnException;
            settings.VerboseLevel = loaded.VerboseLevel;
            settings.LogFile = loaded.LogFile;
            settings.EnableLogFile = loaded.EnableLogFile;
          }
        }
        return;
      }

      switch (key) {
        case "/INPUT:": settings.InputFolder = value; break;
        case "/OUTPUT:": settings.OutputFolder = value; break;
        case "/LOGFILE:": settings.LogFile = value; break;
        case "/ENABLELOGFILE:": settings.EnableLogFile = value.Equals("TRUE", StringComparison.OrdinalIgnoreCase); break;
        case "/CLEAROUTPUT:": settings.ClearOutputFolder = value.Equals("TRUE", StringComparison.OrdinalIgnoreCase); break;
        case "/CONTINUEONERROR:": settings.ContinueOnException = value.Equals("TRUE", StringComparison.OrdinalIgnoreCase); break;
        case "/VERBOSE:":
          if (Int32.TryParse(value, out Int32 level)) {
            settings.VerboseLevel = level;
          }
          break;
        case "/SETTINGSFILE:": break; // Already handled in first pass
      }
    }

  }

}
