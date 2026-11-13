using System.Diagnostics;
using Asysco.Amt.AmtSharedDataModel.Files;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Settings;

namespace Federale.BSP.BusinessLogic.Archisepare_Gn {

  public sealed partial class Archisepare_Gn {
    #region Members
    internal Fd_Farc_Rec m_Fd_Farc_Rec;
    internal Fd_Fkey_Rec m_Fd_Fkey_Rec;
    internal Fd_Fnar_Rec m_Fd_Fnar_Rec;
    internal Fd_Funl_Rec m_Fd_Funl_Rec;
    internal Fd_Parm_Rec m_Fd_Parm_Rec;
    internal Fd_Parm_Fn_Rec m_Fd_Parm_Fn_Rec;
    internal Fd_Parm_Ky_Rec m_Fd_Parm_Ky_Rec;
    internal Fd_Parm_Tn_Rec m_Fd_Parm_Tn_Rec;
    private AmtFileId m_Farc;
    private AmtFileId m_Fkey;
    private AmtFileId m_Fnar;
    private AmtFileId m_Funl;
    private AmtFileId m_Parmf;
    #endregion Members

    #region Properties
    internal Fd_Farc_Rec Fd_Farc_Rec { [DebuggerStepThrough()] get { return m_Fd_Farc_Rec; } }
    internal Fd_Fkey_Rec Fd_Fkey_Rec { [DebuggerStepThrough()] get { return m_Fd_Fkey_Rec; } }
    internal Fd_Fnar_Rec Fd_Fnar_Rec { [DebuggerStepThrough()] get { return m_Fd_Fnar_Rec; } }
    internal Fd_Funl_Rec Fd_Funl_Rec { [DebuggerStepThrough()] get { return m_Fd_Funl_Rec; } }
    internal Fd_Parm_Rec Fd_Parm_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Rec; } }
    internal Fd_Parm_Fn_Rec Fd_Parm_Fn_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Fn_Rec; } }
    internal Fd_Parm_Ky_Rec Fd_Parm_Ky_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Ky_Rec; } }
    internal Fd_Parm_Tn_Rec Fd_Parm_Tn_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Tn_Rec; } }
    public AmtFileId Farc { [DebuggerStepThrough()] get { return m_Farc; } }
    public AmtFileId Fkey { [DebuggerStepThrough()] get { return m_Fkey; } }
    public AmtFileId Fnar { [DebuggerStepThrough()] get { return m_Fnar; } }
    public AmtFileId Funl { [DebuggerStepThrough()] get { return m_Funl; } }
    public AmtFileId Parmf { [DebuggerStepThrough()] get { return m_Parmf; } }
    #endregion Properties

    internal void FilesCreate (AmtFileCollection files, AmtRequestInfoRt requestInfo) {
      m_Fd_Farc_Rec = new Fd_Farc_Rec(this);
      m_Fd_Fkey_Rec = new Fd_Fkey_Rec(this);
      m_Fd_Fnar_Rec = new Fd_Fnar_Rec(this);
      m_Fd_Funl_Rec = new Fd_Funl_Rec(this);
      m_Fd_Parm_Rec = new Fd_Parm_Rec(this);
      m_Fd_Parm_Fn_Rec = new Fd_Parm_Fn_Rec(this, m_Fd_Parm_Rec);
      m_Fd_Parm_Ky_Rec = new Fd_Parm_Ky_Rec(this, m_Fd_Parm_Rec);
      m_Fd_Parm_Tn_Rec = new Fd_Parm_Tn_Rec(this, m_Fd_Parm_Rec);

      m_Farc = new AmtFileId("FARC", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Farc);
      m_Farc.RegisterLayout(Fd_Farc_Rec);

      m_Fkey = new AmtFileId("FKEY", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Fkey);
      m_Fkey.RegisterLayout(Fd_Fkey_Rec);

      m_Fnar = new AmtFileId("FNAR", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Fnar);
      m_Fnar.RegisterLayout(Fd_Fnar_Rec);

      m_Funl = new AmtFileId("FUNL", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Funl);
      m_Funl.RegisterLayout(Fd_Funl_Rec);

      m_Parmf = new AmtFileId("PARMF", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Parmf);
      m_Parmf.RegisterLayout(Fd_Parm_Rec, Fd_Parm_Ky_Rec, Fd_Parm_Tn_Rec, Fd_Parm_Fn_Rec);
    } // FilesCreate

    internal void FilesReset () {
      m_Fd_Farc_Rec.Init();
      m_Farc.SetOptions("ARCOUT", false, false, false, AmtFileRecordEnding.Default);

      m_Fd_Fkey_Rec.Init();
      m_Fkey.SetOptions("ARCKEY", false, false, false, AmtFileRecordEnding.Default);
      m_Fkey.RecordSizeField = m_LocDef.Ws_Key_Len;
      m_Fkey.VariableRecordSize = true;

      m_Fd_Fnar_Rec.Init();
      m_Fnar.SetOptions("ARCNOUT", false, false, false, AmtFileRecordEnding.Default);

      m_Fd_Funl_Rec.Init();
      m_Funl.SetOptions("ARCUNL", false, false, false, AmtFileRecordEnding.Default);
      m_Funl.RecordSizeField = m_LocDef.Ws_Unl_Len;
      m_Funl.VariableRecordSize = true;

      m_Fd_Parm_Rec.Init();
      m_Parmf.SetOptions("SGSPARM", false, false, false, AmtFileRecordEnding.Default);
    } // FilesReset

  } // Class Archisepare_Gn

} // Namespace Federale.BSP.BusinessLogic.Archisepare_Gn

