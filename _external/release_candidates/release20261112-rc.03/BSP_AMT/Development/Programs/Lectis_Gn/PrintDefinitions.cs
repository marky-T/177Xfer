using System;
using System.ComponentModel;
using System.Diagnostics;
using Asysco.Amt.Runtime.Printing;

namespace Federale.BSP.BusinessLogic.Lectis_Gn {

  public partial class PrintDefinitions: AmtTextPrintDocument, IDisposable {
    #region Members
    private AmtPrintText m_Imp;
    private Lectis_Gn m_ParentObject;
    #endregion Members

    #region Properties
    public AmtPrintText Imp { [DebuggerStepThrough()] get { return m_Imp; } set { m_Imp = value; } }
    #endregion Properties

    // Constructor
    public PrintDefinitions (Lectis_Gn parentObject)
      : base() {
      m_ParentObject = parentObject;
      CreatePrinters();
      InitializeComponent();
    } // Constructor PrintDefinitions

    // Constructor
    public PrintDefinitions (IContainer container, Lectis_Gn parentObject)
      : base() {
      m_ParentObject = parentObject;
      CreatePrinters();
      InitializeComponent();
      container.Add(this);
    } // Constructor PrintDefinitions

    private void CreatePrinters () {
      m_Imp = new AmtPrintText("IMP");
      m_Imp.FormDepth = 63;
      m_Imp.Unicode = true;
      m_Imp.Topline = 6;
      m_Imp.CobolMinimumPrintTextWith = 100;
      m_Imp.Bottomline = 3;
    } // CreatePrinters

  } // Class PrintDefinitions

} // Namespace Federale.BSP.BusinessLogic.Lectis_Gn

