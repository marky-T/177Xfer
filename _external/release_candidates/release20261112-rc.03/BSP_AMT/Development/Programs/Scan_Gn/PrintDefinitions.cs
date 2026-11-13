using System;
using System.ComponentModel;
using System.Diagnostics;
using Asysco.Amt.Runtime.Printing;

namespace Federale.BSP.BusinessLogic.Scan_Gn {

  public partial class PrintDefinitions: AmtTextPrintDocument, IDisposable {
    #region Members
    private AmtPrintText m_Prt;
    private Scan_Gn m_ParentObject;
    #endregion Members

    #region Properties
    public AmtPrintText Prt { [DebuggerStepThrough()] get { return m_Prt; } set { m_Prt = value; } }
    #endregion Properties

    // Constructor
    public PrintDefinitions (Scan_Gn parentObject)
      : base() {
      m_ParentObject = parentObject;
      CreatePrinters();
      InitializeComponent();
    } // Constructor PrintDefinitions

    // Constructor
    public PrintDefinitions (IContainer container, Scan_Gn parentObject)
      : base() {
      m_ParentObject = parentObject;
      CreatePrinters();
      InitializeComponent();
      container.Add(this);
    } // Constructor PrintDefinitions

    private void CreatePrinters () {
      m_Prt = new AmtPrintText("PRT");
      m_Prt.Unicode = true;
      m_Prt.CobolMinimumPrintTextWith = 100;
    } // CreatePrinters

  } // Class PrintDefinitions

} // Namespace Federale.BSP.BusinessLogic.Scan_Gn

