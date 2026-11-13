using System.Diagnostics;
using Asysco.Amt.Runtime.Database;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Fusba_Gn {

  public class LocalDefinitions: AmtBaseDefinitions {
    #region Members
    private Fusba_Gn m_ParentObject;
    private readonly AmtVarAlpha m_Recin;
    private readonly AmtVarAlpha m_Rec1;
    private readonly AmtVarAlpha m_Rec2;
    private readonly AmtVarAlpha m_Recout;
    private readonly AmtVarAlpha m_Key1;
    private readonly AmtVarAlpha m_Key2;
    private readonly AmtVarAlpha m_Prev_Key2;
    private readonly AmtVarNumericBinary9 m_Ws_Len1;
    private readonly AmtVarNumericBinary9 m_Ws_Len2;
    private readonly AmtNativeInt m_P_Len1;
    private readonly AmtNativeInt m_P_Len2;
    private readonly AmtNativeInt m_N_In;
    private readonly AmtNativeInt m_N_Out;
    private readonly AmtVarAlpha m_P_Mode;
    private readonly AmtNativeInt m_N_K1;
    private readonly AmtNativeInt m_N_K2;
    private readonly AmtNativeInt m_N_Fm;
    private readonly AmtNativeInt m_I;
    private readonly AmtNativeInt m_Kp;
    private readonly AmtNativeInt m_Kl;
    private readonly AmtNativeInt m_Kl2;
    private readonly AmtNativeInt m_Cp_Len;
    private readonly AmtNativeInt m_Target;
    private readonly AmtVarAlpha m_Eof1;
    private readonly AmtVarAlpha m_Eof2;
    private readonly AmtNativeInt m_Nb_Lus1;
    private readonly AmtNativeInt m_Nb_Lus2;
    private readonly AmtNativeInt m_Nb_Out1;
    private readonly AmtNativeInt m_Nb_Out2;
    private readonly AmtNativeInt m_Nb_Maj;
    private readonly AmtNativeInt m_Nb_Del;
    private readonly AmtStructure m_Out_Tab;
    private readonly AmtVarNumericBinary9 m_Out_Len;
    private readonly AmtStructure m_K1_Tab;
    private readonly AmtStructure m_K1_Ent;
    private readonly AmtVarNumericBinary9 m_K1_Pos;
    private readonly AmtVarNumericBinary9 m_K1_Len;
    private readonly AmtStructure m_K2_Tab;
    private readonly AmtStructure m_K2_Ent;
    private readonly AmtVarNumericBinary9 m_K2_Pos;
    private readonly AmtVarNumericBinary9 m_K2_Len;
    private readonly AmtStructure m_Fm_Tab;
    private readonly AmtStructure m_Fm_Ent;
    private readonly AmtVarNumericBinary9 m_Fm_Ipos;
    private readonly AmtVarNumericBinary9 m_Fm_Ilen;
    private readonly AmtVarNumericBinary9 m_Fm_Opos;
    private readonly AmtVarNumericBinary9 m_Fm_Olen;
    private readonly AmtStructure m_Display_Line;
    private readonly AmtVarAlpha m_Disp_Message;
    private readonly AmtVarNumericOS2200 m_Disp_Ct;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha Recin { [DebuggerStepThrough()] get { return m_Recin; } }

    /// <summary>AmtVarAlpha 4000</summary>
    public AmtVarAlpha Rec1 { [DebuggerStepThrough()] get { return m_Rec1; } }

    /// <summary>AmtVarAlpha 4000</summary>
    public AmtVarAlpha Rec2 { [DebuggerStepThrough()] get { return m_Rec2; } }

    /// <summary>AmtVarAlpha 4000</summary>
    public AmtVarAlpha Recout { [DebuggerStepThrough()] get { return m_Recout; } }

    /// <summary>AmtVarAlpha 400</summary>
    public AmtVarAlpha Key1 { [DebuggerStepThrough()] get { return m_Key1; } }

    /// <summary>AmtVarAlpha 400</summary>
    public AmtVarAlpha Key2 { [DebuggerStepThrough()] get { return m_Key2; } }

    /// <summary>AmtVarAlpha 400</summary>
    public AmtVarAlpha Prev_Key2 { [DebuggerStepThrough()] get { return m_Prev_Key2; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Ws_Len1 { [DebuggerStepThrough()] get { return m_Ws_Len1; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Ws_Len2 { [DebuggerStepThrough()] get { return m_Ws_Len2; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Len1 { [DebuggerStepThrough()] get { return m_P_Len1; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Len2 { [DebuggerStepThrough()] get { return m_P_Len2; } }

    /// <summary>AmtNativeInt 3</summary>
    public AmtNativeInt N_In { [DebuggerStepThrough()] get { return m_N_In; } }

    /// <summary>AmtNativeInt 3</summary>
    public AmtNativeInt N_Out { [DebuggerStepThrough()] get { return m_N_Out; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha P_Mode { [DebuggerStepThrough()] get { return m_P_Mode; } }

    /// <summary>AmtNativeInt 3</summary>
    public AmtNativeInt N_K1 { [DebuggerStepThrough()] get { return m_N_K1; } }

    /// <summary>AmtNativeInt 3</summary>
    public AmtNativeInt N_K2 { [DebuggerStepThrough()] get { return m_N_K2; } }

    /// <summary>AmtNativeInt 3</summary>
    public AmtNativeInt N_Fm { [DebuggerStepThrough()] get { return m_N_Fm; } }

    /// <summary>AmtNativeInt 3</summary>
    public AmtNativeInt I { [DebuggerStepThrough()] get { return m_I; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Kp { [DebuggerStepThrough()] get { return m_Kp; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Kl { [DebuggerStepThrough()] get { return m_Kl; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Kl2 { [DebuggerStepThrough()] get { return m_Kl2; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Cp_Len { [DebuggerStepThrough()] get { return m_Cp_Len; } }

    /// <summary>AmtNativeInt 1</summary>
    public AmtNativeInt Target { [DebuggerStepThrough()] get { return m_Target; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Eof1 { [DebuggerStepThrough()] get { return m_Eof1; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Eof2 { [DebuggerStepThrough()] get { return m_Eof2; } }

    /// <summary>AmtNativeInt 10</summary>
    public AmtNativeInt Nb_Lus1 { [DebuggerStepThrough()] get { return m_Nb_Lus1; } }

    /// <summary>AmtNativeInt 10</summary>
    public AmtNativeInt Nb_Lus2 { [DebuggerStepThrough()] get { return m_Nb_Lus2; } }

    /// <summary>AmtNativeInt 10</summary>
    public AmtNativeInt Nb_Out1 { [DebuggerStepThrough()] get { return m_Nb_Out1; } }

    /// <summary>AmtNativeInt 10</summary>
    public AmtNativeInt Nb_Out2 { [DebuggerStepThrough()] get { return m_Nb_Out2; } }

    /// <summary>AmtNativeInt 10</summary>
    public AmtNativeInt Nb_Maj { [DebuggerStepThrough()] get { return m_Nb_Maj; } }

    /// <summary>AmtNativeInt 10</summary>
    public AmtNativeInt Nb_Del { [DebuggerStepThrough()] get { return m_Nb_Del; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Out_Tab { [DebuggerStepThrough()] get { return m_Out_Tab; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Out_Len { [DebuggerStepThrough()] get { return m_Out_Len; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure K1_Tab { [DebuggerStepThrough()] get { return m_K1_Tab; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure K1_Ent { [DebuggerStepThrough()] get { return m_K1_Ent; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 K1_Pos { [DebuggerStepThrough()] get { return m_K1_Pos; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 K1_Len { [DebuggerStepThrough()] get { return m_K1_Len; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure K2_Tab { [DebuggerStepThrough()] get { return m_K2_Tab; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure K2_Ent { [DebuggerStepThrough()] get { return m_K2_Ent; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 K2_Pos { [DebuggerStepThrough()] get { return m_K2_Pos; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 K2_Len { [DebuggerStepThrough()] get { return m_K2_Len; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Fm_Tab { [DebuggerStepThrough()] get { return m_Fm_Tab; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Fm_Ent { [DebuggerStepThrough()] get { return m_Fm_Ent; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Fm_Ipos { [DebuggerStepThrough()] get { return m_Fm_Ipos; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Fm_Ilen { [DebuggerStepThrough()] get { return m_Fm_Ilen; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Fm_Opos { [DebuggerStepThrough()] get { return m_Fm_Opos; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Fm_Olen { [DebuggerStepThrough()] get { return m_Fm_Olen; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Display_Line { [DebuggerStepThrough()] get { return m_Display_Line; } }

    /// <summary>AmtVarAlpha 24</summary>
    public AmtVarAlpha Disp_Message { [DebuggerStepThrough()] get { return m_Disp_Message; } }

    /// <summary>AmtVarNumericOS2200 12</summary>
    public AmtVarNumericOS2200 Disp_Ct { [DebuggerStepThrough()] get { return m_Disp_Ct; } }
    #endregion Properties

    // Constructor
    public LocalDefinitions (Fusba_Gn parentObject)
      : base(parentObject) {
      m_ParentObject = parentObject;
      m_Recin = new AmtVarAlpha(4001);
      m_Rec1 = new AmtVarAlpha(4000);
      m_Rec2 = new AmtVarAlpha(4000);
      m_Recout = new AmtVarAlpha(4000);
      m_Key1 = new AmtVarAlpha(400);
      m_Key2 = new AmtVarAlpha(400);
      m_Prev_Key2 = new AmtVarAlpha(400);
      m_Ws_Len1 = new AmtVarNumericBinary9(5, false);
      m_Ws_Len1.InitialValue = 0;
      m_Ws_Len2 = new AmtVarNumericBinary9(5, false);
      m_Ws_Len2.InitialValue = 0;
      m_P_Len1 = new AmtNativeInt(6, false);
      m_P_Len1.InitialValue = 0;
      m_P_Len2 = new AmtNativeInt(6, false);
      m_P_Len2.InitialValue = 0;
      m_N_In = new AmtNativeInt(6, false);
      m_N_In.InitialValue = 0;
      m_N_Out = new AmtNativeInt(6, false);
      m_N_Out.InitialValue = 0;
      m_P_Mode = new AmtVarAlpha(1);
      m_P_Mode.InitialValue = "C";
      m_N_K1 = new AmtNativeInt(6, false);
      m_N_K1.InitialValue = 0;
      m_N_K2 = new AmtNativeInt(6, false);
      m_N_K2.InitialValue = 0;
      m_N_Fm = new AmtNativeInt(6, false);
      m_N_Fm.InitialValue = 0;
      m_I = new AmtNativeInt(6, false);
      m_I.InitialValue = 0;
      m_Kp = new AmtNativeInt(6, false);
      m_Kp.InitialValue = 0;
      m_Kl = new AmtNativeInt(6, false);
      m_Kl.InitialValue = 0;
      m_Kl2 = new AmtNativeInt(6, false);
      m_Kl2.InitialValue = 0;
      m_Cp_Len = new AmtNativeInt(6, false);
      m_Cp_Len.InitialValue = 0;
      m_Target = new AmtNativeInt(1, false);
      m_Target.InitialValue = 1;
      m_Eof1 = new AmtVarAlpha(1);
      m_Eof1.InitialValue = "N";
      m_Eof2 = new AmtVarAlpha(1);
      m_Eof2.InitialValue = "N";
      m_Nb_Lus1 = new AmtNativeInt(11, false);
      m_Nb_Lus1.InitialValue = 0;
      m_Nb_Lus2 = new AmtNativeInt(11, false);
      m_Nb_Lus2.InitialValue = 0;
      m_Nb_Out1 = new AmtNativeInt(11, false);
      m_Nb_Out1.InitialValue = 0;
      m_Nb_Out2 = new AmtNativeInt(11, false);
      m_Nb_Out2.InitialValue = 0;
      m_Nb_Maj = new AmtNativeInt(11, false);
      m_Nb_Maj.InitialValue = 0;
      m_Nb_Del = new AmtNativeInt(11, false);
      m_Nb_Del.InitialValue = 0;
      m_Out_Tab = new AmtStructure();
      {
        m_Out_Len = new AmtVarNumericBinary9(5, false, m_Out_Tab);
        m_Out_Len.SetArrayBoundaries(2);
      }
      m_K1_Tab = new AmtStructure();
      {
        m_K1_Ent = new AmtStructure(m_K1_Tab);
        m_K1_Ent.SetArrayBoundaries(20);
        {
          m_K1_Pos = new AmtVarNumericBinary9(5, false, m_K1_Ent);
          m_K1_Len = new AmtVarNumericBinary9(5, false, m_K1_Ent);
        }
      }
      m_K2_Tab = new AmtStructure();
      {
        m_K2_Ent = new AmtStructure(m_K2_Tab);
        m_K2_Ent.SetArrayBoundaries(20);
        {
          m_K2_Pos = new AmtVarNumericBinary9(5, false, m_K2_Ent);
          m_K2_Len = new AmtVarNumericBinary9(5, false, m_K2_Ent);
        }
      }
      m_Fm_Tab = new AmtStructure();
      {
        m_Fm_Ent = new AmtStructure(m_Fm_Tab);
        m_Fm_Ent.SetArrayBoundaries(20);
        {
          m_Fm_Ipos = new AmtVarNumericBinary9(5, false, m_Fm_Ent);
          m_Fm_Ilen = new AmtVarNumericBinary9(5, false, m_Fm_Ent);
          m_Fm_Opos = new AmtVarNumericBinary9(5, false, m_Fm_Ent);
          m_Fm_Olen = new AmtVarNumericBinary9(5, false, m_Fm_Ent);
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

    public void ApplyNewParent (Fusba_Gn parentObject) {
      m_ParentObject = parentObject;
      ApplyNewDatabase(parentObject);
    } // ApplyNewParent

    public void InitLocalDefinitions () {
      m_Recin.Initialise();
      m_Rec1.Initialise();
      m_Rec2.Initialise();
      m_Recout.Initialise();
      m_Key1.Initialise();
      m_Key2.Initialise();
      m_Prev_Key2.Initialise();
      m_Ws_Len1.Initialise();
      m_Ws_Len2.Initialise();
      m_P_Len1.Initialise();
      m_P_Len2.Initialise();
      m_N_In.Initialise();
      m_N_Out.Initialise();
      m_P_Mode.Initialise();
      m_N_K1.Initialise();
      m_N_K2.Initialise();
      m_N_Fm.Initialise();
      m_I.Initialise();
      m_Kp.Initialise();
      m_Kl.Initialise();
      m_Kl2.Initialise();
      m_Cp_Len.Initialise();
      m_Target.Initialise();
      m_Eof1.Initialise();
      m_Eof2.Initialise();
      m_Nb_Lus1.Initialise();
      m_Nb_Lus2.Initialise();
      m_Nb_Out1.Initialise();
      m_Nb_Out2.Initialise();
      m_Nb_Maj.Initialise();
      m_Nb_Del.Initialise();
      m_Out_Tab.Initialise();
      m_K1_Tab.Initialise();
      m_K2_Tab.Initialise();
      m_Fm_Tab.Initialise();
      m_Display_Line.Initialise();
      AmtRtDbsSupport.InitDbsClients(m_DbsClientList);
    } // InitLocalDefinitions

    public void AllocateStructures () {
      m_Out_Tab.AllocStructure();
      m_K1_Tab.AllocStructure();
      m_K2_Tab.AllocStructure();
      m_Fm_Tab.AllocStructure();
      m_Display_Line.AllocStructure();
    } // AllocateStructures

  } // Class LocalDefinitions

} // Namespace Federale.BSP.BusinessLogic.Fusba_Gn

