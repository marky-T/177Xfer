using System;
using System.ComponentModel;
using System.Diagnostics;
using Asysco.Amt.Runtime.Printing;

namespace Federale.BSP.BusinessLogic.Tapeld_Gn {

  public partial class PrintDefinitions: AmtTextPrintDocument, IDisposable {
    #region Members
    private AmtPrintText m_Tapeout;
    private Tapeld_Gn m_ParentObject;
    #endregion Members

    #region Properties
    public AmtPrintText Tapeout { [DebuggerStepThrough()] get { return m_Tapeout; } set { m_Tapeout = value; } }
    #endregion Properties

    // Constructor
    public PrintDefinitions (Tapeld_Gn parentObject)
      : base() {
      m_ParentObject = parentObject;
      CreatePrinters();
      InitializeComponent();
    } // Constructor PrintDefinitions

    // Constructor
    public PrintDefinitions (IContainer container, Tapeld_Gn parentObject)
      : base() {
      m_ParentObject = parentObject;
      CreatePrinters();
      InitializeComponent();
      container.Add(this);
    } // Constructor PrintDefinitions

    private void CreatePrinters () {
      m_Tapeout = new AmtPrintText("TAPEOUT");
      m_Tapeout.Unicode = true;
      m_Tapeout.CobolMinimumPrintTextWith = 132;
    } // CreatePrinters

  } // Class PrintDefinitions

} // Namespace Federale.BSP.BusinessLogic.Tapeld_Gn

