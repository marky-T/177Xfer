using System.Diagnostics;
using Asysco.Amt.AmtSharedDataModel.Files;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Settings;

namespace Federale.BSP.BusinessLogic.Archiformat_Gn {

  public sealed partial class Archiformat_Gn {
    #region Members
    internal Fd_Fic_Descript_Rec m_Fd_Fic_Descript_Rec;
    internal Fd_Fic_Report_Rec m_Fd_Fic_Report_Rec;
    internal Fd_Fic_Unload_Rec m_Fd_Fic_Unload_Rec;
    internal Fd_Lgn_For m_Fd_Lgn_For;
    internal Fd_Parm_Rec m_Fd_Parm_Rec;
    internal Fd_Parm_Ky_Rec m_Fd_Parm_Ky_Rec;
    internal Fd_Parm_Rz_Rec m_Fd_Parm_Rz_Rec;
    internal Fd_Parm_Tb_Rec m_Fd_Parm_Tb_Rec;
    private AmtFileId m_Fic_Descript;
    private AmtFileId m_Fic_Format;
    private AmtFileId m_Fic_Report;
    private AmtFileId m_Fic_Unload;
    private AmtFileId m_Parmf;
    #endregion Members

    #region Properties
    internal Fd_Fic_Descript_Rec Fd_Fic_Descript_Rec { [DebuggerStepThrough()] get { return m_Fd_Fic_Descript_Rec; } }
    internal Fd_Fic_Report_Rec Fd_Fic_Report_Rec { [DebuggerStepThrough()] get { return m_Fd_Fic_Report_Rec; } }
    internal Fd_Fic_Unload_Rec Fd_Fic_Unload_Rec { [DebuggerStepThrough()] get { return m_Fd_Fic_Unload_Rec; } }
    internal Fd_Lgn_For Fd_Lgn_For { [DebuggerStepThrough()] get { return m_Fd_Lgn_For; } }
    internal Fd_Parm_Rec Fd_Parm_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Rec; } }
    internal Fd_Parm_Ky_Rec Fd_Parm_Ky_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Ky_Rec; } }
    internal Fd_Parm_Rz_Rec Fd_Parm_Rz_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Rz_Rec; } }
    internal Fd_Parm_Tb_Rec Fd_Parm_Tb_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Tb_Rec; } }
    public AmtFileId Fic_Descript { [DebuggerStepThrough()] get { return m_Fic_Descript; } }
    public AmtFileId Fic_Format { [DebuggerStepThrough()] get { return m_Fic_Format; } }
    public AmtFileId Fic_Report { [DebuggerStepThrough()] get { return m_Fic_Report; } }
    public AmtFileId Fic_Unload { [DebuggerStepThrough()] get { return m_Fic_Unload; } }
    public AmtFileId Parmf { [DebuggerStepThrough()] get { return m_Parmf; } }
    #endregion Properties

    internal void FilesCreate (AmtFileCollection files, AmtRequestInfoRt requestInfo) {
      m_Fd_Fic_Descript_Rec = new Fd_Fic_Descript_Rec(this);
      m_Fd_Fic_Report_Rec = new Fd_Fic_Report_Rec(this);
      m_Fd_Fic_Unload_Rec = new Fd_Fic_Unload_Rec(this);
      m_Fd_Lgn_For = new Fd_Lgn_For(this);
      m_Fd_Parm_Rec = new Fd_Parm_Rec(this);
      m_Fd_Parm_Ky_Rec = new Fd_Parm_Ky_Rec(this, m_Fd_Parm_Rec);
      m_Fd_Parm_Rz_Rec = new Fd_Parm_Rz_Rec(this, m_Fd_Parm_Rec);
      m_Fd_Parm_Tb_Rec = new Fd_Parm_Tb_Rec(this, m_Fd_Parm_Rec);

      m_Fic_Descript = new AmtFileId("FIC-DESCRIPT", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Fic_Descript);
      m_Fic_Descript.RegisterLayout(Fd_Fic_Descript_Rec);

      m_Fic_Format = new AmtFileId("FIC-FORMAT", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Fic_Format);
      m_Fic_Format.RegisterLayout(Fd_Lgn_For);

      m_Fic_Report = new AmtFileId("FIC-REPORT", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Fic_Report);
      m_Fic_Report.RegisterLayout(Fd_Fic_Report_Rec);

      m_Fic_Unload = new AmtFileId("FIC-UNLOAD", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Fic_Unload);
      m_Fic_Unload.RegisterLayout(Fd_Fic_Unload_Rec);

      m_Parmf = new AmtFileId("PARMF", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Parmf);
      m_Parmf.RegisterLayout(Fd_Parm_Rec, Fd_Parm_Tb_Rec, Fd_Parm_Ky_Rec, Fd_Parm_Rz_Rec);
    } // FilesCreate

    internal void FilesReset () {
      m_Fd_Fic_Descript_Rec.Init();
      m_Fic_Descript.SetOptions("ARFDES", false, false, false, AmtFileRecordEnding.Default);
      m_Fic_Descript.RecordSizeField = m_LocDef.Ws_Des_Len;
      m_Fic_Descript.VariableRecordSize = true;

      m_Fd_Lgn_For.Init();
      m_Fic_Format.SetOptions("ARFOUT", false, false, false, AmtFileRecordEnding.Default);

      m_Fd_Fic_Report_Rec.Init();
      m_Fic_Report.SetOptions("ARFREP", false, false, false, AmtFileRecordEnding.Default);
      m_Fic_Report.RecordSizeField = m_LocDef.Ws_Rep_Len;
      m_Fic_Report.VariableRecordSize = true;

      m_Fd_Fic_Unload_Rec.Init();
      m_Fic_Unload.SetOptions("ARFUNL", false, false, false, AmtFileRecordEnding.Default);
      m_Fic_Unload.RecordSizeField = m_LocDef.Ws_Unl_Len;
      m_Fic_Unload.VariableRecordSize = true;

      m_Fd_Parm_Rec.Init();
      m_Parmf.SetOptions("SGSPARM", false, false, false, AmtFileRecordEnding.Default);
    } // FilesReset

  } // Class Archiformat_Gn

} // Namespace Federale.BSP.BusinessLogic.Archiformat_Gn

