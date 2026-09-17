
var Amt;
(function (Amt) {
  var amtCustomInstance = null;
  function AmtCustomInstance() {
    if (amtCustomInstance === null) {
      amtCustomInstance = new AmtCustom;
    }
    return amtCustomInstance;
  }
  Amt.AmtCustomInstance = AmtCustomInstance;
  class AmtCustom {
    clearFromElement(eventElement) {
      var amtLib = Amt.AmtLibsInstance();
      if (!amtLib.checkForInputField(eventElement)) {
        return false;
      }
      var activeTop = amtLib.getElementTop(eventElement);
      var amtScreenControls = Amt.AmtScreenControlInstance();
      if (amtScreenControls.allAmtControls.length === 0) {
        amtScreenControls.collectAllAmtControls(false);
      }
      var count = 0;
      var formElements = amtScreenControls.allAmtControls;
      for (var key in formElements) {
        var formElement = formElements[key];
        if (!formElement.getAttribute) {
          continue;
        }
        var currentTop = amtLib.getElementTop(formElement);
        if (currentTop >= activeTop) {
          var controlType = formElement.getAttribute("controltype");
          switch (controlType) {
            case Amt.AmtControlType.EditBox:
              var testElement = formElement;
              if (!testElement.disabled) {
                amtLib.setValue(formElement, "");
              }
              break;
            case Amt.AmtControlType.MaskEditBox:
              amtLib.setValue(formElement, "");
              break;
            case Amt.AmtControlType.CheckBox:
              amtLib.setValue(formElement, "");
              break;
            case Amt.AmtControlType.SignedEditBox:
              amtLib.setValue(formElement, "0");
              break;
            case Amt.AmtControlType.ListBox:
            case Amt.AmtControlType.Label:
            case Amt.AmtControlType.Panel:
            case Amt.AmtControlType.DynamicForm:
            case Amt.AmtControlType.ButtonGroup:
            case Amt.AmtControlType.Calendar:
            case Amt.AmtControlType.RadioButtonGroup:
            case Amt.AmtControlType.ComboBox:
              break;
          }
        }
      }
      return true;
    }
    ;
    processKeyDown(event) {
      var amtLib = Amt.AmtLibsInstance();
      var amtDom = Amt.AmtDomInstance();
      var keyEvent = amtDom.getEvent(event);
      var keyCode = amtDom.getKeyCode(keyEvent);
      var amtKeyHandling = AmtBlazor.AmtKeyHandlingInstance();
      if (!keyEvent.altKey && !keyEvent.shiftKey && !keyEvent.ctrlKey) {
        switch (keyCode) {
          case 110:
            return amtKeyHandling.decimalPointToComma(keyEvent.srcElement);
          case 120:
            return this.clearFromElement(keyEvent.srcElement);
        }
      }
      return false;
    }
    processHyperlink(url) { return false; }
    processMouseEvent(event) {
      var amtDom = Amt.AmtDomInstance();
      var mouseEvent = amtDom.getEvent(event);
      var rightclick = false;
      if (mouseEvent.which) {
        rightclick = (mouseEvent.which == 3);
      }
      else if (mouseEvent.button) {
        rightclick = (mouseEvent.button == 2);
      }
      if (rightclick) {
        return true;
      }
      else {
        return false;
      }
    }
  }
  Amt.AmtCustom = AmtCustom;
})(Amt || (Amt = {}));
Customize = Amt.AmtCustomInstance();
