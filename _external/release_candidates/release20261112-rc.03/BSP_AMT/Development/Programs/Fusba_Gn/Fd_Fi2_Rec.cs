using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Fusba_Gn {

  public class Fd_Fi2_Rec: AmtFileLayout {
    #region Members
    private Fusba_Gn m_ParentObject;
    private AmtVarAlpha m_Fi2_Rec;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha Fi2_Rec { [DebuggerStepThrough()] get { return m_Fi2_Rec; } }
    #endregion Properties

    // Constructor
    public Fd_Fi2_Rec (Fusba_Gn parentObject) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Fi2_Rec = new AmtVarAlpha(4001, m_DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Fi2_Rec

    public void Init () {
      m_DataRecord.Initialise();
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Fi2_Rec

} // Namespace Federale.BSP.BusinessLogic.Fusba_Gn

