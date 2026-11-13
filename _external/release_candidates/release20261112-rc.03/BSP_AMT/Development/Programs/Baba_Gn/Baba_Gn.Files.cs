using System.Diagnostics;
using Asysco.Amt.AmtSharedDataModel.Files;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Settings;

namespace Federale.BSP.BusinessLogic.Baba_Gn {

  public sealed partial class Baba_Gn {
    #region Members
    internal Fd_Fi1_Rec m_Fd_Fi1_Rec;
    internal Fd_Fo1_Rec m_Fd_Fo1_Rec;
    internal Fd_Fo2_Rec m_Fd_Fo2_Rec;
    internal Fd_Parm_Rec m_Fd_Parm_Rec;
    internal Fd_Parm_File_Rec m_Fd_Parm_File_Rec;
    internal Fd_Parm_Key_Rec m_Fd_Parm_Key_Rec;
    internal Fd_Parm_Mode_Rec m_Fd_Parm_Mode_Rec;
    internal Fd_Parm_Req_Rec m_Fd_Parm_Req_Rec;
    private AmtFileId m_Fi1;
    private AmtFileId m_Fo1;
    private AmtFileId m_Fo2;
    private AmtFileId m_Parmf;
    #endregion Members

    #region Properties
    internal Fd_Fi1_Rec Fd_Fi1_Rec { [DebuggerStepThrough()] get { return m_Fd_Fi1_Rec; } }
    internal Fd_Fo1_Rec Fd_Fo1_Rec { [DebuggerStepThrough()] get { return m_Fd_Fo1_Rec; } }
    internal Fd_Fo2_Rec Fd_Fo2_Rec { [DebuggerStepThrough()] get { return m_Fd_Fo2_Rec; } }
    internal Fd_Parm_Rec Fd_Parm_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Rec; } }
    internal Fd_Parm_File_Rec Fd_Parm_File_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_File_Rec; } }
    internal Fd_Parm_Key_Rec Fd_Parm_Key_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Key_Rec; } }
    internal Fd_Parm_Mode_Rec Fd_Parm_Mode_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Mode_Rec; } }
    internal Fd_Parm_Req_Rec Fd_Parm_Req_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Req_Rec; } }
    public AmtFileId Fi1 { [DebuggerStepThrough()] get { return m_Fi1; } }
    public AmtFileId Fo1 { [DebuggerStepThrough()] get { return m_Fo1; } }
    public AmtFileId Fo2 { [DebuggerStepThrough()] get { return m_Fo2; } }
    public AmtFileId Parmf { [DebuggerStepThrough()] get { return m_Parmf; } }
    #endregion Properties

    internal void FilesCreate (AmtFileCollection files, AmtRequestInfoRt requestInfo) {
      m_Fd_Fi1_Rec = new Fd_Fi1_Rec(this);
      m_Fd_Fo1_Rec = new Fd_Fo1_Rec(this);
      m_Fd_Fo2_Rec = new Fd_Fo2_Rec(this);
      m_Fd_Parm_Rec = new Fd_Parm_Rec(this);
      m_Fd_Parm_File_Rec = new Fd_Parm_File_Rec(this, m_Fd_Parm_Rec);
      m_Fd_Parm_Key_Rec = new Fd_Parm_Key_Rec(this, m_Fd_Parm_Rec);
      m_Fd_Parm_Mode_Rec = new Fd_Parm_Mode_Rec(this, m_Fd_Parm_Rec);
      m_Fd_Parm_Req_Rec = new Fd_Parm_Req_Rec(this, m_Fd_Parm_Rec);

      m_Fi1 = new AmtFileId("FI1", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Fi1);
      m_Fi1.RegisterLayout(Fd_Fi1_Rec);

      m_Fo1 = new AmtFileId("FO1", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Fo1);
      m_Fo1.RegisterLayout(Fd_Fo1_Rec);

      m_Fo2 = new AmtFileId("FO2", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Fo2);
      m_Fo2.RegisterLayout(Fd_Fo2_Rec);

      m_Parmf = new AmtFileId("PARMF", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Parmf);
      m_Parmf.RegisterLayout(Fd_Parm_Rec, Fd_Parm_File_Rec, Fd_Parm_Mode_Rec, Fd_Parm_Key_Rec, Fd_Parm_Req_Rec);
    } // FilesCreate

    internal void FilesReset () {
      m_Fd_Fi1_Rec.Init();
      m_Fi1.SetOptions("BABIN", false, false, false, AmtFileRecordEnding.Default);
      m_Fi1.RecordSizeField = m_LocDef.Ws_In_Len;
      m_Fi1.VariableRecordSize = true;

      m_Fd_Fo1_Rec.Init();
      m_Fo1.SetOptions("BABOUT1", false, false, false, AmtFileRecordEnding.Default);

      m_Fd_Fo2_Rec.Init();
      m_Fo2.SetOptions("BABOUT2", false, false, false, AmtFileRecordEnding.Default);

      m_Fd_Parm_Rec.Init();
      m_Parmf.SetOptions("SGSPARM", false, false, false, AmtFileRecordEnding.Default);
    } // FilesReset

  } // Class Baba_Gn

} // Namespace Federale.BSP.BusinessLogic.Baba_Gn

