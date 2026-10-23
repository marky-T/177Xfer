using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Condis2_Gn {

  public class Fd_Parm_Move_Rec: AmtFileLayout {
    #region Members
    private Assurfed_Utilit_Condis2_Gn m_ParentObject;
    private AmtStructure m_Parm_Move_Rec;
    private AmtVarNumericOS2200 m_Pm_Is;
    private AmtVarNumericOS2200 m_Pm_Il;
    private AmtVarNumericOS2200 m_Pm_Os;
    private AmtVarNumericOS2200 m_Pm_Ol;
    private AmtVarAlpha m_Pm_Code;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_Move_Rec { [DebuggerStepThrough()] get { return m_Parm_Move_Rec; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pm_Is { [DebuggerStepThrough()] get { return m_Pm_Is; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pm_Il { [DebuggerStepThrough()] get { return m_Pm_Il; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pm_Os { [DebuggerStepThrough()] get { return m_Pm_Os; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pm_Ol { [DebuggerStepThrough()] get { return m_Pm_Ol; } }

    /// <summary>AmtVarAlpha 4</summary>
    public AmtVarAlpha Pm_Code { [DebuggerStepThrough()] get { return m_Pm_Code; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_Move_Rec (Assurfed_Utilit_Condis2_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_Move_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_Move_Rec.AddAlphaFiller(2);
          m_Pm_Is = new AmtVarNumericOS2200(5, m_Parm_Move_Rec);
          m_Pm_Il = new AmtVarNumericOS2200(5, m_Parm_Move_Rec);
          m_Pm_Os = new AmtVarNumericOS2200(5, m_Parm_Move_Rec);
          m_Pm_Ol = new AmtVarNumericOS2200(5, m_Parm_Move_Rec);
          m_Pm_Code = new AmtVarAlpha(4, m_Parm_Move_Rec);
          m_Parm_Move_Rec.AddAlphaFiller(224);
        }
      }
      if (sharedLayout != null) {
        m_DataRecord.Redefines(sharedLayout.DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Parm_Move_Rec

    public void Init () {
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_Move_Rec

} // Namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Condis2_Gn

