using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Tapeld_Gn {

  public class Fd_Parm_Len_Rec: AmtFileLayout {
    #region Members
    private Tapeld_Gn m_ParentObject;
    private AmtStructure m_Parm_Len_Rec;
    private AmtVarNumericOS2200 m_Pl_Len;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_Len_Rec { [DebuggerStepThrough()] get { return m_Parm_Len_Rec; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pl_Len { [DebuggerStepThrough()] get { return m_Pl_Len; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_Len_Rec (Tapeld_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_Len_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_Len_Rec.AddAlphaFiller(2);
          m_Pl_Len = new AmtVarNumericOS2200(5, m_Parm_Len_Rec);
          m_Parm_Len_Rec.AddAlphaFiller(243);
        }
      }
      if (sharedLayout != null) {
        m_DataRecord.Redefines(sharedLayout.DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Parm_Len_Rec

    public void Init () {
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_Len_Rec

} // Namespace Federale.BSP.BusinessLogic.Tapeld_Gn

