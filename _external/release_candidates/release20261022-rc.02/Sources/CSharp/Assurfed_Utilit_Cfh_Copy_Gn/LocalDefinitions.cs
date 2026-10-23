using System.Diagnostics;
using Asysco.Amt.Runtime.Database;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Vars;

namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Cfh_Copy_Gn {

  public class LocalDefinitions: AmtBaseDefinitions {
    #region Members
    private Assurfed_Utilit_Cfh_Copy_Gn m_ParentObject;
    private readonly AmtVarAlpha m_Recin;
    private readonly AmtVarAlpha m_Recout;
    private readonly AmtStructure m_In_Names_V;
    private readonly AmtStructure m_In_Names;
    private readonly AmtVarAlpha m_In_Nm;
    private readonly AmtStructure m_Out_Names_V;
    private readonly AmtStructure m_Out_Names;
    private readonly AmtVarAlpha m_Out_Nm;
    private readonly AmtNativeInt m_Ix_In;
    private readonly AmtNativeInt m_Ix_Out;
    private readonly AmtNativeInt m_Nb_Lus;
    private readonly AmtStructure m_Switches;
    private readonly AmtVarNumericOS2200 m_Rec_Skipped;
    private readonly AmtVarAlpha m_Ws_Inname;
    private readonly AmtVarAlpha m_Ws_Outname;
    private readonly AmtVarNumericBinary9 m_Ws_In_Len;
    private readonly AmtNativeInt m_Ws_Out_Len;
    private readonly AmtNativeInt m_P_Inlen;
    private readonly AmtNativeInt m_P_Outlen;
    private readonly AmtNativeInt m_P_Skip;
    private readonly AmtNativeInt m_N_Mv;
    private readonly AmtNativeInt m_N_Fx;
    private readonly AmtNativeInt m_I;
    private readonly AmtNativeInt m_Cp_Len;
    private readonly AmtStructure m_Mv_Tab;
    private readonly AmtStructure m_Mv_Ent;
    private readonly AmtVarNumericBinary9 m_Mv_Is;
    private readonly AmtVarNumericBinary9 m_Mv_Il;
    private readonly AmtVarNumericBinary9 m_Mv_Os;
    private readonly AmtVarNumericBinary9 m_Mv_Ol;
    private readonly AmtStructure m_Fx_Tab;
    private readonly AmtStructure m_Fx_Ent;
    private readonly AmtVarNumericBinary9 m_Fx_Os;
    private readonly AmtVarNumericBinary9 m_Fx_Len;
    private readonly AmtVarAlpha m_Fx_Txt;
    private readonly AmtVarAlpha m_Ws_In;
    private readonly AmtVarAlpha m_Ws_Out;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha Recin { [DebuggerStepThrough()] get { return m_Recin; } }

    /// <summary>AmtVarAlpha 4000</summary>
    public AmtVarAlpha Recout { [DebuggerStepThrough()] get { return m_Recout; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure In_Names_V { [DebuggerStepThrough()] get { return m_In_Names_V; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure In_Names { [DebuggerStepThrough()] get { return m_In_Names; } }

    /// <summary>AmtVarAlpha 30</summary>
    public AmtVarAlpha In_Nm { [DebuggerStepThrough()] get { return m_In_Nm; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Out_Names_V { [DebuggerStepThrough()] get { return m_Out_Names_V; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Out_Names { [DebuggerStepThrough()] get { return m_Out_Names; } }

    /// <summary>AmtVarAlpha 30</summary>
    public AmtVarAlpha Out_Nm { [DebuggerStepThrough()] get { return m_Out_Nm; } }

    /// <summary>AmtNativeInt 3</summary>
    public AmtNativeInt Ix_In { [DebuggerStepThrough()] get { return m_Ix_In; } }

    /// <summary>AmtNativeInt 3</summary>
    public AmtNativeInt Ix_Out { [DebuggerStepThrough()] get { return m_Ix_Out; } }

    /// <summary>AmtNativeInt 10</summary>
    public AmtNativeInt Nb_Lus { [DebuggerStepThrough()] get { return m_Nb_Lus; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Switches { [DebuggerStepThrough()] get { return m_Switches; } }

    /// <summary>AmtVarNumericOS2200 6</summary>
    public AmtVarNumericOS2200 Rec_Skipped { [DebuggerStepThrough()] get { return m_Rec_Skipped; } }

    /// <summary>AmtVarAlpha 30</summary>
    public AmtVarAlpha Ws_Inname { [DebuggerStepThrough()] get { return m_Ws_Inname; } }

    /// <summary>AmtVarAlpha 30</summary>
    public AmtVarAlpha Ws_Outname { [DebuggerStepThrough()] get { return m_Ws_Outname; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Ws_In_Len { [DebuggerStepThrough()] get { return m_Ws_In_Len; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Ws_Out_Len { [DebuggerStepThrough()] get { return m_Ws_Out_Len; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Inlen { [DebuggerStepThrough()] get { return m_P_Inlen; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Outlen { [DebuggerStepThrough()] get { return m_P_Outlen; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Skip { [DebuggerStepThrough()] get { return m_P_Skip; } }

    /// <summary>AmtNativeInt 3</summary>
    public AmtNativeInt N_Mv { [DebuggerStepThrough()] get { return m_N_Mv; } }

    /// <summary>AmtNativeInt 3</summary>
    public AmtNativeInt N_Fx { [DebuggerStepThrough()] get { return m_N_Fx; } }

    /// <summary>AmtNativeInt 3</summary>
    public AmtNativeInt I { [DebuggerStepThrough()] get { return m_I; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Cp_Len { [DebuggerStepThrough()] get { return m_Cp_Len; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Mv_Tab { [DebuggerStepThrough()] get { return m_Mv_Tab; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Mv_Ent { [DebuggerStepThrough()] get { return m_Mv_Ent; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Mv_Is { [DebuggerStepThrough()] get { return m_Mv_Is; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Mv_Il { [DebuggerStepThrough()] get { return m_Mv_Il; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Mv_Os { [DebuggerStepThrough()] get { return m_Mv_Os; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Mv_Ol { [DebuggerStepThrough()] get { return m_Mv_Ol; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Fx_Tab { [DebuggerStepThrough()] get { return m_Fx_Tab; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Fx_Ent { [DebuggerStepThrough()] get { return m_Fx_Ent; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Fx_Os { [DebuggerStepThrough()] get { return m_Fx_Os; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Fx_Len { [DebuggerStepThrough()] get { return m_Fx_Len; } }

    /// <summary>AmtVarAlpha 238</summary>
    public AmtVarAlpha Fx_Txt { [DebuggerStepThrough()] get { return m_Fx_Txt; } }

    /// <summary>AmtVarAlpha 4000</summary>
    public AmtVarAlpha Ws_In { [DebuggerStepThrough()] get { return m_Ws_In; } }

    /// <summary>AmtVarAlpha 4000</summary>
    public AmtVarAlpha Ws_Out { [DebuggerStepThrough()] get { return m_Ws_Out; } }
    #endregion Properties

    // Constructor
    public LocalDefinitions (Assurfed_Utilit_Cfh_Copy_Gn parentObject)
      : base(parentObject) {
      m_ParentObject = parentObject;
      m_Recin = new AmtVarAlpha(4001);
      m_Recout = new AmtVarAlpha(4000);
      m_In_Names_V = new AmtStructure();
      {
        m_In_Names_V.AddAlphaFiller(30, "CFHIN");
      }
      m_In_Names = new AmtStructure();
      {
        m_In_Names.Redefines(m_In_Names_V);
        m_In_Nm = new AmtVarAlpha(30, m_In_Names);
        m_In_Nm.SetArrayBoundaries(1);
      }
      m_Out_Names_V = new AmtStructure();
      {
        m_Out_Names_V.AddAlphaFiller(30, "CFHOUT");
      }
      m_Out_Names = new AmtStructure();
      {
        m_Out_Names.Redefines(m_Out_Names_V);
        m_Out_Nm = new AmtVarAlpha(30, m_Out_Names);
        m_Out_Nm.SetArrayBoundaries(1);
      }
      m_Ix_In = new AmtNativeInt(6, false);
      m_Ix_In.InitialValue = 0;
      m_Ix_Out = new AmtNativeInt(6, false);
      m_Ix_Out.InitialValue = 0;
      m_Nb_Lus = new AmtNativeInt(11, false);
      m_Nb_Lus.InitialValue = 0;
      m_Switches = new AmtStructure();
      {
        m_Rec_Skipped = new AmtVarNumericOS2200(6, true, m_Switches);
        m_Rec_Skipped.InitialValue = AmtConstRuntime.ZerosValueString;
      }
      m_Ws_Inname = new AmtVarAlpha(30);
      m_Ws_Inname.InitialValue = AmtConstRuntime.SpacesValueString;
      m_Ws_Outname = new AmtVarAlpha(30);
      m_Ws_Outname.InitialValue = AmtConstRuntime.SpacesValueString;
      m_Ws_In_Len = new AmtVarNumericBinary9(5, false);
      m_Ws_In_Len.InitialValue = 0;
      m_Ws_Out_Len = new AmtNativeInt(6, false);
      m_Ws_Out_Len.InitialValue = 0;
      m_P_Inlen = new AmtNativeInt(6, false);
      m_P_Inlen.InitialValue = 0;
      m_P_Outlen = new AmtNativeInt(6, false);
      m_P_Outlen.InitialValue = 0;
      m_P_Skip = new AmtNativeInt(6, false);
      m_P_Skip.InitialValue = 0;
      m_N_Mv = new AmtNativeInt(6, false);
      m_N_Mv.InitialValue = 0;
      m_N_Fx = new AmtNativeInt(6, false);
      m_N_Fx.InitialValue = 0;
      m_I = new AmtNativeInt(6, false);
      m_I.InitialValue = 0;
      m_Cp_Len = new AmtNativeInt(6, false);
      m_Cp_Len.InitialValue = 0;
      m_Mv_Tab = new AmtStructure();
      {
        m_Mv_Ent = new AmtStructure(m_Mv_Tab);
        m_Mv_Ent.SetArrayBoundaries(30);
        {
          m_Mv_Is = new AmtVarNumericBinary9(5, false, m_Mv_Ent);
          m_Mv_Il = new AmtVarNumericBinary9(5, false, m_Mv_Ent);
          m_Mv_Os = new AmtVarNumericBinary9(5, false, m_Mv_Ent);
          m_Mv_Ol = new AmtVarNumericBinary9(5, false, m_Mv_Ent);
        }
      }
      m_Fx_Tab = new AmtStructure();
      {
        m_Fx_Ent = new AmtStructure(m_Fx_Tab);
        m_Fx_Ent.SetArrayBoundaries(20);
        {
          m_Fx_Os = new AmtVarNumericBinary9(5, false, m_Fx_Ent);
          m_Fx_Len = new AmtVarNumericBinary9(5, false, m_Fx_Ent);
          m_Fx_Txt = new AmtVarAlpha(238, m_Fx_Ent);
        }
      }
      m_Ws_In = new AmtVarAlpha(4000);
      m_Ws_Out = new AmtVarAlpha(4000);
      AllocateStructures();
    } // Constructor LocalDefinitions

    public override void ResetParent () {
      m_ParentObject = null;
      ResetDatabase();
    } // ResetParent

    public void ApplyNewParent (Assurfed_Utilit_Cfh_Copy_Gn parentObject) {
      m_ParentObject = parentObject;
      ApplyNewDatabase(parentObject);
    } // ApplyNewParent

    public void InitLocalDefinitions () {
      m_Recin.Initialise();
      m_Recout.Initialise();
      m_In_Names_V.Initialise();
      m_Out_Names_V.Initialise();
      m_Ix_In.Initialise();
      m_Ix_Out.Initialise();
      m_Nb_Lus.Initialise();
      m_Switches.Initialise();
      m_Ws_Inname.Initialise();
      m_Ws_Outname.Initialise();
      m_Ws_In_Len.Initialise();
      m_Ws_Out_Len.Initialise();
      m_P_Inlen.Initialise();
      m_P_Outlen.Initialise();
      m_P_Skip.Initialise();
      m_N_Mv.Initialise();
      m_N_Fx.Initialise();
      m_I.Initialise();
      m_Cp_Len.Initialise();
      m_Mv_Tab.Initialise();
      m_Fx_Tab.Initialise();
      m_Ws_In.Initialise();
      m_Ws_Out.Initialise();
      AmtRtDbsSupport.InitDbsClients(m_DbsClientList);
    } // InitLocalDefinitions

    public void AllocateStructures () {
      m_In_Names_V.AllocStructure();
      m_In_Names.AllocStructure();
      m_Out_Names_V.AllocStructure();
      m_Out_Names.AllocStructure();
      m_Switches.AllocStructure();
      m_Mv_Tab.AllocStructure();
      m_Fx_Tab.AllocStructure();
    } // AllocateStructures

  } // Class LocalDefinitions

} // Namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Cfh_Copy_Gn

