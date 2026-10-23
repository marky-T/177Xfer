using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Fusba_Gn {

  public class Fd_Parm_Mode_Rec: AmtFileLayout {
    #region Members
    private Assurfed_Utilit_Fusba_Gn m_ParentObject;
    private AmtStructure m_Parm_Mode_Rec;
    private AmtVarAlpha m_Pd_Mode;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_Mode_Rec { [DebuggerStepThrough()] get { return m_Parm_Mode_Rec; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Pd_Mode { [DebuggerStepThrough()] get { return m_Pd_Mode; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_Mode_Rec (Assurfed_Utilit_Fusba_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_Mode_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_Mode_Rec.AddAlphaFiller(2);
          m_Pd_Mode = new AmtVarAlpha(1, m_Parm_Mode_Rec);
          m_Parm_Mode_Rec.AddAlphaFiller(77);
        }
      }
      if (sharedLayout != null) {
        m_DataRecord.Redefines(sharedLayout.DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Parm_Mode_Rec

    public void Init () {
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_Mode_Rec

} // Namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Fusba_Gn

