using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Lectis_Gn {

  public class Fd_Parm_Cd_Rec: AmtFileLayout {
    #region Members
    private Lectis_Gn m_ParentObject;
    private AmtStructure m_Parm_Cd_Rec;
    private AmtVarAlpha m_Pc_Op;
    private AmtVarAlpha m_Pc_Rel;
    private AmtVarNumericOS2200 m_Pc_Litlen;
    private AmtVarAlpha m_Pc_Lit;
    private AmtStructure m_Pc_Litg;
    private AmtVarNumericOS2200 m_Pc_Litn;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_Cd_Rec { [DebuggerStepThrough()] get { return m_Parm_Cd_Rec; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Pc_Op { [DebuggerStepThrough()] get { return m_Pc_Op; } }

    /// <summary>AmtVarAlpha 2</summary>
    public AmtVarAlpha Pc_Rel { [DebuggerStepThrough()] get { return m_Pc_Rel; } }

    /// <summary>AmtVarNumericOS2200 3</summary>
    public AmtVarNumericOS2200 Pc_Litlen { [DebuggerStepThrough()] get { return m_Pc_Litlen; } }

    /// <summary>AmtVarAlpha 100</summary>
    public AmtVarAlpha Pc_Lit { [DebuggerStepThrough()] get { return m_Pc_Lit; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Pc_Litg { [DebuggerStepThrough()] get { return m_Pc_Litg; } }

    /// <summary>AmtVarNumericOS2200 9</summary>
    public AmtVarNumericOS2200 Pc_Litn { [DebuggerStepThrough()] get { return m_Pc_Litn; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_Cd_Rec (Lectis_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_Cd_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_Cd_Rec.AddAlphaFiller(2);
          m_Pc_Op = new AmtVarAlpha(1, m_Parm_Cd_Rec);
          m_Pc_Rel = new AmtVarAlpha(2, m_Parm_Cd_Rec);
          m_Pc_Litlen = new AmtVarNumericOS2200(3, m_Parm_Cd_Rec);
          m_Pc_Lit = new AmtVarAlpha(100, m_Parm_Cd_Rec);
          m_Pc_Litg = new AmtStructure(m_Parm_Cd_Rec);
          {
            m_Pc_Litg.Redefines(m_Pc_Lit);
            m_Pc_Litn = new AmtVarNumericOS2200(9, m_Pc_Litg);
            m_Pc_Litg.AddAlphaFiller(91);
          }
          m_Parm_Cd_Rec.AddAlphaFiller(142);
        }
      }
      if (sharedLayout != null) {
        m_DataRecord.Redefines(sharedLayout.DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Parm_Cd_Rec

    public void Init () {
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_Cd_Rec

} // Namespace Federale.BSP.BusinessLogic.Lectis_Gn

