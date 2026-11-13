using System.Diagnostics;
using Asysco.Amt.Runtime.Database;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Baba_Gn {

  public class LocalDefinitions: AmtBaseDefinitions {
    #region Members
    private Baba_Gn m_ParentObject;
    private readonly AmtVarAlpha m_Recin;
    private readonly AmtVarAlpha m_Recout;
    private readonly AmtVarAlpha m_Ws_In;
    private readonly AmtVarAlpha m_Ws_Key;
    private readonly AmtVarAlpha m_Prev_Key;
    private readonly AmtVarNumericBinary9 m_Ws_In_Len;
    private readonly AmtNativeInt m_P_Inlen;
    private readonly AmtVarAlpha m_P_Mode;
    private readonly AmtVarAlpha m_P_Seq;
    private readonly AmtNativeInt m_N_Out;
    private readonly AmtNativeInt m_N_Kf;
    private readonly AmtNativeInt m_N_Rq;
    private readonly AmtNativeInt m_I;
    private readonly AmtNativeInt m_Kp;
    private readonly AmtNativeInt m_Key_Len;
    private readonly AmtNativeInt m_Cp_Len;
    private readonly AmtNativeInt m_Target;
    private readonly AmtVarAlpha m_Dup;
    private readonly AmtNativeInt m_Nb_Lus;
    private readonly AmtNativeInt m_Nb_Out1;
    private readonly AmtNativeInt m_Nb_Out2;
    private readonly AmtNativeInt m_Nb_Elim;
    private readonly AmtNativeInt m_Nb_Prev;
    private readonly AmtStructure m_Out_Tab;
    private readonly AmtVarNumericBinary9 m_Out_Len;
    private readonly AmtStructure m_Kf_Tab;
    private readonly AmtStructure m_Kf_Ent;
    private readonly AmtVarNumericBinary9 m_Kf_Pos;
    private readonly AmtVarNumericBinary9 m_Kf_Len;
    private readonly AmtStructure m_Rq_Tab;
    private readonly AmtStructure m_Rq_Ent;
    private readonly AmtVarNumericBinary9 m_Rq_Len;
    private readonly AmtVarAlpha m_Rq_Val;
    private readonly AmtStructure m_Display_Line;
    private readonly AmtVarAlpha m_Disp_Message;
    private readonly AmtVarNumericOS2200 m_Disp_Ct;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha Recin { [DebuggerStepThrough()] get { return m_Recin; } }

    /// <summary>AmtVarAlpha 4000</summary>
    public AmtVarAlpha Recout { [DebuggerStepThrough()] get { return m_Recout; } }

    /// <summary>AmtVarAlpha 4000</summary>
    public AmtVarAlpha Ws_In { [DebuggerStepThrough()] get { return m_Ws_In; } }

    /// <summary>AmtVarAlpha 400</summary>
    public AmtVarAlpha Ws_Key { [DebuggerStepThrough()] get { return m_Ws_Key; } }

    /// <summary>AmtVarAlpha 400</summary>
    public AmtVarAlpha Prev_Key { [DebuggerStepThrough()] get { return m_Prev_Key; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Ws_In_Len { [DebuggerStepThrough()] get { return m_Ws_In_Len; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Inlen { [DebuggerStepThrough()] get { return m_P_Inlen; } }

    /// <summary>AmtVarAlpha 3</summary>
    public AmtVarAlpha P_Mode { [DebuggerStepThrough()] get { return m_P_Mode; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha P_Seq { [DebuggerStepThrough()] get { return m_P_Seq; } }

    /// <summary>AmtNativeInt 3</summary>
    public AmtNativeInt N_Out { [DebuggerStepThrough()] get { return m_N_Out; } }

    /// <summary>AmtNativeInt 3</summary>
    public AmtNativeInt N_Kf { [DebuggerStepThrough()] get { return m_N_Kf; } }

    /// <summary>AmtNativeInt 3</summary>
    public AmtNativeInt N_Rq { [DebuggerStepThrough()] get { return m_N_Rq; } }

    /// <summary>AmtNativeInt 3</summary>
    public AmtNativeInt I { [DebuggerStepThrough()] get { return m_I; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Kp { [DebuggerStepThrough()] get { return m_Kp; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Key_Len { [DebuggerStepThrough()] get { return m_Key_Len; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Cp_Len { [DebuggerStepThrough()] get { return m_Cp_Len; } }

    /// <summary>AmtNativeInt 1</summary>
    public AmtNativeInt Target { [DebuggerStepThrough()] get { return m_Target; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Dup { [DebuggerStepThrough()] get { return m_Dup; } }

    /// <summary>AmtNativeInt 10</summary>
    public AmtNativeInt Nb_Lus { [DebuggerStepThrough()] get { return m_Nb_Lus; } }

    /// <summary>AmtNativeInt 10</summary>
    public AmtNativeInt Nb_Out1 { [DebuggerStepThrough()] get { return m_Nb_Out1; } }

    /// <summary>AmtNativeInt 10</summary>
    public AmtNativeInt Nb_Out2 { [DebuggerStepThrough()] get { return m_Nb_Out2; } }

    /// <summary>AmtNativeInt 10</summary>
    public AmtNativeInt Nb_Elim { [DebuggerStepThrough()] get { return m_Nb_Elim; } }

    /// <summary>AmtNativeInt 10</summary>
    public AmtNativeInt Nb_Prev { [DebuggerStepThrough()] get { return m_Nb_Prev; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Out_Tab { [DebuggerStepThrough()] get { return m_Out_Tab; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Out_Len { [DebuggerStepThrough()] get { return m_Out_Len; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Kf_Tab { [DebuggerStepThrough()] get { return m_Kf_Tab; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Kf_Ent { [DebuggerStepThrough()] get { return m_Kf_Ent; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Kf_Pos { [DebuggerStepThrough()] get { return m_Kf_Pos; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Kf_Len { [DebuggerStepThrough()] get { return m_Kf_Len; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Rq_Tab { [DebuggerStepThrough()] get { return m_Rq_Tab; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Rq_Ent { [DebuggerStepThrough()] get { return m_Rq_Ent; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Rq_Len { [DebuggerStepThrough()] get { return m_Rq_Len; } }

    /// <summary>AmtVarAlpha 393</summary>
    public AmtVarAlpha Rq_Val { [DebuggerStepThrough()] get { return m_Rq_Val; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Display_Line { [DebuggerStepThrough()] get { return m_Display_Line; } }

    /// <summary>AmtVarAlpha 24</summary>
    public AmtVarAlpha Disp_Message { [DebuggerStepThrough()] get { return m_Disp_Message; } }

    /// <summary>AmtVarNumericOS2200 12</summary>
    public AmtVarNumericOS2200 Disp_Ct { [DebuggerStepThrough()] get { return m_Disp_Ct; } }
    #endregion Properties

    // Constructor
    public LocalDefinitions (Baba_Gn parentObject)
      : base(parentObject) {
      m_ParentObject = parentObject;
      m_Recin = new AmtVarAlpha(4001);
      m_Recout = new AmtVarAlpha(4000);
      m_Ws_In = new AmtVarAlpha(4000);
      m_Ws_Key = new AmtVarAlpha(400);
      m_Prev_Key = new AmtVarAlpha(400);
      m_Ws_In_Len = new AmtVarNumericBinary9(5, false);
      m_Ws_In_Len.InitialValue = 0;
      m_P_Inlen = new AmtNativeInt(6, false);
      m_P_Inlen.InitialValue = 0;
      m_P_Mode = new AmtVarAlpha(3);
      m_P_Mode.InitialValue = "ALL";
      m_P_Seq = new AmtVarAlpha(1);
      m_P_Seq.InitialValue = "N";
      m_N_Out = new AmtNativeInt(6, false);
      m_N_Out.InitialValue = 0;
      m_N_Kf = new AmtNativeInt(6, false);
      m_N_Kf.InitialValue = 0;
      m_N_Rq = new AmtNativeInt(6, false);
      m_N_Rq.InitialValue = 0;
      m_I = new AmtNativeInt(6, false);
      m_I.InitialValue = 0;
      m_Kp = new AmtNativeInt(6, false);
      m_Kp.InitialValue = 0;
      m_Key_Len = new AmtNativeInt(6, false);
      m_Key_Len.InitialValue = 0;
      m_Cp_Len = new AmtNativeInt(6, false);
      m_Cp_Len.InitialValue = 0;
      m_Target = new AmtNativeInt(1, false);
      m_Target.InitialValue = 1;
      m_Dup = new AmtVarAlpha(1);
      m_Dup.InitialValue = "N";
      m_Nb_Lus = new AmtNativeInt(11, false);
      m_Nb_Lus.InitialValue = 0;
      m_Nb_Out1 = new AmtNativeInt(11, false);
      m_Nb_Out1.InitialValue = 0;
      m_Nb_Out2 = new AmtNativeInt(11, false);
      m_Nb_Out2.InitialValue = 0;
      m_Nb_Elim = new AmtNativeInt(11, false);
      m_Nb_Elim.InitialValue = 0;
      m_Nb_Prev = new AmtNativeInt(11, false);
      m_Nb_Prev.InitialValue = 0;
      m_Out_Tab = new AmtStructure();
      {
        m_Out_Len = new AmtVarNumericBinary9(5, false, m_Out_Tab);
        m_Out_Len.SetArrayBoundaries(2);
      }
      m_Kf_Tab = new AmtStructure();
      {
        m_Kf_Ent = new AmtStructure(m_Kf_Tab);
        m_Kf_Ent.SetArrayBoundaries(20);
        {
          m_Kf_Pos = new AmtVarNumericBinary9(5, false, m_Kf_Ent);
          m_Kf_Len = new AmtVarNumericBinary9(5, false, m_Kf_Ent);
        }
      }
      m_Rq_Tab = new AmtStructure();
      {
        m_Rq_Ent = new AmtStructure(m_Rq_Tab);
        m_Rq_Ent.SetArrayBoundaries(40);
        {
          m_Rq_Len = new AmtVarNumericBinary9(5, false, m_Rq_Ent);
          m_Rq_Val = new AmtVarAlpha(393, m_Rq_Ent);
        }
      }
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

    public void ApplyNewParent (Baba_Gn parentObject) {
      m_ParentObject = parentObject;
      ApplyNewDatabase(parentObject);
    } // ApplyNewParent

    public void InitLocalDefinitions () {
      m_Recin.Initialise();
      m_Recout.Initialise();
      m_Ws_In.Initialise();
      m_Ws_Key.Initialise();
      m_Prev_Key.Initialise();
      m_Ws_In_Len.Initialise();
      m_P_Inlen.Initialise();
      m_P_Mode.Initialise();
      m_P_Seq.Initialise();
      m_N_Out.Initialise();
      m_N_Kf.Initialise();
      m_N_Rq.Initialise();
      m_I.Initialise();
      m_Kp.Initialise();
      m_Key_Len.Initialise();
      m_Cp_Len.Initialise();
      m_Target.Initialise();
      m_Dup.Initialise();
      m_Nb_Lus.Initialise();
      m_Nb_Out1.Initialise();
      m_Nb_Out2.Initialise();
      m_Nb_Elim.Initialise();
      m_Nb_Prev.Initialise();
      m_Out_Tab.Initialise();
      m_Kf_Tab.Initialise();
      m_Rq_Tab.Initialise();
      m_Display_Line.Initialise();
      AmtRtDbsSupport.InitDbsClients(m_DbsClientList);
    } // InitLocalDefinitions

    public void AllocateStructures () {
      m_Out_Tab.AllocStructure();
      m_Kf_Tab.AllocStructure();
      m_Rq_Tab.AllocStructure();
      m_Display_Line.AllocStructure();
    } // AllocateStructures

  } // Class LocalDefinitions

} // Namespace Federale.BSP.BusinessLogic.Baba_Gn

