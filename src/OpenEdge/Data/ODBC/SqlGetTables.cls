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
    File        : SqlGetTables
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Wed Jul 24 13:45:14 EDT 2013
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.Assert.
using OpenEdge.Core.ServerConnection.ODBCConnection.
using OpenEdge.Data.ODBC.CTypeEnum.
using OpenEdge.Data.ODBC.RowReadEventArgs.
using OpenEdge.Data.ODBC.SqlGetColumns.
using OpenEdge.Data.ODBC.SqlGetTables.
using OpenEdge.Data.ODBC.SqlStatement.
using Progress.Json.ObjectModel.JsonArray.
using Progress.Json.ObjectModel.JsonObject.
using Progress.Lang.Object.

class OpenEdge.Data.ODBC.SqlGetTables inherits SqlStatement:
    /* basically just some random number */ 
    define static private variable SQL_TABLES_STATEMENT_ID as character no-undo init 'OpenEdge.Data.ODBC.SqlGetTables'.
    
    /* DLL forward declarations */
    {OpenEdge/Data/ODBC/SqlStatementProto.i}
    
    constructor static SqlGetTables():
        /* Set up schema */
        /* From http://msdn.microsoft.com/en-us/library/windows/desktop/ms711831%28v=vs.85%29.aspx
        Column name             Col No  Data type   Comments
        TABLE_CAT (ODBC 1.0)    1       Varchar     Catalog name; NULL if not applicable to the data source. 
                                                    If a driver supports catalogs for some tables but not for others, 
                                                    such as when the driver retrieves data from different DBMSs, 
                                                    it returns an empty string ("") for those tables that do not
                                                    have catalogs.
        TABLE_SCHEM (ODBC 1.0)  2       Varchar     Schema name; NULL if not applicable to the data source. If a driver 
                                                    supports schemas for some tables but not for others, such as when 
                                                    the driver retrieves data from different DBMSs, it returns an empty 
                                                    string ("") for those tables that do not have schemas.
        TABLE_NAME (ODBC 1.0)   3       Varchar     Table name.
        TABLE_TYPE (ODBC 1.0)   4       Varchar     Table type name; one of the following: "TABLE", "VIEW", 
                                                    "SYSTEM TABLE", "GLOBAL TEMPORARY", "LOCAL TEMPORARY", "ALIAS", 
                                                    "SYNONYM", or a data source–specific type name. The meanings of
                                                    "ALIAS" and "SYNONYM" are driver-specific.
        REMARKS (ODBC 1.0)      5       Varchar     A description of the table.     */
        
        /* Schema cache for GetTables query */
        SqlStatement:ClearColumnSchema(SQL_TABLES_STATEMENT_ID).
        
        /* Notice that the driver counts the null-termination character when it returns character data to mTargetValue. 
           mTargetValue must therefore contain space for the null-termination character or the driver will truncate the data. */
        SqlStatement:AddColumnSchema(SqlGetTables:SQL_TABLES_STATEMENT_ID, 1, 'TABLE_CAT',    CTypeEnum:SQL_C_CHAR).
        SqlStatement:AddColumnSchema(SqlGetTables:SQL_TABLES_STATEMENT_ID, 2, 'TABLE_SCHEM',  CTypeEnum:SQL_C_CHAR).
        SqlStatement:AddColumnSchema(SqlGetTables:SQL_TABLES_STATEMENT_ID, 3, 'TABLE_NAME',   CTypeEnum:SQL_C_CHAR).
        SqlStatement:AddColumnSchema(SqlGetTables:SQL_TABLES_STATEMENT_ID, 4, 'TABLE_TYPE',   CTypeEnum:SQL_C_CHAR).
        SqlStatement:AddColumnSchema(SqlGetTables:SQL_TABLES_STATEMENT_ID, 5, 'REMARKS',      CTypeEnum:SQL_C_WCHAR).        
    end constructor.
    
	constructor public SqlGetTables ( input piStmt as int64, input poConnection as ODBCConnection):
		super (input piStmt, input poConnection).
		this-object:StatementId = SqlGetTables:SQL_TABLES_STATEMENT_ID.
	end constructor.

    /** Retrieves table schema information.
                
        @return JsonObject A json object containing the schema  */
    method public JsonObject GetTables():
        return GetTables('column').
    end method.
    
    /** Retrieves table schema information for a single table.
                
        @param character The table name. 
        @param character The type of additional schema to return. 'Column' for example. 
        @return JsonObject A json object containing the schema  */
    method public JsonObject GetSingleTable(input pcTableName as character,
                                            input pcChildTypes as character):
        Assert:NotNullOrEmpty(pcTableName, 'Table name').
        return GetTables(SQL_ALL_CATALOGS, SQL_ALL_SCHEMAS, pcTableName, 'TABLE', pcChildTypes).
    end method.
    
    /** Retrieves table schema information.
                
        @param character The type of additional schema to return. 'Column' for example. 
        @return JsonObject A json object containing the schema  */
    method public JsonObject GetTables(input pcChildTypes as character):
        return GetTables(SQL_ALL_CATALOGS, SQL_ALL_SCHEMAS, '%', 'TABLE', pcChildTypes).
    end method.
    
    /** Returns table metadata/schema 
        
        @param character The catalog for selection
        @param character The schema for selection
        @param character The table for selection
        @return JsonObject A json object containing the schema  */
    method public JsonObject GetTables(input pcCatalogName as character,
                                        input pcSchemaName as character,
                                        input pcTableName as character,
                                        input pcTableType as character,
                                        input pcChildTypes as character):
        /* pcSchemaType = table, column, ??? */ 
        define variable oResultSet as JsonObject no-undo.
        define variable iReturnCode as integer no-undo.
        define variable oDataArray as JsonArray no-undo.
        
        Assert:NotNull(pcCatalogName, 'Catalog name').
        Assert:NotNull(pcSchemaName, 'Schema name').
        Assert:NotNull(pcTableName, 'Table name').
        Assert:NotNull(pcTableType, 'Table type').
        
        /* this is the query */
        run SQLTables (input        this-object:StatementHandle,
                       input        pcCatalogName,
                       input        length(pcCatalogName),
                       input        pcSchemaName,
                       input        length(pcSchemaName),
                       input        pcTableName,
                       input        length(pcTableName),
                       input        pcTableType,
                       input        length(pcTableType),
                             output iReturnCode).
        SqlCommonLib:ProcessReturnCode(
                        iReturnCode,
                        'SQLTables').
        
        oResultSet = new JsonObject().
        oResultSet:Add('query', 'SQLTables').
        oDataArray = new JsonArray().
        oResultSet:Add('tables', oDataArray).
        
        if lookup('column', pcChildTypes) gt 0 then
        do:
            /* don't use the standard behaviour */
            RowReadComplete:Unsubscribe(this-object:RowReadCompleteJsonEventHandler()).
            RowReadComplete:Subscribe(this-object:RowReadCompleteEventHandler()).
        end.
        
        LoadResultSet(oDataArray).
        
        if lookup('column', pcChildTypes) gt 0 then
            RowReadComplete:Unsubscribe(this-object:RowReadCompleteEventHandler()).
        
        return oResultSet.
    end method.	
    
	method protected void RowReadCompleteEventHandler(input poSender as Object,
	                                                  input poEventArgs as RowReadEventArgs):
        /* Get Columns */
        define variable oColStmt as SqlGetColumns no-undo.
        define variable oColumns as JsonArray no-undo.
        define variable oRow as JsonObject no-undo.
        
        oColStmt = this-object:ODBCConnection:CreateColumnStatement().
        oRow = cast(poEventArgs:RowReference, JsonObject).
        
        oColumns = oColStmt:GetColumns(
                oRow:GetCharacter('TABLE_CAT'),
                oRow:GetCharacter('TABLE_SCHEM'),
                oRow:GetCharacter('TABLE_NAME')).
        
        oRow:Add('columns', oColumns).
	end method.
	
end class.
