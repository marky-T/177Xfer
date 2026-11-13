using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Company.AFBUS_2200COBOL.BusinessLogic.Cfh_Copy_Gn {

  public class Fd_Parm_Skip_Rec: AmtFileLayout {
    #region Members
    private Cfh_Copy_Gn m_ParentObject;
    private AmtStructure m_Parm_Skip_Rec;
    private AmtVarNumericOS2200 m_Ps_N;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_Skip_Rec { [DebuggerStepThrough()] get { return m_Parm_Skip_Rec; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Ps_N { [DebuggerStepThrough()] get { return m_Ps_N; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_Skip_Rec (Cfh_Copy_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_Skip_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_Skip_Rec.AddAlphaFiller(2);
          m_Ps_N = new AmtVarNumericOS2200(5, m_Parm_Skip_Rec);
          m_Parm_Skip_Rec.AddAlphaFiller(243);
        }
      }
      if (sharedLayout != null) {
        m_DataRecord.Redefines(sharedLayout.DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Parm_Skip_Rec

    public void Init () {
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_Skip_Rec

} // Namespace Company.AFBUS_2200COBOL.BusinessLogic.Cfh_Copy_Gn

