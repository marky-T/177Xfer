using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Scan_Gn {

  public class Fd_Parm_Max_Rec: AmtFileLayout {
    #region Members
    private Assurfed_Utilit_Scan_Gn m_ParentObject;
    private AmtStructure m_Parm_Max_Rec;
    private AmtVarNumericOS2200 m_Px_Max;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_Max_Rec { [DebuggerStepThrough()] get { return m_Parm_Max_Rec; } }

    /// <summary>AmtVarNumericOS2200 10</summary>
    public AmtVarNumericOS2200 Px_Max { [DebuggerStepThrough()] get { return m_Px_Max; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_Max_Rec (Assurfed_Utilit_Scan_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_Max_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_Max_Rec.AddAlphaFiller(2);
          m_Px_Max = new AmtVarNumericOS2200(10, m_Parm_Max_Rec);
          m_Parm_Max_Rec.AddAlphaFiller(68);
        }
      }
      if (sharedLayout != null) {
        m_DataRecord.Redefines(sharedLayout.DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Parm_Max_Rec

    public void Init () {
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_Max_Rec

} // Namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Scan_Gn

