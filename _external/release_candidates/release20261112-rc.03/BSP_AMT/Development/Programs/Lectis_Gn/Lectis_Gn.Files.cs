using System.Diagnostics;
using Asysco.Amt.AmtSharedDataModel.Files;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Settings;

namespace Federale.BSP.BusinessLogic.Lectis_Gn {

  public sealed partial class Lectis_Gn {
    #region Members
    internal Fd_Leccrd_Rec m_Fd_Leccrd_Rec;
    internal Fd_Lecin_Rec m_Fd_Lecin_Rec;
    internal Fd_Parm_Rec m_Fd_Parm_Rec;
    internal Fd_Zprint m_Fd_Zprint;
    internal Fd_Parm_Cd_Rec m_Fd_Parm_Cd_Rec;
    internal Fd_Parm_In_Rec m_Fd_Parm_In_Rec;
    internal Fd_Parm_Ky_Rec m_Fd_Parm_Ky_Rec;
    internal Fd_Parm_Md_Rec m_Fd_Parm_Md_Rec;
    internal Fd_Parm_Yd_Rec m_Fd_Parm_Yd_Rec;
    private AmtFileId m_Leccrd;
    private AmtFileId m_Lecin;
    private AmtFileId m_Parmf;
    #endregion Members

    #region Properties
    internal Fd_Leccrd_Rec Fd_Leccrd_Rec { [DebuggerStepThrough()] get { return m_Fd_Leccrd_Rec; } }
    internal Fd_Lecin_Rec Fd_Lecin_Rec { [DebuggerStepThrough()] get { return m_Fd_Lecin_Rec; } }
    internal Fd_Parm_Rec Fd_Parm_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Rec; } }
    internal Fd_Zprint Fd_Zprint { [DebuggerStepThrough()] get { return m_Fd_Zprint; } }
    internal Fd_Parm_Cd_Rec Fd_Parm_Cd_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Cd_Rec; } }
    internal Fd_Parm_In_Rec Fd_Parm_In_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_In_Rec; } }
    internal Fd_Parm_Ky_Rec Fd_Parm_Ky_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Ky_Rec; } }
    internal Fd_Parm_Md_Rec Fd_Parm_Md_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Md_Rec; } }
    internal Fd_Parm_Yd_Rec Fd_Parm_Yd_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Yd_Rec; } }
    public AmtFileId Leccrd { [DebuggerStepThrough()] get { return m_Leccrd; } }
    public AmtFileId Lecin { [DebuggerStepThrough()] get { return m_Lecin; } }
    public AmtFileId Parmf { [DebuggerStepThrough()] get { return m_Parmf; } }
    #endregion Properties

    internal void FilesCreate (AmtFileCollection files, AmtRequestInfoRt requestInfo) {
      m_Fd_Leccrd_Rec = new Fd_Leccrd_Rec(this);
      m_Fd_Lecin_Rec = new Fd_Lecin_Rec(this);
      m_Fd_Parm_Rec = new Fd_Parm_Rec(this);
      m_Fd_Zprint = new Fd_Zprint(this);
      m_Fd_Zprint.FileId = m_PrnDef.Imp.PrintId;
      m_Fd_Parm_Cd_Rec = new Fd_Parm_Cd_Rec(this, m_Fd_Parm_Rec);
      m_Fd_Parm_In_Rec = new Fd_Parm_In_Rec(this, m_Fd_Parm_Rec);
      m_Fd_Parm_Ky_Rec = new Fd_Parm_Ky_Rec(this, m_Fd_Parm_Rec);
      m_Fd_Parm_Md_Rec = new Fd_Parm_Md_Rec(this, m_Fd_Parm_Rec);
      m_Fd_Parm_Yd_Rec = new Fd_Parm_Yd_Rec(this, m_Fd_Parm_Rec);

      m_Leccrd = new AmtFileId("LECCRD", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Leccrd);
      m_Leccrd.RegisterLayout(Fd_Leccrd_Rec);

      m_Lecin = new AmtFileId("LECIN", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Lecin);
      m_Lecin.RegisterLayout(Fd_Lecin_Rec);

      m_Parmf = new AmtFileId("PARMF", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Parmf);
      m_Parmf.RegisterLayout(Fd_Parm_Rec, Fd_Parm_In_Rec, Fd_Parm_Ky_Rec, Fd_Parm_Md_Rec, Fd_Parm_Cd_Rec, Fd_Parm_Yd_Rec);
    } // FilesCreate

    internal void FilesReset () {
      m_Fd_Leccrd_Rec.Init();
      m_Leccrd.SetOptions("LECCRD", false, false, false, AmtFileRecordEnding.Default);
      m_Leccrd.RecordSizeField = m_LocDef.Ws_Crd_Len;
      m_Leccrd.VariableRecordSize = true;

      m_Fd_Lecin_Rec.Init();
      m_Lecin.SetOptions("LECIN", false, false, false, AmtFileRecordEnding.Default);
      m_Lecin.RecordSizeField = m_LocDef.Ws_In_Len;
      m_Lecin.VariableRecordSize = true;

      m_Fd_Parm_Rec.Init();
      m_Parmf.SetOptions("SGSPARM", false, false, false, AmtFileRecordEnding.Default);
    } // FilesReset

  } // Class Lectis_Gn

} // Namespace Federale.BSP.BusinessLogic.Lectis_Gn

