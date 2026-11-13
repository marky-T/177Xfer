using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Lectis_Gn {

  public class Fd_Parm_In_Rec: AmtFileLayout {
    #region Members
    private Lectis_Gn m_ParentObject;
    private AmtStructure m_Parm_In_Rec;
    private AmtVarNumericOS2200 m_Pi_Len;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_In_Rec { [DebuggerStepThrough()] get { return m_Parm_In_Rec; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pi_Len { [DebuggerStepThrough()] get { return m_Pi_Len; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_In_Rec (Lectis_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_In_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_In_Rec.AddAlphaFiller(2);
          m_Pi_Len = new AmtVarNumericOS2200(5, m_Parm_In_Rec);
          m_Parm_In_Rec.AddAlphaFiller(243);
        }
      }
      if (sharedLayout != null) {
        m_DataRecord.Redefines(sharedLayout.DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Parm_In_Rec

    public void Init () {
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_In_Rec

} // Namespace Federale.BSP.BusinessLogic.Lectis_Gn

