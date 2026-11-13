using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Archiformat_Gn {

  public class Fd_Lgn_For: AmtFileLayout {
    #region Members
    private Archiformat_Gn m_ParentObject;
    private AmtVarAlpha m_Lgn_For;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha 4000</summary>
    public AmtVarAlpha Lgn_For { [DebuggerStepThrough()] get { return m_Lgn_For; } }
    #endregion Properties

    // Constructor
    public Fd_Lgn_For (Archiformat_Gn parentObject) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Lgn_For = new AmtVarAlpha(4000, m_DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Lgn_For

    public void Init () {
      m_DataRecord.Initialise();
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Lgn_For

} // Namespace Federale.BSP.BusinessLogic.Archiformat_Gn

