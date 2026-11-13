using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Fusba_Gn {

  public class Fd_Parm_File_Rec: AmtFileLayout {
    #region Members
    private Fusba_Gn m_ParentObject;
    private AmtStructure m_Parm_File_Rec;
    private AmtVarAlpha m_Pf_Name;
    private AmtVarNumericOS2200 m_Pf_Len;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_File_Rec { [DebuggerStepThrough()] get { return m_Parm_File_Rec; } }

    /// <summary>AmtVarAlpha 30</summary>
    public AmtVarAlpha Pf_Name { [DebuggerStepThrough()] get { return m_Pf_Name; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pf_Len { [DebuggerStepThrough()] get { return m_Pf_Len; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_File_Rec (Fusba_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_File_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_File_Rec.AddAlphaFiller(2);
          m_Pf_Name = new AmtVarAlpha(30, m_Parm_File_Rec);
          m_Pf_Len = new AmtVarNumericOS2200(5, m_Parm_File_Rec);
          m_Parm_File_Rec.AddAlphaFiller(43);
        }
      }
      if (sharedLayout != null) {
        m_DataRecord.Redefines(sharedLayout.DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Parm_File_Rec

    public void Init () {
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_File_Rec

} // Namespace Federale.BSP.BusinessLogic.Fusba_Gn

