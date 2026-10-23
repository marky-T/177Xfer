using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Chaban_Gn {

  public class Fd_Parm_Nb_Rec: AmtFileLayout {
    #region Members
    private Assurfed_Utilit_Chaban_Gn m_ParentObject;
    private AmtStructure m_Parm_Nb_Rec;
    private AmtVarNumericOS2200 m_Pn_Rec;
    private AmtVarNumericOS2200 m_Pn_Per;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_Nb_Rec { [DebuggerStepThrough()] get { return m_Parm_Nb_Rec; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pn_Rec { [DebuggerStepThrough()] get { return m_Pn_Rec; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pn_Per { [DebuggerStepThrough()] get { return m_Pn_Per; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_Nb_Rec (Assurfed_Utilit_Chaban_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_Nb_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_Nb_Rec.AddAlphaFiller(2);
          m_Pn_Rec = new AmtVarNumericOS2200(5, m_Parm_Nb_Rec);
          m_Pn_Per = new AmtVarNumericOS2200(5, m_Parm_Nb_Rec);
          m_Parm_Nb_Rec.AddAlphaFiller(68);
        }
      }
      if (sharedLayout != null) {
        m_DataRecord.Redefines(sharedLayout.DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Parm_Nb_Rec

    public void Init () {
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_Nb_Rec

} // Namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Chaban_Gn

