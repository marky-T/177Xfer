using System;
using Asysco.Amt.Runtime.Batch;
using Asysco.Amt.Runtime.Cobol;
using Asysco.Amt.Runtime.Settings;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Support;
using Asysco.Amt.Runtime.Vars;
using Company.AFBUS_2200COBOL.BusinessLogic.Application;
using Company.AFBUS_2200COBOL.BusinessLogic.Database;

namespace Company.AFBUS_2200COBOL.BusinessLogic.Cfh_Copy_Gn {

  /* CFH-COPY-GN
   *  BuildInfo    = "Built: 20261112 19:11"
   *  LionVersion  = "8.0"
   */
  public sealed partial class Cfh_Copy_Gn: AmtBaseCobolProgram {
    // Constructor
    public Cfh_Copy_Gn ()
      // REBUILT-FOR-177A: genDate 20261112 / genTime 1943 removed from base(); the GenDate/GenTime system items are NOT set in this build.
      : base("CFH_COPY_GN", "COBOL PROGRAM", "1.0", "1.0") {
    } // Constructor Cfh_Copy_Gn

    /// <summary>
    /// Main entry point for windows applications.
    /// </summary>
    /// <param name="args">Command line arguments</param>
    /// <returns>Program return code</returns>
    static public Int32 Main (String[] args) {
      return (CallMain(args, null));
    } // Main

    /// <summary>
    /// Main entry point for starting program or calling program from BatchController.
    /// </summary>
    /// <param name="args">Command line arguments</param>
    /// <param name="batchControllerCommands">Message Queue for passing commands to the program, used for interrupts</param>
    /// <returns>Program return code</returns>
    static public Int32 CallMain (String[] args, AmtBatchControllerCommands batchControllerCommands) {
      Int32 exitCode = 0;
      using (Cfh_Copy_Gn program = CreateProgram()) {
        program.BatchControllerCommands = batchControllerCommands;
        exitCode = program.BaseMain(args);
      }
      return (exitCode);
    } // CallMain

    /// <summary>
    /// Main entry point for starting program or calling program from external program.
    /// </summary>
    /// <param name="args">Command line arguments</param>
    /// <returns>Program return code</returns>
    static public Int32 CallMainExternal (ref Object[] args) {
      Int32 exitCode = 0;
      using (Cfh_Copy_Gn program = CreateProgram()) {
        program.CallMainWithNativeParams(ref args);
      }
      return (exitCode);
    } // CallMainExternal

    /// <summary>
    /// Create program object.
    /// </summary>
    /// <returns>Program object</returns>
    static private Cfh_Copy_Gn CreateProgram () {
      Cfh_Copy_Gn program = new Cfh_Copy_Gn();
      program.DateConvertInfo = ApplicationRt.Instance.DoGetDateConvertInfo();
      program.AppOptions = ApplicationRt.Instance.DoGetAppOptions();
      return (program);
    } // CreateProgram

    public override void InitProgram (IAmtCobolTransaction cobolTransaction) {
      m_CobolTransaction = cobolTransaction;
      ApplyApplicationRtSettings(ApplicationRt.Instance);
    } // InitProgram

    protected override void CreateDefinitions () {
      if (m_Parent != null) {
        m_RequestInfo.CobolProgramOptions.DecimalSign = AmtSeparator.Dot;
        m_RequestInfo.CobolProgramOptions.Separator1000Sign = AmtSeparator.Comma;
      }
      m_RequestInfo.UseDbStatus = true;
      m_RequestInfo.Company = ApplicationRt.Instance.CompanyName;
      AmtCacheDefinitions cacheDefs = (AmtCacheDefinitions)AmtBaseCobolSkeleton.GetDefinitionsFromCache(m_ObjectName, this);
      if (cacheDefs != null) {
        m_LocDef = (LocalDefinitions)cacheDefs.WorkingStorage;
        m_LocDef.ApplyNewParent(this);
        m_LocDef.InitLocalDefinitions();
      } else if (ReentrantProgram() && (m_LocDef != null)) {
        InitReentrantProgram();
      } else {
        m_LocDef = new LocalDefinitions(this);
      }
      m_LocDefinitions = m_LocDef;
      if (!(ReentrantProgram() && m_Tables != null)) {
        m_Tables = new QueryObjects(this);
        m_TableObjects = m_Tables;
      }
      FilesCreate(m_Files, m_RequestInfo);
      FilesReset();
    } // CreateDefinitions

    protected override void InitDefinitions () {
      m_LocDef.InitLocalDefinitions();
    } // InitDefinitions

    protected override void FillCobolProgramOptions (AmtCobolProgramOptions programOptions) {
      programOptions.DecimalSign = AmtSeparator.Dot;
      programOptions.Separator1000Sign = AmtSeparator.Comma;
    } // FillCobolProgramOptions

    protected override void ExecProgram () {
      FilesSetExternalIoResult();
      PerformMain();
    } // ExecProgram

    protected override void ExecMain () {
      try {
        FilesSetExternalIoResult();
        PerformMain();
      } catch (AmtExitModule) {
        // Catch the exit program so it continues running the caller code
      }
    } // ExecMain

    private void PerformMain () {
      if (m_CobolPerform == null) {
        m_CobolPerform = AmtCobolPerform.CreateCobolPerform(m_ObjectName);
      } else {
        m_CobolPerform.Clear();
      }

      Main();
    } // PerformMain

    protected override AmtVariable ExecMainWithParams (params Object[] parameters) {
      AmtVariable[] amtParams = CreateAmtVariablesFromParams(parameters);
      ExecMain();
      return (null);
    } // ExecMainWithParams

    protected override Object[] ExecMainWithNativeParams (params Object[] parameters) {
      ExecMain();
      return (null);
    } // ExecMainWithNativeParams

  } // Class Cfh_Copy_Gn

} // Namespace Company.AFBUS_2200COBOL.BusinessLogic.Cfh_Copy_Gn

