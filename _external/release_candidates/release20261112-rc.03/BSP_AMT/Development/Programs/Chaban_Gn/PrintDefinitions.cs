using System;
using System.ComponentModel;
using Asysco.Amt.Runtime.Printing;

namespace Federale.BSP.BusinessLogic.Chaban_Gn {

  public partial class PrintDefinitions: AmtTextPrintDocument, IDisposable {
    #region Members
    private Chaban_Gn m_ParentObject;
    #endregion Members

    // Constructor
    public PrintDefinitions (Chaban_Gn parentObject)
      : base() {
      m_ParentObject = parentObject;
      InitializeComponent();
    } // Constructor PrintDefinitions

    // Constructor
    public PrintDefinitions (IContainer container, Chaban_Gn parentObject)
      : base() {
      m_ParentObject = parentObject;
      InitializeComponent();
      container.Add(this);
    } // Constructor PrintDefinitions

  } // Class PrintDefinitions

} // Namespace Federale.BSP.BusinessLogic.Chaban_Gn

