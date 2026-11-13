using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Archisepare_Gn {

  public class Fd_Fnar_Rec: AmtFileLayout {
    #region Members
    private Archisepare_Gn m_ParentObject;
    private AmtVarAlpha m_Fnar_Rec;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha 4000</summary>
    public AmtVarAlpha Fnar_Rec { [DebuggerStepThrough()] get { return m_Fnar_Rec; } }
    #endregion Properties

    // Constructor
    public Fd_Fnar_Rec (Archisepare_Gn parentObject) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Fnar_Rec = new AmtVarAlpha(4000, m_DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Fnar_Rec

    public void Init () {
      m_DataRecord.Initialise();
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Fnar_Rec

} // Namespace Federale.BSP.BusinessLogic.Archisepare_Gn

