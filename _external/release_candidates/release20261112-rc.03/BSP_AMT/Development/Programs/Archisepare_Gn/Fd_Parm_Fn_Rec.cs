using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Archisepare_Gn {

  public class Fd_Parm_Fn_Rec: AmtFileLayout {
    #region Members
    private Archisepare_Gn m_ParentObject;
    private AmtStructure m_Parm_Fn_Rec;
    private AmtVarAlpha m_Pn_Archi;
    private AmtVarAlpha m_Pn_Narchi;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_Fn_Rec { [DebuggerStepThrough()] get { return m_Parm_Fn_Rec; } }

    /// <summary>AmtVarAlpha 30</summary>
    public AmtVarAlpha Pn_Archi { [DebuggerStepThrough()] get { return m_Pn_Archi; } }

    /// <summary>AmtVarAlpha 30</summary>
    public AmtVarAlpha Pn_Narchi { [DebuggerStepThrough()] get { return m_Pn_Narchi; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_Fn_Rec (Archisepare_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_Fn_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_Fn_Rec.AddAlphaFiller(2);
          m_Pn_Archi = new AmtVarAlpha(30, m_Parm_Fn_Rec);
          m_Pn_Narchi = new AmtVarAlpha(30, m_Parm_Fn_Rec);
          m_Parm_Fn_Rec.AddAlphaFiller(188);
        }
      }
      if (sharedLayout != null) {
        m_DataRecord.Redefines(sharedLayout.DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Parm_Fn_Rec

    public void Init () {
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_Fn_Rec

} // Namespace Federale.BSP.BusinessLogic.Archisepare_Gn

