using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Archisepare_Gn {

  public class Fd_Fkey_Rec: AmtFileLayout {
    #region Members
    private Archisepare_Gn m_ParentObject;
    private AmtVarAlpha m_Fkey_Rec;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha Fkey_Rec { [DebuggerStepThrough()] get { return m_Fkey_Rec; } }
    #endregion Properties

    // Constructor
    public Fd_Fkey_Rec (Archisepare_Gn parentObject) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Fkey_Rec = new AmtVarAlpha(4001, m_DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Fkey_Rec

    public void Init () {
      m_DataRecord.Initialise();
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Fkey_Rec

} // Namespace Federale.BSP.BusinessLogic.Archisepare_Gn

