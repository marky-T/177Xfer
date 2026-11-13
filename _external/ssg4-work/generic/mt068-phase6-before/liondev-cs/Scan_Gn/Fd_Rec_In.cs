using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Company.AFBUS_2200COBOL.BusinessLogic.Scan_Gn {

  public class Fd_Rec_In: AmtFileLayout {
    #region Members
    private Scan_Gn m_ParentObject;
    private AmtVarAlpha m_Rec_In;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha Rec_In { [DebuggerStepThrough()] get { return m_Rec_In; } }
    #endregion Properties

    // Constructor
    public Fd_Rec_In (Scan_Gn parentObject) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Rec_In = new AmtVarAlpha(4001, m_DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Rec_In

    public void Init () {
      m_DataRecord.Initialise();
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Rec_In

} // Namespace Company.AFBUS_2200COBOL.BusinessLogic.Scan_Gn

