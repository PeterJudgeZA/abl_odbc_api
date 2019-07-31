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
    File        : SqlGetColumns
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Wed Jul 24 15:20:38 EDT 2013
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.ServerConnection.ODBCConnection.
using OpenEdge.Data.ODBC.CTypeEnum.
using OpenEdge.Data.ODBC.SqlStatement.
using OpenEdge.Data.ODBC.SqlGetColumns.
using Progress.Json.ObjectModel.JsonArray.

class OpenEdge.Data.ODBC.SqlGetColumns inherits SqlStatement: 
    /* basically just some random number */
    define static private variable SQL_COLUMNS_STATEMENT_ID as character no-undo init 'OpenEdge.Data.ODBC.SqlGetColumns'.
    
    /* DLL forward declarations */
    {OpenEdge/Data/ODBC/SqlStatementProto.i}
    
    constructor static SqlGetColumns():
        /* Schema cache for GetColumns query */
        SqlStatement:ClearColumnSchema(SQL_COLUMNS_STATEMENT_ID).
        
        /* doc via  http://msdn.microsoft.com/en-us/library/windows/desktop/ms711683%28v=vs.85%29.aspx 
        Column name                 Col No  Data type           Comments        
        TABLE_CAT (ODBC 1.0)        1       Varchar             Catalog name; NULL if not applicable to the data source. If a driver supports catalogs for 
                                                                some tables but not for others, such as when the driver retrieves data from different DBMSs, 
                                                                it returns an empty string ("") for those tables that do not have catalogs.
        TABLE_SCHEM (ODBC 1.0)      2       Varchar             Schema name; NULL if not applicable to the data source. If a driver supports schemas 
                                                                for some tables but not for others, such as when the driver retrieves data from different 
                                                                DBMSs, it returns an empty string ("") for those tables that do not have schemas.
        TABLE_NAME (ODBC 1.0)       3       Varchar not NULL    Table name.
        COLUMN_NAME (ODBC 1.0)      4       Varchar not NULL    Column name. The driver returns an empty string for a column that does not have a name.
        DATA_TYPE (ODBC 1.0)        5       Smallint not NULL   SQL data type. This can be an ODBC SQL data type or a driver-specific 
                                                                SQL data type. For datetime and interval data types, this column returns 
                                                                the concise data type (such as SQL_TYPE_DATE or SQL_INTERVAL_YEAR_TO_MONTH,
                                                                instead of the nonconcise data type such as SQL_DATETIME or SQL_INTERVAL). 
                                                                For a list of valid ODBC SQL data types, see SQL Data Types in 
                                                                Appendix D: Data Types. For information about driver-specific SQL data 
                                                                types, see the driver's documentation. The data types returned for 
                                                                ODBC 3.x and ODBC 2.x applications may be different. For more information, 
                                                                see Backward Compatibility and Standards Compliance.
                                                                
        TYPE_NAME (ODBC 1.0)        6       Varchar not NULL    Data source–dependent data type name; for example, "CHAR", "VARCHAR", 
                                                                "MONEY", "LONG VARBINAR", or "CHAR ( ) FOR BIT DATA".
        COLUMN_SIZE (ODBC 1.0)      7       Integer             If DATA_TYPE is SQL_CHAR or SQL_VARCHAR, this column contains the
                                                                maximum length in characters of the column. For datetime data types,
                                                                this is the total number of characters required to display the value 
                                                                when it is converted to characters. For numeric data types, this is 
                                                                either the total number of digits or the total number of bits 
                                                                allowed in the column, according to the NUM_PREC_RADIX column. 
                                                                For interval data types, this is the number of characters in the 
                                                                character representation of the interval literal (as defined by 
                                                                the interval leading precision, see Interval Data Type Length in
                                                                Appendix D: Data Types). For more information, see Column Size,
                                                                ecimal Digits, Transfer Octet Length, and Display Size in 
                                                                Appendix D: Data Types.
                                                                   
        BUFFER_LENGTH (ODBC 1.0)    8       Integer             The length in bytes of data transferred on an SQLGetData, SQLFetch, 
                                                                or SQLFetchScroll operation if SQL_C_DEFAULT is specified. For numeric 
                                                                data, this size may differ from the size of the data stored on the 
                                                                data source. This value might differ from COLUMN_SIZE column for 
                                                                character data. For more information about length, see Column Size,
                                                                Decimal Digits, Transfer Octet Length, and Display Size in 
                                                                Appendix D: Data Types.
                                                                
        DECIMAL_DIGITS (ODBC 1.0)   9       Smallint            The total number of significant digits to the right of the decimal point. For SQL_TYPE_TIME and SQL_TYPE_TIMESTAMP, this column contains the number of digits in the fractional seconds component. For the other data types, this is the decimal digits of the column on the data source. For interval data types that contain a time component, this column contains the number of digits to the right of the decimal point (fractional seconds). For interval data types that do not contain a time component, this column is 0. For more information about decimal digits, see Column Size, Decimal Digits, Transfer Octet Length, and Display Size in Appendix D: Data Types. NULL is returned for data types where DECIMAL_DIGITS is not applicable.
        NUM_PREC_RADIX (ODBC 1.0)   10      Smallint            For numeric data types, either 10 or 2. If it is 10, the values in COLUMN_SIZE and DECIMAL_DIGITS give the number of decimal digits allowed for the column. For example, a DECIMAL(12,5) column would return a NUM_PREC_RADIX of 10, a COLUMN_SIZE of 12, and a DECIMAL_DIGITS of 5; a FLOAT column could return a NUM_PREC_RADIX of 10, a COLUMN_SIZE of 15, and a DECIMAL_DIGITS of NULL. If it is 2, the values in COLUMN_SIZE and DECIMAL_DIGITS give the number of bits allowed in the column. For example, a FLOAT column could return a RADIX of 2, a COLUMN_SIZE of 53, and a DECIMAL_DIGITS of NULL. NULL is returned for data types where NUM_PREC_RADIX is not applicable.
        NULLABLE (ODBC 1.0)         11      Smallint not NULL   SQL_NO_NULLS if the column could not include NULL values. SQL_NULLABLE if the column accepts NULL values. SQL_NULLABLE_UNKNOWN if it is not known whether the column accepts NULL values. The value returned for this column differs from the value returned for the IS_NULLABLE column. The NULLABLE column indicates with certainty that a column can accept NULLs, but cannot indicate with certainty that a column does not accept NULLs. The IS_NULLABLE column indicates with certainty that a column cannot accept NULLs, but cannot indicate with certainty that a column accepts NULLs.
        REMARKS (ODBC 1.0)          12      Varchar             A description of the column.
        COLUMN_DEF (ODBC 3.0)       13      Varchar             The default value of the column. The value in this column should be interpreted as a string if it is enclosed in quotation marks. If NULL was specified as the default value, this column is the word NULL, not enclosed in quotation marks. If the default value cannot be represented without truncation, this column contains TRUNCATED, without enclosing single quotation marks. If no default value was specified, this column is NULL. The value of COLUMN_DEF can be used in generating a new column definition, except when it contains the value TRUNCATED.
        SQL_DATA_TYPE (ODBC 3.0)    14      Smallint not NULL   SQL data type, as it appears in the SQL_DESC_TYPE record field in the IRD. 
                                                                This can be an ODBC SQL data type or a driver-specific SQL data type. This
                                                                column is the same as the DATA_TYPE column, except for datetime and interval 
                                                                data types. This column returns the nonconcise data type (such as SQL_DATETIME 
                                                                or SQL_INTERVAL), instead of the concise data type (such as SQL_TYPE_DATE or 
                                                                SQL_INTERVAL_YEAR_TO_MONTH) for datetime and interval data types. If this 
                                                                column returns SQL_DATETIME or SQL_INTERVAL, the specific data type can 
                                                                be determined from the SQL_DATETIME_SUB column. For a list of valid 
                                                                ODBC SQL data types, see SQL Data Types in Appendix D: Data Types. 
                                                                For information about driver-specific SQL data types, see the driver's 
                                                                documentation. The data types returned for ODBC 3.x and ODBC 2.x 
                                                                applications may be different. For more information, see Backward 
                                                                Compatibility and Standards Compliance.
                                                                
        SQL_DATETIME_SUB (ODBC 3.0) 15      Smallint            The subtype code for datetime and interval data types. For other data
                                                                types, this column returns a NULL. For more information about datetime
                                                                and interval subcodes, see "SQL_DESC_DATETIME_INTERVAL_CODE" in 
                                                                SQLSetDescField.
                                                                
        CHAR_OCTET_LENGTH (ODBC 3.0)16      Integer             The maximum length in bytes of a character or binary data type column. 
                                                                For all other data types, this column returns a NULL.
        ORDINAL_POSITION (ODBC 3.0) 17      Integer not NULL    The ordinal position of the column in the table. The first column in the table is number 1.
        IS_NULLABLE (ODBC 3.0)      18      Varchar             "NO" if the column does not include NULLs. "YES" if the column could include NULLs. This column returns a zero-length string if nullability is unknown. ISO rules are followed to determine nullability. An ISO SQL–compliant DBMS cannot return an empty string. The value returned for this column differs from the value returned for the NULLABLE column. (See the description of the NULLABLE column.)        
        */

        SqlStatement:AddColumnSchema(SQL_COLUMNS_STATEMENT_ID, 1,  'TABLE_CAT',         CTypeEnum:SQL_C_CHAR).
        SqlStatement:AddColumnSchema(SQL_COLUMNS_STATEMENT_ID, 2,  'TABLE_SCHEM',       CTypeEnum:SQL_C_CHAR).
        SqlStatement:AddColumnSchema(SQL_COLUMNS_STATEMENT_ID, 3,  'TABLE_NAME',        CTypeEnum:SQL_C_CHAR).
        SqlStatement:AddColumnSchema(SQL_COLUMNS_STATEMENT_ID, 4,  'COLUMN_NAME',       CTypeEnum:SQL_C_CHAR).
        SqlStatement:AddColumnSchema(SQL_COLUMNS_STATEMENT_ID, 5,  'DATA_TYPE',         CTypeEnum:SQL_C_SSHORT).
        SqlStatement:AddColumnSchema(SQL_COLUMNS_STATEMENT_ID, 6,  'TYPE_NAME',         CTypeEnum:SQL_C_CHAR).
        SqlStatement:AddColumnSchema(SQL_COLUMNS_STATEMENT_ID, 7,  'COLUMN_SIZE',       CTypeEnum:SQL_C_SLONG).
        SqlStatement:AddColumnSchema(SQL_COLUMNS_STATEMENT_ID, 8,  'BUFFER_LENGTH',     CTypeEnum:SQL_C_SLONG).
        SqlStatement:AddColumnSchema(SQL_COLUMNS_STATEMENT_ID, 9,  'DECIMAL_DIGITS',    CTypeEnum:SQL_C_SSHORT).
        SqlStatement:AddColumnSchema(SQL_COLUMNS_STATEMENT_ID, 10, 'NUM_PREC_RADIX',    CTypeEnum:SQL_C_SSHORT).
        SqlStatement:AddColumnSchema(SQL_COLUMNS_STATEMENT_ID, 11, 'NULLABLE',          CTypeEnum:SQL_C_SSHORT).
        SqlStatement:AddColumnSchema(SQL_COLUMNS_STATEMENT_ID, 12, 'REMARKS',           CTypeEnum:SQL_C_WCHAR).
        SqlStatement:AddColumnSchema(SQL_COLUMNS_STATEMENT_ID, 13, 'COLUMN_DEF',        CTypeEnum:SQL_C_WCHAR).
        SqlStatement:AddColumnSchema(SQL_COLUMNS_STATEMENT_ID, 14, 'SQL_DATA_TYPE',     CTypeEnum:SQL_C_SSHORT).
        SqlStatement:AddColumnSchema(SQL_COLUMNS_STATEMENT_ID, 15, 'SQL_DATETIME_SUB',  CTypeEnum:SQL_C_SSHORT).
        SqlStatement:AddColumnSchema(SQL_COLUMNS_STATEMENT_ID, 16, 'CHAR_OCTET_LENGTH', CTypeEnum:SQL_C_SLONG).
        SqlStatement:AddColumnSchema(SQL_COLUMNS_STATEMENT_ID, 17, 'ORDINAL_POSITION',  CTypeEnum:SQL_C_SSHORT).
        SqlStatement:AddColumnSchema(SQL_COLUMNS_STATEMENT_ID, 18, 'IS_NULLABLE',       CTypeEnum:SQL_C_WCHAR).
    end constructor.
    
	constructor public SqlGetColumns ( input piStmt as int64, input poConnection as ODBCConnection):
		super (input piStmt, input poConnection).
		
		this-object:StatementId = SqlGetColumns:SQL_COLUMNS_STATEMENT_ID.
	end constructor.

    method public JsonArray GetColumns (input pcTableName as character):
        define variable oColumnData as JsonArray no-undo.
        
        oColumnData = new JsonArray().
        
        return oColumnData.
    end method.
    
    /** Returns column metadata/schema 
        
        @param character The catalog for selection
        @param character The schema for selection
        @param character The table for selection
        @return JsonArray An array of column schema data */
    method public JsonArray GetColumns(input pcCatalogName as character,
                                       input pcSchemaName as character,
                                       input pcTableName as character):
        define variable oColumns as JsonArray no-undo.
        define variable iReturnCode as integer no-undo.
        
        /* this is the query */
        if pcCatalogName eq ? then pcCatalogName = ''.
        if pcSchemaName eq ? then pcSchemaName = '%'.
        
        run SQLColumns(input        this-object:StatementHandle,
                       input        pcCatalogName,
                       input        length(pcCatalogName),
                       input        pcSchemaName,
                       input        length(pcSchemaName),
                       input        pcTableName,
                       input        length(pcTableName),
                       input        '%',                        /* column name */
                       input        length('%'),
                             output iReturnCode).
        SqlCommonLib:ProcessReturnCode(
                        iReturnCode,
                        substitute('&4: &1 / &2 / &3', pcCatalogName, pcSchemaName, pcTableName, SQL_COLUMNS_STATEMENT_ID)).
        
        oColumns = new JsonArray().

        LoadResultSet(oColumns).
        
        return oColumns.                                           
    end method.
    
end class.
