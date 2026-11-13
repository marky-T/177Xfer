using System.Diagnostics;
using Asysco.Amt.Runtime.Files;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Lectis_Gn {

  public class Fd_Parm_Yd_Rec: AmtFileLayout {
    #region Members
    private Lectis_Gn m_ParentObject;
    private AmtStructure m_Parm_Yd_Rec;
    private AmtVarNumericOS2200 m_Py_Nd;
    private AmtVarNumericOS2200 m_Py_Z5;
    private AmtVarNumericOS2200 m_Py_Pos;
    #endregion Members

    #region Properties

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Parm_Yd_Rec { [DebuggerStepThrough()] get { return m_Parm_Yd_Rec; } }

    /// <summary>AmtVarNumericOS2200 2</summary>
    public AmtVarNumericOS2200 Py_Nd { [DebuggerStepThrough()] get { return m_Py_Nd; } }

    /// <summary>AmtVarNumericOS2200 3</summary>
    public AmtVarNumericOS2200 Py_Z5 { [DebuggerStepThrough()] get { return m_Py_Z5; } }

    /// <summary>AmtVarNumericOS2200 3</summary>
    public AmtVarNumericOS2200 Py_Pos { [DebuggerStepThrough()] get { return m_Py_Pos; } }
    #endregion Properties

    // Constructor
    public Fd_Parm_Yd_Rec (Lectis_Gn parentObject, AmtFileLayout sharedLayout) {
      m_ParentObject = parentObject;
      m_DataRecord = new AmtStructure();
      {
        m_Parm_Yd_Rec = new AmtStructure(m_DataRecord);
        {
          m_Parm_Yd_Rec.AddAlphaFiller(2);
          m_Py_Nd = new AmtVarNumericOS2200(2, m_Parm_Yd_Rec);
          m_Py_Z5 = new AmtVarNumericOS2200(3, m_Parm_Yd_Rec);
          m_Py_Pos = new AmtVarNumericOS2200(3, m_Parm_Yd_Rec);
          m_Py_Pos.SetArrayBoundaries(40);
          m_Parm_Yd_Rec.AddAlphaFiller(123);
        }
      }
      if (sharedLayout != null) {
        m_DataRecord.Redefines(sharedLayout.DataRecord);
      }
      AllocateStructures();
    } // Constructor Fd_Parm_Yd_Rec

    public void Init () {
    } // Init

    public void AllocateStructures () {
      m_DataRecord.AllocStructure();
    } // AllocateStructures

  } // Class Fd_Parm_Yd_Rec

} // Namespace Federale.BSP.BusinessLogic.Lectis_Gn

