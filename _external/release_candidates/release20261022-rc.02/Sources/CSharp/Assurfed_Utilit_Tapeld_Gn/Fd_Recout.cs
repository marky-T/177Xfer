using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Tapeld_Gn {

  public class Fd_Recout: AmtFileLayout {
    #region Members
    private Assurfed_Utilit_Tapeld_Gn m_ParentObject;
    private AmtVarAlpha m_Recout;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha 132</summary>
    public AmtVarAlpha Recout { [DebuggerStepThrough()] get { return m_Recout; } }
    #endregion Properties

    // Constructor
    public Fd_Recout (Assurfed_Utilit_Tapeld_Gn parentObject) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Recout = new AmtVarAlpha(132, m_DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Recout

    public void Init () {
      m_DataRecord.Initialise();
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Recout

} // Namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Tapeld_Gn

