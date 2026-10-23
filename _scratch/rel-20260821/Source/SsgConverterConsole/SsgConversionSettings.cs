using System;
using System.Xml.Serialization;

namespace SsgConverterConsole {

  /// <summary>
  /// Settings for the SSG to PowerShell converter.
  /// XML-serializable for load/save as parameter file.
  /// </summary>
  public sealed class SsgConversionSettings {

    private String m_InputFolder = String.Empty;
    private String m_OutputFolder = String.Empty;
    private Boolean m_ClearOutputFolder = true;
    private Boolean m_ContinueOnException;
    private Int32 m_VerboseLevel = 2;
    private String m_LogFile = String.Empty;
    private Boolean m_EnableLogFile;

    /// <summary>Input folder containing .ssg source files</summary>
    public String InputFolder { get { return m_InputFolder; } set { m_InputFolder = value; } }

    /// <summary>Output folder for generated .ps1 scripts</summary>
    public String OutputFolder { get { return m_OutputFolder; } set { m_OutputFolder = value; } }

    /// <summary>Whether to clear the output folder before conversion</summary>
    public Boolean ClearOutputFolder { get { return m_ClearOutputFolder; } set { m_ClearOutputFolder = value; } }

    /// <summary>Whether to continue processing remaining files when an exception occurs</summary>
    public Boolean ContinueOnException { get { return m_ContinueOnException; } set { m_ContinueOnException = value; } }

    /// <summary>Verbose level (0=Minimal, 1=Compact, 2=Normal, 3=Diagnostic)</summary>
    public Int32 VerboseLevel { get { return m_VerboseLevel; } set { m_VerboseLevel = value; } }

    /// <summary>Log file path</summary>
    public String LogFile { get { return m_LogFile; } set { m_LogFile = value; } }

    /// <summary>Whether the log file is enabled</summary>
    public Boolean EnableLogFile { get { return m_EnableLogFile; } set { m_EnableLogFile = value; } }

    /// <summary>File name this settings was loaded from (not serialized)</summary>
    [XmlIgnore]
    public String FileName { get; set; } = String.Empty;

  }

}
