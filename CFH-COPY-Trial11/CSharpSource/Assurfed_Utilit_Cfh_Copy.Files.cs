using System.Diagnostics;
using Asysco.Amt.AmtSharedDataModel.Files;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Settings;

namespace Company.AFBUS_2200COBOL.BusinessLogic.Assurfed_Utilit_Cfh_Copy {

  public sealed partial class Assurfed_Utilit_Cfh_Copy {
    #region Members
    internal Fd_Recin m_Fd_Recin;
    internal Fd_Recout m_Fd_Recout;
    private AmtFileId m_Tapein;
    private AmtFileId m_Tapeout;
    // T3 record-size parameterisation proof — single point of change (SSG [INPUT/OUTPUT,1,1,2])
    private const int m_RecordSize = 120;
    #endregion Members

    #region Properties
    internal Fd_Recin Fd_Recin { [DebuggerStepThrough()] get { return m_Fd_Recin; } }
    internal Fd_Recout Fd_Recout { [DebuggerStepThrough()] get { return m_Fd_Recout; } }
    public AmtFileId Tapein { [DebuggerStepThrough()] get { return m_Tapein; } }
    public AmtFileId Tapeout { [DebuggerStepThrough()] get { return m_Tapeout; } }
    #endregion Properties

    internal void FilesCreate (AmtFileCollection files, AmtRequestInfoRt requestInfo) {
      m_Fd_Recin = new Fd_Recin(this, m_RecordSize);
      m_Fd_Recout = new Fd_Recout(this, m_RecordSize);

      m_Tapein = new AmtFileId("TAPEIN", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Tapein);
      m_Tapein.RegisterLayout(Fd_Recin);

      m_Tapeout = new AmtFileId("TAPEOUT", false, false, AmtFileRecordEnding.Default);
      files.AddFileId(m_Tapeout);
      m_Tapeout.RegisterLayout(Fd_Recout);
    } // FilesCreate

    internal void FilesReset () {
      m_Fd_Recin.Init();
      m_Tapein.SetOptions("ECL-TAPEIN", false, false, false, AmtFileRecordEnding.Default);

      m_Fd_Recout.Init();
      m_Tapeout.SetOptions("ECL-TAPEOUT", false, false, false, AmtFileRecordEnding.Default);
    } // FilesReset

  } // Class Assurfed_Utilit_Cfh_Copy

} // Namespace Company.AFBUS_2200COBOL.BusinessLogic.Assurfed_Utilit_Cfh_Copy

