using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Archiformat_Gn {

  public class Fd_Parm_Rz_Rec: AmtFileLayout {
    #region Members
    private Archiformat_Gn m_ParentObject;
    private AmtStructure m_Parm_Rz_Rec;
    private AmtVarNumericOS2200 m_Pr_Rsz;
    private AmtVarNumericOS2200 m_Pr_Cols;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_Rz_Rec { [DebuggerStepThrough()] get { return m_Parm_Rz_Rec; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pr_Rsz { [DebuggerStepThrough()] get { return m_Pr_Rsz; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pr_Cols { [DebuggerStepThrough()] get { return m_Pr_Cols; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_Rz_Rec (Archiformat_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_Rz_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_Rz_Rec.AddAlphaFiller(2);
          m_Pr_Rsz = new AmtVarNumericOS2200(5, m_Parm_Rz_Rec);
          m_Pr_Cols = new AmtVarNumericOS2200(5, m_Parm_Rz_Rec);
          m_Parm_Rz_Rec.AddAlphaFiller(238);
        }
      }
      if (sharedLayout != null) {
        m_DataRecord.Redefines(sharedLayout.DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Parm_Rz_Rec

    public void Init () {
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_Rz_Rec

} // Namespace Federale.BSP.BusinessLogic.Archiformat_Gn

