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
    File        : SqlExecuteDirect
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Wed Jul 24 15:32:55 EDT 2013
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.ServerConnection.ODBCConnection.
using OpenEdge.Data.ODBC.SqlStatement.
using Progress.Json.ObjectModel.JsonArray.
using Progress.Json.ObjectModel.JsonObject.
using OpenEdge.Data.ODBC.SqlHandleTypeEnum.
using OpenEdge.Data.ODBC.SqlReturnCodeEnum.

class OpenEdge.Data.ODBC.SqlExecuteDirect inherits SqlStatement: 
    /* DLL forward declarations */
    {OpenEdge/Data/ODBC/SqlStatementProto.i}
    
    constructor public SqlExecuteDirect ( input piStmt as int64, input poConnection as ODBCConnection):
        super (input piStmt, input poConnection).
        
        /* do not set the StatementId here; it's dependent on the statement being executed. */
    end constructor.
    
    method public void Execute(input  pcStatement as character,
                               output poResultSet as JsonObject):
        define variable iReturnCode as integer no-undo.
        define variable oArray as JsonArray no-undo.
        define variable oResults as JsonObject no-undo.
        
        /* 0. Set the statement id, so that we can reuse cached column schema */
        this-object:StatementId = base64-encode(md5-digest(pcStatement)).
        
        /* 1. Execute query */
        run SQLExecDirect(input  this-object:StatementHandle,
                          input  pcStatement,
                          input  length(pcStatement),
                          output iReturnCode).                
        SqlCommonLib:ProcessReturnCode(
                        iReturnCode,
                        'SQLExecDirect').
        
        poResultSet = new JsonObject().
        poResultSet:Add('query', pcStatement).
        
        /* 2. Add schema */
        MapColumns().
        poResultSet:Add('columns', GetColumnSchema()).
        
        /* 3. Add data */
        oArray = new JsonArray().
        poResultSet:Add('resultset', oArray).
        
        LoadResultSet(oArray).
    end method.
        
    method public void Execute(input  pcStatement as character,
                               output table-handle phResultSet):
        define variable iReturnCode as integer no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable oSchema as JsonArray no-undo.
        define variable oField as JsonObject no-undo.
        
        /* 0. Set the statement id, so that we can reuse cached column schema */
        this-object:StatementId = base64-encode(md5-digest(pcStatement)).
        
        /* 1. execute query */
        run SQLExecDirect(input  this-object:StatementHandle,
                          input  pcStatement,
                          input  length(pcStatement),
                          output iReturnCode).                
        SqlCommonLib:ProcessReturnCode(SqlReturnCodeEnum:ValueToEnum(iReturnCode),
                                       'SQLExecDirect', 
                                       SqlHandleTypeEnum:SQL_HANDLE_STMT, 
                                       this-object:StatementHandle).
        
        /* 2. create schema */        
        MapColumns().
        assign oSchema = GetColumnSchema()
               iMax = oSchema:Length.
                 
        create temp-table phResultSet.
        do iLoop = 1 to iMax:
            oField = oSchema:GetJsonObject(iLoop).
            phResultSet:add-new-field( 
                    oField:GetCharacter('ColumnName'),
                    oField:GetCharacter('AblType'),
                    oField:GetInteger('NumDecimals')).
        end.
        phResultSet:temp-table-prepare('resultset').
        
        /* 3. Add data */
        LoadResultSet(phResultSet:default-buffer-handle).
    end method.

    method public void Execute(input  pcStatement as character,
                               input  phResultSet as handle):
        define variable iReturnCode as integer no-undo.
        
        /* 0. Set the statement id, so that we can reuse cached column schema */
        this-object:StatementId = base64-encode(md5-digest(pcStatement)).
        
        /* 1. execute query */
        run SQLExecDirect(input  this-object:StatementHandle,
                          input  pcStatement,
                          input  length(pcStatement),
                          output iReturnCode).                
        SqlCommonLib:ProcessReturnCode(
                        iReturnCode,
                        'SQLExecDirect').
        
        /* 2. create schema */ 
        MapColumns().
        
        /* 3. Add data */
        LoadResultSet(phResultSet).
    end method.
    
end class.
