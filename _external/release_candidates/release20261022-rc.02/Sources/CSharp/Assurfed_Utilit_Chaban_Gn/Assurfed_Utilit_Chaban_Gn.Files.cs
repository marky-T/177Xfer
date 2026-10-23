using System.Diagnostics;
using Asysco.Amt.AmtSharedDataModel.Files;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Settings;

namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Chaban_Gn {

  public sealed partial class Assurfed_Utilit_Chaban_Gn {
    #region Members
    internal Fd_Fi1_Rec m_Fd_Fi1_Rec;
    internal Fd_Fo1_Rec m_Fd_Fo1_Rec;
    internal Fd_Parm_Rec m_Fd_Parm_Rec;
    internal Fd_Parm_File_Rec m_Fd_Parm_File_Rec;
    internal Fd_Parm_Nb_Rec m_Fd_Parm_Nb_Rec;
    private AmtFileId m_Fi1;
    private AmtFileId m_Fo1;
    private AmtFileId m_Parmf;
    #endregion Members

    #region Properties
    internal Fd_Fi1_Rec Fd_Fi1_Rec { [DebuggerStepThrough()] get { return m_Fd_Fi1_Rec; } }
    internal Fd_Fo1_Rec Fd_Fo1_Rec { [DebuggerStepThrough()] get { return m_Fd_Fo1_Rec; } }
    internal Fd_Parm_Rec Fd_Parm_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Rec; } }
    internal Fd_Parm_File_Rec Fd_Parm_File_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_File_Rec; } }
    internal Fd_Parm_Nb_Rec Fd_Parm_Nb_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Nb_Rec; } }
    public AmtFileId Fi1 { [DebuggerStepThrough()] get { return m_Fi1; } }
    public AmtFileId Fo1 { [DebuggerStepThrough()] get { return m_Fo1; } }
    public AmtFileId Parmf { [DebuggerStepThrough()] get { return m_Parmf; } }
    #endregion Properties

    internal void FilesCreate (AmtFileCollection files, AmtRequestInfoRt requestInfo) {
      m_Fd_Fi1_Rec = new Fd_Fi1_Rec(this);
      m_Fd_Fo1_Rec = new Fd_Fo1_Rec(this);
      m_Fd_Parm_Rec = new Fd_Parm_Rec(this);
      m_Fd_Parm_File_Rec = new Fd_Parm_File_Rec(this, m_Fd_Parm_Rec);
      m_Fd_Parm_Nb_Rec = new Fd_Parm_Nb_Rec(this, m_Fd_Parm_Rec);

      m_Fi1 = new AmtFileId("FI1", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Fi1);
      m_Fi1.RegisterLayout(Fd_Fi1_Rec);

      m_Fo1 = new AmtFileId("FO1", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Fo1);
      m_Fo1.RegisterLayout(Fd_Fo1_Rec);

      m_Parmf = new AmtFileId("PARMF", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Parmf);
      m_Parmf.RegisterLayout(Fd_Parm_Rec, Fd_Parm_File_Rec, Fd_Parm_Nb_Rec);
    } // FilesCreate

    internal void FilesReset () {
      m_Fd_Fi1_Rec.Init();
      m_Fi1.SetOptions("CHAIN", false, false, false, AmtFileRecordEnding.Default);
      m_Fi1.RecordSizeField = m_LocDef.Ws_In_Len;
      m_Fi1.VariableRecordSize = true;

      m_Fd_Fo1_Rec.Init();
      m_Fo1.SetOptions("CHAOUT", false, false, false, AmtFileRecordEnding.Default);

      m_Fd_Parm_Rec.Init();
      m_Parmf.SetOptions("SGSPARM", false, false, false, AmtFileRecordEnding.Default);
    } // FilesReset

  } // Class Assurfed_Utilit_Chaban_Gn

} // Namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Chaban_Gn

