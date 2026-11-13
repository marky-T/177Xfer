using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Lectis_Gn {

  public class Fd_Parm_Md_Rec: AmtFileLayout {
    #region Members
    private Lectis_Gn m_ParentObject;
    private AmtStructure m_Parm_Md_Rec;
    private AmtVarNumericOS2200 m_Pm_Keys;
    private AmtVarNumericOS2200 m_Pm_Nolist;
    private AmtVarNumericOS2200 m_Pm_Y2k;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_Md_Rec { [DebuggerStepThrough()] get { return m_Parm_Md_Rec; } }

    /// <summary>AmtVarNumericOS2200 1</summary>
    public AmtVarNumericOS2200 Pm_Keys { [DebuggerStepThrough()] get { return m_Pm_Keys; } }

    /// <summary>AmtVarNumericOS2200 1</summary>
    public AmtVarNumericOS2200 Pm_Nolist { [DebuggerStepThrough()] get { return m_Pm_Nolist; } }

    /// <summary>AmtVarNumericOS2200 1</summary>
    public AmtVarNumericOS2200 Pm_Y2k { [DebuggerStepThrough()] get { return m_Pm_Y2k; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_Md_Rec (Lectis_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_Md_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_Md_Rec.AddAlphaFiller(2);
          m_Pm_Keys = new AmtVarNumericOS2200(1, m_Parm_Md_Rec);
          m_Pm_Nolist = new AmtVarNumericOS2200(1, m_Parm_Md_Rec);
          m_Pm_Y2k = new AmtVarNumericOS2200(1, m_Parm_Md_Rec);
          m_Parm_Md_Rec.AddAlphaFiller(245);
        }
      }
      if (sharedLayout != null) {
        m_DataRecord.Redefines(sharedLayout.DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Parm_Md_Rec

    public void Init () {
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_Md_Rec

} // Namespace Federale.BSP.BusinessLogic.Lectis_Gn

