using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Archiformat_Gn {

  public class Fd_Fic_Report_Rec: AmtFileLayout {
    #region Members
    private Archiformat_Gn m_ParentObject;
    private AmtVarAlpha m_Fic_Report_Rec;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha Fic_Report_Rec { [DebuggerStepThrough()] get { return m_Fic_Report_Rec; } }
    #endregion Properties

    // Constructor
    public Fd_Fic_Report_Rec (Archiformat_Gn parentObject) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Fic_Report_Rec = new AmtVarAlpha(4001, m_DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Fic_Report_Rec

    public void Init () {
      m_DataRecord.Initialise();
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Fic_Report_Rec

} // Namespace Federale.BSP.BusinessLogic.Archiformat_Gn

