using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Archiformat_Gn {

  public class Fd_Parm_Ky_Rec: AmtFileLayout {
    #region Members
    private Archiformat_Gn m_ParentObject;
    private AmtStructure m_Parm_Ky_Rec;
    private AmtVarAlpha m_Pk_Name;
    private AmtVarAlpha m_Pk_Type;
    private AmtVarNumericOS2200 m_Pk_Len;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_Ky_Rec { [DebuggerStepThrough()] get { return m_Parm_Ky_Rec; } }

    /// <summary>AmtVarAlpha 30</summary>
    public AmtVarAlpha Pk_Name { [DebuggerStepThrough()] get { return m_Pk_Name; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Pk_Type { [DebuggerStepThrough()] get { return m_Pk_Type; } }

    /// <summary>AmtVarNumericOS2200 5</summary>
    public AmtVarNumericOS2200 Pk_Len { [DebuggerStepThrough()] get { return m_Pk_Len; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_Ky_Rec (Archiformat_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_Ky_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_Ky_Rec.AddAlphaFiller(2);
          m_Pk_Name = new AmtVarAlpha(30, m_Parm_Ky_Rec);
          m_Pk_Type = new AmtVarAlpha(1, m_Parm_Ky_Rec);
          m_Pk_Len = new AmtVarNumericOS2200(5, m_Parm_Ky_Rec);
          m_Parm_Ky_Rec.AddAlphaFiller(212);
        }
      }
      if (sharedLayout != null) {
        m_DataRecord.Redefines(sharedLayout.DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Parm_Ky_Rec

    public void Init () {
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_Ky_Rec

} // Namespace Federale.BSP.BusinessLogic.Archiformat_Gn

