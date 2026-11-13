using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Company.AFBUS_2200COBOL.BusinessLogic.Cfh_Copy_Gn {

  public class Fd_Parm_Fixe_Rec: AmtFileLayout {
    #region Members
    private Cfh_Copy_Gn m_ParentObject;
    private AmtStructure m_Parm_Fixe_Rec;
    private AmtVarNumericOS2200 m_Px_Os;
    private AmtVarNumericOS2200 m_Px_Len;
    private AmtVarAlpha m_Px_Txt;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_Fixe_Rec { [DebuggerStepThrough()] get { return m_Parm_Fixe_Rec; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Px_Os { [DebuggerStepThrough()] get { return m_Px_Os; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Px_Len { [DebuggerStepThrough()] get { return m_Px_Len; } }

    /// <summary>AmtVarAlpha 238</summary>
    public AmtVarAlpha Px_Txt { [DebuggerStepThrough()] get { return m_Px_Txt; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_Fixe_Rec (Cfh_Copy_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_Fixe_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_Fixe_Rec.AddAlphaFiller(2);
          m_Px_Os = new AmtVarNumericOS2200(5, m_Parm_Fixe_Rec);
          m_Px_Len = new AmtVarNumericOS2200(5, m_Parm_Fixe_Rec);
          m_Px_Txt = new AmtVarAlpha(238, m_Parm_Fixe_Rec);
        }
      }
      if (sharedLayout != null) {
        m_DataRecord.Redefines(sharedLayout.DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Parm_Fixe_Rec

    public void Init () {
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_Fixe_Rec

} // Namespace Company.AFBUS_2200COBOL.BusinessLogic.Cfh_Copy_Gn

