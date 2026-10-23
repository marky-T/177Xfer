using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Baba_Gn {

  public class Fd_Parm_Key_Rec: AmtFileLayout {
    #region Members
    private Assurfed_Utilit_Baba_Gn m_ParentObject;
    private AmtStructure m_Parm_Key_Rec;
    private AmtVarNumericOS2200 m_Pk_Pos;
    private AmtVarNumericOS2200 m_Pk_Len;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_Key_Rec { [DebuggerStepThrough()] get { return m_Parm_Key_Rec; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pk_Pos { [DebuggerStepThrough()] get { return m_Pk_Pos; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pk_Len { [DebuggerStepThrough()] get { return m_Pk_Len; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_Key_Rec (Assurfed_Utilit_Baba_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_Key_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_Key_Rec.AddAlphaFiller(2);
          m_Pk_Pos = new AmtVarNumericOS2200(5, m_Parm_Key_Rec);
          m_Pk_Len = new AmtVarNumericOS2200(5, m_Parm_Key_Rec);
          m_Parm_Key_Rec.AddAlphaFiller(388);
        }
      }
      if (sharedLayout != null) {
        m_DataRecord.Redefines(sharedLayout.DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Parm_Key_Rec

    public void Init () {
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_Key_Rec

} // Namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Baba_Gn

