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
    File        : test_odbc_connect.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
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
define variable oParams as ODBCConnectionParameters no-undo.
define variable cStmt as character no-undo.
define variable oResultSet as JsonObject no-undo.
define variable oResultArray as JsonArray no-undo.
define variable hResultSet as handle no-undo.
define variable cPassword as character no-undo.
define variable oConfig as JsonObject no-undo.
define variable oParamData as JsonObject no-undo.
define variable oD2CServer as ODBCConnection no-undo.

/* Make sure the d2c.json file has the following format, replacing the nulls with
   appropriate values.
   Note that the property names are case-sensitive.
{"DataSourceName":null,
 "UserName": null,
 "Password": null }
*/
oConfig = cast(new ObjectModelParser():ParseFile('conf/d2c.json'), JsonObject).
oD2CServer = new ODBCConnection(oConfig).

/* [PJ] Validate that these 3 properties are present and non-null (blanks allowed) 
oConfig = new JsonObject().
oConfig:add('DataSourceName', cValue).
oConfig:add('UserName', cUser).
oConfig:add('Password', cPassword).
*/

/* Alternative approach
oParams = new ODBCConnectionParameters(oConfig).
oD2CServer = new ODBCConnection(oParams).
*/

oD2CServer:Initialize().

oResultSet = oD2CServer:GetTables(false).
if valid-object(oResultSet) then
    oResultSet:WriteFile(session:temp-dir + 'get-tables-object.json', true).

oResultSet = oD2CServer:GetTableSchema('USER').
if valid-object(oResultSet) then
    oResultSet:WriteFile(session:temp-dir + 'user-table-object.json', true).


oResultArray = oD2CServer:GetTypeInfo().
if valid-object(oResultArray) then
    oResultArray:WriteFile(session:temp-dir + 'type-info-all.json', true).

cStmt = 'select ROWID, USERNAME, LASTNAME, EMAIL from USER'.
cStmt = " select ROWID, USERNAME, LASTNAME, EMAIL from USER where LASTNAME = 'Moloney' ".
cStmt = "select * from USER where LASTNAME = 'Moloney' ".
cStmt = " select USERTYPE, USERPERMISSIONSMOBILEUSER, LASTLOGINDATE, ROWID, USERNAME, LASTNAME, EMAIL from USER where LASTNAME = 'Moloney' ".

oD2CServer:ExecuteStatement(cStmt, output oResultSet).
if valid-object(oResultSet) then
    oResultSet:WriteFile(session:temp-dir + 'execute-user-object.json', true).

cStmt = "select ACCOUNTNUMBER, ANNUALREVENUE, NUMBEROFEMPLOYEES, DESCRIPTION, SLAEXPIRATIONDATE, SYS_NAME from ACCOUNT ".

/**/
oD2CServer:ExecuteStatement(cStmt, output oResultSet).
if valid-object(oResultSet) then
    oResultSet:WriteFile(session:temp-dir + 'execute-ACCOUNT-object.json', true).
/**/

/*
cStmt = " select LASTLOGINDATE, ROWID, USERNAME, LASTNAME, EMAIL from USER where LASTNAME = 'Moloney' ".
cStmt = " select ROWID, USERNAME, LASTNAME, EMAIL from USER where LASTNAME = 'Moloney' ".
/*cStmt = "select * from USER where LASTNAME = 'Moloney' ".*/
oD2CServer:ExecuteStatement(cStmt, output table-handle hResultSet).
hResultSet:write-json('file', session:temp-dir + 'execute-user-table-filter.json', true).
*/

/*                                                               */
/*define temp-table ttUsers no-undo                              */
/*    field UserName as char                                     */
/*    field lastName as char                                     */
/*    field Email as char                                        */
/*    field City as char.                                        */
/*                                                               */
/*                                                               */
/*oD2CServer:ExecuteStatement(cStmt, input-output table ttUsers).*/

/* Can also perform UPDATEs via Execute()
cStmt = "update USER 
         set CITY='Beford',
             STATE='MA',
             POSTALCODE='01730'
         where LASTNAME = 'Moloney' ".

oD2CServer:ExecuteStatement(cStmt, output oResultSet).
if valid-object(oResultSet) then
    oResultSet:WriteFile(session:temp-dir + 'execute-update-user-object.json', true).
*/

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

