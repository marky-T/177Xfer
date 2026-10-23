using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Company.AFBUS_2200COBOL.BusinessLogic.Assurfed_Utilit_Cfh_Copy {

  public class Fd_Recin: AmtFileLayout {
    #region Members
    private Assurfed_Utilit_Cfh_Copy m_ParentObject;
    private AmtVarAlpha m_Recin;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha, size set by recordSize (SSG [INPUT,1,1,2])</summary>
    public AmtVarAlpha Recin { [DebuggerStepThrough()] get { return m_Recin; } }
    #endregion Properties

    // Constructor
    public Fd_Recin (Assurfed_Utilit_Cfh_Copy parentObject, int recordSize = 80) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Recin = new AmtVarAlpha(recordSize, m_DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Recin

    public void Init () {
      m_DataRecord.Initialise();
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Recin

} // Namespace Company.AFBUS_2200COBOL.BusinessLogic.Assurfed_Utilit_Cfh_Copy

