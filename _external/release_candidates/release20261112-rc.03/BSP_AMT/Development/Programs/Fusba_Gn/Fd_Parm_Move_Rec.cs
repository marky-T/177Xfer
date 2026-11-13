using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Fusba_Gn {

  public class Fd_Parm_Move_Rec: AmtFileLayout {
    #region Members
    private Fusba_Gn m_ParentObject;
    private AmtStructure m_Parm_Move_Rec;
    private AmtVarNumericOS2200 m_Pm_Ipos;
    private AmtVarNumericOS2200 m_Pm_Ilen;
    private AmtVarNumericOS2200 m_Pm_Opos;
    private AmtVarNumericOS2200 m_Pm_Olen;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_Move_Rec { [DebuggerStepThrough()] get { return m_Parm_Move_Rec; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pm_Ipos { [DebuggerStepThrough()] get { return m_Pm_Ipos; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pm_Ilen { [DebuggerStepThrough()] get { return m_Pm_Ilen; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pm_Opos { [DebuggerStepThrough()] get { return m_Pm_Opos; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pm_Olen { [DebuggerStepThrough()] get { return m_Pm_Olen; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_Move_Rec (Fusba_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_Move_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_Move_Rec.AddAlphaFiller(2);
          m_Pm_Ipos = new AmtVarNumericOS2200(5, m_Parm_Move_Rec);
          m_Pm_Ilen = new AmtVarNumericOS2200(5, m_Parm_Move_Rec);
          m_Pm_Opos = new AmtVarNumericOS2200(5, m_Parm_Move_Rec);
          m_Pm_Olen = new AmtVarNumericOS2200(5, m_Parm_Move_Rec);
          m_Parm_Move_Rec.AddAlphaFiller(58);
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

} // Namespace Federale.BSP.BusinessLogic.Fusba_Gn

