using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Tapeld_Gn {

  public class Fd_Recin_Fd: AmtFileLayout {
    #region Members
    private Assurfed_Utilit_Tapeld_Gn m_ParentObject;
    private AmtVarAlpha m_Recin_Fd;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha Recin_Fd { [DebuggerStepThrough()] get { return m_Recin_Fd; } }
    #endregion Properties

    // Constructor
    public Fd_Recin_Fd (Assurfed_Utilit_Tapeld_Gn parentObject) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Recin_Fd = new AmtVarAlpha(4001, m_DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Recin_Fd

    public void Init () {
      m_DataRecord.Initialise();
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Recin_Fd

} // Namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Tapeld_Gn

