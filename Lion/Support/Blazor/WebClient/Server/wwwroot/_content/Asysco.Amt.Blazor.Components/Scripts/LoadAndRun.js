/*! *******************************************************
// File      : LoadandRun.js                                *
// Date      : 04-04-2022                                 *
// Copyright : Asysco Software BV (http://www.asysco.com) *
// Product   : AMT                                        *
********************************************************  */



var objectFields = new Array();

/// <summary>
/// Init objects executes when page is loaded
/// </summary>
function InitObjectFields(fields) {
  objectFields = fields.split(';');
} // LoadObjects

/// <summary>
/// Load objects executes when page is loaded
/// </summary>
function LoadObjects() {
  return true;
} // LoadObjects


/// <summary>
/// Run objects executes before values are sent to server
/// </summary>
function RunObjects() {
  //alert('Run Objects');
  return true; // When returning False the transaction is NOT send. Used when having validation rules in this method.
} // RunObjects

/// <summary>
/// Refresh objects executes when page is refreshed with values
/// </summary>
function RefreshObjects() {
  //alert('Refresh Objects');
  return true;
} // RefreshObjects

