using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Baba_Gn {

  public class Fd_Parm_Req_Rec: AmtFileLayout {
    #region Members
    private Baba_Gn m_ParentObject;
    private AmtStructure m_Parm_Req_Rec;
    private AmtVarNumericOS2200 m_Pr_Len;
    private AmtVarAlpha m_Pr_Val;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_Req_Rec { [DebuggerStepThrough()] get { return m_Parm_Req_Rec; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pr_Len { [DebuggerStepThrough()] get { return m_Pr_Len; } }

    /// <summary>AmtVarAlpha 393</summary>
    public AmtVarAlpha Pr_Val { [DebuggerStepThrough()] get { return m_Pr_Val; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_Req_Rec (Baba_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_Req_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_Req_Rec.AddAlphaFiller(2);
          m_Pr_Len = new AmtVarNumericOS2200(5, m_Parm_Req_Rec);
          m_Pr_Val = new AmtVarAlpha(393, m_Parm_Req_Rec);
        }
      }
      if (sharedLayout != null) {
        m_DataRecord.Redefines(sharedLayout.DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Parm_Req_Rec

    public void Init () {
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_Req_Rec

} // Namespace Federale.BSP.BusinessLogic.Baba_Gn

