using System.Diagnostics;
using Asysco.Amt.Runtime.Database;
using Asysco.Amt.Runtime.Skeleton;
using Asysco.Amt.Runtime.Vars;

namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Scan_Gn {

  public class LocalDefinitions: AmtBaseDefinitions {
    #region Members
    private Assurfed_Utilit_Scan_Gn m_ParentObject;
    private readonly AmtVarAlpha m_Recin;
    private readonly AmtVarAlpha m_Rec_Area;
    private readonly AmtVarAlpha m_Ws_Chunk;
    private readonly AmtVarNumericBinary9 m_Ws_In_Len;
    private readonly AmtNativeInt m_Cp_Len;
    private readonly AmtNativeInt m_P_Len;
    private readonly AmtNativeInt m_P_Max;
    private readonly AmtNativeInt m_N_Chunk;
    private readonly AmtNativeInt m_K;
    private readonly AmtNativeInt m_Kp;
    private readonly AmtNativeInt m_Skip;
    private readonly AmtNativeInt m_Line_Cnt;
    private readonly AmtNativeInt m_Rec_In_Ct;
    private readonly AmtNativeInt m_Rec_Found_Ct;
    private readonly AmtStructure m_Ct_Line;
    private readonly AmtVarNumericOS2200 m_Ct_Ct;
    private readonly AmtStructure m_F_Line;
    private readonly AmtVarNumericOS2200 m_F_Ct;
    private readonly AmtNativeInt m_Five_Ct;
    private readonly AmtStructure m_M_Line;
    private readonly AmtVarAlpha m_M_Name;
    private readonly AmtVarNumericOS2200 m_M_Ct;
    private readonly AmtVarNumericOS2200 m_Fn_Ct;
    #endregion Members

    #region Properties

    /// <summary>AmtVarAlpha 4001</summary>
    public AmtVarAlpha Recin { [DebuggerStepThrough()] get { return m_Recin; } }

    /// <summary>AmtVarAlpha 4000</summary>
    public AmtVarAlpha Rec_Area { [DebuggerStepThrough()] get { return m_Rec_Area; } }

    /// <summary>AmtVarAlpha 100</summary>
    public AmtVarAlpha Ws_Chunk { [DebuggerStepThrough()] get { return m_Ws_Chunk; } }

    /// <summary>AmtVarNumericBinary9 5</summary>
    public AmtVarNumericBinary9 Ws_In_Len { [DebuggerStepThrough()] get { return m_Ws_In_Len; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Cp_Len { [DebuggerStepThrough()] get { return m_Cp_Len; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt P_Len { [DebuggerStepThrough()] get { return m_P_Len; } }

    /// <summary>AmtNativeInt 10</summary>
    public AmtNativeInt P_Max { [DebuggerStepThrough()] get { return m_P_Max; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt N_Chunk { [DebuggerStepThrough()] get { return m_N_Chunk; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt K { [DebuggerStepThrough()] get { return m_K; } }

    /// <summary>AmtNativeInt 5</summary>
    public AmtNativeInt Kp { [DebuggerStepThrough()] get { return m_Kp; } }

    /// <summary>AmtNativeInt 10</summary>
    public AmtNativeInt Skip { [DebuggerStepThrough()] get { return m_Skip; } }

    /// <summary>AmtNativeInt 10</summary>
    public AmtNativeInt Line_Cnt { [DebuggerStepThrough()] get { return m_Line_Cnt; } }

    /// <summary>AmtNativeInt 10</summary>
    public AmtNativeInt Rec_In_Ct { [DebuggerStepThrough()] get { return m_Rec_In_Ct; } }

    /// <summary>AmtNativeInt 10</summary>
    public AmtNativeInt Rec_Found_Ct { [DebuggerStepThrough()] get { return m_Rec_Found_Ct; } }

    /// <summary>AmtStructure 0 USAGE DISP-1</summary>
    public AmtStructure Ct_Line { [DebuggerStepThrough()] get { return m_Ct_Line; } }

    /// <summary>AmtVarNumericOS2200 7</summary>
    public AmtVarNumericOS2200 Ct_Ct { [DebuggerStepThrough()] get { return m_Ct_Ct; } }

    /// <summary>AmtStructure 0 USAGE DISP-1</summary>
    public AmtStructure F_Line { [DebuggerStepThrough()] get { return m_F_Line; } }

    /// <summary>AmtVarNumericOS2200 7</summary>
    public AmtVarNumericOS2200 F_Ct { [DebuggerStepThrough()] get { return m_F_Ct; } }

    /// <summary>AmtNativeInt 10</summary>
    public AmtNativeInt Five_Ct { [DebuggerStepThrough()] get { return m_Five_Ct; } }

    /// <summary>AmtStructure 0 USAGE DISP-1</summary>
    public AmtStructure M_Line { [DebuggerStepThrough()] get { return m_M_Line; } }

    /// <summary>AmtVarAlpha 37</summary>
    public AmtVarAlpha M_Name { [DebuggerStepThrough()] get { return m_M_Name; } }

    /// <summary>AmtVarNumericOS2200 11</summary>
    public AmtVarNumericOS2200 M_Ct { [DebuggerStepThrough()] get { return m_M_Ct; } }

    /// <summary>AmtVarNumericOS2200 11</summary>
    public AmtVarNumericOS2200 Fn_Ct { [DebuggerStepThrough()] get { return m_Fn_Ct; } }
    #endregion Properties

    // Constructor
    public LocalDefinitions (Assurfed_Utilit_Scan_Gn parentObject)
      : base(parentObject) {
      m_ParentObject = parentObject;
      m_Recin = new AmtVarAlpha(4001);
      m_Rec_Area = new AmtVarAlpha(4000);
      m_Ws_Chunk = new AmtVarAlpha(100);
      m_Ws_In_Len = new AmtVarNumericBinary9(5, false);
      m_Ws_In_Len.InitialValue = 0;
      m_Cp_Len = new AmtNativeInt(6, false);
      m_Cp_Len.InitialValue = 0;
      m_P_Len = new AmtNativeInt(6, false);
      m_P_Len.InitialValue = 0;
      m_P_Max = new AmtNativeInt(11, false);
      m_P_Max.InitialValue = 0;
      m_N_Chunk = new AmtNativeInt(6, false);
      m_N_Chunk.InitialValue = 0;
      m_K = new AmtNativeInt(6, false);
      m_K.InitialValue = 0;
      m_Kp = new AmtNativeInt(6, false);
      m_Kp.InitialValue = 0;
      m_Skip = new AmtNativeInt(11, false);
      m_Skip.InitialValue = 0;
      m_Line_Cnt = new AmtNativeInt(11, false);
      m_Line_Cnt.InitialValue = 66;
      m_Rec_In_Ct = new AmtNativeInt(11, false);
      m_Rec_In_Ct.InitialValue = 0;
      m_Rec_Found_Ct = new AmtNativeInt(11, false);
      m_Rec_Found_Ct.InitialValue = 0;
      m_Ct_Line = new AmtStructure();
      {
        m_Ct_Line.AddAlphaFiller(2, "**");
        m_Ct_Ct = new AmtVarNumericOS2200(7, "ZZZZZZ9", m_Ct_Line);
        m_Ct_Line.AddAlphaFiller(2, "**");
        m_Ct_Line.AddAlphaFiller(121, AmtConstRuntime.SpacesValueString);
      }
      m_F_Line = new AmtStructure();
      {
        m_F_Line.AddAlphaFiller(2, "**");
        m_F_Ct = new AmtVarNumericOS2200(7, "ZZZZZZ9", m_F_Line);
        m_F_Line.AddAlphaFiller(2, "**");
        m_F_Line.AddAlphaFiller(8, "........");
        m_F_Line.AddAlphaFiller(10, "2.........");
        m_F_Line.AddAlphaFiller(10, "3.........");
        m_F_Line.AddAlphaFiller(10, "4.........");
        m_F_Line.AddAlphaFiller(10, "5.........");
        m_F_Line.AddAlphaFiller(10, "6.........");
        m_F_Line.AddAlphaFiller(10, "7.........");
        m_F_Line.AddAlphaFiller(10, "8.........");
        m_F_Line.AddAlphaFiller(10, "9.........");
        m_F_Line.AddAlphaFiller(10, "0.........");
        m_F_Line.AddAlphaFiller(10, "1.........");
        m_F_Line.AddAlphaFiller(10, "2.........");
        m_F_Line.AddAlphaFiller(3, "3..");
      }
      m_Five_Ct = new AmtNativeInt(11, false);
      m_Five_Ct.InitialValue = 6;
      m_M_Line = new AmtStructure();
      {
        m_M_Line.AddAlphaFiller(20, "** END SCAN **      ");
        m_M_Name = new AmtVarAlpha(37, m_M_Line);
        m_M_Ct = new AmtVarNumericOS2200(11, "ZZZZZZZZZZ9", m_M_Line);
        m_M_Line.AddAlphaFiller(19, " RECORD MATCHING = ");
        m_Fn_Ct = new AmtVarNumericOS2200(11, "ZZZZZZZZZZ9", m_M_Line);
      }
      AllocateStructures();
    } // Constructor LocalDefinitions

    public override void ResetParent () {
      m_ParentObject = null;
      ResetDatabase();
    } // ResetParent

    public void ApplyNewParent (Assurfed_Utilit_Scan_Gn parentObject) {
      m_ParentObject = parentObject;
      ApplyNewDatabase(parentObject);
    } // ApplyNewParent

    public void InitLocalDefinitions () {
      m_Recin.Initialise();
      m_Rec_Area.Initialise();
      m_Ws_Chunk.Initialise();
      m_Ws_In_Len.Initialise();
      m_Cp_Len.Initialise();
      m_P_Len.Initialise();
      m_P_Max.Initialise();
      m_N_Chunk.Initialise();
      m_K.Initialise();
      m_Kp.Initialise();
      m_Skip.Initialise();
      m_Line_Cnt.Initialise();
      m_Rec_In_Ct.Initialise();
      m_Rec_Found_Ct.Initialise();
      m_Ct_Line.Initialise();
      m_F_Line.Initialise();
      m_Five_Ct.Initialise();
      m_M_Line.Initialise();
      AmtRtDbsSupport.InitDbsClients(m_DbsClientList);
    } // InitLocalDefinitions

    public void AllocateStructures () {
      m_Ct_Line.AllocStructure();
      m_F_Line.AllocStructure();
      m_M_Line.AllocStructure();
    } // AllocateStructures

  } // Class LocalDefinitions

} // Namespace Federale.AFBUS.BusinessLogic.Assurfed_Utilit_Scan_Gn

