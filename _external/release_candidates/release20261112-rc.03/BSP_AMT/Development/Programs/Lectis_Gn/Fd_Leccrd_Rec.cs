using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Lectis_Gn {

  public class Fd_Leccrd_Rec: AmtFileLayout {
    #region Members
    private Lectis_Gn m_ParentObject;
    private AmtVarAlpha m_Leccrd_Rec;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha Leccrd_Rec { [DebuggerStepThrough()] get { return m_Leccrd_Rec; } }
    #endregion Properties

    // Constructor
    public Fd_Leccrd_Rec (Lectis_Gn parentObject) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Leccrd_Rec = new AmtVarAlpha(4001, m_DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Leccrd_Rec

    public void Init () {
      m_DataRecord.Initialise();
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Leccrd_Rec

} // Namespace Federale.BSP.BusinessLogic.Lectis_Gn

