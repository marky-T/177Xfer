using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Cfh_Copy_Gn {

  public class Fd_Fo1_Rec: AmtFileLayout {
    #region Members
    private Assurfed_Utilit_Cfh_Copy_Gn m_ParentObject;
    private AmtVarAlpha m_Fo1_Rec;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha 4000</summary>
    public AmtVarAlpha Fo1_Rec { [DebuggerStepThrough()] get { return m_Fo1_Rec; } }
    #endregion Properties

    // Constructor
    public Fd_Fo1_Rec (Assurfed_Utilit_Cfh_Copy_Gn parentObject) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Fo1_Rec = new AmtVarAlpha(4000, m_DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Fo1_Rec

    public void Init () {
      m_DataRecord.Initialise();
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Fo1_Rec

} // Namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Cfh_Copy_Gn

