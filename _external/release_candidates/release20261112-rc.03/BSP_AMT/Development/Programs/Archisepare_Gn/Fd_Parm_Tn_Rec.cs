using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Archisepare_Gn {

  public class Fd_Parm_Tn_Rec: AmtFileLayout {
    #region Members
    private Archisepare_Gn m_ParentObject;
    private AmtStructure m_Parm_Tn_Rec;
    private AmtVarAlpha m_Pt_Base;
    private AmtVarAlpha m_Pt_Table;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_Tn_Rec { [DebuggerStepThrough()] get { return m_Parm_Tn_Rec; } }

    /// <summary>AmtVarAlpha 6</summary>
    public AmtVarAlpha Pt_Base { [DebuggerStepThrough()] get { return m_Pt_Base; } }

    /// <summary>AmtVarAlpha 30</summary>
    public AmtVarAlpha Pt_Table { [DebuggerStepThrough()] get { return m_Pt_Table; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_Tn_Rec (Archisepare_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_Tn_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_Tn_Rec.AddAlphaFiller(2);
          m_Pt_Base = new AmtVarAlpha(6, m_Parm_Tn_Rec);
          m_Pt_Table = new AmtVarAlpha(30, m_Parm_Tn_Rec);
          m_Parm_Tn_Rec.AddAlphaFiller(212);
        }
      }
      if (sharedLayout != null) {
        m_DataRecord.Redefines(sharedLayout.DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Parm_Tn_Rec

    public void Init () {
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_Tn_Rec

} // Namespace Federale.BSP.BusinessLogic.Archisepare_Gn

