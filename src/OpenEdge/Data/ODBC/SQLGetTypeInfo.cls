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
    File        : SQLGetTypeInfo
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Thu Jul 25 13:42:09 EDT 2013
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Data.ODBC.RowReadEventArgs.
using OpenEdge.Data.ODBC.FieldReadEventArgs.
using OpenEdge.Data.ODBC.CTypeEnum.
using OpenEdge.Data.ODBC.SqlTypeEnum.
using OpenEdge.Data.ODBC.SqlHandleTypeEnum.
using OpenEdge.Data.ODBC.SQLGetTypeInfo.
using OpenEdge.Data.ODBC.SqlStatement.
using OpenEdge.Core.WidgetHandle.
using Progress.Json.ObjectModel.JsonObject.
using Progress.Json.ObjectModel.JsonArray.
using Progress.Lang.Object.

class OpenEdge.Data.ODBC.SQLGetTypeInfo inherits SqlStatement:
    define static private temp-table TypeInfo no-undo
        field TYPE_NAME             as character
        field DATA_TYPE             as integer
        field COLUMN_SIZE           as integer
        field LITERAL_PREFIX        as character
        field LITERAL_SUFFIX        as character
        field CREATE_PARAMS         as character
        field NULLABLE              as integer
        field CASE_SENSITIVE        as integer
        field SEARCHABLE            as integer
        field UNSIGNED_ATTRIBUTE    as integer
        field FIXED_PREC_SCALE      as integer
        field AUTO_UNIQUE_VALUE     as integer
        field LOCAL_TYPE_NAME       as character
        field MINIMUM_SCALE         as integer
        field MAXIMUM_SCALE         as integer
        field SQL_DATA_TYPE         as integer
        field SQL_DATETIME_SUB      as integer
        field NUM_PREC_RADIX        as integer
        field INTERVAL_PRECISION    as integer
        index idx1 as primary TYPE_NAME DATA_TYPE
        index idx2            DATA_TYPE.
    
    /* basically just some random number */ 
    define static private variable SQL_TYPE_INFO_STATEMENT_ID as character no-undo init 'OpenEdge.Data.ODBC.SQLGetTypeInfo'.
    
    /* DLL forward declarations */
    {OpenEdge/Data/ODBC/SqlStatementProto.i}
    
    constructor static SQLGetTypeInfo():
        /* Schema cache for GetColumns query */
        SqlStatement:ClearColumnSchema(SQLGetTypeInfo:SQL_TYPE_INFO_STATEMENT_ID).
        
        /* Doc'ed at http://msdn.microsoft.com/en-us/library/windows/desktop/ms714632%28v=vs.85%29.aspx */
        /* TYPE_NAME (ODBC 2.0)            1   Varchar not NULL     Data source–dependent data-type name; for example, "CHAR()", 
                                                                    "VARCHAR()", "MONEY", "LONG VARBINARY", or "CHAR ( ) FOR BIT DATA".
                                                                    Applications must use this name in CREATE TABLE */
                                                                    
        /* DATA_TYPE (ODBC 2.0)            2   Smallint not NULL    SQL data type. This can be an ODBC SQL data type or a driver-specific 
                                                                    SQL data type. For datetime or interval data types, this column 
                                                                    returns the concise data type (such as SQL_TYPE_TIME or 
                                                                    SQL_INTERVAL_YEAR_TO_MONTH). For a list of valid ODBC SQL 
                                                                    data types, see SQL Data Types in Appendix D: Data Types. 
                                                                    For information about driver-specific SQL data types, see
                                                                    the driver's documentation. */
                                                                    
        /* COLUMN_SIZE (ODBC 2.0)          3   Integer              The maximum column size that the server supports for this data type.
                                                                    For numeric data, this is the maximum precision. For string data, 
                                                                    this is the length in characters. For datetime data types, this 
                                                                    is the length in characters of the string representation (assuming 
                                                                    the maximum allowed precision of the fractional seconds component).
                                                                    NULL is returned for data types where column size is not applicable. 
                                                                    For interval data types, this is the number of characters in the 
                                                                    character representation of the interval literal (as defined by 
                                                                    the interval leading precision; see Interval Data Type Length in 
                                                                    Appendix D: Data Types). For more information on column size, see 
                                                                    Column Size, Decimal Digits, Transfer Octet Length, and Display 
                                                                    Size in Appendix D: Data Types. */
               
        /* LITERAL_PREFIX (ODBC 2.0)       4   Varchar              Character or characters used to prefix a literal; for example, a
                                                                    single quotation mark (') for character data types or 0x for 
                                                                    binary data types; NULL is returned for data types where a 
                                                                    literal prefix is not applicable.   */
               
        /* LITERAL_SUFFIX (ODBC 2.0)       5   Varchar              Character or characters used to terminate a literal; for example,
                                                                    a single quotation mark (') for character data types; NULL is 
                                                                    returned for data types where a literal suffix is not applicable. */
               
        /* CREATE_PARAMS (ODBC 2.0)        6   Varchar              A list of keywords, separated by commas, corresponding to each 
                                                                    parameter that the application may specify in parentheses when
                                                                    using the name that is returned in the TYPE_NAME field. The 
                                                                    keywords in the list can be any of the following: length, precision, 
                                                                    or scale. They appear in the order that the syntax requires them to 
                                                                    be used. For example, CREATE_PARAMS for DECIMAL would be 
                                                                    "precision,scale"; CREATE_PARAMS for VARCHAR would equal "length." 
                                                                    NULL is returned if there are no parameters for the data type 
                                                                    definition; for example, INTEGER. The driver supplies the 
                                                                    CREATE_PARAMS text in the language of the country/region where 
                                                                    it is used. */

        /* NULLABLE (ODBC 2.0)             7   Smallint not NULL    Whether the data type accepts a NULL value:
                                                                      SQL_NO_NULLS if the data type does not accept NULL values.
                                                                      SQL_NULLABLE if the data type accepts NULL values.
                                                                      SQL_NULLABLE_UNKNOWN if it is not known whether the column 
                                                                      accepts NULL values.  */
               
        /* CASE_SENSITIVE (ODBC 2.0)       8   Smallint not NULL     Whether a character data type is case-sensitive in collations and 
                                                                     comparisons:
                                                                       SQL_TRUE if the data type is a character data type and 
                                                                       is case-sensitive.
                                                                       SQL_FALSE if the data type is not a character data type or 
                                                                       is not case-sensitive. */

        /* SEARCHABLE (ODBC 2.0)           9   Smallint not NULL    How the data type is used in a WHERE clause:
                                                                      SQL_PRED_NONE if the column cannot be used in a WHERE clause.
                                                                        (This is the same as the SQL_UNSEARCHABLE value in ODBC 2.x.)
                                                                      SQL_PRED_CHAR if the column can be used in a WHERE clause, but 
                                                                        only with the LIKE predicate. (This is the same as the 
                                                                        SQL_LIKE_ONLY value in ODBC 2.x.)
                                                                      SQL_PRED_BASIC if the column can be used in a WHERE clause 
                                                                        with all the comparison operators except LIKE (comparison,
                                                                        quantified comparison, BETWEEN, DISTINCT, IN, MATCH, and 
                                                                        UNIQUE). (This is the same as the SQL_ALL_EXCEPT_LIKE value 
                                                                        in ODBC 2.x.)
                                                                      SQL_SEARCHABLE if the column can be used in a WHERE clause with 
                                                                        any comparison operator.        */
               
        /* UNSIGNED_ATTRIBUTE (ODBC 2.0)   10  Smallint              Whether the data type is unsigned:
                                                                       SQL_TRUE if the data type is unsigned.
                                                                       SQL_FALSE if the data type is signed.
                                                                       NULL is returned if the attribute is not applicable to the 
                                                                        data type or the data type is not numeric.  */
        /* FIXED_PREC_SCALE (ODBC 2.0)     11  Smallint not NULL     Whether the data type has predefined fixed precision and scale 
                                                                    (which are data source–specific), such as a money data type:
                                                                      SQL_TRUE if it has predefined fixed precision and scale.
                                                                      SQL_FALSE if it does not have predefined fixed precision and scale */
               
        /* AUTO_UNIQUE_VALUE (ODBC 2.0)    12  Smallint             Whether the data type is autoincrementing:
                                                                      SQL_TRUE if the data type is autoincrementing.
                                                                      SQL_FALSE if the data type is not autoincrementing.
                                                                      NULL is returned if the attribute is not applicable to the 
                                                                        data type or the data type is not numeric. An application
                                                                        can insert values into a column having this attribute, 
                                                                        but typically cannot update the values in the column.When 
                                                                        an insert is made into an auto-increment column, a unique
                                                                        value is inserted into the column at insert time. The 
                                                                        increment is not defined, but is data source–specific. An 
                                                                        application should not assume that an auto-increment column 
                                                                        starts at any particular point or increments by any 
                                                                        particular value.   */

        /* LOCAL_TYPE_NAME (ODBC 2.0)      13  Varchar              Localized version of the data source–dependent name of the data 
                                                                    type. NULL is returned if a localized name is not supported by 
                                                                    the data source. This name is intended for display only, such 
                                                                    as in dialog boxes.     */
               
        /* MINIMUM_SCALE (ODBC 2.0)        14  Smallint             The minimum scale of the data type on the data source. If a 
                                                                    data type has a fixed scale, the MINIMUM_SCALE and MAXIMUM_SCALE 
                                                                    columns both contain this value. For example, an SQL_TYPE_TIMESTAMP 
                                                                    column might have a fixed scale for fractional seconds. NULL is 
                                                                    returned where scale is not applicable. For more information, 
                                                                    see Column Size, Decimal Digits, Transfer Octet Length, and 
                                                                    Display Size in Appendix D: Data Types. */
               
        /* MAXIMUM_SCALE (ODBC 2.0)        15  Smallint             The maximum scale of the data type on the data source. NULL is 
                                                                    returned where scale is not applicable. If the maximum scale is
                                                                    not defined separately on the data source, but is instead defined 
                                                                    to be the same as the maximum precision, this column contains the
                                                                    same value as the COLUMN_SIZE column. For more information, see 
                                                                    Column Size, Decimal Digits, Transfer Octet Length, and Display
                                                                    Size in Appendix D: Data Types.     */

        /* SQL_DATA_TYPE (ODBC 3.0)        16  Smallint NOT NULL    The value of the SQL data type as it appears in the SQL_DESC_TYPE 
                                                                    field of the descriptor. This column is the same as the DATA_TYPE
                                                                    column, except for interval and datetime data types. For interval
                                                                    and datetime data types, the SQL_DATA_TYPE field in the result 
                                                                    set will return SQL_INTERVAL or SQL_DATETIME, and the 
                                                                    SQL_DATETIME_SUB field will return the subcode for the specific 
                                                                    interval or datetime data type. (See Appendix D: Data Types.)   */
        /* SQL_DATETIME_SUB (ODBC 3.0)     17  Smallint             When the value of SQL_DATA_TYPE is SQL_DATETIME or SQL_INTERVAL,
                                                                    this column contains the datetime/interval subcode. For data types 
                                                                    other than datetime and interval, this field is NULL. For interval 
                                                                    or datetime data types, the SQL_DATA_TYPE field in the result set 
                                                                    will return SQL_INTERVAL or SQL_DATETIME, and the SQL_DATETIME_SUB 
                                                                    field will return the subcode for the specific interval or datetime 
                                                                    data type. (See Appendix D: Data Types.)    */
               
        /* NUM_PREC_RADIX (ODBC 3.0)       18  Integer              If the data type is an approximate numeric type, this column 
                                                                    contains the value 2 to indicate that COLUMN_SIZE specifies a 
                                                                    number of bits. For exact numeric types, this column contains
                                                                     the value 10 to indicate that COLUMN_SIZE specifies a number 
                                                                     of decimal digits. Otherwise, this column is NULL. */
               
        /* INTERVAL_PRECISION (ODBC 3.0)   19  Smallint             If the data type is an interval data type, then this column 
                                                                    contains the value of the interval leading precision. (See Interval 
                                                                    Data Type Precision in Appendix D: Data Types.) Otherwise, this 
                                                                    column is NULL  */

        SqlStatement:AddColumnSchema(SQLGetTypeInfo:SQL_TYPE_INFO_STATEMENT_ID, 1,  'TYPE_NAME',            CTypeEnum:SQL_C_CHAR).
        SqlStatement:AddColumnSchema(SQLGetTypeInfo:SQL_TYPE_INFO_STATEMENT_ID, 2,  'DATA_TYPE',            CTypeEnum:SQL_C_SSHORT).
        SqlStatement:AddColumnSchema(SQLGetTypeInfo:SQL_TYPE_INFO_STATEMENT_ID, 3,  'COLUMN_SIZE',          CTypeEnum:SQL_C_SLONG).
        SqlStatement:AddColumnSchema(SQLGetTypeInfo:SQL_TYPE_INFO_STATEMENT_ID, 4,  'LITERAL_PREFIX',       CTypeEnum:SQL_C_CHAR).
        SqlStatement:AddColumnSchema(SQLGetTypeInfo:SQL_TYPE_INFO_STATEMENT_ID, 5,  'LITERAL_SUFFIX',       CTypeEnum:SQL_C_CHAR).
        SqlStatement:AddColumnSchema(SQLGetTypeInfo:SQL_TYPE_INFO_STATEMENT_ID, 6,  'CREATE_PARAMS',        CTypeEnum:SQL_C_CHAR).
        SqlStatement:AddColumnSchema(SQLGetTypeInfo:SQL_TYPE_INFO_STATEMENT_ID, 7,  'NULLABLE',             CTypeEnum:SQL_C_SSHORT).
        SqlStatement:AddColumnSchema(SQLGetTypeInfo:SQL_TYPE_INFO_STATEMENT_ID, 8,  'CASE_SENSITIVE',       CTypeEnum:SQL_C_SSHORT).
        SqlStatement:AddColumnSchema(SQLGetTypeInfo:SQL_TYPE_INFO_STATEMENT_ID, 9,  'SEARCHABLE',           CTypeEnum:SQL_C_SSHORT).
        SqlStatement:AddColumnSchema(SQLGetTypeInfo:SQL_TYPE_INFO_STATEMENT_ID, 10, 'UNSIGNED_ATTRIBUTE',   CTypeEnum:SQL_C_SSHORT).
        SqlStatement:AddColumnSchema(SQLGetTypeInfo:SQL_TYPE_INFO_STATEMENT_ID, 11, 'FIXED_PREC_SCALE',     CTypeEnum:SQL_C_SSHORT).
        SqlStatement:AddColumnSchema(SQLGetTypeInfo:SQL_TYPE_INFO_STATEMENT_ID, 12, 'AUTO_UNIQUE_VALUE',    CTypeEnum:SQL_C_SSHORT).
        SqlStatement:AddColumnSchema(SQLGetTypeInfo:SQL_TYPE_INFO_STATEMENT_ID, 13, 'LOCAL_TYPE_NAME',      CTypeEnum:SQL_C_CHAR).
        SqlStatement:AddColumnSchema(SQLGetTypeInfo:SQL_TYPE_INFO_STATEMENT_ID, 14, 'MINIMUM_SCALE',        CTypeEnum:SQL_C_SSHORT).
        SqlStatement:AddColumnSchema(SQLGetTypeInfo:SQL_TYPE_INFO_STATEMENT_ID, 15, 'MAXIMUM_SCALE',        CTypeEnum:SQL_C_SSHORT).
        SqlStatement:AddColumnSchema(SQLGetTypeInfo:SQL_TYPE_INFO_STATEMENT_ID, 16, 'SQL_DATA_TYPE',        CTypeEnum:SQL_C_SSHORT).
        SqlStatement:AddColumnSchema(SQLGetTypeInfo:SQL_TYPE_INFO_STATEMENT_ID, 17, 'SQL_DATETIME_SUB',     CTypeEnum:SQL_C_SSHORT).
        SqlStatement:AddColumnSchema(SQLGetTypeInfo:SQL_TYPE_INFO_STATEMENT_ID, 18, 'NUM_PREC_RADIX',       CTypeEnum:SQL_C_SLONG).
        SqlStatement:AddColumnSchema(SQLGetTypeInfo:SQL_TYPE_INFO_STATEMENT_ID, 19, 'INTERVAL_PRECISION',   CTypeEnum:SQL_C_SSHORT).
    end constructor.
    
	constructor public SQLGetTypeInfo ( input piStmt as int64, input poConnection as OpenEdge.Core.ServerConnection.ODBCConnection ):
		super (input piStmt, input poConnection).
		
		this-object:StatementId = SQLGetTypeInfo:SQL_TYPE_INFO_STATEMENT_ID.
		
		CacheTypeInfo().		
	end constructor.
	
	/** Caches the driver's type info. Cannot be done statically since we need
	    a statement handle; we also want to use the SqlStatement (inherited) code
	    for this. */
	method private void CacheTypeInfo():
        define variable iReturnCode as integer no-undo.
        
        run SQLGetTypeInfo (input        this-object:StatementHandle,
                            input        SqlTypeEnum:SQL_ALL_TYPES:Value,
                                  output iReturnCode).
        SqlCommonLib:ProcessReturnCode(
                        iReturnCode,
                        substitute('SQLGetTypeInfo: &1', SqlTypeEnum:SQL_ALL_TYPES:ToString())).
        
        empty temp-table TypeInfo.
        
        LoadResultSet(buffer TypeInfo:handle).
        
        if session:debug-alert then
            buffer TypeInfo:write-json('file', session:temp-dir + 'SQLGetTypeInfo_TypeInfo.json', true).
    end method.
    
	method public JsonArray GetTypeInfo (input poSqlType as SqlTypeEnum):
        define variable oTypeInfo as JsonArray no-undo.
        define variable oRow as JsonObject no-undo.
        define variable iMax as integer no-undo.
        define variable iLoop as integer no-undo.
        define variable hField as handle no-undo.
        
        assign oTypeInfo = new JsonArray()
               iMax =  buffer TypeInfo:num-fields.
        
        for each TypeInfo where TypeInfo.SQL_DATA_TYPE eq poSqlType:Value:
            oRow = new JsonObject().
            oTypeInfo:add(oRow).
            do iLoop = 1 to iMax:
                hField = buffer TypeInfo:buffer-field(iLoop).
                /* A shortcut here, since the TypeInfo tt only has 2 types: int*/
                case hField:data-type:
                    when 'INTEGER' then oRow:Add(hField:name, integer(hField:buffer-value)).
                    otherwise           oRow:Add(hField:name, string(hField:buffer-value)).
                end case.
            end.    /* field loop */
        end. 
        
        return oTypeInfo.	    
    end method.
    
    method public JsonArray GetTypeInfo ():
        define variable oTypeInfo as JsonArray no-undo.
        
        oTypeInfo = new JsonArray().
        oTypeInfo:Read(temp-table TypeInfo:handle).
        
        return oTypeInfo.
    end method.

end class.
