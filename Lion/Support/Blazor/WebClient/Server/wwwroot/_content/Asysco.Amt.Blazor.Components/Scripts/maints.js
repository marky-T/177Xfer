"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var AmtBlazorComponents;
(function (AmtBlazorComponents) {
    let AmtMacroManager;
    (function (AmtMacroManager) {
        function triggerKeyDown(inputId, keyCode) {
            let editInputElement = document.getElementById(inputId);
            editInputElement.addEventListener("keydown", macroKeydownHandler);
            return editInputElement.dispatchEvent(new KeyboardEvent('keydown', { keyCode: keyCode, bubbles: true, cancelable: true }));
        }
        AmtMacroManager.triggerKeyDown = triggerKeyDown;
        function macroKeydownHandler(e) {
            let editInputElement = e.target;
            editInputElement.removeEventListener("keydown", macroKeydownHandler);
            if (!e.defaultPrevented) {
                let char = String.fromCharCode(e.keyCode);
                AmtBlazorComponents.AmtKeyHandling.placeEnteredCharAtCursor(editInputElement, char);
                editInputElement.focus();
            }
        }
        function up(id) {
            var _a, _b;
            let element = document.getElementById(id);
            if (element) {
                const offsetInLine = getOffsetInLine(element.value, (_a = element.selectionStart) !== null && _a !== void 0 ? _a : 0);
                let offsetStartLine = getStartLine(element.value, (_b = element.selectionStart) !== null && _b !== void 0 ? _b : 0);
                offsetStartLine = getStartLine(element.value, offsetStartLine - 1);
                let selectionStart = offsetStartLine + offsetInLine;
                if (selectionStart < 0) {
                    selectionStart = 0;
                }
                element.setSelectionRange(selectionStart, selectionStart);
                element.focus();
                return true;
            }
            return false;
        }
        AmtMacroManager.up = up;
        function down(id) {
            var _a, _b;
            let element = document.getElementById(id);
            if (element) {
                const offsetInLine = getOffsetInLine(element.value, (_a = element.selectionStart) !== null && _a !== void 0 ? _a : 0);
                const indexEndOfLine = element.value.indexOf('\n', (_b = element.selectionStart) !== null && _b !== void 0 ? _b : 0);
                const selectionStart = indexEndOfLine + offsetInLine;
                element.setSelectionRange(selectionStart, selectionStart);
                element.focus();
                return true;
            }
            return false;
        }
        AmtMacroManager.down = down;
        function getStartLine(value, index) {
            for (let i = index; i > 0; i--) {
                if (value[i] === '\n') {
                    return i;
                }
            }
            return 0;
        }
        function getOffsetInLine(value, index) {
            for (let i = index; i > 0; i--) {
                if (value[i] === '\n') {
                    return index - i;
                }
            }
            return index;
        }
        function left(id) {
            var _a;
            var element = document.getElementById(id);
            if (element) {
                const selectionStart = (_a = element.selectionStart) !== null && _a !== void 0 ? _a : 0;
                element.selectionStart = selectionStart - 1;
                element.selectionEnd = element.selectionStart;
                element.focus();
                return true;
            }
            return false;
        }
        AmtMacroManager.left = left;
        function right(id) {
            var _a;
            var element = document.getElementById(id);
            if (element) {
                const selectionStart = (_a = element.selectionStart) !== null && _a !== void 0 ? _a : 0;
                element.selectionStart = selectionStart + 1;
                element.selectionEnd = element.selectionStart;
                element.focus();
                return true;
            }
            return false;
        }
        AmtMacroManager.right = right;
        function copy(id) {
            return __awaiter(this, void 0, void 0, function* () {
                var element = document.getElementById(id);
                if (window.isSecureContext && navigator.clipboard) {
                    if (element) {
                        element.focus();
                        yield navigator.clipboard.writeText(element.value);
                        return true;
                    }
                }
                return false;
            });
        }
        AmtMacroManager.copy = copy;
        function paste(id) {
            return __awaiter(this, void 0, void 0, function* () {
                var element = document.getElementById(id);
                if (window.isSecureContext && navigator.clipboard) {
                    element.focus();
                    const text = yield navigator.clipboard.readText();
                    if (element) {
                        element.value = text;
                        element.dispatchEvent(new Event('input', { bubbles: true }));
                        element.dispatchEvent(new Event('change', { bubbles: true }));
                        return true;
                    }
                }
                return false;
            });
        }
        AmtMacroManager.paste = paste;
        function cut(id) {
            return __awaiter(this, void 0, void 0, function* () {
                var element = document.getElementById(id);
                if (window.isSecureContext && navigator.clipboard) {
                    if (element) {
                        element.focus();
                        yield navigator.clipboard.writeText(element.value);
                        element.value = "";
                        element.dispatchEvent(new Event('input', { bubbles: true }));
                        element.dispatchEvent(new Event('change', { bubbles: true }));
                        return true;
                    }
                }
                return false;
            });
        }
        AmtMacroManager.cut = cut;
        function selectAll(id) {
            var element = document.getElementById(id);
            if (element) {
                element.focus();
                element.select();
                return true;
            }
            return false;
        }
        AmtMacroManager.selectAll = selectAll;
        function macroDelete(id) {
            var _a, _b;
            let element = document.getElementById(id);
            if (element) {
                let lenght = element.value.length;
                const selectionStart = (_a = element.selectionStart) !== null && _a !== void 0 ? _a : 0;
                const selectionEnd = (_b = element.selectionEnd) !== null && _b !== void 0 ? _b : 0;
                if (selectionStart == selectionEnd) {
                    let startSubString = element.value.substring(0, selectionStart);
                    let endSubString = element.value.substring(selectionEnd + 1, lenght);
                    element.value = startSubString + endSubString;
                }
                element.selectionStart = selectionStart;
                element.selectionEnd = selectionEnd;
                element.dispatchEvent(new Event('input', { bubbles: true }));
                element.dispatchEvent(new Event('change', { bubbles: true }));
                element.focus();
                return true;
            }
            return false;
        }
        AmtMacroManager.macroDelete = macroDelete;
        function back(id) {
            var _a, _b;
            let element = document.getElementById(id);
            if (element) {
                let lenght = element.value.length;
                const selectionStart = (_a = element.selectionStart) !== null && _a !== void 0 ? _a : 0;
                const selectionEnd = (_b = element.selectionEnd) !== null && _b !== void 0 ? _b : 0;
                if (selectionStart == selectionEnd) {
                    element.value = element.value.substring(0, selectionStart - 1) + element.value.substring(selectionEnd, lenght);
                    element.selectionStart = selectionStart - 1;
                    element.selectionEnd = selectionStart - 1;
                }
                element.dispatchEvent(new Event('input', { bubbles: true }));
                element.dispatchEvent(new Event('change', { bubbles: true }));
                element.focus();
                return true;
            }
            return false;
        }
        AmtMacroManager.back = back;
        function clear(id) {
            let element = document.getElementById(id);
            if (element) {
                element.value = '';
                element.dispatchEvent(new Event('input', { bubbles: true }));
                element.dispatchEvent(new Event('change', { bubbles: true }));
                element.focus();
                return true;
            }
            return false;
        }
        AmtMacroManager.clear = clear;
        function clearEnd(id) {
            var _a;
            let element = document.getElementById(id);
            if (element) {
                const caretPosition = (_a = element.selectionStart) !== null && _a !== void 0 ? _a : 0;
                if (caretPosition > 0) {
                    element.value = element.value.substring(0, caretPosition);
                    element.selectionStart = caretPosition;
                    element.selectionEnd = caretPosition;
                    element.dispatchEvent(new Event('input', { bubbles: true }));
                    element.dispatchEvent(new Event('change', { bubbles: true }));
                }
                element.focus();
                return true;
            }
            return false;
        }
        AmtMacroManager.clearEnd = clearEnd;
    })(AmtMacroManager = AmtBlazorComponents.AmtMacroManager || (AmtBlazorComponents.AmtMacroManager = {}));
})(AmtBlazorComponents || (AmtBlazorComponents = {}));
var AmtBlazorComponents;
(function (AmtBlazorComponents) {
    let AvaPopup;
    (function (AvaPopup) {
        function registerHeaderOnClickHandler(headerId, popupId) {
            let headerElement = document.getElementById(headerId);
            let popupElement = document.getElementById(popupId);
            if (!headerElement) {
                return;
            }
            let offset = [0, 0];
            if (headerElement && popupElement) {
                headerElement.addEventListener('mousedown', (event) => {
                    event.stopPropagation();
                    event.preventDefault();
                    offset = [
                        popupElement.offsetLeft - event.clientX,
                        popupElement.offsetTop - event.clientY
                    ];
                    document.addEventListener("mousemove", mouseMove);
                });
                const mouseMove = (event) => {
                    popupElement.style.position = 'absolute';
                    popupElement.style.left = `${event.clientX + offset[0]}px`;
                    popupElement.style.top = `${event.clientY + offset[1]}px`;
                };
                document.addEventListener('mouseup', (event) => {
                    document.removeEventListener("mousemove", mouseMove);
                });
            }
        }
        AvaPopup.registerHeaderOnClickHandler = registerHeaderOnClickHandler;
    })(AvaPopup = AmtBlazorComponents.AvaPopup || (AmtBlazorComponents.AvaPopup = {}));
})(AmtBlazorComponents || (AmtBlazorComponents = {}));
var AmtBlazorComponents;
(function (AmtBlazorComponents) {
    let PrintScreen;
    (function (PrintScreen) {
        function print(divName) {
            var _a, _b;
            if ((!divName) || (divName === '') || (divName === null)) {
                divName = "AppBodyContent";
            }
            const BodyToPrint = (_a = document.getElementById(divName)) === null || _a === void 0 ? void 0 : _a.innerHTML.trim();
            const StatusBar = (_b = document.getElementById("AppStatusBar")) === null || _b === void 0 ? void 0 : _b.innerHTML.trim();
            const winPrint = window.open('', '', 'left=0,top=0,width=1280,height=1024,toolbar=0,scrollbars=1,status=0');
            if (!winPrint) {
                return;
            }
            winPrint.document.head.innerHTML = document.head.innerHTML;
            var pathName = document.location.href.split("/Forms/");
            winPrint.document.body.innerHTML = "<div class='AppBodyContent' style='position:absolute;'>" + BodyToPrint + "</div>" + "<div id='StatusBar' style='position:absolute;left:16px;bottom:0;'>" + StatusBar + "</div>";
            for (var i = 0; i < winPrint.document.head.children.length; i++) {
                if (winPrint.document.head.children[i].tagName == "LINK") {
                    var winPrintHeadItem = winPrint.document.head.children[i];
                    winPrintHeadItem.href = document.head.children[i].href;
                }
            }
            var winPrintItems = winPrint.document.querySelectorAll('[controltype="AmtEditBox"]');
            winPrintItems.forEach(function (winPrintItem) {
                var currentElement = winPrintItem.querySelector('input');
                var inputElement = document.getElementById(currentElement.id);
                var computedWidth = inputElement.offsetWidth;
                var componentValue = inputElement.value;
                currentElement.value = componentValue;
                currentElement.width = computedWidth;
            });
            winPrintItems = winPrint.document.querySelectorAll('[controltype="AmtImage"] > img');
            winPrintItems.forEach(function (winPrintItem) {
                var element = document.getElementById(winPrintItem.id);
                winPrintItem.src = element.src;
            });
            winPrintItems = winPrint.document.querySelectorAll('[controltype="AmtButton"]');
            winPrintItems.forEach(function (winPrintItem) {
                fixButtonImage(winPrint, winPrintItem, pathName);
            });
            var css = '* { overflow:visible; }fieldset{ background-color:white !important;padding-bottom:0; }.AppBodyContent{overflow:visible !important}';
            var head = winPrint.document.getElementsByTagName('head')[0];
            var style = winPrint.document.createElement('style');
            style.type = 'text/css';
            style.appendChild(winPrint.document.createTextNode(css));
            head.appendChild(style);
            if (winPrint.document.readyState) {
                if (winPrint.document.readyState != 'complete') {
                    winPrint.setInterval(function () { winPrint.document.close(); winPrint.focus(); winPrint.print(); winPrint.close(); }, 1000);
                }
                else {
                    winPrint.setInterval(function () { winPrint.document.close(); winPrint.focus(); winPrint.print(); winPrint.close(); }, 250);
                }
            }
            else {
                winPrint.setInterval(function () { winPrint.document.close(); winPrint.focus(); winPrint.print(); winPrint.close(); }, 1000);
            }
        }
        PrintScreen.print = print;
        function fixButtonImage(winPrint, winPrintItem, pathName) {
            var _a;
            const childElement = (_a = document.getElementById(winPrintItem.id)) === null || _a === void 0 ? void 0 : _a.children[0];
            const oldUrl = winPrintItem.getAttribute("imageupurl");
            if (oldUrl == null || !childElement || !childElement.hasChildNodes()) {
                return;
            }
            const fixedUrl = pathName.toString() + oldUrl;
            const imageIsFixed = fixStretchedImage(winPrint, childElement, fixedUrl);
            if (!imageIsFixed) {
                winPrintItem.style.backgroundImage = "url(" + fixedUrl + ")";
            }
            removeDisabledButtonText(winPrint, childElement);
        }
        function fixStretchedImage(winPrint, childElement, fixedUrl) {
            const granchildElement = childElement.children[0];
            if ((granchildElement.tagName !== "DIV") || (!granchildElement.hasChildNodes())) {
                return false;
            }
            const targetElement = granchildElement.children[0];
            if ((typeof targetElement === 'undefined') || (targetElement.id === '') || (targetElement.tagName !== "IMG")) {
                return false;
            }
            winPrint.document.getElementById(targetElement.id).src = fixedUrl;
            return true;
        }
        function removeDisabledButtonText(winPrint, childElement) {
            var _a;
            if (childElement.children.length <= 1) {
                return;
            }
            const textElement = childElement.children[1];
            if ((typeof textElement !== 'undefined') && (textElement.tagName === "DIV") && (textElement.id.lastIndexOf("_text") === textElement.id.length - 5) && (textElement.classList.contains("CDisabled"))) {
                (_a = winPrint.document.getElementById(textElement.id)) === null || _a === void 0 ? void 0 : _a.remove();
            }
        }
    })(PrintScreen = AmtBlazorComponents.PrintScreen || (AmtBlazorComponents.PrintScreen = {}));
})(AmtBlazorComponents || (AmtBlazorComponents = {}));
var AmtBlazorComponents;
(function (AmtBlazorComponents) {
    let AmtComboBox;
    (function (AmtComboBox) {
        function addArrowImageHandlers(imageElementId, imageSrc, imageOverSrc) {
            var imageElement = document.getElementById(imageElementId);
            if (!imageElement) {
                console.error("Tried to find arrow image element by id [" + imageElementId + "] but no element was found!");
                return;
            }
            imageElement.addEventListener('mouseover', function () {
                imageElement.src = imageOverSrc;
            });
            imageElement.addEventListener('mouseout', function () {
                imageElement.src = imageSrc;
            });
        }
        AmtComboBox.addArrowImageHandlers = addArrowImageHandlers;
        function setSelectedItem(contentContainerId, listItemId) {
            const contentContainerElement = document.getElementById(contentContainerId);
            if (!contentContainerElement) {
                console.error("Tried to find content container element by id [" + contentContainerId + "] but no element was found!");
                return;
            }
            contentContainerElement.querySelectorAll("ul > li.selected").forEach(function (currentNode) {
                currentNode.classList.remove("selected");
            });
            if (listItemId == null) {
                return;
            }
            const listItemElement = document.getElementById(listItemId);
            if (!listItemElement) {
                console.error("Tried to find list item element by id [" + listItemId + "] but no element was found!");
                return;
            }
            listItemElement.classList.add("selected");
        }
        AmtComboBox.setSelectedItem = setSelectedItem;
        function getElementBoundingDomRect(elementId, mainParentId) {
            const element = document.getElementById(elementId);
            const mainParentElement = document.getElementById(mainParentId);
            if (!element) {
                console.error("Could not retrieve bounding DOMRect values of DOM element with ID: " + elementId);
                return null;
            }
            if (!mainParentElement) {
                console.error("Could not retrieve bounding DOMRect values of DOM element with ID: " + mainParentId);
                return null;
            }
            let elementDomRect = element.getBoundingClientRect();
            let parentDomRect = mainParentElement.getBoundingClientRect();
            return new DOMRect((elementDomRect.left - parentDomRect.left), (elementDomRect.top - parentDomRect.top), (elementDomRect.width), (elementDomRect.height));
        }
        AmtComboBox.getElementBoundingDomRect = getElementBoundingDomRect;
        function select(id) {
            let element = document.getElementById(id);
            if (!element) {
                return;
            }
            element.select();
        }
        AmtComboBox.select = select;
        function getActiveElement() {
            if (!document.activeElement) {
                return "";
            }
            return document.activeElement.id;
        }
        AmtComboBox.getActiveElement = getActiveElement;
    })(AmtComboBox = AmtBlazorComponents.AmtComboBox || (AmtBlazorComponents.AmtComboBox = {}));
})(AmtBlazorComponents || (AmtBlazorComponents = {}));
var AmtBlazorComponents;
(function (AmtBlazorComponents) {
    let AmtHelp;
    (function (AmtHelp) {
        function goToHelpScreen(helpScreen, helpTitle) {
            if (helpScreen !== "") {
                var helpWindow = window.open('blank', helpTitle, '');
                if (helpWindow !== null) {
                    helpWindow.document.open('text/html', 'replace');
                    helpWindow.document.write(helpScreen);
                    helpWindow.document.title = helpTitle;
                    helpWindow.document.close();
                }
            }
            else {
                alert("Help url is empty");
            }
        }
        AmtHelp.goToHelpScreen = goToHelpScreen;
    })(AmtHelp = AmtBlazorComponents.AmtHelp || (AmtBlazorComponents.AmtHelp = {}));
})(AmtBlazorComponents || (AmtBlazorComponents = {}));
var AmtBlazorComponents;
(function (AmtBlazorComponents) {
    let AvaListView;
    (function (AvaListView) {
        const _observers = new Map();
        const _mutationConfig = { attributes: true, attributeFilter: ['style'] };
        function addOnScrollHeaderTable(scrollableDivId, headerTableDivId) {
            const scrollableDiv = document.getElementById(scrollableDivId);
            const headerTable = document.getElementById(headerTableDivId);
            scrollableDiv === null || scrollableDiv === void 0 ? void 0 : scrollableDiv.addEventListener("scroll", () => {
                if (headerTable) {
                    if (scrollableDiv) {
                        headerTable.style.left = `${-scrollableDiv.scrollLeft}px`;
                    }
                    else {
                        headerTable.style.left = "0px";
                    }
                }
            });
        }
        function mutationCallback(mutationList, observer) {
            for (const mutation of mutationList) {
                if (mutation.attributeName !== 'style') {
                    continue;
                }
                const tableColumn = mutation.target;
                if (!tableColumn) {
                    continue;
                }
                const columnWidth = parseInt(tableColumn.style.width);
                if (!columnWidth || columnWidth <= 0) {
                    continue;
                }
                const columnIndex = tableColumn.id.split("#")[1];
                if (!columnIndex) {
                    continue;
                }
                const tableName = tableColumn.getAttribute("tablename");
                const className = tableName + "_ResizeColumn" + "#" + columnIndex;
                const targetElements = document.getElementsByClassName(className);
                if (!targetElements || targetElements.length === 0) {
                    continue;
                }
                Array.from(targetElements).forEach((element) => {
                    element.style.width = columnWidth.toString() + "px";
                });
            }
        }
        function disconnectMutationObserver(listviewId) {
            var _a;
            (_a = _observers.get(listviewId)) === null || _a === void 0 ? void 0 : _a.disconnect();
        }
        AvaListView.disconnectMutationObserver = disconnectMutationObserver;
        function addToMutationObserver(listviewId, headerColumnIds) {
            var mutationObserver = _observers.get(listviewId);
            if (!mutationObserver) {
                mutationObserver = new MutationObserver(mutationCallback);
                _observers.set(listviewId, mutationObserver);
            }
            const observer = mutationObserver;
            headerColumnIds.forEach((id) => {
                var tableColumn = document.getElementById(id);
                if (tableColumn) {
                    observer.observe(tableColumn, _mutationConfig);
                }
            });
        }
        function scrollToRow(id, y_Coordinates, rowName = null) {
            const gridComponentScrollDiv = document.getElementById(id);
            let rowElement = null;
            if (rowName) {
                rowElement = document.getElementById(rowName);
            }
            if (gridComponentScrollDiv && rowElement == null) {
                if (y_Coordinates > 0) {
                    gridComponentScrollDiv.scrollTo(0, y_Coordinates);
                }
                else {
                    gridComponentScrollDiv.scrollTo(0, 0);
                }
                setTimeout(() => {
                    var _a;
                    setItemSelect(rowName, true);
                    if (rowName) {
                        (_a = document.getElementById(rowName)) === null || _a === void 0 ? void 0 : _a.click();
                    }
                }, 20);
            }
            else if (rowElement) {
                setItemSelect(rowName, true);
            }
        }
        AvaListView.scrollToRow = scrollToRow;
        function setItemSelect(id = null, isGridComponent = false) {
            let element;
            const elements = document.querySelectorAll(".avaListViewRowSelected");
            elements.forEach((element) => element.classList.remove("avaListViewRowSelected"));
            if (id) {
                element = document.getElementById(id);
                if (element && isGridComponent) {
                    element.classList.add("avaListViewRowSelected");
                }
            }
            else {
                element = document.getElementsByClassName("amthovered")[0];
            }
            if (element) {
                element.scrollIntoView({ block: "center", inline: "nearest" });
                if (!isGridComponent) {
                    element.focus();
                }
            }
        }
        AvaListView.setItemSelect = setItemSelect;
        function setScrollElementUp(id, tableHeight, scrollUp) {
            const element = document.getElementById(id);
            if (element) {
                const maxScrollHeight = element.scrollHeight - element.clientHeight;
                if (scrollUp) {
                    if (element.scrollTop == 0) {
                        return;
                    }
                    element.scrollTop = Math.max(element.scrollTop - tableHeight, 0);
                }
                else {
                    if (element.scrollTop == maxScrollHeight) {
                        return;
                    }
                    element.scrollTop = Math.min(element.scrollTop + tableHeight, maxScrollHeight);
                }
            }
        }
        AvaListView.setScrollElementUp = setScrollElementUp;
        function initHandlers(listviewId, headercolumnIds, scrollableDivId, headerTableId) {
            addToMutationObserver(listviewId, headercolumnIds);
            addOnScrollHeaderTable(scrollableDivId, headerTableId);
        }
        AvaListView.initHandlers = initHandlers;
    })(AvaListView = AmtBlazorComponents.AvaListView || (AmtBlazorComponents.AvaListView = {}));
})(AmtBlazorComponents || (AmtBlazorComponents = {}));
var Amt;
(function (Amt) {
    let AmtControlType;
    (function (AmtControlType) {
        AmtControlType["ButtonGroup"] = "AmtButtonGroup";
        AmtControlType["Calendar"] = "AmtCalendar";
        AmtControlType["Chart"] = "AmtChart";
        AmtControlType["CheckBox"] = "AmtCheckBox";
        AmtControlType["ComboBox"] = "AmtComboBox";
        AmtControlType["GroupBox"] = "AmtGroupBox";
        AmtControlType["Datagrid"] = "AmtDataGrid";
        AmtControlType["Image"] = "AmtImage";
        AmtControlType["Shape"] = "AmtShape";
        AmtControlType["ListBox"] = "AmtListbox";
        AmtControlType["Listview"] = "AmtListview";
        AmtControlType["MaskEditBox"] = "AmtMaskEditBox";
        AmtControlType["Memo"] = "AmtMemo";
        AmtControlType["Menu"] = "AmtMenu";
        AmtControlType["PageControl"] = "AmtPageControl";
        AmtControlType["RadioButtonGroup"] = "AmtRadioButtonGroup";
        AmtControlType["ScrollBox"] = "AmtScrollBox";
        AmtControlType["Tabsheet"] = "AmtTabSheet";
        AmtControlType["EditBox"] = "AmtEditBox";
        AmtControlType["Label"] = "AmtLabel";
        AmtControlType["Panel"] = "AmtPanel";
        AmtControlType["DynamicForm"] = "AmtDynamicForm";
        AmtControlType["Timer"] = "AmtTimer";
        AmtControlType["FileUploader"] = "AmtFileUploader";
    })(AmtControlType = Amt.AmtControlType || (Amt.AmtControlType = {}));
    ;
})(Amt || (Amt = {}));
var AmtBlazorComponents;
(function (AmtBlazorComponents) {
    let AmtKeyHandling;
    (function (AmtKeyHandling) {
        function overrideKeyHandlers(id, inputId, data1, data2) {
            let containerElement = document.getElementById(id);
            let controlType = containerElement.getAttribute("controltype");
            switch (controlType) {
                case Amt.AmtControlType.EditBox:
                    const editType = containerElement.getAttribute("edit");
                    let editInputElement = document.getElementById(inputId);
                    switch (editType) {
                        case 'Financial':
                        case 'Numeric':
                        case 'Signed':
                            let length = Number(containerElement.getAttribute("amtlength"));
                            let decimals = Number(containerElement.getAttribute("amtdecimals"));
                            ;
                            const decimalChar = containerElement.getAttribute("sepdec");
                            AddNumericHandler(editInputElement, editType !== null && editType !== void 0 ? editType : "", length, decimals, decimalChar !== null && decimalChar !== void 0 ? decimalChar : "");
                            return;
                        case 'Boolean':
                            addBooleanHandler(editInputElement);
                            return;
                    }
                    break;
                case Amt.AmtControlType.MaskEditBox:
                    let mask = containerElement.getAttribute("mask");
                    let placeholder = containerElement.getAttribute("placeholder");
                    let maskIndexes = JSON.parse(data1);
                    let maskRegexes = JSON.parse(data2);
                    let maskEditInputElement = document.getElementById(inputId);
                    AddMaskEditHandler(maskEditInputElement, mask !== null && mask !== void 0 ? mask : "", placeholder !== null && placeholder !== void 0 ? placeholder : "", maskIndexes, maskRegexes);
                    return;
                case Amt.AmtControlType.Listview:
                    addListViewHandler(containerElement);
                    return;
            }
        }
        AmtKeyHandling.overrideKeyHandlers = overrideKeyHandlers;
        function AddNumericHandler(element, editType, length, decimals, decimalChar) {
            let isSigned = editType !== 'Numeric';
            let pattern = "0-9";
            if (isSigned) {
                pattern += "+\\-";
            }
            if (decimals > 0) {
                pattern += ",.";
            }
            let regex = new RegExp('[' + pattern + ']');
            element.addEventListener('keydown', function (e) {
                var _a, _b, _c;
                if (handleDefault(element, e)) {
                    return;
                }
                switch (e.key) {
                    case 'Backspace':
                        const newRemovedValue = removeChar(element.value, ((_a = element.selectionStart) !== null && _a !== void 0 ? _a : 0) - 1);
                        if (!isValidNumeric(newRemovedValue, length, decimals)) {
                            e.preventDefault();
                        }
                        return;
                    case 'Delete':
                        const newDeletedValue = removeChar(element.value, (_b = element.selectionStart) !== null && _b !== void 0 ? _b : 0);
                        if (!isValidNumeric(newDeletedValue, length, decimals)) {
                            e.preventDefault();
                        }
                        return;
                    case 'v':
                    case 'V':
                        if (e.ctrlKey) {
                            e.preventDefault();
                            pasteNumeric(element, length, decimals);
                            return;
                        }
                        break;
                    case 'c':
                    case 'C':
                    case 'x':
                    case 'X':
                        if (e.ctrlKey) {
                            return;
                        }
                        break;
                }
                if (!regex.test(e.key)) {
                    e.preventDefault();
                    return;
                }
                switch (e.key) {
                    case ".":
                    case ",":
                        if (decimalChar != '/0') {
                            let newValue = getValueWithInsertedText(element, '');
                            let decPos = String(newValue).indexOf('.');
                            if (decPos < 0) {
                                decPos = String(newValue).indexOf(',');
                            }
                            const resultDec = newValue.length - ((_c = element.selectionStart) !== null && _c !== void 0 ? _c : 0);
                            if ((decPos < 0) && (resultDec <= decimals)) {
                                placeEnteredCharAtCursor(element, decimalChar);
                            }
                            e.preventDefault();
                            return;
                        }
                        break;
                    case "+":
                    case "-":
                        let currentValue = element.value;
                        let minPos = String(currentValue).indexOf('-');
                        if ((minPos > -1) && e.key === '+') {
                            element.value = element.value.substring(1);
                            this.maxLength = this.maxLength - 1;
                        }
                        else if ((minPos < 0) && e.key === '-') {
                            this.maxLength = this.maxLength + 1;
                            element.value = "-" + currentValue;
                        }
                        element.dispatchEvent(new Event('input', { bubbles: true }));
                        element.dispatchEvent(new Event('change', { bubbles: true }));
                        e.preventDefault();
                        break;
                    default:
                        let newValue = getValueWithInsertedText(element, e.key);
                        if (!isValidNumeric(newValue, length, decimals)) {
                            e.preventDefault();
                        }
                        break;
                }
            });
        }
        function AddMaskEditHandler(element, mask, placeholder, maskIndexes, maskRegexes) {
            element.addEventListener('keydown', function (e) {
                var _a, _b, _c, _d, _e, _f, _g;
                if (handleDefault(element, e)) {
                    return;
                }
                switch (e.key) {
                    case 'Backspace':
                        deleteChars(element, mask, placeholder, maskIndexes, (_a = element.selectionStart) !== null && _a !== void 0 ? _a : 0, (_b = element.selectionEnd) !== null && _b !== void 0 ? _b : 0, false);
                        e.preventDefault();
                        return;
                    case 'Delete':
                        deleteChars(element, mask, placeholder, maskIndexes, (_c = element.selectionStart) !== null && _c !== void 0 ? _c : 0, (_d = element.selectionEnd) !== null && _d !== void 0 ? _d : 0, true);
                        e.preventDefault();
                        return;
                    case 'v':
                    case 'V':
                        if (e.ctrlKey) {
                            e.preventDefault();
                            pasteMask(element, mask, placeholder, maskIndexes, maskRegexes);
                            return;
                        }
                        break;
                    case 'c':
                    case 'C':
                    case 'x':
                    case 'X':
                        if (e.ctrlKey) {
                            return;
                        }
                        break;
                }
                e.preventDefault();
                for (let i = (_e = element.selectionStart) !== null && _e !== void 0 ? _e : 0; i < mask.length; i++) {
                    element.selectionStart = i;
                    let maskChar = mask[element.selectionStart];
                    let maskCharIndex = maskIndexes.indexOf(maskChar);
                    if (maskCharIndex > -1) {
                        let regex = maskRegexes[maskCharIndex];
                        let patt = new RegExp(regex);
                        if (patt.test(e.key)) {
                            if (element.selectionStart < ((_f = element.selectionEnd) !== null && _f !== void 0 ? _f : 0)) {
                                deleteChars(element, mask, placeholder, maskIndexes, element.selectionStart, (_g = element.selectionEnd) !== null && _g !== void 0 ? _g : 0, true);
                            }
                            element.selectionEnd = element.selectionStart + 1;
                            placeEnteredCharAtCursor(element, e.key);
                            for (let i = element.selectionStart; i < mask.length; i++) {
                                let nextMaskCharIndex = maskIndexes.indexOf(mask[i]);
                                element.selectionStart = i;
                                element.selectionEnd = element.selectionStart;
                                if (nextMaskCharIndex < 0) {
                                    element.selectionEnd = element.selectionStart + 1;
                                    placeEnteredCharAtCursor(element, mask[i]);
                                }
                                else {
                                    break;
                                }
                            }
                        }
                        return;
                    }
                }
            });
        }
        function addBooleanHandler(element) {
            element.addEventListener('keydown', function (e) {
                if (handleDefault(element, e)) {
                    return;
                }
                switch (e.key) {
                    case 't':
                    case 'T':
                    case 'f':
                    case 'F':
                    case 'Backspace':
                    case 'Delete':
                        return;
                    default:
                        e.preventDefault();
                        break;
                }
            });
        }
        function isValidNumeric(value, length, decimals) {
            let decPos = String(value).indexOf('.');
            if (decPos < 0) {
                decPos = String(value).indexOf(',');
            }
            if (decPos > -1) {
                if (decPos > (length - decimals)) {
                    return false;
                }
                else {
                    let newDecimals = value.length - (decPos + 1);
                    if (newDecimals > decimals) {
                        return false;
                    }
                }
            }
            else if (value.length > (length - decimals)) {
                return false;
            }
            return true;
        }
        function removeChar(value, index) {
            return value.slice(0, index) + value.slice(index + 1);
        }
        function handleDefault(element, e) {
            const readonly = element.getAttribute("readonly");
            if (readonly !== null) {
                return true;
            }
            switch (e.key) {
                case "Shift":
                case "Home":
                case "End":
                case "ArrowRight":
                case "ArrowLeft":
                case "ArrowUp":
                case "ArrowDown":
                case 'Tab':
                    return true;
            }
            return false;
        }
        function pasteNumeric(element, length, decimals) {
            return __awaiter(this, void 0, void 0, function* () {
                if (window.isSecureContext && navigator.clipboard) {
                    let newValue = yield navigator.clipboard.readText();
                    if (isValidNumeric(newValue, length, decimals)) {
                        element.value = newValue;
                        element.dispatchEvent(new Event('input', { bubbles: true }));
                        element.dispatchEvent(new Event('change', { bubbles: true }));
                    }
                }
            });
        }
        function deleteChars(element, mask, placeholder, maskIndexes, startIndex, endIndex, foreward) {
            var _a, _b;
            if (((_a = element.selectionStart) !== null && _a !== void 0 ? _a : 0) < mask.length) {
                const pos = (_b = element.selectionStart) !== null && _b !== void 0 ? _b : 0;
                if (startIndex === endIndex) {
                    if (foreward) {
                        endIndex++;
                    }
                    else {
                        startIndex--;
                    }
                }
                for (let i = startIndex; i < endIndex; i++) {
                    element.selectionStart = i;
                    element.selectionEnd = i + 1;
                    deleteMaskValue(element, mask, placeholder, maskIndexes);
                }
                element.selectionStart = pos;
                element.selectionEnd = pos;
            }
        }
        function deleteMaskValue(element, mask, placeholder, maskIndexes) {
            var _a, _b, _c;
            if (((_a = element.selectionStart) !== null && _a !== void 0 ? _a : 0) >= mask.length) {
                return;
            }
            const nextMaskCharIndex = maskIndexes.indexOf(mask[(_b = element.selectionStart) !== null && _b !== void 0 ? _b : 0]);
            if (nextMaskCharIndex < 0) {
                placeEnteredCharAtCursor(element, mask[(_c = element.selectionStart) !== null && _c !== void 0 ? _c : 0]);
            }
            else {
                placeEnteredCharAtCursor(element, placeholder);
            }
        }
        function pasteMask(element, mask, placeholder, maskIndexes, maskRegexes) {
            return __awaiter(this, void 0, void 0, function* () {
                if (window.isSecureContext && navigator.clipboard) {
                    let pastedValue = yield navigator.clipboard.readText();
                    let oldValue = element.value;
                    let pasteIndex = 0;
                    let newValue = '';
                    for (let i = 0; i < mask.length; i++) {
                        let maskChar = mask[i];
                        let maskCharIndex = maskIndexes.indexOf(maskChar);
                        if (maskCharIndex > -1) {
                            let regex = maskRegexes[maskCharIndex];
                            let patt = new RegExp(regex);
                            let found = false;
                            for (let j = pasteIndex; j < pastedValue.length; j++) {
                                if (patt.test(pastedValue[j])) {
                                    newValue += pastedValue[j];
                                    pasteIndex = j + 1;
                                    found = true;
                                    break;
                                }
                            }
                            if (!found) {
                                if (oldValue.length > i) {
                                    newValue += oldValue[i];
                                }
                                else {
                                    newValue += placeholder;
                                }
                            }
                        }
                        else {
                            newValue += mask[i];
                        }
                    }
                    element.value = newValue;
                    element.dispatchEvent(new Event('input', { bubbles: true }));
                    element.dispatchEvent(new Event('change', { bubbles: true }));
                }
            });
        }
        function addListViewHandler(element) {
            element.addEventListener('keydown', function (e) {
                switch (e.key) {
                    case "Shift":
                    case "Home":
                    case "End":
                    case "PageUp":
                    case "PageDown":
                    case "ArrowUp":
                    case "ArrowDown":
                    case 'Tab':
                        e.preventDefault();
                        return true;
                }
                return false;
            });
        }
        function placeEnteredCharAtCursor(element, newChar) {
            var _a;
            const caretPos = ((_a = element.selectionStart) !== null && _a !== void 0 ? _a : 0) + 1;
            let newValue = getValueWithInsertedText(element, newChar);
            element.value = newValue;
            element.setSelectionRange(caretPos, caretPos, "none");
            element.dispatchEvent(new Event('input', { bubbles: true }));
            element.dispatchEvent(new Event('change', { bubbles: true }));
        }
        AmtKeyHandling.placeEnteredCharAtCursor = placeEnteredCharAtCursor;
        function getValueWithInsertedText(element, text) {
            var _a, _b, _c, _d;
            let value = element.value;
            const selLength = ((_a = element.selectionEnd) !== null && _a !== void 0 ? _a : 0) - ((_b = element.selectionStart) !== null && _b !== void 0 ? _b : 0);
            return value.slice(0, (_c = element.selectionStart) !== null && _c !== void 0 ? _c : 0) + text + value.slice(((_d = element.selectionStart) !== null && _d !== void 0 ? _d : 0) + selLength);
        }
    })(AmtKeyHandling = AmtBlazorComponents.AmtKeyHandling || (AmtBlazorComponents.AmtKeyHandling = {}));
})(AmtBlazorComponents || (AmtBlazorComponents = {}));
var AmtBlazorComponents;
(function (AmtBlazorComponents) {
    let AmtListView;
    (function (AmtListView) {
        const _mutationConfig = { attributes: true, attributeFilter: ['style'] };
        AmtListView._observers = new Map();
        function addUpdateListViewHeaderOnScroll(id, headerId) {
            var scrollElement = document.getElementById(id);
            var headerElement = document.getElementById(headerId);
            scrollElement === null || scrollElement === void 0 ? void 0 : scrollElement.addEventListener("scroll", (event) => setListViewHeaderLeft(scrollElement, headerElement));
        }
        function setListViewHeaderLeft(scrollElement, headerElement) {
            if (scrollElement && headerElement) {
                var newLeft = 0;
                if (scrollElement.scrollLeft > 0) {
                    newLeft = (scrollElement.scrollLeft * -1);
                }
                headerElement.style.left = (newLeft.toString() + "px");
            }
        }
        function mutationCallback(mutationList, observer) {
            for (const mutation of mutationList) {
                if (mutation.attributeName !== 'style') {
                    continue;
                }
                var tableColumn = mutation.target;
                if (!tableColumn) {
                    continue;
                }
                var columnWidth = parseInt(tableColumn.style.width);
                if (isNaN(columnWidth) || columnWidth < 1) {
                    continue;
                }
                var columnIndex = tableColumn.id.split('|')[1].split("_")[1];
                if (!columnIndex) {
                    continue;
                }
                var tableName = tableColumn.getAttribute("tablename");
                var className = "CListViewBlazorCol_" + tableName + "_ResizeColumn" + "_" + columnIndex;
                var targetElements = document.getElementsByClassName(className);
                if (!targetElements || targetElements.length < 1) {
                    continue;
                }
                var firstElement = targetElements[0];
                var oldWidth = parseInt(firstElement.width);
                Array.from(targetElements).forEach((element) => element.setAttribute("width", columnWidth.toString()));
                var fillerColumnClass = "CListViewBlazorColFiller_" + tableName;
                var fillerColumnElements = document.getElementsByClassName(fillerColumnClass);
                if (fillerColumnElements && fillerColumnElements.length > 0) {
                    var newWidth;
                    if (oldWidth > columnWidth) {
                        newWidth = (oldWidth - columnWidth) * -1;
                    }
                    else {
                        newWidth = columnWidth - oldWidth;
                    }
                    Array.from(fillerColumnElements).forEach(function (element) {
                        var oldElementWidth = parseInt(element.width);
                        element.width = (oldElementWidth + (newWidth * -1)).toString();
                    });
                }
            }
        }
        ;
        function disconnectMutationObserver(listviewId) {
            var _a;
            (_a = AmtListView._observers.get(listviewId)) === null || _a === void 0 ? void 0 : _a.disconnect();
            AmtListView._observers.delete(listviewId);
        }
        AmtListView.disconnectMutationObserver = disconnectMutationObserver;
        function addToMutationObserver(listviewId, headerColumnIds) {
            let mutationObserver = AmtListView._observers.get(listviewId);
            if (!mutationObserver) {
                mutationObserver = new MutationObserver(mutationCallback);
                AmtListView._observers.set(listviewId, mutationObserver);
            }
            const observer = mutationObserver;
            headerColumnIds.forEach((headerColumnId) => {
                let headerColumn = document.getElementById(headerColumnId);
                if (headerColumn) {
                    observer.observe(headerColumn, _mutationConfig);
                }
            });
        }
        function setListViewClickHandler(dynamicTableBodyId) {
            var element = document.getElementById(dynamicTableBodyId);
            if (!element) {
                console.error("Could not register listview click handler because element [" + dynamicTableBodyId + "] was not found!");
            }
            element.addEventListener("click", (event) => onListViewClick(event, dynamicTableBodyId));
        }
        function onListViewClick(event, dynamicTableBodyId) {
            event.stopPropagation();
            var target = event.target;
            if (!target) {
                console.error("Invalid target element [" + target + "] for OnAmtClick");
            }
            var tdElement = target.closest("td[data-columnIndex]");
            var trElement = target.closest("tr[data-rowIndex]");
            if (!tdElement || !trElement) {
                console.error("Could not find td or tr element for OnAmtListViewClick");
                return;
            }
            if (tdElement.dataset.amtclick !== undefined) {
                tdElement.dataset.amtclick = (parseInt(tdElement.dataset.amtclick) + 1).toString();
                return;
            }
            tdElement.dataset.amtclick = (1).toString();
            setTimeout(() => {
                var _a, _b, _c, _d;
                (_a = document.getElementById(dynamicTableBodyId)) === null || _a === void 0 ? void 0 : _a.dispatchEvent(new CustomEvent("amtlistviewclick", {
                    bubbles: true,
                    detail: {
                        rowIndex: parseInt((_b = trElement.dataset.rowindex) !== null && _b !== void 0 ? _b : "", 10),
                        columnIndex: parseInt((_c = tdElement.dataset.columnindex) !== null && _c !== void 0 ? _c : "", 10),
                        doubleClick: (parseInt((_d = tdElement.dataset.amtclick) !== null && _d !== void 0 ? _d : "", 10) > 1),
                        ctrlKey: event.ctrlKey,
                        shiftKey: event.shiftKey
                    }
                }));
                delete tdElement.dataset.amtclick;
            }, 200);
        }
        function initHandlers(listviewId, headerColumns, scrollableDivId, headerTableId, dynamicTableBodyId) {
            addToMutationObserver(listviewId, headerColumns);
            addUpdateListViewHeaderOnScroll(scrollableDivId, headerTableId);
            setListViewClickHandler(dynamicTableBodyId);
        }
        AmtListView.initHandlers = initHandlers;
        function focusCell(cellId) {
            try {
                const cell = document.getElementById(cellId);
                if (!cell) {
                    return false;
                }
                cell.focus();
                return true;
            }
            catch (_a) {
                return false;
            }
        }
        AmtListView.focusCell = focusCell;
    })(AmtListView = AmtBlazorComponents.AmtListView || (AmtBlazorComponents.AmtListView = {}));
})(AmtBlazorComponents || (AmtBlazorComponents = {}));
var AmtBlazorComponents;
(function (AmtBlazorComponents) {
    let AmtWebClient;
    (function (AmtWebClient) {
        AmtWebClient.mousePosition = { mouseX: 0, mouseY: 0 };
        function getCurrentForm() {
            return __awaiter(this, void 0, void 0, function* () {
                return yield (AmtWebClient._dotNetPageReference === null || AmtWebClient._dotNetPageReference === void 0 ? void 0 : AmtWebClient._dotNetPageReference.invokeMethodAsync("GetCurrentForm"));
            });
        }
        AmtWebClient.getCurrentForm = getCurrentForm;
        function setDotNetPageObjectReference(pageObject) {
            return __awaiter(this, void 0, void 0, function* () {
                AmtWebClient._dotNetPageReference = pageObject;
            });
        }
        AmtWebClient.setDotNetPageObjectReference = setDotNetPageObjectReference;
        function doesFileExistAsync(urlToFile) {
            return __awaiter(this, void 0, void 0, function* () {
                return (yield fetch(urlToFile)).ok;
            });
        }
        AmtWebClient.doesFileExistAsync = doesFileExistAsync;
        function downloadTextFile(fileName, text) {
            if (!(fileName && text)) {
                return;
            }
            var link = document.createElement('a');
            link.download = fileName;
            link.href = "data:text/plain;charset=utf-8," + encodeURIComponent(text);
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }
        AmtWebClient.downloadTextFile = downloadTextFile;
        function includeScript(scriptName, isAppSetting) {
            return __awaiter(this, void 0, void 0, function* () {
                if (!scriptName) {
                    return;
                }
                var scriptLink = document.getElementById(scriptName);
                if (scriptLink) {
                    return;
                }
                let script = document.createElement("script");
                let uri = isAppSetting ? `scripts/${scriptName}.js` : `_content/Asysco.Amt.Blazor.Components/scripts/${scriptName}.js`;
                if (!(yield doesFileExistAsync(uri))) {
                    console.error(isAppSetting ? `Unable to find 'wwwroot/scripts/${scriptName}.js'!` : `Unable to find '${uri}'`);
                }
                script.setAttribute("src", uri);
                script.setAttribute("id", scriptName);
                document.body.appendChild(script);
            });
        }
        AmtWebClient.includeScript = includeScript;
        function setTheme(themeName, isAppSetting, noDefaultTheme) {
            return __awaiter(this, void 0, void 0, function* () {
                if (!themeName) {
                    return;
                }
                var defaultStyleLink = document.getElementById("amt_default_theme");
                var styleLink = document.getElementById("amt_blazor_theme");
                if (!styleLink) {
                    return;
                }
                let uri = isAppSetting ? `App_Themes/${themeName}/Amt.css` : `_content/Asysco.Amt.Blazor.Components/App_Themes/${themeName}/Amt.css`;
                if (yield doesFileExistAsync(uri)) {
                    styleLink.setAttribute("href", uri);
                    if (noDefaultTheme && defaultStyleLink) {
                        defaultStyleLink.remove();
                    }
                }
            });
        }
        AmtWebClient.setTheme = setTheme;
        function afterBlazorStarted() {
            registerCustomEvents();
            registerMousePositionHandler();
            registerKeydownHandlerToPreventDefaultActions();
            registerBeforeUnloadHandler();
        }
        AmtWebClient.afterBlazorStarted = afterBlazorStarted;
        function registerCustomEvents() {
            Blazor.registerCustomEventType('amtlistviewclick', {
                createEventArgs: (event) => {
                    const customEvent = event;
                    return {
                        doubleClick: customEvent.detail.doubleClick,
                        rowIndex: customEvent.detail.rowIndex,
                        columnIndex: customEvent.detail.columnIndex,
                        ctrlKey: customEvent.detail.ctrlKey,
                        shiftKey: customEvent.detail.shiftKey,
                    };
                }
            });
            Blazor.registerCustomEventType('amtsetlistitems', {
                createEventArgs: (event) => {
                    const customEvent = event;
                    return {
                        listItems: customEvent.detail.listItems,
                    };
                }
            });
        }
        function registerMousePositionHandler() {
            document.addEventListener('mousemove', (event) => AmtWebClient.mousePosition = { mouseX: event.clientX, mouseY: event.clientY });
        }
        const keysHandledByAmt = ['F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12', 'Tab'];
        function shouldPreventDefaultAction(e) {
            if (e.key === 'Control' || e.key === 'Alt') {
                return false;
            }
            if (isMemoNavigationKey(e)) {
                return false;
            }
            if (keysHandledByAmt.indexOf(e.key) !== -1) {
                return true;
            }
            const allowedCTRLKeys = ['a', 'x', 'c', 'v'];
            return (e.ctrlKey && !allowedCTRLKeys.join().includes(e.key)) || e.altKey;
        }
        function registerKeydownHandlerToPreventDefaultActions() {
            document.addEventListener('keydown', (e) => {
                if (shouldPreventDefaultAction(e)) {
                    e.preventDefault();
                }
            }, false);
        }
        function isMemoNavigationKey(e) {
            const target = e.target;
            if (!target || target.tagName !== 'TEXTAREA') {
                return false;
            }
            if (e.altKey || e.metaKey) {
                return false;
            }
            switch (e.key) {
                case 'Home':
                case 'End':
                    return true;
                default:
                    return false;
            }
        }
        function registerBeforeUnloadHandler() {
            window.addEventListener("beforeunload", () => __awaiter(this, void 0, void 0, function* () { return yield (AmtWebClient._dotNetPageReference === null || AmtWebClient._dotNetPageReference === void 0 ? void 0 : AmtWebClient._dotNetPageReference.invokeMethodAsync("OnExit")); }));
        }
    })(AmtWebClient = AmtBlazorComponents.AmtWebClient || (AmtBlazorComponents.AmtWebClient = {}));
})(AmtBlazorComponents || (AmtBlazorComponents = {}));
var AmtBlazorComponents;
(function (AmtBlazorComponents) {
    let AmtPageControl;
    (function (AmtPageControl) {
        function hideElementsFromOffset(ids, offset, arrowDivId, showArrow) {
            let showArrows = showArrow;
            for (const id of ids) {
                const elm = document.getElementById(id);
                if (elm && ((elm.offsetLeft + elm.offsetWidth) > offset)) {
                    showArrows = true;
                    elm.classList.remove('CTabStripHidden', 'CTabStripSelected', 'CTabStrip');
                    elm.classList.add('CTabStripHidden');
                }
            }
            const arrowElm = document.getElementById(arrowDivId);
            if (arrowElm) {
                arrowElm.style.display = (showArrows || showArrow) ? 'block' : 'none';
            }
            return showArrows;
        }
        AmtPageControl.hideElementsFromOffset = hideElementsFromOffset;
    })(AmtPageControl = AmtBlazorComponents.AmtPageControl || (AmtBlazorComponents.AmtPageControl = {}));
})(AmtBlazorComponents || (AmtBlazorComponents = {}));
/*! *******************************************************
// File      : AmtImage.ts                                *
// Date      : 30-12-2021                                 *
// Copyright : Asysco Software BV (http://www.asysco.com) *
// Product   : AMT                                        *
********************************************************  */
var AmtBlazorComponents;
(function (AmtBlazorComponents) {
    let AmtImage;
    (function (AmtImage) {
        function setSourceAndSizeById(id, howToSize, newSource, canvasWidth, canvasHeight) {
            let imageElement = document.getElementById(id);
            if (!imageElement)
                return;
            imageElement.onload = null;
            imageElement.src = "";
            if (!newSource || newSource.length === 0) {
                imageElement.style.display = "none";
                return;
            }
            imageElement.onload = () => {
                let width = canvasWidth - 2;
                let height = canvasHeight - 2;
                let imageWidth = imageElement.width;
                let imageHeight = imageElement.height;
                let toWidth = 0;
                let toHeight = 0;
                switch (howToSize) {
                    case AmtImage.ImageResize.StretchToFill:
                        imageElement.width = width;
                        imageElement.height = height;
                        break;
                    case AmtImage.ImageResize.StretchByRatio:
                        let ratioX = width / imageWidth;
                        let ratioY = height / imageHeight;
                        if (ratioX > ratioY) {
                            toWidth = imageWidth * ratioY;
                            toHeight = imageHeight * ratioY;
                        }
                        else {
                            toWidth = imageWidth * ratioX;
                            toHeight = imageHeight * ratioX;
                        }
                        imageElement.width = toWidth;
                        imageElement.height = toHeight;
                        break;
                    case AmtImage.ImageResize.ClipToDesignedSize:
                        imageElement.style.position = "absolute";
                        imageElement.style.clip = `rect(0px, ${canvasWidth}px, ${canvasHeight}px, 0px)`;
                        break;
                    case AmtImage.ImageResize.EntirePicture:
                        break;
                }
            };
            imageElement.style.removeProperty("display");
            imageElement.src = newSource;
        }
        AmtImage.setSourceAndSizeById = setSourceAndSizeById;
    })(AmtImage = AmtBlazorComponents.AmtImage || (AmtBlazorComponents.AmtImage = {}));
})(AmtBlazorComponents || (AmtBlazorComponents = {}));
var AmtBlazorComponents;
(function (AmtBlazorComponents) {
    let AmtImage;
    (function (AmtImage) {
        let ImageResize;
        (function (ImageResize) {
            ImageResize["StretchToFill"] = "StretchToFill";
            ImageResize["StretchByRatio"] = "StretchByRatio";
            ImageResize["ClipToDesignedSize"] = "ClipToDesignedSize";
            ImageResize["EntirePicture"] = "EntirePicture";
        })(ImageResize = AmtImage.ImageResize || (AmtImage.ImageResize = {}));
    })(AmtImage = AmtBlazorComponents.AmtImage || (AmtBlazorComponents.AmtImage = {}));
})(AmtBlazorComponents || (AmtBlazorComponents = {}));
var AmtBlazorComponents;
(function (AmtBlazorComponents) {
    let AmtComponent;
    (function (AmtComponent) {
        function getCursorPosition(mainParentId) {
            const mainParentElement = document.getElementById(mainParentId);
            if (!mainParentElement) {
                console.error("Could not retrieve bounding DOMRect values of DOM element with control ID: " + mainParentId);
                return null;
            }
            let parentDomRect = mainParentElement.getBoundingClientRect();
            return {
                "MouseX": Math.round(AmtBlazorComponents.AmtWebClient.mousePosition.mouseX - parentDomRect.x),
                "MouseY": Math.round(AmtBlazorComponents.AmtWebClient.mousePosition.mouseY - parentDomRect.y)
            };
        }
        AmtComponent.getCursorPosition = getCursorPosition;
        function openPageURL(uri, target) {
            window.open(uri, target, 'noreferrer');
        }
        AmtComponent.openPageURL = openPageURL;
        function getSelectionStart(inputId) {
            var _a, _b;
            return (_b = (_a = document.getElementById(inputId)) === null || _a === void 0 ? void 0 : _a.selectionStart) !== null && _b !== void 0 ? _b : null;
        }
        AmtComponent.getSelectionStart = getSelectionStart;
        function selectRange(id, selectionStart, selectionEnd) {
            let element = document.getElementById(id);
            if (!element) {
                return;
            }
            element.selectionStart = Math.max(0, Math.min(selectionStart, element.value.length));
            element.selectionEnd = Math.max(0, Math.min(selectionEnd, element.value.length));
        }
        AmtComponent.selectRange = selectRange;
    })(AmtComponent = AmtBlazorComponents.AmtComponent || (AmtBlazorComponents.AmtComponent = {}));
})(AmtBlazorComponents || (AmtBlazorComponents = {}));
var AmtBlazorComponents;
(function (AmtBlazorComponents) {
    let AmtLoadAndRun;
    (function (AmtLoadAndRun) {
        function executeRefreshObjects() {
            if (typeof RefreshObjects !== 'undefined') {
                RefreshObjects();
            }
        }
        AmtLoadAndRun.executeRefreshObjects = executeRefreshObjects;
        function executeRunObjects() {
            if (typeof RunObjects !== 'undefined') {
                return RunObjects();
            }
            return true;
        }
        AmtLoadAndRun.executeRunObjects = executeRunObjects;
        function executeLoadObjects() {
            if (typeof LoadObjects !== 'undefined') {
                LoadObjects();
            }
        }
        AmtLoadAndRun.executeLoadObjects = executeLoadObjects;
    })(AmtLoadAndRun = AmtBlazorComponents.AmtLoadAndRun || (AmtBlazorComponents.AmtLoadAndRun = {}));
})(AmtBlazorComponents || (AmtBlazorComponents = {}));
var AmtBlazorComponents;
(function (AmtBlazorComponents) {
    let AmtFileUploader;
    (function (AmtFileUploader) {
        function open(fileUploaderContainerId) {
            var _a;
            ((_a = document.getElementById(fileUploaderContainerId)) === null || _a === void 0 ? void 0 : _a.querySelector('input[type="file"]')).click();
        }
        AmtFileUploader.open = open;
    })(AmtFileUploader = AmtBlazorComponents.AmtFileUploader || (AmtBlazorComponents.AmtFileUploader = {}));
})(AmtBlazorComponents || (AmtBlazorComponents = {}));
var Amt;
(function (Amt) {
    class AmtControl {
        constructor(amtId, subsessionId = 1) {
            this._amtId = amtId;
            this._subsessionId = subsessionId;
        }
        static getElementByAmtId(amtId, subsessionId) {
            return document.getElementById(amtId + "|Container|" + (subsessionId !== null && subsessionId !== void 0 ? subsessionId : 1));
        }
        static getAmtControlByAmtId(amtId, subsessionId) {
            var element = AmtControl.getElementByAmtId(amtId, subsessionId);
            if (!element) {
                throw new Error(`Element with AMT ID '${amtId}' and subsession ID '${subsessionId}' not found.`);
            }
            switch (element.getAttribute("controltype")) {
                case Amt.AmtControlType.ButtonGroup:
                    return new Amt.AmtButtonGroup(amtId, subsessionId);
                case Amt.AmtControlType.Calendar:
                    return new Amt.AmtCalendar(amtId, subsessionId);
                case Amt.AmtControlType.Chart:
                    return new Amt.AmtChart(amtId, subsessionId);
                case Amt.AmtControlType.CheckBox:
                    return new Amt.AmtCheckBox(amtId, subsessionId);
                case Amt.AmtControlType.ComboBox:
                    return new Amt.AmtComboBox(amtId, subsessionId);
                case Amt.AmtControlType.Datagrid:
                    return new Amt.AmtDatagrid(amtId, subsessionId);
                case Amt.AmtControlType.DynamicForm:
                    return new Amt.AmtDynamicForm(amtId, subsessionId);
                case Amt.AmtControlType.EditBox:
                    return new Amt.AmtEditBox(amtId, subsessionId);
                case Amt.AmtControlType.FileUploader:
                    return new Amt.AmtFileUploader(amtId, subsessionId);
                case Amt.AmtControlType.GroupBox:
                    return new Amt.AmtGroupBox(amtId, subsessionId);
                case Amt.AmtControlType.Image:
                    return new Amt.AmtImage(amtId, subsessionId);
                case Amt.AmtControlType.Label:
                    return new Amt.AmtLabel(amtId, subsessionId);
                case Amt.AmtControlType.ListBox:
                    return new Amt.AmtListBox(amtId, subsessionId);
                case Amt.AmtControlType.Listview:
                    return new Amt.AmtListview(amtId, subsessionId);
                case Amt.AmtControlType.MaskEditBox:
                    return new Amt.AmtMaskEditBox(amtId, subsessionId);
                case Amt.AmtControlType.Memo:
                    return new Amt.AmtMemo(amtId, subsessionId);
                case Amt.AmtControlType.Menu:
                    return new Amt.AmtMenu(amtId, subsessionId);
                case Amt.AmtControlType.PageControl:
                    return new Amt.AmtPageControl(amtId, subsessionId);
                case Amt.AmtControlType.Panel:
                    return new Amt.AmtPanel(amtId, subsessionId);
                case Amt.AmtControlType.RadioButtonGroup:
                    return new Amt.AmtRadioButtonGroup(amtId, subsessionId);
                case Amt.AmtControlType.ScrollBox:
                    return new Amt.AmtScrollBox(amtId, subsessionId);
                case Amt.AmtControlType.Shape:
                    return new Amt.AmtShape(amtId, subsessionId);
                case Amt.AmtControlType.Tabsheet:
                    return new Amt.AmtTabSheet(amtId, subsessionId);
                case Amt.AmtControlType.Timer:
                    return new Amt.AmtTimer(amtId, subsessionId);
                default:
                    throw new Error(`Unknown control type for AMT ID '${amtId}' and subsession ID '${subsessionId}': ${element.getAttribute("controltype")}`);
            }
        }
        getElement() {
            return AmtControl.getElementByAmtId(this._amtId, this._subsessionId);
        }
        getValue() {
            return __awaiter(this, void 0, void 0, function* () {
                var _a;
                return (yield ((_a = AmtBlazorComponents.AmtWebClient._dotNetPageReference) === null || _a === void 0 ? void 0 : _a.invokeMethodAsync("GetControlValue", this._amtId, this._subsessionId))) || "";
            });
        }
        setValue(value) {
            return __awaiter(this, void 0, void 0, function* () {
                var _a;
                yield ((_a = AmtBlazorComponents.AmtWebClient._dotNetPageReference) === null || _a === void 0 ? void 0 : _a.invokeMethodAsync("SetControlValue", this._amtId, this._subsessionId, value));
            });
        }
    }
    Amt.AmtControl = AmtControl;
    HTMLDocument.prototype.getElementByAmtId = AmtControl.getElementByAmtId;
    HTMLDocument.prototype.getAmtControlByAmtId = AmtControl.getAmtControlByAmtId;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtListControl extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
        setListItems(items) {
            var _a;
            (_a = this.getElement()) === null || _a === void 0 ? void 0 : _a.dispatchEvent(new CustomEvent("amtsetlistitems", {
                bubbles: true,
                detail: {
                    listItems: items.map(item => ({ Caption: item.Text, Value: item.Value.toString() }))
                }
            }));
        }
    }
    Amt.AmtListControl = AmtListControl;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtButtonGroup extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtButtonGroup = AmtButtonGroup;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtCalendar extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtCalendar = AmtCalendar;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtChart extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtChart = AmtChart;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtCheckBox extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtCheckBox = AmtCheckBox;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtComboBox extends Amt.AmtListControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtComboBox = AmtComboBox;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtDatagrid extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtDatagrid = AmtDatagrid;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtDynamicForm extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtDynamicForm = AmtDynamicForm;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtEditBox extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtEditBox = AmtEditBox;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtFileUploader extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtFileUploader = AmtFileUploader;
})(Amt || (Amt = {}));
/*! *******************************************************
// File      : AmtForm.ts                                *
// Date      : 15-09-2022                                 *
// Copyright : Asysco Software BV (http://www.asysco.com) *
// Product   : AMT                                        *
********************************************************  */
var Amt;
(function (Amt) {
    function AmtFormInstance() {
        return __awaiter(this, void 0, void 0, function* () {
            return yield AmtBlazorComponents.AmtWebClient.getCurrentForm();
        });
    }
    Amt.AmtFormInstance = AmtFormInstance;
    class AmtForm {
        constructor() {
            this.formName = '';
            this.activeControlName = '';
            this.eventSourceName = '';
            this.language = 'ENGLISH';
            this.messages = null;
            this.objectFields = '';
            this.userPreference = new Amt.AmtUserPreference();
        }
    }
    Amt.AmtForm = AmtForm;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtGroupBox extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtGroupBox = AmtGroupBox;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtImage extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtImage = AmtImage;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtLabel extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtLabel = AmtLabel;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtListBox extends Amt.AmtListControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtListBox = AmtListBox;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtListview extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtListview = AmtListview;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtMaskEditBox extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtMaskEditBox = AmtMaskEditBox;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtMemo extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtMemo = AmtMemo;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtMenu extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtMenu = AmtMenu;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    let Page2Suppress;
    (function (Page2Suppress) {
        Page2Suppress[Page2Suppress["Suppress"] = 0] = "Suppress";
        Page2Suppress[Page2Suppress["DontSuppress"] = 1] = "DontSuppress";
        Page2Suppress[Page2Suppress["OnError"] = 2] = "OnError";
    })(Page2Suppress = Amt.Page2Suppress || (Amt.Page2Suppress = {}));
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtPageControl extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtPageControl = AmtPageControl;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtPanel extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtPanel = AmtPanel;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtRadioButtonGroup extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtRadioButtonGroup = AmtRadioButtonGroup;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtScrollBox extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtScrollBox = AmtScrollBox;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtShape extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtShape = AmtShape;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtTabSheet extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtTabSheet = AmtTabSheet;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtTimer extends Amt.AmtControl {
        constructor(amtId, subsessionId = 1) {
            super(amtId, subsessionId);
        }
    }
    Amt.AmtTimer = AmtTimer;
})(Amt || (Amt = {}));
var Amt;
(function (Amt) {
    class AmtUserPreference {
        getOldXmitStyle() {
            return this._oldXmitStyle;
        }
        ;
        getSuppressPage2() {
            return this._suppressPage2;
        }
        ;
        getMessagePopupType() {
            return this._messagePopupType;
        }
        ;
        getCaptionScreenDescription() {
            return this._captionScreenDescription;
        }
        ;
        getClientCaption() {
            return this._clientCaption;
        }
        ;
        constructor() {
            this._oldXmitStyle = false;
            this._suppressPage2 = Amt.Page2Suppress.DontSuppress;
            this._messagePopupType = 0;
            this._captionScreenDescription = true;
            this._clientCaption = "Avanade Migration Technology";
        }
        setUserPreference(userPreference) {
            if (userPreference) {
                this._oldXmitStyle = userPreference.OldXmitStyle;
                this._suppressPage2 = userPreference.SuppressPage2;
                this._messagePopupType = userPreference.MessagePopupType;
                this._captionScreenDescription = userPreference.CaptionScreenDescription;
                if (userPreference.ClientCaption != '') {
                    this._clientCaption = userPreference.ClientCaption;
                }
            }
        }
        ;
    }
    Amt.AmtUserPreference = AmtUserPreference;
})(Amt || (Amt = {}));
//# sourceMappingURL=maints.js.map