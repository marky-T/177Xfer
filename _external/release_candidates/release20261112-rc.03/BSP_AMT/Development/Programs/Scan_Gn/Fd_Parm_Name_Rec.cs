using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Scan_Gn {

  public class Fd_Parm_Name_Rec: AmtFileLayout {
    #region Members
    private Scan_Gn m_ParentObject;
    private AmtStructure m_Parm_Name_Rec;
    private AmtVarAlpha m_Pn_Text;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_Name_Rec { [DebuggerStepThrough()] get { return m_Parm_Name_Rec; } }

    /// <summary>AmtVarAlpha 37</summary>
    public AmtVarAlpha Pn_Text { [DebuggerStepThrough()] get { return m_Pn_Text; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_Name_Rec (Scan_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_Name_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_Name_Rec.AddAlphaFiller(2);
          m_Pn_Text = new AmtVarAlpha(37, m_Parm_Name_Rec);
          m_Parm_Name_Rec.AddAlphaFiller(41);
        }
      }
      if (sharedLayout != null) {
        m_DataRecord.Redefines(sharedLayout.DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Parm_Name_Rec

    public void Init () {
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_Name_Rec

} // Namespace Federale.BSP.BusinessLogic.Scan_Gn

