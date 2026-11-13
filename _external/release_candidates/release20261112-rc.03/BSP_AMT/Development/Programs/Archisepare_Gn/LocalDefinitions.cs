using System.Diagnostics;
using Asysco.Amt.Runtime.Database;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Vars;

namespace Federale.BSP.BusinessLogic.Archisepare_Gn {

  public class LocalDefinitions: AmtBaseDefinitions {
    #region Members
    private Archisepare_Gn m_ParentObject;
    private readonly AmtVarAlpha m_Recin;
    private readonly AmtVarAlpha m_Ws_Keyrec;
    private readonly AmtVarAlpha m_Ws_Unl;
    private readonly AmtVarAlpha m_Ws_Out;
    private readonly AmtVarAlpha m_Key_C_X;
    private readonly AmtVarNumericOS2200 m_Key_C_N;
    private readonly AmtVarAlpha m_Key_U_X;
    private readonly AmtVarNumericOS2200 m_Key_U_N;
    private readonly AmtVarNumericBinary9 m_Ws_Key_Len;
    private readonly AmtVarNumericBinary9 m_Ws_Unl_Len;
    private readonly AmtNativeInt m_P_K1;
    private readonly AmtNativeInt m_P_Off;
    private readonly AmtNativeInt m_P_K2;
    private readonly AmtNativeInt m_P_Rsz;
    private readonly AmtNativeInt m_P_Kst;
    private readonly AmtNativeInt m_P_Ksu;
    private readonly AmtNativeInt m_P_Ksc;
    private readonly AmtNativeInt m_P_Don;
    private readonly AmtNativeInt m_Cp_Len;
    private readonly AmtVarAlpha m_P_Base;
    private readonly AmtVarAlpha m_P_Table;
    private readonly AmtVarAlpha m_P_Archi;
    private readonly AmtVarAlpha m_P_Narchi;
    private readonly AmtNativeInt m_Lecrchf;
    private readonly AmtNativeInt m_Lecunloadf;
    private readonly AmtVarNumericOS2200 m_Cptlu;
    private readonly AmtVarNumericOS2200 m_Cptarchi;
    private readonly AmtVarNumericOS2200 m_Cptnarchi;
    private readonly AmtVarNumericOS2200 m_Cptluf;
    private readonly AmtVarNumericOS2200 m_Cptarchif;
    private readonly AmtVarNumericOS2200 m_Cptnarchif;
    private readonly AmtStructure m_Ligne_Type9;
    private readonly AmtVarAlpha m_Cd_Don9;
    private readonly AmtVarAlpha m_Nm_Bas9;
    private readonly AmtVarAlpha m_Nm_Tab9;
    private readonly AmtVarAlpha m_Dt_Ach9;
    private readonly AmtVarNumericOS2200 m_Cptach1;
    private readonly AmtVarNumericOS2200 m_Cptach2;
    private readonly AmtStructure m_Date_I;
    private readonly AmtVarNumericOS2200 m_Annee_I;
    private readonly AmtVarNumericOS2200 m_Mois_I;
    private readonly AmtVarNumericOS2200 m_Jour_I;
    private readonly AmtStructure m_Date_Fr;
    private readonly AmtVarNumericOS2200 m_Jour_Fr;
    private readonly AmtVarNumericOS2200 m_Mois_Fr;
    private readonly AmtVarNumericOS2200 m_Annee_Fr;
    private readonly AmtVarAlpha m_Ws_Msg;
    private readonly AmtNativeInt m_Ws_Ptr;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha Recin { [DebuggerStepThrough()] get { return m_Recin; } }

    /// <summary>AmtVarAlpha 4000</summary>
    public AmtVarAlpha Ws_Keyrec { [DebuggerStepThrough()] get { return m_Ws_Keyrec; } }

    /// <summary>AmtVarAlpha 4000</summary>
    public AmtVarAlpha Ws_Unl { [DebuggerStepThrough()] get { return m_Ws_Unl; } }

    /// <summary>AmtVarAlpha 4000</summary>
    public AmtVarAlpha Ws_Out { [DebuggerStepThrough()] get { return m_Ws_Out; } }

    /// <summary>AmtVarAlpha 18</summary>
    public AmtVarAlpha Key_C_X { [DebuggerStepThrough()] get { return m_Key_C_X; } }

    /// <summary>AmtVarNumericOS2200 18</summary>
    public AmtVarNumericOS2200 Key_C_N { [DebuggerStepThrough()] get { return m_Key_C_N; } }

    /// <summary>AmtVarAlpha 18</summary>
    public AmtVarAlpha Key_U_X { [DebuggerStepThrough()] get { return m_Key_U_X; } }

    /// <summary>AmtVarNumericOS2200 18</summary>
    public AmtVarNumericOS2200 Key_U_N { [DebuggerStepThrough()] get { return m_Key_U_N; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Ws_Key_Len { [DebuggerStepThrough()] get { return m_Ws_Key_Len; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Ws_Unl_Len { [DebuggerStepThrough()] get { return m_Ws_Unl_Len; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_K1 { [DebuggerStepThrough()] get { return m_P_K1; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Off { [DebuggerStepThrough()] get { return m_P_Off; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_K2 { [DebuggerStepThrough()] get { return m_P_K2; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Rsz { [DebuggerStepThrough()] get { return m_P_Rsz; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Kst { [DebuggerStepThrough()] get { return m_P_Kst; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Ksu { [DebuggerStepThrough()] get { return m_P_Ksu; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Ksc { [DebuggerStepThrough()] get { return m_P_Ksc; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Don { [DebuggerStepThrough()] get { return m_P_Don; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Cp_Len { [DebuggerStepThrough()] get { return m_Cp_Len; } }

    /// <summary>AmtVarAlpha 6</summary>
    public AmtVarAlpha P_Base { [DebuggerStepThrough()] get { return m_P_Base; } }

    /// <summary>AmtVarAlpha 30</summary>
    public AmtVarAlpha P_Table { [DebuggerStepThrough()] get { return m_P_Table; } }

    /// <summary>AmtVarAlpha 30</summary>
    public AmtVarAlpha P_Archi { [DebuggerStepThrough()] get { return m_P_Archi; } }

    /// <summary>AmtVarAlpha 30</summary>
    public AmtVarAlpha P_Narchi { [DebuggerStepThrough()] get { return m_P_Narchi; } }

    /// <summary>AmtNativeInt 1</summary>
    public AmtNativeInt Lecrchf { [DebuggerStepThrough()] get { return m_Lecrchf; } }

    /// <summary>AmtNativeInt 1</summary>
    public AmtNativeInt Lecunloadf { [DebuggerStepThrough()] get { return m_Lecunloadf; } }

    /// <summary>AmtVarNumericOS2200 7</summary>
    public AmtVarNumericOS2200 Cptlu { [DebuggerStepThrough()] get { return m_Cptlu; } }

    /// <summary>AmtVarNumericOS2200 7</summary>
    public AmtVarNumericOS2200 Cptarchi { [DebuggerStepThrough()] get { return m_Cptarchi; } }

    /// <summary>AmtVarNumericOS2200 7</summary>
    public AmtVarNumericOS2200 Cptnarchi { [DebuggerStepThrough()] get { return m_Cptnarchi; } }

    /// <summary>AmtVarNumericOS2200 7</summary>
    public AmtVarNumericOS2200 Cptluf { [DebuggerStepThrough()] get { return m_Cptluf; } }

    /// <summary>AmtVarNumericOS2200 7</summary>
    public AmtVarNumericOS2200 Cptarchif { [DebuggerStepThrough()] get { return m_Cptarchif; } }

    /// <summary>AmtVarNumericOS2200 7</summary>
    public AmtVarNumericOS2200 Cptnarchif { [DebuggerStepThrough()] get { return m_Cptnarchif; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Ligne_Type9 { [DebuggerStepThrough()] get { return m_Ligne_Type9; } }

    /// <summary>AmtVarAlpha 1</summary>
    public AmtVarAlpha Cd_Don9 { [DebuggerStepThrough()] get { return m_Cd_Don9; } }

    /// <summary>AmtVarAlpha 6</summary>
    public AmtVarAlpha Nm_Bas9 { [DebuggerStepThrough()] get { return m_Nm_Bas9; } }

    /// <summary>AmtVarAlpha 30</summary>
    public AmtVarAlpha Nm_Tab9 { [DebuggerStepThrough()] get { return m_Nm_Tab9; } }

    /// <summary>AmtVarAlpha 8</summary>
    public AmtVarAlpha Dt_Ach9 { [DebuggerStepThrough()] get { return m_Dt_Ach9; } }

    /// <summary>AmtVarNumericOS2200 11</summary>
    public AmtVarNumericOS2200 Cptach1 { [DebuggerStepThrough()] get { return m_Cptach1; } }

    /// <summary>AmtVarNumericOS2200 11</summary>
    public AmtVarNumericOS2200 Cptach2 { [DebuggerStepThrough()] get { return m_Cptach2; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Date_I { [DebuggerStepThrough()] get { return m_Date_I; } }

    /// <summary>AmtVarNumericOS2200 4</summary>
    public AmtVarNumericOS2200 Annee_I { [DebuggerStepThrough()] get { return m_Annee_I; } }

    /// <summary>AmtVarNumericOS2200 2</summary>
    public AmtVarNumericOS2200 Mois_I { [DebuggerStepThrough()] get { return m_Mois_I; } }

    /// <summary>AmtVarNumericOS2200 2</summary>
    public AmtVarNumericOS2200 Jour_I { [DebuggerStepThrough()] get { return m_Jour_I; } }

    /// <summary>AmtStructure 0</summary>
    public AmtStructure Date_Fr { [DebuggerStepThrough()] get { return m_Date_Fr; } }

    /// <summary>AmtVarNumericOS2200 2</summary>
    public AmtVarNumericOS2200 Jour_Fr { [DebuggerStepThrough()] get { return m_Jour_Fr; } }

    /// <summary>AmtVarNumericOS2200 2</summary>
    public AmtVarNumericOS2200 Mois_Fr { [DebuggerStepThrough()] get { return m_Mois_Fr; } }

    /// <summary>AmtVarNumericOS2200 4</summary>
    public AmtVarNumericOS2200 Annee_Fr { [DebuggerStepThrough()] get { return m_Annee_Fr; } }

    /// <summary>AmtVarAlpha 80</summary>
    public AmtVarAlpha Ws_Msg { [DebuggerStepThrough()] get { return m_Ws_Msg; } }

    /// <summary>AmtNativeInt 3</summary>
    public AmtNativeInt Ws_Ptr { [DebuggerStepThrough()] get { return m_Ws_Ptr; } }
    #endregion Properties

    // Constructor
    public LocalDefinitions (Archisepare_Gn parentObject)
      : base(parentObject) {
      m_ParentObject = parentObject;
      m_Recin = new AmtVarAlpha(4001);
      m_Ws_Keyrec = new AmtVarAlpha(4000);
      m_Ws_Unl = new AmtVarAlpha(4000);
      m_Ws_Out = new AmtVarAlpha(4000);
      m_Key_C_X = new AmtVarAlpha(18);
      m_Key_C_N = new AmtVarNumericOS2200(18);
      m_Key_C_N.Redefines(m_Key_C_X);
      m_Key_U_X = new AmtVarAlpha(18);
      m_Key_U_N = new AmtVarNumericOS2200(18);
      m_Key_U_N.Redefines(m_Key_U_X);
      m_Ws_Key_Len = new AmtVarNumericBinary9(5, false);
      m_Ws_Key_Len.InitialValue = 0;
      m_Ws_Unl_Len = new AmtVarNumericBinary9(5, false);
      m_Ws_Unl_Len.InitialValue = 0;
      m_P_K1 = new AmtNativeInt(6, false);
      m_P_K1.InitialValue = 0;
      m_P_Off = new AmtNativeInt(6, false);
      m_P_Off.InitialValue = 0;
      m_P_K2 = new AmtNativeInt(6, false);
      m_P_K2.InitialValue = 0;
      m_P_Rsz = new AmtNativeInt(6, false);
      m_P_Rsz.InitialValue = 0;
      m_P_Kst = new AmtNativeInt(6, false);
      m_P_Kst.InitialValue = 0;
      m_P_Ksu = new AmtNativeInt(6, false);
      m_P_Ksu.InitialValue = 0;
      m_P_Ksc = new AmtNativeInt(6, false);
      m_P_Ksc.InitialValue = 0;
      m_P_Don = new AmtNativeInt(6, false);
      m_P_Don.InitialValue = 0;
      m_Cp_Len = new AmtNativeInt(6, false);
      m_Cp_Len.InitialValue = 0;
      m_P_Base = new AmtVarAlpha(6);
      m_P_Base.InitialValue = AmtConstRuntime.SpacesValueString;
      m_P_Table = new AmtVarAlpha(30);
      m_P_Table.InitialValue = AmtConstRuntime.SpacesValueString;
      m_P_Archi = new AmtVarAlpha(30);
      m_P_Archi.InitialValue = AmtConstRuntime.SpacesValueString;
      m_P_Narchi = new AmtVarAlpha(30);
      m_P_Narchi.InitialValue = AmtConstRuntime.SpacesValueString;
      m_Lecrchf = new AmtNativeInt(1, false);
      m_Lecrchf.InitialValue = 0;
      m_Lecunloadf = new AmtNativeInt(1, false);
      m_Lecunloadf.InitialValue = 0;
      m_Cptlu = new AmtVarNumericOS2200(7);
      m_Cptlu.InitialValue = 0;
      m_Cptarchi = new AmtVarNumericOS2200(7);
      m_Cptarchi.InitialValue = 0;
      m_Cptnarchi = new AmtVarNumericOS2200(7);
      m_Cptnarchi.InitialValue = 0;
      m_Cptluf = new AmtVarNumericOS2200(7, "ZZZZZZ9");
      m_Cptarchif = new AmtVarNumericOS2200(7, "ZZZZZZ9");
      m_Cptnarchif = new AmtVarNumericOS2200(7, "ZZZZZZ9");
      m_Ligne_Type9 = new AmtStructure();
      {
        m_Cd_Don9 = new AmtVarAlpha(1, m_Ligne_Type9);
        m_Cd_Don9.InitialValue = "9";
        m_Nm_Bas9 = new AmtVarAlpha(6, m_Ligne_Type9);
        m_Nm_Tab9 = new AmtVarAlpha(30, m_Ligne_Type9);
        m_Dt_Ach9 = new AmtVarAlpha(8, m_Ligne_Type9);
        m_Cptach1 = new AmtVarNumericOS2200(11, true, "+99999999999", m_Ligne_Type9);
        m_Cptach2 = new AmtVarNumericOS2200(11, true, "+99999999999", m_Ligne_Type9);
      }
      m_Date_I = new AmtStructure();
      {
        m_Annee_I = new AmtVarNumericOS2200(4, m_Date_I);
        m_Mois_I = new AmtVarNumericOS2200(2, m_Date_I);
        m_Jour_I = new AmtVarNumericOS2200(2, m_Date_I);
      }
      m_Date_Fr = new AmtStructure();
      {
        m_Jour_Fr = new AmtVarNumericOS2200(2, m_Date_Fr);
        m_Date_Fr.AddAlphaFiller(1, "/");
        m_Mois_Fr = new AmtVarNumericOS2200(2, m_Date_Fr);
        m_Date_Fr.AddAlphaFiller(1, "/");
        m_Annee_Fr = new AmtVarNumericOS2200(4, m_Date_Fr);
      }
      m_Ws_Msg = new AmtVarAlpha(80);
      m_Ws_Ptr = new AmtNativeInt(6, false);
      m_Ws_Ptr.InitialValue = 0;
      AllocateStructures();
    } // Constructor LocalDefinitions

    public override void ResetParent () {
      m_ParentObject = null;
      ResetDatabase();
    } // ResetParent

    public void ApplyNewParent (Archisepare_Gn parentObject) {
      m_ParentObject = parentObject;
      ApplyNewDatabase(parentObject);
    } // ApplyNewParent

    public void InitLocalDefinitions () {
      m_Recin.Initialise();
      m_Ws_Keyrec.Initialise();
      m_Ws_Unl.Initialise();
      m_Ws_Out.Initialise();
      m_Key_C_X.Initialise();
      m_Key_U_X.Initialise();
      m_Ws_Key_Len.Initialise();
      m_Ws_Unl_Len.Initialise();
      m_P_K1.Initialise();
      m_P_Off.Initialise();
      m_P_K2.Initialise();
      m_P_Rsz.Initialise();
      m_P_Kst.Initialise();
      m_P_Ksu.Initialise();
      m_P_Ksc.Initialise();
      m_P_Don.Initialise();
      m_Cp_Len.Initialise();
      m_P_Base.Initialise();
      m_P_Table.Initialise();
      m_P_Archi.Initialise();
      m_P_Narchi.Initialise();
      m_Lecrchf.Initialise();
      m_Lecunloadf.Initialise();
      m_Cptlu.Initialise();
      m_Cptarchi.Initialise();
      m_Cptnarchi.Initialise();
      m_Cptluf.Initialise();
      m_Cptarchif.Initialise();
      m_Cptnarchif.Initialise();
      m_Ligne_Type9.Initialise();
      m_Date_I.Initialise();
      m_Date_Fr.Initialise();
      m_Ws_Msg.Initialise();
      m_Ws_Ptr.Initialise();
      AmtRtDbsSupport.InitDbsClients(m_DbsClientList);
    } // InitLocalDefinitions

    public void AllocateStructures () {
      m_Ligne_Type9.AllocStructure();
      m_Date_I.AllocStructure();
      m_Date_Fr.AllocStructure();
    } // AllocateStructures

  } // Class LocalDefinitions

} // Namespace Federale.BSP.BusinessLogic.Archisepare_Gn

