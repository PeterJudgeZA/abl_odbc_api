/* ****
Copyright 2013 Progress Software Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
**** */
/*------------------------------------------------------------------------
    File        : run_sample.p
    Purpose     : Simple example of calling the DataDirect Cloud Server from ABL
    Author(s)   : pjudge 
    Created     : Tue Jul 02 13:25:54 EDT 2013
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.ServerConnection.ODBCConnection.
using OpenEdge.Core.ServerConnection.ODBCConnectionParameters.
using Progress.Json.ObjectModel.ObjectModelParser.
using Progress.Json.ObjectModel.JsonObject.
using Progress.Json.ObjectModel.JsonArray.

/* ***************************  Main Block  *************************** */
define variable oD2CServer as ODBCConnection no-undo.
define variable cStmt as character no-undo.
define variable oResultSet as JsonObject no-undo.
define variable hResultSet as handle no-undo.
define variable oConfig as JsonObject no-undo.
                
/* Make sure the d2c.json file has the following format, replacing the nulls with
   appropriate values (your name, password and the datasource name.
   Note that the property names are case-sensitive.
{"DataSourceName":null,
 "UserName": null,
 "Password": null }
*/

oConfig = cast(new ObjectModelParser():ParseFile('conf/d2c.json'), JsonObject).
oD2CServer = new ODBCConnection(oConfig).
oD2CServer:Initialize().

/* Execute a SQL SELECT statement and get the result set as an ABL temp-table */
cStmt = " select USERNAME, LASTNAME, EMAIL from USER ".
oD2CServer:ExecuteStatement(cStmt, output table-handle hResultSet).
/* just dump the output to disk. Obviously you would do more with this data in the real world */
hResultSet:write-json('file', 'temp/resultset-d2c-table.json', true).

/* Execute a SQL SELECT statement and get the result set in JSON form */
cStmt = "select ACCOUNTNUMBER, SYS_NAME, ANNUALREVENUE, NUMBEROFEMPLOYEES, DESCRIPTION, SLAEXPIRATIONDATE from ACCOUNT ".
oD2CServer:ExecuteStatement(cStmt, output oResultSet).
/* just dump the output to disk. Obviously you would do more with this data in the real world */
if valid-object(oResultSet) then
    oResultSet:WriteFile('temp/resultset-d2c-json.json', true).

/* Deal with any errors */
catch e as OpenEdge.Data.ODBC.ODBCCallError:
    define variable lcDR as longchar no-undo.
    
    if valid-object(e:DiagnosticRecord) then
        e:DiagnosticRecord:Write(input-output lcDR).
    
    message 
      e:ReturnCode:ToString() skip
      e:ExternalProcedure skip
      string(lcDR) skip(2)
      e:GetMessage(1) skip
      e:GetMessage(2) skip
      e:GetMessage(3) skip
      e:GetMessage(4) skip
      e:GetMessage(5) skip(2)
      e:CallStack
      view-as alert-box title 'ODBCCallError: Caught ' + string(e:NumMessages).
end catch.

catch eAE as Progress.Lang.AppError:
    message 
      eAE:ReturnValue skip(2)
      e:GetMessage(1) skip
      e:GetMessage(2) skip
      e:GetMessage(3) skip
      e:GetMessage(4) skip
      e:GetMessage(5) skip(2)
      e:CallStack
      view-as alert-box title 'AppError: Caught ' + string(e:NumMessages).
end catch.
  
finally:
    message 'done'
      view-as alert-box.
end finally.
