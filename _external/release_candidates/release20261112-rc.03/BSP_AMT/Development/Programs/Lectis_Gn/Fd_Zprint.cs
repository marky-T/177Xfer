using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Lectis_Gn {

  public class Fd_Zprint: AmtFileLayout {
    #region Members
    private Lectis_Gn m_ParentObject;
    private AmtVarAlpha m_Zprint;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Zprint { [DebuggerStepThrough()] get { return m_Zprint; } }
    #endregion Properties

    // Constructor
    public Fd_Zprint (Lectis_Gn parentObject) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Zprint = new AmtVarAlpha(100, m_DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Zprint

    public void Init () {
      m_DataRecord.Initialise();
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Zprint

} // Namespace Federale.BSP.BusinessLogic.Lectis_Gn

