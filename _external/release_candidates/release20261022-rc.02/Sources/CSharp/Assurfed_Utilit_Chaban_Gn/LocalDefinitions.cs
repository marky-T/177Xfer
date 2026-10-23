using System.Diagnostics;
using Asysco.Amt.Runtime.Database;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Vars;

namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Chaban_Gn {

  public class LocalDefinitions: AmtBaseDefinitions {
    #region Members
    private Assurfed_Utilit_Chaban_Gn m_ParentObject;
    private readonly AmtVarAlpha m_Recin;
    private readonly AmtVarAlpha m_Ws_Rec;
    private readonly AmtVarNumericBinary9 m_Ws_In_Len;
    private readonly AmtNativeInt m_P_Card;
    private readonly AmtNativeInt m_P_Len;
    private readonly AmtNativeInt m_N_Rec;
    private readonly AmtNativeInt m_N_Per;
    private readonly AmtNativeInt m_R;
    private readonly AmtNativeInt m_C;
    private readonly AmtNativeInt m_Kp;
    private readonly AmtNativeInt m_Cp_Len;
    private readonly AmtNativeInt m_Nb_Cards;
    private readonly AmtNativeInt m_Nb_Out;
    private readonly AmtStructure m_Display_Line;
    private readonly AmtVarAlpha m_Disp_Message;
    private readonly AmtVarNumericOS2200 m_Disp_Ct;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha Recin { [DebuggerStepThrough()] get { return m_Recin; } }

    /// <summary>AmtVarAlpha 4200</summary>
    public AmtVarAlpha Ws_Rec { [DebuggerStepThrough()] get { return m_Ws_Rec; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Ws_In_Len { [DebuggerStepThrough()] get { return m_Ws_In_Len; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Card { [DebuggerStepThrough()] get { return m_P_Card; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Len { [DebuggerStepThrough()] get { return m_P_Len; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt N_Rec { [DebuggerStepThrough()] get { return m_N_Rec; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt N_Per { [DebuggerStepThrough()] get { return m_N_Per; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt R { [DebuggerStepThrough()] get { return m_R; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt C { [DebuggerStepThrough()] get { return m_C; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Kp { [DebuggerStepThrough()] get { return m_Kp; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Cp_Len { [DebuggerStepThrough()] get { return m_Cp_Len; } }

    /// <summary>AmtNativeInt 10</summary>
    public AmtNativeInt Nb_Cards { [DebuggerStepThrough()] get { return m_Nb_Cards; } }

    /// <summary>AmtNativeInt 10</summary>
    public AmtNativeInt Nb_Out { [DebuggerStepThrough()] get { return m_Nb_Out; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Display_Line { [DebuggerStepThrough()] get { return m_Display_Line; } }

    /// <summary>AmtVarAlpha 24</summary>
    public AmtVarAlpha Disp_Message { [DebuggerStepThrough()] get { return m_Disp_Message; } }

    /// <summary>AmtVarNumericOS2200 12</summary>
    public AmtVarNumericOS2200 Disp_Ct { [DebuggerStepThrough()] get { return m_Disp_Ct; } }
    #endregion Properties

    // Constructor
    public LocalDefinitions (Assurfed_Utilit_Chaban_Gn parentObject)
      : base(parentObject) {
      m_ParentObject = parentObject;
      m_Recin = new AmtVarAlpha(4001);
      m_Ws_Rec = new AmtVarAlpha(4200);
      m_Ws_In_Len = new AmtVarNumericBinary9(5, false);
      m_Ws_In_Len.InitialValue = 0;
      m_P_Card = new AmtNativeInt(6, false);
      m_P_Card.InitialValue = 80;
      m_P_Len = new AmtNativeInt(6, false);
      m_P_Len.InitialValue = 0;
      m_N_Rec = new AmtNativeInt(6, false);
      m_N_Rec.InitialValue = 0;
      m_N_Per = new AmtNativeInt(6, false);
      m_N_Per.InitialValue = 0;
      m_R = new AmtNativeInt(6, false);
      m_R.InitialValue = 0;
      m_C = new AmtNativeInt(6, false);
      m_C.InitialValue = 0;
      m_Kp = new AmtNativeInt(6, false);
      m_Kp.InitialValue = 0;
      m_Cp_Len = new AmtNativeInt(6, false);
      m_Cp_Len.InitialValue = 0;
      m_Nb_Cards = new AmtNativeInt(11, false);
      m_Nb_Cards.InitialValue = 0;
      m_Nb_Out = new AmtNativeInt(11, false);
      m_Nb_Out.InitialValue = 0;
      m_Display_Line = new AmtStructure();
      {
        m_Disp_Message = new AmtVarAlpha(24, m_Display_Line);
        m_Disp_Ct = new AmtVarNumericOS2200(12, "ZZZZZZZZZZZ9", m_Display_Line);
      }
      AllocateStructures();
    } // Constructor LocalDefinitions

    public override void ResetParent () {
      m_ParentObject = null;
      ResetDatabase();
    } // ResetParent

    public void ApplyNewParent (Assurfed_Utilit_Chaban_Gn parentObject) {
      m_ParentObject = parentObject;
      ApplyNewDatabase(parentObject);
    } // ApplyNewParent

    public void InitLocalDefinitions () {
      m_Recin.Initialise();
      m_Ws_Rec.Initialise();
      m_Ws_In_Len.Initialise();
      m_P_Card.Initialise();
      m_P_Len.Initialise();
      m_N_Rec.Initialise();
      m_N_Per.Initialise();
      m_R.Initialise();
      m_C.Initialise();
      m_Kp.Initialise();
      m_Cp_Len.Initialise();
      m_Nb_Cards.Initialise();
      m_Nb_Out.Initialise();
      m_Display_Line.Initialise();
      AmtRtDbsSupport.InitDbsClients(m_DbsClientList);
    } // InitLocalDefinitions

    public void AllocateStructures () {
      m_Display_Line.AllocStructure();
    } // AllocateStructures

  } // Class LocalDefinitions

} // Namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Chaban_Gn

