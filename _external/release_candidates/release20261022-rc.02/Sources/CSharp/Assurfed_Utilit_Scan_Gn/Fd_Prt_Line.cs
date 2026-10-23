using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Scan_Gn {

  public class Fd_Prt_Line: AmtFileLayout {
    #region Members
    private Assurfed_Utilit_Scan_Gn m_ParentObject;
    private AmtVarAlpha m_Prt_Line;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Prt_Line { [DebuggerStepThrough()] get { return m_Prt_Line; } }
    #endregion Properties

    // Constructor
    public Fd_Prt_Line (Assurfed_Utilit_Scan_Gn parentObject) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Prt_Line = new AmtVarAlpha(100, m_DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Prt_Line

    public void Init () {
      m_DataRecord.Initialise();
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Prt_Line

} // Namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Scan_Gn

