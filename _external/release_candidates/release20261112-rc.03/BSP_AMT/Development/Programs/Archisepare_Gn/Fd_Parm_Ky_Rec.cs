using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Archisepare_Gn {

  public class Fd_Parm_Ky_Rec: AmtFileLayout {
    #region Members
    private Archisepare_Gn m_ParentObject;
    private AmtStructure m_Parm_Ky_Rec;
    private AmtVarNumericOS2200 m_Pk_K1;
    private AmtVarNumericOS2200 m_Pk_Off;
    private AmtVarNumericOS2200 m_Pk_K2;
    private AmtVarNumericOS2200 m_Pk_Rsz;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_Ky_Rec { [DebuggerStepThrough()] get { return m_Parm_Ky_Rec; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pk_K1 { [DebuggerStepThrough()] get { return m_Pk_K1; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pk_Off { [DebuggerStepThrough()] get { return m_Pk_Off; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pk_K2 { [DebuggerStepThrough()] get { return m_Pk_K2; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pk_Rsz { [DebuggerStepThrough()] get { return m_Pk_Rsz; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_Ky_Rec (Archisepare_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_Ky_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_Ky_Rec.AddAlphaFiller(2);
          m_Pk_K1 = new AmtVarNumericOS2200(5, m_Parm_Ky_Rec);
          m_Pk_Off = new AmtVarNumericOS2200(5, m_Parm_Ky_Rec);
          m_Pk_K2 = new AmtVarNumericOS2200(5, m_Parm_Ky_Rec);
          m_Pk_Rsz = new AmtVarNumericOS2200(5, m_Parm_Ky_Rec);
          m_Parm_Ky_Rec.AddAlphaFiller(228);
        }
      }
      if (sharedLayout != null) {
        m_DataRecord.Redefines(sharedLayout.DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Parm_Ky_Rec

    public void Init () {
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_Ky_Rec

} // Namespace Federale.BSP.BusinessLogic.Archisepare_Gn

