using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Condis2_Gn {

  public class Fd_Parm_Rec: AmtFileLayout {
    #region Members
    private Condis2_Gn m_ParentObject;
    private AmtStructure m_Parm_Rec;
    private AmtVarAlpha m_P_Type;
    private AmtVarAlpha m_P_Rest;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_Rec { [DebuggerStepThrough()] get { return m_Parm_Rec; } }

    /// <summary>AmtVarAlpha 2</summary>
    public AmtVarAlpha P_Type { [DebuggerStepThrough()] get { return m_P_Type; } }

    /// <summary>AmtVarAlpha 248</summary>
    public AmtVarAlpha P_Rest { [DebuggerStepThrough()] get { return m_P_Rest; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_Rec (Condis2_Gn parentObject) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_Rec = new AmtStructure(m_DataRecord);
        {
          m_P_Type = new AmtVarAlpha(2, m_Parm_Rec);
          m_P_Rest = new AmtVarAlpha(248, m_Parm_Rec);
        }
      }
      AllocateStructures();
    } // Constructor Fd_Parm_Rec

    public void Init () {
      m_DataRecord.Initialise();
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_Rec

} // Namespace Federale.BSP.BusinessLogic.Condis2_Gn

