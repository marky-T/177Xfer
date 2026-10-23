using System.Diagnostics;
using Asysco.Amt.AmtSharedDataModel.Files;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Settings;

namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Scan_Gn {

  public sealed partial class Assurfed_Utilit_Scan_Gn {
    #region Members
    internal Fd_Parm_Rec m_Fd_Parm_Rec;
    internal Fd_Prt_Line m_Fd_Prt_Line;
    internal Fd_Rec_In m_Fd_Rec_In;
    internal Fd_Parm_Len_Rec m_Fd_Parm_Len_Rec;
    internal Fd_Parm_Max_Rec m_Fd_Parm_Max_Rec;
    internal Fd_Parm_Name_Rec m_Fd_Parm_Name_Rec;
    private AmtFileId m_Parmf;
    private AmtFileId m_Tapein;
    #endregion Members

    #region Properties
    internal Fd_Parm_Rec Fd_Parm_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Rec; } }
    internal Fd_Prt_Line Fd_Prt_Line { [DebuggerStepThrough()] get { return m_Fd_Prt_Line; } }
    internal Fd_Rec_In Fd_Rec_In { [DebuggerStepThrough()] get { return m_Fd_Rec_In; } }
    internal Fd_Parm_Len_Rec Fd_Parm_Len_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Len_Rec; } }
    internal Fd_Parm_Max_Rec Fd_Parm_Max_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Max_Rec; } }
    internal Fd_Parm_Name_Rec Fd_Parm_Name_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Name_Rec; } }
    public AmtFileId Parmf { [DebuggerStepThrough()] get { return m_Parmf; } }
    public AmtFileId Tapein { [DebuggerStepThrough()] get { return m_Tapein; } }
    #endregion Properties

    internal void FilesCreate (AmtFileCollection files, AmtRequestInfoRt requestInfo) {
      m_Fd_Parm_Rec = new Fd_Parm_Rec(this);
      m_Fd_Prt_Line = new Fd_Prt_Line(this);
      m_Fd_Prt_Line.FileId = m_PrnDef.Prt.PrintId;
      m_Fd_Rec_In = new Fd_Rec_In(this);
      m_Fd_Parm_Len_Rec = new Fd_Parm_Len_Rec(this, m_Fd_Parm_Rec);
      m_Fd_Parm_Max_Rec = new Fd_Parm_Max_Rec(this, m_Fd_Parm_Rec);
      m_Fd_Parm_Name_Rec = new Fd_Parm_Name_Rec(this, m_Fd_Parm_Rec);

      m_Parmf = new AmtFileId("PARMF", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Parmf);
      m_Parmf.RegisterLayout(Fd_Parm_Rec, Fd_Parm_Len_Rec, Fd_Parm_Name_Rec, Fd_Parm_Max_Rec);

      m_Tapein = new AmtFileId("TAPEIN", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Tapein);
      m_Tapein.RegisterLayout(Fd_Rec_In);
    } // FilesCreate

    internal void FilesReset () {
      m_Fd_Parm_Rec.Init();
      m_Parmf.SetOptions("SGSPARM", false, false, false, AmtFileRecordEnding.Default);

      m_Fd_Rec_In.Init();
      m_Tapein.SetOptions("SCANIN", false, false, false, AmtFileRecordEnding.Default);
      m_Tapein.RecordSizeField = m_LocDef.Ws_In_Len;
      m_Tapein.VariableRecordSize = true;
    } // FilesReset

  } // Class Assurfed_Utilit_Scan_Gn

} // Namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Scan_Gn

