using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Condis2_Gn {

  public class Fd_Parm_Val_Rec: AmtFileLayout {
    #region Members
    private Condis2_Gn m_ParentObject;
    private AmtStructure m_Parm_Val_Rec;
    private AmtVarNumericOS2200 m_Pv_Pos;
    private AmtVarNumericOS2200 m_Pv_Len;
    private AmtVarAlpha m_Pv_Txt;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_Val_Rec { [DebuggerStepThrough()] get { return m_Parm_Val_Rec; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pv_Pos { [DebuggerStepThrough()] get { return m_Pv_Pos; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pv_Len { [DebuggerStepThrough()] get { return m_Pv_Len; } }

    /// <summary>AmtVarAlpha 238</summary>
    public AmtVarAlpha Pv_Txt { [DebuggerStepThrough()] get { return m_Pv_Txt; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_Val_Rec (Condis2_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_Val_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_Val_Rec.AddAlphaFiller(2);
          m_Pv_Pos = new AmtVarNumericOS2200(5, m_Parm_Val_Rec);
          m_Pv_Len = new AmtVarNumericOS2200(5, m_Parm_Val_Rec);
          m_Pv_Txt = new AmtVarAlpha(238, m_Parm_Val_Rec);
        }
      }
      if (sharedLayout != null) {
        m_DataRecord.Redefines(sharedLayout.DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Parm_Val_Rec

    public void Init () {
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_Val_Rec

} // Namespace Federale.BSP.BusinessLogic.Condis2_Gn

