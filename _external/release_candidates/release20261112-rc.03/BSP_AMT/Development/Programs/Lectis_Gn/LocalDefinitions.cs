using System.Diagnostics;
using Asysco.Amt.Runtime.Database;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Lectis_Gn {

  public class LocalDefinitions: AmtBaseDefinitions {
    #region Members
    private Lectis_Gn m_ParentObject;
    private readonly AmtNativeInt64 m_Imp_Linecount;
    private readonly AmtVarNumericBinary9 m_Ws_In_Len;
    private readonly AmtVarNumericBinary9 m_Ws_Crd_Len;
    private readonly AmtNativeInt m_P_Len;
    private readonly AmtNativeInt m_P_Off;
    private readonly AmtNativeInt m_P_Klen;
    private readonly AmtVarNumericOS2200 m_P_Keys;
    private readonly AmtVarNumericOS2200 m_P_Nolist;
    private readonly AmtVarNumericOS2200 m_P_Y2k;
    private readonly AmtVarAlpha m_P_Op;
    private readonly AmtVarAlpha m_P_Rel;
    private readonly AmtNativeInt m_P_Litlen;
    private readonly AmtNativeInt m_P_Litn;
    private readonly AmtVarAlpha m_P_Lit;
    private readonly AmtNativeInt m_P_Nd;
    private readonly AmtNativeInt m_P_Z5;
    private readonly AmtStructure m_Yp_Tab;
    private readonly AmtVarNumericBinary9 m_Yp;
    private readonly AmtNativeInt m_Da;
    private readonly AmtNativeInt m_Cp_Len;
    private readonly AmtNativeInt m_Cc_Len;
    private readonly AmtNativeInt m_Zl_Len;
    private readonly AmtNativeInt m_Kp;
    private readonly AmtVarNumericOS2200 m_Cond_Ok;
    private readonly AmtVarAlpha m_Recin;
    private readonly AmtVarAlpha m_Crdrec;
    private readonly AmtVarAlpha m_Zl1;
    private readonly AmtVarAlpha m_Symk_W;
    private readonly AmtVarAlpha m_W_A;
    private readonly AmtVarAlpha m_W_B;
    private readonly AmtVarAlpha m_Wrec;
    private readonly AmtNativeInt m_Indexi;
    private readonly AmtNativeInt m_Indexo;
    private readonly AmtNativeInt m_Sw_Avant;
    private readonly AmtNativeInt m_Dcnt;
    private readonly AmtNativeInt m_W3;
    private readonly AmtVarAlpha m_Ws_Mark;
    private readonly AmtStructure m_Tab_Input;
    private readonly AmtVarAlpha m_Tab_I;
    private readonly AmtStructure m_Tab_Output;
    private readonly AmtVarAlpha m_Tab_O;
    private readonly AmtStructure m_Tit;
    private readonly AmtVarNumericOS2200 m_Filco;
    private readonly AmtStructure m_Zpr;
    private readonly AmtVarAlpha m_Zp1;
    private readonly AmtVarAlpha m_Zp2;
    private readonly AmtVarAlpha m_Zp3;
    private readonly AmtVarAlpha m_Zp4;
    private readonly AmtVarAlpha m_Zp5;
    private readonly AmtVarAlpha m_Zp6;
    private readonly AmtVarAlpha m_Zp7;
    private readonly AmtVarAlpha m_Zp8;
    private readonly AmtVarAlpha m_Zp9;
    private readonly AmtVarAlpha m_Zp10;
    private readonly AmtVarAlpha m_Zp11;
    private readonly AmtVarAlpha m_Zp12;
    private readonly AmtVarAlpha m_Zp13;
    private readonly AmtVarAlpha m_Zp14;
    private readonly AmtVarAlpha m_Zp15;
    private readonly AmtVarAlpha m_Zp16;
    private readonly AmtVarAlpha m_Zp17;
    private readonly AmtVarAlpha m_Zp18;
    private readonly AmtVarAlpha m_Zp19;
    private readonly AmtVarAlpha m_Zp20;
    private readonly AmtVarNumericOS2200 m_Ctrli;
    private readonly AmtNativeInt m_Ctr;
    private readonly AmtNativeInt m_Swi;
    #endregion Members

    #region Properties

    /// <summary>AmtNativeInt64</summary>
    public AmtNativeInt64 Imp_Linecount { [DebuggerStepThrough()] get { return m_Imp_Linecount; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Ws_In_Len { [DebuggerStepThrough()] get { return m_Ws_In_Len; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Ws_Crd_Len { [DebuggerStepThrough()] get { return m_Ws_Crd_Len; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Len { [DebuggerStepThrough()] get { return m_P_Len; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Off { [DebuggerStepThrough()] get { return m_P_Off; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Klen { [DebuggerStepThrough()] get { return m_P_Klen; } }

    /// <summary>AmtVarNumericOS2200 1</summary>
    public AmtVarNumericOS2200 P_Keys { [DebuggerStepThrough()] get { return m_P_Keys; } }

    /// <summary>AmtVarNumericOS2200 1</summary>
    public AmtVarNumericOS2200 P_Nolist { [DebuggerStepThrough()] get { return m_P_Nolist; } }

    /// <summary>AmtVarNumericOS2200 1</summary>
    public AmtVarNumericOS2200 P_Y2k { [DebuggerStepThrough()] get { return m_P_Y2k; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha P_Op { [DebuggerStepThrough()] get { return m_P_Op; } }

    /// <summary>AmtVarAlpha 2</summary>
    public AmtVarAlpha P_Rel { [DebuggerStepThrough()] get { return m_P_Rel; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Litlen { [DebuggerStepThrough()] get { return m_P_Litlen; } }

    /// <summary>AmtNativeInt 9</summary>
    public AmtNativeInt P_Litn { [DebuggerStepThrough()] get { return m_P_Litn; } }

    /// <summary>AmtVarAlpha 100</summary>
    public AmtVarAlpha P_Lit { [DebuggerStepThrough()] get { return m_P_Lit; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Nd { [DebuggerStepThrough()] get { return m_P_Nd; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Z5 { [DebuggerStepThrough()] get { return m_P_Z5; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Yp_Tab { [DebuggerStepThrough()] get { return m_Yp_Tab; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Yp { [DebuggerStepThrough()] get { return m_Yp; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Da { [DebuggerStepThrough()] get { return m_Da; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Cp_Len { [DebuggerStepThrough()] get { return m_Cp_Len; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Cc_Len { [DebuggerStepThrough()] get { return m_Cc_Len; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Zl_Len { [DebuggerStepThrough()] get { return m_Zl_Len; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Kp { [DebuggerStepThrough()] get { return m_Kp; } }

    /// <summary>AmtVarNumericOS2200 1</summary>
    public AmtVarNumericOS2200 Cond_Ok { [DebuggerStepThrough()] get { return m_Cond_Ok; } }

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha Recin { [DebuggerStepThrough()] get { return m_Recin; } }

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha Crdrec { [DebuggerStepThrough()] get { return m_Crdrec; } }

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha Zl1 { [DebuggerStepThrough()] get { return m_Zl1; } }

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha Symk_W { [DebuggerStepThrough()] get { return m_Symk_W; } }

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha W_A { [DebuggerStepThrough()] get { return m_W_A; } }

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha W_B { [DebuggerStepThrough()] get { return m_W_B; } }

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha Wrec { [DebuggerStepThrough()] get { return m_Wrec; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Indexi { [DebuggerStepThrough()] get { return m_Indexi; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Indexo { [DebuggerStepThrough()] get { return m_Indexo; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Sw_Avant { [DebuggerStepThrough()] get { return m_Sw_Avant; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Dcnt { [DebuggerStepThrough()] get { return m_Dcnt; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt W3 { [DebuggerStepThrough()] get { return m_W3; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Ws_Mark { [DebuggerStepThrough()] get { return m_Ws_Mark; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Tab_Input { [DebuggerStepThrough()] get { return m_Tab_Input; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Tab_I { [DebuggerStepThrough()] get { return m_Tab_I; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Tab_Output { [DebuggerStepThrough()] get { return m_Tab_Output; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Tab_O { [DebuggerStepThrough()] get { return m_Tab_O; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Tit { [DebuggerStepThrough()] get { return m_Tit; } }

    /// <summary>AmtVarNumericOS2200 7</summary>
    public AmtVarNumericOS2200 Filco { [DebuggerStepThrough()] get { return m_Filco; } }

    /// <summary>AmtStructure 0 USAGE DISP-1</summary>
    public AmtStructure Zpr { [DebuggerStepThrough()] get { return m_Zpr; } }

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Zp1 { [DebuggerStepThrough()] get { return m_Zp1; } }

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Zp2 { [DebuggerStepThrough()] get { return m_Zp2; } }

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Zp3 { [DebuggerStepThrough()] get { return m_Zp3; } }

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Zp4 { [DebuggerStepThrough()] get { return m_Zp4; } }

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Zp5 { [DebuggerStepThrough()] get { return m_Zp5; } }

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Zp6 { [DebuggerStepThrough()] get { return m_Zp6; } }

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Zp7 { [DebuggerStepThrough()] get { return m_Zp7; } }

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Zp8 { [DebuggerStepThrough()] get { return m_Zp8; } }

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Zp9 { [DebuggerStepThrough()] get { return m_Zp9; } }

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Zp10 { [DebuggerStepThrough()] get { return m_Zp10; } }

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Zp11 { [DebuggerStepThrough()] get { return m_Zp11; } }

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Zp12 { [DebuggerStepThrough()] get { return m_Zp12; } }

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Zp13 { [DebuggerStepThrough()] get { return m_Zp13; } }

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Zp14 { [DebuggerStepThrough()] get { return m_Zp14; } }

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Zp15 { [DebuggerStepThrough()] get { return m_Zp15; } }

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Zp16 { [DebuggerStepThrough()] get { return m_Zp16; } }

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Zp17 { [DebuggerStepThrough()] get { return m_Zp17; } }

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Zp18 { [DebuggerStepThrough()] get { return m_Zp18; } }

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Zp19 { [DebuggerStepThrough()] get { return m_Zp19; } }

    /// <summary>AmtVarAlpha 100 USAGE DISP-1</summary>
    public AmtVarAlpha Zp20 { [DebuggerStepThrough()] get { return m_Zp20; } }

    /// <summary>AmtVarNumericOS2200 4</summary>
    public AmtVarNumericOS2200 Ctrli { [DebuggerStepThrough()] get { return m_Ctrli; } }

    /// <summary>AmtNativeInt 7</summary>
    public AmtNativeInt Ctr { [DebuggerStepThrough()] get { return m_Ctr; } }

    /// <summary>AmtNativeInt 1</summary>
    public AmtNativeInt Swi { [DebuggerStepThrough()] get { return m_Swi; } }
    #endregion Properties

    // Constructor
    public LocalDefinitions (Lectis_Gn parentObject)
      : base(parentObject) {
      m_ParentObject = parentObject;
      m_Imp_Linecount = new AmtNativeInt64();
      m_Imp_Linecount.InitialValue = 1;
      m_Ws_In_Len = new AmtVarNumericBinary9(5, false);
      m_Ws_In_Len.InitialValue = 0;
      m_Ws_Crd_Len = new AmtVarNumericBinary9(5, false);
      m_Ws_Crd_Len.InitialValue = 0;
      m_P_Len = new AmtNativeInt(6, false);
      m_P_Len.InitialValue = 0;
      m_P_Off = new AmtNativeInt(6, false);
      m_P_Off.InitialValue = 0;
      m_P_Klen = new AmtNativeInt(6, false);
      m_P_Klen.InitialValue = 0;
      m_P_Keys = new AmtVarNumericOS2200(1);
      m_P_Keys.InitialValue = 0;
      m_P_Nolist = new AmtVarNumericOS2200(1);
      m_P_Nolist.InitialValue = 0;
      m_P_Y2k = new AmtVarNumericOS2200(1);
      m_P_Y2k.InitialValue = 0;
      m_P_Op = new AmtVarAlpha(1);
      m_P_Op.InitialValue = AmtConstRuntime.SpacesValueString;
      m_P_Rel = new AmtVarAlpha(2);
      m_P_Rel.InitialValue = AmtConstRuntime.SpacesValueString;
      m_P_Litlen = new AmtNativeInt(6, false);
      m_P_Litlen.InitialValue = 0;
      m_P_Litn = new AmtNativeInt(11, false);
      m_P_Litn.InitialValue = 0;
      m_P_Lit = new AmtVarAlpha(100);
      m_P_Lit.InitialValue = AmtConstRuntime.SpacesValueString;
      m_P_Nd = new AmtNativeInt(6, false);
      m_P_Nd.InitialValue = 0;
      m_P_Z5 = new AmtNativeInt(6, false);
      m_P_Z5.InitialValue = 0;
      m_Yp_Tab = new AmtStructure();
      {
        m_Yp = new AmtVarNumericBinary9(5, false, m_Yp_Tab);
        m_Yp.SetArrayBoundaries(40);
      }
      m_Da = new AmtNativeInt(6, false);
      m_Da.InitialValue = 0;
      m_Cp_Len = new AmtNativeInt(6, false);
      m_Cp_Len.InitialValue = 0;
      m_Cc_Len = new AmtNativeInt(6, false);
      m_Cc_Len.InitialValue = 0;
      m_Zl_Len = new AmtNativeInt(6, false);
      m_Zl_Len.InitialValue = 0;
      m_Kp = new AmtNativeInt(6, false);
      m_Kp.InitialValue = 0;
      m_Cond_Ok = new AmtVarNumericOS2200(1);
      m_Cond_Ok.InitialValue = 0;
      m_Recin = new AmtVarAlpha(4001);
      m_Crdrec = new AmtVarAlpha(4001);
      m_Zl1 = new AmtVarAlpha(4001);
      m_Symk_W = new AmtVarAlpha(4001);
      m_W_A = new AmtVarAlpha(4001);
      m_W_B = new AmtVarAlpha(4001);
      m_Wrec = new AmtVarAlpha(4001);
      m_Indexi = new AmtNativeInt(6, false);
      m_Indexi.InitialValue = 0;
      m_Indexo = new AmtNativeInt(6, false);
      m_Indexo.InitialValue = 0;
      m_Sw_Avant = new AmtNativeInt(6, false);
      m_Sw_Avant.InitialValue = 0;
      m_Dcnt = new AmtNativeInt(6, true);
      m_Dcnt.InitialValue = 0;
      m_W3 = new AmtNativeInt(6, false);
      m_W3.InitialValue = 0;
      m_Ws_Mark = new AmtVarAlpha(1);
      m_Ws_Mark.InitialValue = AmtConstRuntime.SpacesValueString;
      m_Tab_Input = new AmtStructure();
      {
        m_Tab_I = new AmtVarAlpha(1, m_Tab_Input);
        m_Tab_I.SetArrayBoundaries(4200);
      }
      m_Tab_Output = new AmtStructure();
      {
        m_Tab_O = new AmtVarAlpha(1, m_Tab_Output);
        m_Tab_O.SetArrayBoundaries(4200);
      }
      m_Tit = new AmtStructure();
      {
        m_Tit.AddAlphaFiller(5, "***  ");
        m_Tit.AddAlphaFiller(14, "RECORD NUMERO ");
        m_Filco = new AmtVarNumericOS2200(7, "Z,ZZZ,ZZZ", m_Tit);
        m_Tit.AddAlphaFiller(5, "  ***");
      }
      m_Zpr = new AmtStructure();
      {
        m_Zpr.InitialValue = AmtConstRuntime.SpacesValueString;
        m_Zp1 = new AmtVarAlpha(100, m_Zpr);
        m_Zp2 = new AmtVarAlpha(100, m_Zpr);
        m_Zp3 = new AmtVarAlpha(100, m_Zpr);
        m_Zp4 = new AmtVarAlpha(100, m_Zpr);
        m_Zp5 = new AmtVarAlpha(100, m_Zpr);
        m_Zp6 = new AmtVarAlpha(100, m_Zpr);
        m_Zp7 = new AmtVarAlpha(100, m_Zpr);
        m_Zp8 = new AmtVarAlpha(100, m_Zpr);
        m_Zp9 = new AmtVarAlpha(100, m_Zpr);
        m_Zp10 = new AmtVarAlpha(100, m_Zpr);
        m_Zp11 = new AmtVarAlpha(100, m_Zpr);
        m_Zp12 = new AmtVarAlpha(100, m_Zpr);
        m_Zp13 = new AmtVarAlpha(100, m_Zpr);
        m_Zp14 = new AmtVarAlpha(100, m_Zpr);
        m_Zp15 = new AmtVarAlpha(100, m_Zpr);
        m_Zp16 = new AmtVarAlpha(100, m_Zpr);
        m_Zp17 = new AmtVarAlpha(100, m_Zpr);
        m_Zp18 = new AmtVarAlpha(100, m_Zpr);
        m_Zp19 = new AmtVarAlpha(100, m_Zpr);
        m_Zp20 = new AmtVarAlpha(100, m_Zpr);
      }
      m_Ctrli = new AmtVarNumericOS2200(4);
      m_Ctrli.InitialValue = AmtConstRuntime.ZerosValueString;
      m_Ctr = new AmtNativeInt(7, true);
      m_Ctr.InitialValue = 0;
      m_Swi = new AmtNativeInt(1, true);
      m_Swi.InitialValue = 0;
      AllocateStructures();
    } // Constructor LocalDefinitions

    public override void ResetParent () {
      m_ParentObject = null;
      ResetDatabase();
    } // ResetParent

    public void ApplyNewParent (Lectis_Gn parentObject) {
      m_ParentObject = parentObject;
      ApplyNewDatabase(parentObject);
    } // ApplyNewParent

    public void InitLocalDefinitions () {
      m_Imp_Linecount.Initialise();
      m_Ws_In_Len.Initialise();
      m_Ws_Crd_Len.Initialise();
      m_P_Len.Initialise();
      m_P_Off.Initialise();
      m_P_Klen.Initialise();
      m_P_Keys.Initialise();
      m_P_Nolist.Initialise();
      m_P_Y2k.Initialise();
      m_P_Op.Initialise();
      m_P_Rel.Initialise();
      m_P_Litlen.Initialise();
      m_P_Litn.Initialise();
      m_P_Lit.Initialise();
      m_P_Nd.Initialise();
      m_P_Z5.Initialise();
      m_Yp_Tab.Initialise();
      m_Da.Initialise();
      m_Cp_Len.Initialise();
      m_Cc_Len.Initialise();
      m_Zl_Len.Initialise();
      m_Kp.Initialise();
      m_Cond_Ok.Initialise();
      m_Recin.Initialise();
      m_Crdrec.Initialise();
      m_Zl1.Initialise();
      m_Symk_W.Initialise();
      m_W_A.Initialise();
      m_W_B.Initialise();
      m_Wrec.Initialise();
      m_Indexi.Initialise();
      m_Indexo.Initialise();
      m_Sw_Avant.Initialise();
      m_Dcnt.Initialise();
      m_W3.Initialise();
      m_Ws_Mark.Initialise();
      m_Tab_Input.Initialise();
      m_Tab_Output.Initialise();
      m_Tit.Initialise();
      m_Zpr.Initialise();
      m_Ctrli.Initialise();
      m_Ctr.Initialise();
      m_Swi.Initialise();
      AmtRtDbsSupport.InitDbsClients(m_DbsClientList);
    } // InitLocalDefinitions

    public void AllocateStructures () {
      m_Yp_Tab.AllocStructure();
      m_Tab_Input.AllocStructure();
      m_Tab_Output.AllocStructure();
      m_Tit.AllocStructure();
      m_Zpr.AllocStructure();
    } // AllocateStructures

  } // Class LocalDefinitions

} // Namespace Federale.BSP.BusinessLogic.Lectis_Gn

