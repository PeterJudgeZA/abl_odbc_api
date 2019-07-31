/* ****
Copyright 2013, 2018-2019 Progress Software Corporation

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
    File        : ODBCConnection
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Tue Jul 02 13:08:37 EDT 2013
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.Assert.
using OpenEdge.Core.ServerConnection.IConnectionParameters.
using OpenEdge.Core.ServerConnection.IServerConnection.
using OpenEdge.Core.ServerConnection.ODBCConnectionParameters.
using OpenEdge.Data.ODBC.SQLGetTypeInfo.
using OpenEdge.Data.ODBC.SqlCommonFunctions.
using OpenEdge.Data.ODBC.SqlExecuteDirect.
using OpenEdge.Data.ODBC.SqlGetColumns.
using OpenEdge.Data.ODBC.SqlGetTables.
using OpenEdge.Data.ODBC.SqlHandleTypeEnum.
using OpenEdge.Data.ODBC.SqlStatement.
using OpenEdge.Data.ODBC.SqlTypeEnum.
using Progress.Json.ObjectModel.JsonArray.
using Progress.Json.ObjectModel.JsonObject.
using Progress.Lang.Object.
using Progress.Lang.ParameterList.
using OpenEdge.Data.ODBC.SqlReturnCodeEnum.

class OpenEdge.Core.ServerConnection.ODBCConnection use-widget-pool implements IServerConnection:
    /* DLL forward declarations */
    {OpenEdge/Data/ODBC/ODBCConnectionProto.i}
    
    {OpenEdge/Data/ODBC/SqlAttributeConstants.i &ACCESS-LEVEL=private}
    {OpenEdge/Data/ODBC/SqlCommonConstants.i &ACCESS-LEVEL=private}
    
    define protected property SqlCommonLib as SqlCommonFunctions no-undo get. set.
    
    /**  Returns true if the server is valid and connected. False otherwise */
    define public property Connected as logical no-undo get. 
    
    /** Parameters for this connection */
    define public property ConnectionParameters as IConnectionParameters no-undo get. private set.
    
    /** A reference to the actual server. The type of this property depends on the server type 
        (since AppServers have HANDLEs, BPMServers have IBizLogicAPI and databases none. The Object 
        acts as a wrapper for handle-based servers */
    define public property Server as Object no-undo get. 

    define private variable miEnvironmentHandle as int64 no-undo.
    define private variable miConnectionHandle as int64 no-undo.
    
    define private variable moParamList as ParameterList no-undo.
    
    define private temp-table ttSqlStatement no-undo
        field StmtHandle as int64
        field StmtRef    as Object
        index idx1 as primary unique StmtHandle.
    
    constructor public ODBCConnection(input poParameters as JsonObject):
        this-object(new ODBCConnectionParameters(poParameters)).
    end constructor.
    
    constructor public ODBCConnection(input poConnectionParameters as IConnectionParameters):
        this-object(cast(poConnectionParameters, ODBCConnectionParameters)).
    end constructor.
    
    constructor public ODBCConnection(input poConnectionParameters as ODBCConnectionParameters):
        Assert:IsType(poConnectionParameters,
            get-class(OpenEdge.Core.ServerConnection.ODBCConnectionParameters)).
        
        assign ConnectionParameters = poConnectionParameters
               SqlCommonLib = new SqlCommonFunctions().
    end constructor.
    
    destructor ODBCConnection():
        this-object:Destroy().
    end.
    
    method public void Initialize():
        moParamList = new ParameterList(2).
        
        this-object:CreateServer().
        this-object:Connect().
        
        /* Cache the type info from the driver, done in the constructor. */
        CreateTypeInfoStatement().
    end method.
    
    method public void Destroy():
        ClearStatementCache().
        
        this-object:Disconnect().
        this-object:DestroyServer().
        
        SqlStatement:EmptyColumnSchemaCache().
    end method.
    
    /** Connect to the server specified, based on the ConnectionParameters */
    method public void Connect():
        define variable iReturnCode as integer no-undo.
        define variable cDataSourceName as character no-undo.
        define variable cUserName as character no-undo.
        define variable cPassword as character no-undo.
        
        assign cDataSourceName = cast(ConnectionParameters, ODBCConnectionParameters):DataSourceName
               cUserName = cast(ConnectionParameters, ODBCConnectionParameters):UserName
               cPassword = cast(ConnectionParameters, ODBCConnectionParameters):Password
               .
        run SQLConnect(input  miConnectionHandle,
                       input  cDataSourceName,  input length(cDataSourceName),
                       input  cUserName,        input length(cUserName),
                       input  cPassword,        input length(cPassword),
                       output iReturnCode).
        SqlCommonLib:ProcessReturnCode(SqlReturnCodeEnum:ValueToEnum(iReturnCode),
                                       'SQLConnect',
                                       SqlHandleTypeEnum:SQL_HANDLE_DBC,
                                       miConnectionHandle).
    end method.
    
    /** Creates a server object (ie this-object:Server). This is separated
        from the Connect/Disconnect pair of methods so that one server can 
        be connected and disconnected multiple time. */
    method public void CreateServer():
        miEnvironmentHandle = SqlCommonLib:AllocateHandle(SqlHandleTypeEnum:SQL_HANDLE_ENV, SqlHandleTypeEnum:SQL_NULL_HANDLE:Value).
        
        SetEnvAttribute(SQL_ATTR_ODBC_VERSION, SQL_OV_ODBC3).
        miConnectionHandle = SqlCommonLib:AllocateHandle(SqlHandleTypeEnum:SQL_HANDLE_DBC, miEnvironmentHandle).
    end method.
    
    method private void SetEnvAttribute(input piAttribute as integer,
                                        input piValue as integer):
        define variable iReturnCode as integer no-undo.
        
        /* for SQLSetEnvAttr integer values, always use 32bit integers. length param is ignored */
        run SQLSetEnvAttr (input  miEnvironmentHandle,
                           input  piAttribute,
                           input  piValue,
                           input  0,        /* ignored for integer values */
                           output iReturnCode).
        SqlCommonLib:ProcessReturnCode(iReturnCode, substitute('SQLSetEnvAttr:&1', piAttribute)).
    end method.

    method private void SetEnvAttribute(input piAttribute as integer,
                                        input pcValue as character):
        define variable iReturnCode as integer no-undo.
        define variable mValue as memptr no-undo.
        define variable iEnvValue as integer no-undo.
        define variable iValueLength as integer no-undo.
        
        /* for character parameters, pass pointer */
        set-size(mValue) = 8.
        put-string(mValue, 1) = pcValue.
        
        assign iEnvValue    = get-long(mValue, 1)
               iValueLength = get-size(mValue)
               .
        run SQLSetEnvAttr (input  miEnvironmentHandle,
                           input  piAttribute,
                           input  iEnvValue,
                           input  iValueLength,
                           output iReturnCode).
        SqlCommonLib:ProcessReturnCode(iReturnCode, substitute('SQLSetEnvAttr:&1', piAttribute)).
    end method.
    
    /** Destroys the server object (ie this-object:Server). This is separated
        from the Connect/Disconnect pair of methods so that one server can 
        be connected and disconnected multiple time. */
    method public void DestroyServer():       
        this-object:Disconnect().
        release external "{&ODBC-DLL}".
    end method.
    
    /** Disconnect from the server, if connected */
    method public void Disconnect():
        define variable iReturnCode as integer no-undo.
        
        if miConnectionHandle gt 0 then
        do:
            run SQLDisconnect (input miConnectionHandle, output iReturnCode).
            SqlCommonLib:ProcessReturnCode(iReturnCode, 'SQLDisconnect').
        end.
                
        SqlCommonLib:FreeHandle(input SqlHandleTypeEnum:SQL_HANDLE_DBC, input  miConnectionHandle).
        SqlCommonLib:FreeHandle(input SqlHandleTypeEnum:SQL_HANDLE_ENV, input  miEnvironmentHandle).
    end method.
    
    /** Returns a new statement object to a caller. The SqlExecuteDirect object is used
        to execute a query against the connection's data source.
        
        @return SqlExecuteDirect  */
    method public SqlExecuteDirect CreateExecuteStatement():
        return cast(SqlStatementFactory(get-class(OpenEdge.Data.ODBC.SqlExecuteDirect)), SqlExecuteDirect).
    end method.
    
    method private SqlStatement SqlStatementFactory(input poStatementType as Progress.Lang.Class):
        define variable oStmt as SqlStatement no-undo.
        
        Assert:IsPositive(miEnvironmentHandle, 'Environment Handle').
        Assert:IsPositive(miConnectionHandle, 'Connection Handle').
        
        create ttSqlStatement.
        assign ttSqlStatement.StmtHandle = SqlCommonLib:AllocateHandle(SqlHandleTypeEnum:SQL_HANDLE_STMT, miConnectionHandle).
        
        moParamList:SetParameter(1,
                                 'INT64',
                                 'INPUT',
                                 ttSqlStatement.StmtHandle).
        moParamList:SetParameter(2,
                                 'CLASS OpenEdge.Core.ServerConnection.ODBCConnection',
                                 'INPUT', 
                                 this-object).
        oStmt = cast(poStatementType:New(moParamList), SqlStatement).
        
        assign ttSqlStatement.StmtRef = oStmt. 
        oStmt:Initialize().
        
        return oStmt.
    end method.
    
    /** Cleans up the statement cache and handle.
        @param int64 The statement handle to clean up.     */
    method public void ClearStatementCache(input piStatementHandle as int64):
        define buffer lbStmt for ttSqlStatement.
        
        find lbStmt where lbStmt.StmtHandle eq piStatementHandle.
        if available lbStmt then
        do:
            SqlCommonLib:FreeHandle(SqlHandleTypeEnum:SQL_HANDLE_STMT, lbStmt.StmtHandle).
            delete lbStmt.
        end.
    end method.
    
    /** Clear the entire statement cache */
    method protected void ClearStatementCache():
        define query qrySqlStmt for ttSqlStatement.
        
        open query qrySqlStmt preselect each ttSqlStatement.
        
        query qrySqlStmt:get-first().
        do while not query qrySqlStmt:query-off-end: 
            /* delete the statememt, which will call back to ClearStatementCache() via the destructor */
            delete object ttSqlStatement.StmtRef.
            
            query qrySqlStmt:get-next().
        end.
    end method.
    
    method public SqlGetTables CreateTableStatement().
        return cast(SqlStatementFactory(get-class(OpenEdge.Data.ODBC.SqlGetTables)), SqlGetTables).
    end method.

    method public SqlGetColumns CreateColumnStatement().
        return cast(SqlStatementFactory(get-class(OpenEdge.Data.ODBC.SqlGetColumns)), SqlGetColumns).
    end method.
    
    method public SqlGetTypeInfo CreateTypeInfoStatement().
        return cast(SqlStatementFactory(get-class(OpenEdge.Data.ODBC.SqlGetTypeInfo)), SqlGetTypeInfo).
    end method.
    
    /** Executes a SQL statement and returns a result set.
        
        @param character A SQL statement to execute 
        @param JsonObject Output The restult set of the SQL statement */
    method public void ExecuteStatement(input  pcStatement as character,
                                        output poResultSet as JsonObject):
        CreateExecuteStatement():Execute(pcStatement, output poResultSet).
    end method.
    
    /** Executes a SQL statement and returns a result set.
        
        @param character A SQL statement to execute 
        @param table-handle Output A temp-table build from the columns defined by the SQL statement that contains the result set */
    method public void ExecuteStatement(input  pcStatement as character,
                                        output table-handle phResultSet):
        CreateExecuteStatement():Execute(pcStatement, output table-handle phResultSet).
    end method.

    /** Executes a SQL statement and populates a result set.
        
        @param character A SQL statement to execute 
        @param handle   A buffer handle to contains the result set */
    method public void ExecuteStatement(input pcStatement as character,
                                        input phResultSet as handle):
        CreateExecuteStatement():Execute(pcStatement, phResultSet).
    end method.

    /** Returns the schema - table and columns - for a single table.
    
        @param character The table for which to return schema
        @return JsonObject The schema for the table */
    method public JsonObject GetTableSchema(input pcTableName as character):
        return CreateTableStatement():GetSingleTable(pcTableName, 'column').        
    end method.
    
    /** Returns the schema - table only - for all tables.
    
        @param logical If true, retrieve columns and other related schema for each table
        @return JsonObject The schema for the table */
    method public JsonObject GetTables(input plChildSchema as logical):
        return CreateTableStatement():GetTables((if plChildSchema then 'column' else '')).        
    end method.

    /** Returns the columns for a single table.
    
        @param character The table for which to return schema
        @return JsonArray The column schema for the table */
    method public JsonArray GetColumns(input pcTableName as character):
        return CreateColumnStatement():GetColumns(pcTableName).        
    end method.

    /** Returns information about all types supported by the data source
    
        @return JsonArray An array of types. */    
    method public JsonArray GetTypeInfo():
        return CreateTypeInfoStatement():GetTypeInfo().
    end method.

    /** Returns information about the types supported by the data source
        that map to a specific SQL data type
        
        @param SqlTypeEnum The SQL type for which to list supported types.
        @return JsonArray An array of types. */
    method public JsonArray GetTypeInfo(input poSqlType as SqlTypeEnum):
        return CreateTypeInfoStatement():GetTypeInfo(poSqlType).
    end method.
    
end class.
