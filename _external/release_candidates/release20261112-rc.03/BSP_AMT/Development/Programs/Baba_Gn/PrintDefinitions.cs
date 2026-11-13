using System;
using System.ComponentModel;
using Asysco.Amt.Runtime.Printing;

namespace Federale.BSP.BusinessLogic.Baba_Gn {

  public partial class PrintDefinitions: AmtTextPrintDocument, IDisposable {
    #region Members
    private Baba_Gn m_ParentObject;
    #endregion Members

    // Constructor
    public PrintDefinitions (Baba_Gn parentObject)
      : base() {
      m_ParentObject = parentObject;
      InitializeComponent();
    } // Constructor PrintDefinitions

    // Constructor
    public PrintDefinitions (IContainer container, Baba_Gn parentObject)
      : base() {
      m_ParentObject = parentObject;
      InitializeComponent();
      container.Add(this);
    } // Constructor PrintDefinitions

  } // Class PrintDefinitions

} // Namespace Federale.BSP.BusinessLogic.Baba_Gn

