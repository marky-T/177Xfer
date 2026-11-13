using System.Diagnostics;
using Asysco.Amt.AmtSharedDataModel.Files;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Settings;

namespace Federale.BSP.BusinessLogic.Condis2_Gn {

  public sealed partial class Condis2_Gn {
    #region Members
    internal Fd_Fi1_Rec m_Fd_Fi1_Rec;
    internal Fd_Fo1_Rec m_Fd_Fo1_Rec;
    internal Fd_Parm_Rec m_Fd_Parm_Rec;
    internal Fd_Parm_Len_Rec m_Fd_Parm_Len_Rec;
    internal Fd_Parm_Move_Rec m_Fd_Parm_Move_Rec;
    internal Fd_Parm_Val_Rec m_Fd_Parm_Val_Rec;
    private AmtFileId m_Fi1;
    private AmtFileId m_Fo1;
    private AmtFileId m_Parmf;
    #endregion Members

    #region Properties
    internal Fd_Fi1_Rec Fd_Fi1_Rec { [DebuggerStepThrough()] get { return m_Fd_Fi1_Rec; } }
    internal Fd_Fo1_Rec Fd_Fo1_Rec { [DebuggerStepThrough()] get { return m_Fd_Fo1_Rec; } }
    internal Fd_Parm_Rec Fd_Parm_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Rec; } }
    internal Fd_Parm_Len_Rec Fd_Parm_Len_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Len_Rec; } }
    internal Fd_Parm_Move_Rec Fd_Parm_Move_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Move_Rec; } }
    internal Fd_Parm_Val_Rec Fd_Parm_Val_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Val_Rec; } }
    public AmtFileId Fi1 { [DebuggerStepThrough()] get { return m_Fi1; } }
    public AmtFileId Fo1 { [DebuggerStepThrough()] get { return m_Fo1; } }
    public AmtFileId Parmf { [DebuggerStepThrough()] get { return m_Parmf; } }
    #endregion Properties

    internal void FilesCreate (AmtFileCollection files, AmtRequestInfoRt requestInfo) {
      m_Fd_Fi1_Rec = new Fd_Fi1_Rec(this);
      m_Fd_Fo1_Rec = new Fd_Fo1_Rec(this);
      m_Fd_Parm_Rec = new Fd_Parm_Rec(this);
      m_Fd_Parm_Len_Rec = new Fd_Parm_Len_Rec(this, m_Fd_Parm_Rec);
      m_Fd_Parm_Move_Rec = new Fd_Parm_Move_Rec(this, m_Fd_Parm_Rec);
      m_Fd_Parm_Val_Rec = new Fd_Parm_Val_Rec(this, m_Fd_Parm_Rec);

      m_Fi1 = new AmtFileId("FI1", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Fi1);
      m_Fi1.RegisterLayout(Fd_Fi1_Rec);

      m_Fo1 = new AmtFileId("FO1", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Fo1);
      m_Fo1.RegisterLayout(Fd_Fo1_Rec);

      m_Parmf = new AmtFileId("PARMF", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Parmf);
      m_Parmf.RegisterLayout(Fd_Parm_Rec, Fd_Parm_Len_Rec, Fd_Parm_Val_Rec, Fd_Parm_Move_Rec);
    } // FilesCreate

    internal void FilesReset () {
      m_Fd_Fi1_Rec.Init();
      m_Fi1.SetOptions("FILEIN", false, false, false, AmtFileRecordEnding.Default);
      m_Fi1.RecordSizeField = m_LocDef.Ws_In_Len;
      m_Fi1.VariableRecordSize = true;

      m_Fd_Fo1_Rec.Init();
      m_Fo1.SetOptions("FILEOUT", false, false, false, AmtFileRecordEnding.Default);

      m_Fd_Parm_Rec.Init();
      m_Parmf.SetOptions("SGSPARM", false, false, false, AmtFileRecordEnding.Default);
    } // FilesReset

  } // Class Condis2_Gn

} // Namespace Federale.BSP.BusinessLogic.Condis2_Gn

