using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Company.AFBUS_2200COBOL.BusinessLogic.Cfh_Copy_Gn {

  public class Fd_Fi1_Rec: AmtFileLayout {
    #region Members
    private Cfh_Copy_Gn m_ParentObject;
    private AmtVarAlpha m_Fi1_Rec;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha Fi1_Rec { [DebuggerStepThrough()] get { return m_Fi1_Rec; } }
    #endregion Properties

    // Constructor
    public Fd_Fi1_Rec (Cfh_Copy_Gn parentObject) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Fi1_Rec = new AmtVarAlpha(4001, m_DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Fi1_Rec

    public void Init () {
      m_DataRecord.Initialise();
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Fi1_Rec

} // Namespace Company.AFBUS_2200COBOL.BusinessLogic.Cfh_Copy_Gn

