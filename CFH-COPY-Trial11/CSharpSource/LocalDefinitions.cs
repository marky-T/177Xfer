using System.Diagnostics;
using Asysco.Amt.Runtime.Database;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Vars;

namespace Company.AFBUS_2200COBOL.BusinessLogic.Assurfed_Utilit_Cfh_Copy {

  public class LocalDefinitions: AmtBaseDefinitions {
    #region Members
    private Assurfed_Utilit_Cfh_Copy m_ParentObject;
    private readonly AmtNativeInt m_Nb_Lus;
    private readonly AmtStructure m_Switches;
    private readonly AmtVarNumericOS2200 m_Rec_Skipped;
    #endregion Members

    #region Properties

    /// <summary>AmtNativeInt 10</summary>
    public AmtNativeInt Nb_Lus { [DebuggerStepThrough()] get { return m_Nb_Lus; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Switches { [DebuggerStepThrough()] get { return m_Switches; } }

    /// <summary>AmtVarNumericOS2200 6</summary>
    public AmtVarNumericOS2200 Rec_Skipped { [DebuggerStepThrough()] get { return m_Rec_Skipped; } }
    #endregion Properties

    // Constructor
    public LocalDefinitions (Assurfed_Utilit_Cfh_Copy parentObject)
      : base(parentObject) {
      m_ParentObject = parentObject;
      m_Nb_Lus = new AmtNativeInt(11, false);
      m_Nb_Lus.InitialValue = 0;
      m_Switches = new AmtStructure();
      {
        m_Rec_Skipped = new AmtVarNumericOS2200(6, true, m_Switches);
        m_Rec_Skipped.InitialValue = AmtConstRuntime.ZerosValueString;
      }
      AllocateStructures();
    } // Constructor LocalDefinitions

    public override void ResetParent () {
      m_ParentObject = null;
      ResetDatabase();
    } // ResetParent

    public void ApplyNewParent (Assurfed_Utilit_Cfh_Copy parentObject) {
      m_ParentObject = parentObject;
      ApplyNewDatabase(parentObject);
    } // ApplyNewParent

    public void InitLocalDefinitions () {
      m_Nb_Lus.Initialise();
      m_Switches.Initialise();
      AmtRtDbsSupport.InitDbsClients(m_DbsClientList);
    } // InitLocalDefinitions

    public void AllocateStructures () {
      m_Switches.AllocStructure();
    } // AllocateStructures

  } // Class LocalDefinitions

} // Namespace Company.AFBUS_2200COBOL.BusinessLogic.Assurfed_Utilit_Cfh_Copy

