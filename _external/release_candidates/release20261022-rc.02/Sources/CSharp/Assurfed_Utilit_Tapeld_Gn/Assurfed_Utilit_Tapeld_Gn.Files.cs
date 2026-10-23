using System.Diagnostics;
using Asysco.Amt.AmtSharedDataModel.Files;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Settings;

namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Tapeld_Gn {

  public sealed partial class Assurfed_Utilit_Tapeld_Gn {
    #region Members
    internal Fd_Parm_Rec m_Fd_Parm_Rec;
    internal Fd_Recin_Fd m_Fd_Recin_Fd;
    internal Fd_Recout m_Fd_Recout;
    internal Fd_Parm_Fixe_Rec m_Fd_Parm_Fixe_Rec;
    internal Fd_Parm_Len_Rec m_Fd_Parm_Len_Rec;
    internal Fd_Parm_Move_Rec m_Fd_Parm_Move_Rec;
    private AmtFileId m_Parmf;
    private AmtFileId m_Tapein;
    #endregion Members

    #region Properties
    internal Fd_Parm_Rec Fd_Parm_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Rec; } }
    internal Fd_Recin_Fd Fd_Recin_Fd { [DebuggerStepThrough()] get { return m_Fd_Recin_Fd; } }
    internal Fd_Recout Fd_Recout { [DebuggerStepThrough()] get { return m_Fd_Recout; } }
    internal Fd_Parm_Fixe_Rec Fd_Parm_Fixe_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Fixe_Rec; } }
    internal Fd_Parm_Len_Rec Fd_Parm_Len_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Len_Rec; } }
    internal Fd_Parm_Move_Rec Fd_Parm_Move_Rec { [DebuggerStepThrough()] get { return m_Fd_Parm_Move_Rec; } }
    public AmtFileId Parmf { [DebuggerStepThrough()] get { return m_Parmf; } }
    public AmtFileId Tapein { [DebuggerStepThrough()] get { return m_Tapein; } }
    #endregion Properties

    internal void FilesCreate (AmtFileCollection files, AmtRequestInfoRt requestInfo) {
      m_Fd_Parm_Rec = new Fd_Parm_Rec(this);
      m_Fd_Recin_Fd = new Fd_Recin_Fd(this);
      m_Fd_Recout = new Fd_Recout(this);
      m_Fd_Recout.FileId = m_PrnDef.Tapeout.PrintId;
      m_Fd_Parm_Fixe_Rec = new Fd_Parm_Fixe_Rec(this, m_Fd_Parm_Rec);
      m_Fd_Parm_Len_Rec = new Fd_Parm_Len_Rec(this, m_Fd_Parm_Rec);
      m_Fd_Parm_Move_Rec = new Fd_Parm_Move_Rec(this, m_Fd_Parm_Rec);

      m_Parmf = new AmtFileId("PARMF", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Parmf);
      m_Parmf.RegisterLayout(Fd_Parm_Rec, Fd_Parm_Len_Rec, Fd_Parm_Move_Rec, Fd_Parm_Fixe_Rec);

      m_Tapein = new AmtFileId("TAPEIN", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Tapein);
      m_Tapein.RegisterLayout(Fd_Recin_Fd);
    } // FilesCreate

    internal void FilesReset () {
      m_Fd_Parm_Rec.Init();
      m_Parmf.SetOptions("SGSPARM", false, false, false, AmtFileRecordEnding.Default);

      m_Fd_Recin_Fd.Init();
      m_Tapein.SetOptions("TAPLIN", false, false, false, AmtFileRecordEnding.Default);
      m_Tapein.RecordSizeField = m_LocDef.Ws_In_Len;
      m_Tapein.VariableRecordSize = true;
    } // FilesReset

  } // Class Assurfed_Utilit_Tapeld_Gn

} // Namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Tapeld_Gn

