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
    File        : SqlStatement
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Wed Jul 10 13:29:33 EDT 2013
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.Assert.
using OpenEdge.Core.ServerConnection.ODBCConnection.
using OpenEdge.Core.WidgetHandle.
using OpenEdge.Data.ODBC.SqlStatement.
using OpenEdge.Data.ODBC.CTypeEnum.
using OpenEdge.Data.ODBC.FieldReadEventArgs.
using OpenEdge.Data.ODBC.ODBCCallError.
using OpenEdge.Data.ODBC.RowReadEventArgs.
using OpenEdge.Data.ODBC.SqlCommonFunctions.
using OpenEdge.Data.ODBC.SqlHandleTypeEnum.
using OpenEdge.Data.ODBC.SqlReturnCodeEnum.
using OpenEdge.Data.ODBC.SqlTypeEnum.
using OpenEdge.Data.ODBC.TypeMap.
using Progress.Json.ObjectModel.JsonArray.
using Progress.Json.ObjectModel.JsonConstruct.
using Progress.Json.ObjectModel.JsonObject.
using Progress.Lang.AppError.
using Progress.Lang.Error.
using Progress.Lang.Object.
using OpenEdge.Core.EnumMember.
using OpenEdge.Core.DataTypeEnum.


class OpenEdge.Data.ODBC.SqlStatement abstract:
    /* various constant values */
    {OpenEdge/Data/ODBC/SqlStatementConstants.i &ACCESS-LEVEL=protected}.
    
    /* DLL forward declarations */
    {OpenEdge/Data/ODBC/SqlStatementProto.i}
    
    define static private temp-table ttStmtCol no-undo
        field StatementId    as character       /* unique ID for this schema; not necessarily statement handle but could also be a fixed value */
        field ColumnNum      as integer
        field ColumnName     as character
        field CType          as Object          /* OpenEdge.Data.ODBC.CTypeEnum */
        field CTypeSize      as int64
        field AblType        as character
        field NumDecimals    as integer   initial 0
        field IsNullable     as logical   initial ?
        field ColMaxWidth    as integer   initial ?
        index idx1 as primary StatementId ColumnNum
        index idx2            StatementId ColumnName
        .
    define protected event RowRead signature void (input poSender as Object,
                                                   input poArgs as RowReadEventArgs).
    define protected event RowReadComplete signature void (input poSender as Object,
                                                           input poArgs as RowReadEventArgs).
    define protected event FieldRead signature void (input poSender as Object,
                                                     input poArgs as FieldReadEventArgs).
         
    define protected property SqlCommonLib as SqlCommonFunctions no-undo get. set.
    
    /** An unique identifier of a particular statement. Typically a hash of the statement or some other named identifier,
        but not the statement handle, which is transient.  */
    define protected property StatementId as character no-undo initial ?
        get():
            if this-object:StatementId eq ? then
                this-object:StatementId = string(this-object:StatementHandle).
            
            return this-object:StatementId.
        end get.
        set.
    
    define public property StatementHandle as int64 no-undo get. private set.
    define public property ODBCConnection as ODBCConnection no-undo get. private set.
    
    constructor public SqlStatement(input piStmt as int64, input poConnection as ODBCConnection):
        Assert:IsPositive(piStmt, 'Statement handle').
        Assert:NotNull(poConnection, 'ODBC Connection').
        
        assign StatementHandle = piStmt
               ODBCConnection = poConnection
               SqlCommonLib    = new SqlCommonFunctions().
    end method.
    
    method public void Initialize():
        
    end method.
    
    method public void Destroy():
        ClearColumnSchema().
    end method.
    
    destructor SqlStatement():
        Destroy().
        
        /* remove from the cache and free handle */
        this-object:ODBCConnection:ClearStatementCache(this-object:StatementHandle).
    end destructor.
    
    method protected void MapColumns():
        define variable cColName    as character no-undo.
        define variable mColCnt     as memptr    no-undo.
        define variable mColName    as memptr    no-undo.
        define variable mNameLength as memptr    no-undo.
        define variable mDataType   as memptr    no-undo.
        define variable mColSize    as memptr    no-undo.
        define variable mDecDigits  as memptr    no-undo.
        define variable mIsNullable as memptr    no-undo.
        define variable iReturnCode as integer   no-undo.
        define variable iNumCols    as integer   no-undo.
        define variable iIsNullable as integer   no-undo.
        define variable iLoop       as integer   no-undo.
        define variable cValue      as character no-undo.
        define variable iValue      as int64     no-undo.
        define variable dValue      as decimal   no-undo.
        define variable rStmtCol as rowid no-undo.
        define variable oCType as CTypeEnum no-undo.
                
        empty temp-table ttStmtCol.
        
        set-size(mColCnt) = 2.
        
        run SQLNumResultCols (input        this-object:StatementHandle,
                              input-output mColCnt,
                                    output iReturnCode).
        SqlCommonLib:ProcessReturnCode(iReturnCode, 'SQLNumResultCols').
        iNumCols = get-short(mColCnt, 1).
        
        if iNumCols gt 0 then
        do:
            set-size(mNameLength) = 8.
            set-size(mDataType) = 4.
            set-size(mColSize) = 8.
            set-size(mDecDigits) = 8.
            set-size(mIsNullable) = 8.
            set-size(mColName) = (SQL_MAX_COLUMN_NAME_LEN + 1).
            
            do iLoop = 1 to iNumCols:
                run SQLDescribeCol (input        this-object:StatementHandle,
                                    input        iLoop,
                                    input-output mColName,
                                    input        get-size(mColName),
                                    input-output mNameLength,
                                    input-output mDataType,     /* SQL_DESC_CONCISE_TYPE */
                                    input-output mColSize, 
                                    input-output mDecDigits,
                                    input-output mIsNullable,
                                          output iReturnCode).
                SqlCommonLib:ProcessReturnCode(iReturnCode, substitute('SQLDescribeCol: &1', iLoop)).
                
                /* mDataType is SQL Data Type http://msdn.microsoft.com/en-us/library/windows/desktop/ms710150%28v=vs.85%29.aspx */
                assign cColName = get-string(mColName, 1)
                       /* this is sql type. convert to c type */
                       iValue   = get-short(mDataType, 1)
                       oCType   = TypeMap:DefaultCType(iValue)
                       rStmtCol = AddColumnSchema(iLoop, cColName, oCType).
                
                find ttStmtCol where rowid(ttStmtCol) eq rStmtCol.
                assign iValue                = get-long(mDecDigits, 1)
                       ttStmtCol.NumDecimals = iValue
                       iValue                = get-long(mColSize, 1)
                       ttStmtCol.ColMaxWidth = iValue.
                
                case get-long(mIsNullable, 1):
                    when SQL_NO_NULLS then ttStmtCol.IsNullable = false.
                    when SQL_NULLABLE then ttStmtCol.IsNullable = true.
                    when SQL_NULLABLE_UNKNOWN then ttStmtCol.IsNullable = ?.
                end case.
            end.    /* col loop */
        end.
        
        finally:
            set-size(mColCnt) = 0.
            set-size(mColName) = 0.
            set-size(mNameLength) = 0.
            set-size(mDataType) = 0.
            set-size(mColSize) = 0.
            set-size(mDecDigits) = 0.
            set-size(mIsNullable) = 0.
        end finally.
    end method.
    
    method static protected void ClearColumnSchema(input pcStatementId as character):
        for each ttStmtCol where ttStmtCol.StatementId eq pcStatementId:
            delete ttStmtCol.
        end.
    end method.
    
    method static public void EmptyColumnSchemaCache():
        for each ttStmtCol:
            delete ttStmtCol.
        end.
    end method.
    
    method protected void ClearColumnSchema():
        /* Only clear the cache if the handle has been used as an identifier.
           Since handles are opaque and we don't know whether the handle will be reused,
           or if it is, for which query, clean up. */
        if this-object:StatementId eq string(this-object:StatementHandle) then
            SqlStatement:ClearColumnSchema(this-object:StatementId).
    end method.
    
    method static protected rowid AddColumnSchema (input pcStatementId as character,
                                                   input piColNum as integer,
                                                   input pcName as character,
                                                   input poCType as CTypeEnum):
        find ttStmtCol where 
             ttStmtCol.StatementId = pcStatementId and
             ttStmtCol.ColumnNum   = piColNum
             no-error.
        if not available ttStmtCol then
        do:         
            create ttStmtCol.
            assign ttStmtCol.StatementId = pcStatementId
                   ttStmtCol.ColumnNum   = piColNum
                   ttStmtCol.ColumnName  = pcName
                   ttStmtCol.CType       = poCType
                   ttStmtCol.CTypeSize   = TypeMap:CTypeSize(poCType)
                   ttStmtCol.ABLType     = TypeMap:CToAbl(poCType)
                   .
        end.
        return rowid(ttStmtCol).
    end method.
    
    method static public JsonArray GetColumnSchema(input pcStatementId as character):
        define variable oColumns as JsonArray no-undo.
        define variable oColumn as JsonObject no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable hField as handle no-undo.
         
        define query qryStmtCol for ttStmtCol.
        
        open query qryStmtCol 
            preselect each ttStmtCol where
                           ttStmtCol.StatementId eq pcStatementId
                           by ttStmtCol.ColumnNum.
        
        assign oColumns = new JsonArray(query qryStmtCol:num-results)
               iMax = buffer ttStmtCol:num-fields. 
               
        query qryStmtCol:get-first().
        do while not query qryStmtCol:query-off-end:
            oColumn = new JsonObject().
            oColumns:Set(query qryStmtCol:current-result-row, oColumn).
            do iLoop = 1 to iMax:                
                hField = buffer ttStmtCol:buffer-field(iLoop).
                
                if hField:name eq 'StatementId' then
                    next.
                
                /* Deal with Objects */
                if hField:data-type eq 'Progress.Lang.Object' then
                do:
                    /* if an enum, then add the value */
                    if type-of(hField:buffer-value, EnumMember) then
                        oColumn:Add(hField:name, cast(hField:buffer-value, EnumMember):Value).
                    /* add weak reference */
                    else
                        oColumn:Add(hField:name, integer(hField:buffer-value)).
                end.
                else
                    oColumn:Add(hField:name, hField:buffer-value).
            end.
            query qryStmtCol:get-next(). 
        end.
        
        return oColumns.
    end method.
    
    method protected JsonArray GetColumnSchema():
        return SqlStatement:GetColumnSchema(this-object:StatementId).
    end method.

    method protected rowid AddColumnSchema (input piColNum as integer,
                                            input pcName as character,
                                            input poCType as CTypeEnum):
        return SqlStatement:AddColumnSchema(
                    this-object:StatementId,
                    piColNum,
                    pcName,
                    poCType).                                                
    end method.
    
    method protected void RowReadJsonEventHandler(input poSender as Object,
                                                  input poEventArgs as RowReadEventArgs):
        define variable oParent as JsonArray no-undo.
        define variable oRecord as JsonObject no-undo.
        
        oParent = cast(poEventArgs:TargetReference, JsonArray).
        oRecord = new JsonObject().
        
        oParent:add(oRecord).
        poEventArgs:RowReference = oRecord.
    end method.

    method protected void RowReadTableEventHandler(input poSender as Object,
                                                   input poEventArgs as RowReadEventArgs):
        define variable oParent as WidgetHandle no-undo.
        
        oParent = cast(poEventArgs:TargetReference, WidgetHandle).
        oParent:Value:buffer-create().
        poEventArgs:RowReference = oParent.
    end method.

    method protected void RowReadCompleteTableEventHandler(input poSender as Object,
                                                           input poEventArgs as RowReadEventArgs):
        define variable oParent as WidgetHandle no-undo.
        
        oParent = cast(poEventArgs:TargetReference, WidgetHandle).
        oParent:Value:buffer-release().
    end method.
    
    method protected void RowReadCompleteJsonEventHandler(input poSender as Object,
                                                          input poEventArgs as RowReadEventArgs):
        /* no default behaviour */                                                              
    end method.
    
    method protected void FieldReadJsonEventHandler(input poSender as Object,
                                                    input poEventArgs as FieldReadEventArgs):
        define variable oParent as JsonObject no-undo.
        define variable mColumnData as memptr no-undo.
        define variable oSqlType as SqlTypeEnum no-undo.
        define variable cAblType as character no-undo.
        
        oParent = cast(poEventArgs:ParentReference, JsonObject).
        
        if poEventArgs:IsNullValue then
            oParent:AddNull(poEventArgs:FieldReference).
        else
        do:
            set-pointer-value(mColumnData) = poEventArgs:ValuePointer.
            
            assign oSqlType = TypeMap:CToSql(poEventArgs:CType)
                   cAblType = TypeMap:CToAbl(poEventArgs:CType).
                    
            case cAblType:
                when 'CHARACTER' then
                    oParent:Add(ttStmtCol.ColumnName, ColumnDataToCharacter(mColumnData, oSqlType)).
                when 'CLOB' then
                    oParent:Add(ttStmtCol.ColumnName, ColumnDataToClob(mColumnData, oSqlType)).
                when 'INTEGER' then
                    oParent:Add(ttStmtCol.ColumnName, ColumnDataToInt(mColumnData, oSqlType)). 
                when 'INT64' then
                    oParent:Add(ttStmtCol.ColumnName, ColumnDataToInt64(mColumnData, oSqlType)).
                when 'BLOB' then
                    oParent:Add(ttStmtCol.ColumnName, mColumnData).
                when 'DATETIME' then
                    oParent:Add(ttStmtCol.ColumnName, ColumnDataToDateTime(mColumnData, oSqlType)).
                when 'DATE' then
                    oParent:Add(ttStmtCol.ColumnName, ColumnDataToDate(mColumnData, oSqlType)).
                when 'LOGICAL' then
                    oParent:Add(ttStmtCol.ColumnName, ColumnDataToLogical(mColumnData, oSqlType)).
                when 'DECIMAL' then
                    oParent:Add(ttStmtCol.ColumnName, ColumnDataToDecimal(mColumnData, oSqlType)).
            end case.
        end.
    end method.

    method protected void FieldReadTableEventHandler(input poSender as Object,
                                                     input poEventArgs as FieldReadEventArgs):
        define variable oParent as WidgetHandle no-undo.
        define variable hBuffer as handle no-undo.
        define variable hField as handle no-undo.
        define variable mColumnData as memptr no-undo.
        define variable cAblType as character no-undo.
        define variable oSqlType as SqlTypeEnum no-undo.
        
        oParent = cast(poEventArgs:ParentReference, WidgetHandle).
        Assert:NotNull(oParent:Value, 'Buffer handle').
        
        hField = oParent:Value:buffer-field(poEventArgs:FieldReference) no-error.
        Assert:NotNull(hField, substitute('Field &1 in buffer &2', poEventArgs:FieldReference, oParent:Value:name)).

        if poEventArgs:IsNullValue then
            hField:buffer-value = ?.
        else 
        do:
            set-pointer-value(mColumnData) = poEventArgs:ValuePointer.
            
            assign cAblType = TypeMap:CToAbl(poEventArgs:CType)
                   oSqlType = TypeMap:CToSql(poEventArgs:CType).
                   
            if hField:data-type ne cAblType then
                undo, throw new AppError(
                        substitute('Buffer field data type is &1; data returned has type &2', hField:data-type, cAblType),
                        0).
            case cAblType:
                when 'CHARACTER' then
                    hField:buffer-value = ColumnDataToCharacter(mColumnData, oSqlType).
                when 'CLOB' then
                    hField:buffer-value = ColumnDataToClob(mColumnData, oSqlType).
                when 'INTEGER' then
                    hField:buffer-value = ColumnDataToInt(mColumnData, oSqlType).
                when 'INT64' then
                    hField:buffer-value = ColumnDataToInt64(mColumnData, oSqlType).
                when 'BLOB' then
                    copy-lob mColumnData to hField:buffer-value. 
                when 'DATETIME' then
                    hField:buffer-value = ColumnDataToDateTime(mColumnData, oSqlType).
                when 'DATE' then
                    hField:buffer-value = ColumnDataToDate(mColumnData, oSqlType).
                when 'LOGICAL' then
                    hField:buffer-value = ColumnDataToLogical(mColumnData, oSqlType).
                when 'DECIMAL' then
                    hField:buffer-value = ColumnDataToDecimal(mColumnData, oSqlType).
            end case.
        end.
    end method.

    /** A default (helper) method for populating a table with a result set
        
        @param Object The buffer handle into which the result set is stored */    
    method protected void LoadResultSet(input poTargetReference as JsonConstruct):
        RowRead:Subscribe(this-object:RowReadJsonEventHandler()).
        RowReadComplete:Subscribe(this-object:RowReadCompleteJsonEventHandler()).
        FieldRead:Subscribe(this-object:FieldReadJsonEventHandler()).
        
        BuildResultSet('JSON', poTargetReference).
        
        FieldRead:Unsubscribe(this-object:FieldReadJsonEventHandler()).
        RowRead:Unsubscribe(this-object:RowReadJsonEventHandler()).
        RowReadComplete:Unsubscribe(this-object:RowReadCompleteJsonEventHandler()).
    end method.
    
    /** A default (helper) method for populating a table with a result set
        
        @param handle The buffer handle into which the result set is stored */
    method protected void LoadResultSet(input phTargetReference as handle):
        Assert:IsType(phTargetReference, DataTypeEnum:Handle, 'Target Reference').
        
        RowRead:Subscribe(this-object:RowReadTableEventHandler()). 
        RowReadComplete:Subscribe(this-object:RowReadCompleteTableEventHandler()).
        FieldRead:Subscribe(this-object:FieldReadTableEventHandler()).
        
        BuildResultSet('TABLE', new WidgetHandle(phTargetReference)).
        
        FieldRead:Unsubscribe(this-object:FieldReadTableEventHandler()).
        RowRead:Unsubscribe(this-object:RowReadTableEventHandler()).
        RowReadComplete:Unsubscribe(this-object:RowReadCompleteTableEventHandler()).
    end method.
    
    /** Builds a result set and adds it to the specified target
        
        @param character The target type - JSON or TABLE
        @param integer A reference to the targer - an object reference or widget handle */
    method private void BuildResultSet(input pcTargetType as character,
                                       input poTargetReference as Object):
        define variable oRowReadArgs as RowReadEventArgs no-undo.
        define variable mColumnData as memptr no-undo.  /* complete data for the column, chunks combined */
        define variable mDataChunk as memptr no-undo.   /* a single chunk of data from the API call */
        define variable mStrLenOrInd as memptr no-undo.
        define variable iReturnCode as integer no-undo.
        define variable iStrLenOrInd as integer no-undo.
        define variable lHasNext as logical no-undo.
        define variable cParentRefrence as character no-undo.
        define variable eAppError as AppError no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable iDataLength as integer no-undo.
        define variable oDiagnosticRecord as JsonArray no-undo.
        define variable lDataChunked as logical no-undo.
        define variable iPutPos as integer no-undo.
        define variable oReturnCode as SqlReturnCodeEnum no-undo.
        
        run SQLFetch(input this-object:StatementHandle, output iReturnCode).
        lHasNext = (iReturnCode eq SqlReturnCodeEnum:SQL_SUCCESS:Value).
        do while lHasNext:
            oRowReadArgs = new RowReadEventArgs(pcTargetType, poTargetReference).
            RowRead:Publish(this-object, oRowReadArgs).
            
            /* process current record */
            for each ttStmtCol where
                     ttStmtCol.StatementId eq this-object:StatementId 
                     by ttStmtCol.ColumnNum:
                set-size(mStrLenOrInd) = 8.
                
                /* The data may be returned chunked. */
                assign lDataChunked = false.
                
                GET-DATA-LOOP:
                do while true on error undo, throw:
                    /* temp-data will be at most as large as the c-size */
                    set-size(mDataChunk) = ttStmtCol.CTypeSize.
                    
                    run SQLGetData (input        this-object:StatementHandle,
                                    input        ttStmtCol.ColumnNum,
                                    input        cast(ttStmtCol.CType, CTypeEnum):Value, 
                                    input-output mDataChunk,
                                    input        ttStmtCol.CTypeSize,
                                    input-output mStrLenOrInd,
                                          output iReturnCode).
                    assign oReturnCode       = SqlReturnCodeEnum:ValueToEnum(iReturnCode)
                           oDiagnosticRecord = SqlCommonLib:ProcessReturnCode(
                                                    oReturnCode,
                                                    substitute('SQLGetData: &1', ttStmtCol.ColumnName),
                                                    SqlHandleTypeEnum:SQL_HANDLE_STMT,
                                                    this-object:StatementHandle)
                           iStrLenOrInd = get-long(mStrLenOrInd, 1).
                    
                    /* Logic for processing the mStrLenOrInd pointer value is based on the 'Retrieving Data with SQLGetData' 
                       section at http://msdn.microsoft.com/en-us/library/windows/desktop/ms715441%28v=vs.85%29.aspx. */
                    case oReturnCode:
                        when SqlReturnCodeEnum:SQL_NO_DATA then
                        do:
                            assign iPutPos = 0
                                   lDataChunked = false.
                            /* no-op since the null terminator is already there */                            
                            leave GET-DATA-LOOP.
                        end.
                        when SqlReturnCodeEnum:SQL_SUCCESS_WITH_INFO or
                        when SqlReturnCodeEnum:SQL_SUCCESS then
                        do:
                            /* The 01004 code is the notification that there is chunked data */
                            if valid-object(oDiagnosticRecord) and
                               not lDataChunked and 
                               oDiagnosticRecord:GetJsonObject(1):GetCharacter('SQLState') eq '01004' then
                            do:
                                /* Driver cannot determine size, so guesstimate using max type size.
                                   Based on example at http://msdn.microsoft.com/en-us/library/windows/desktop/ms712426%28v=vs.85%29.aspx */
                                if iStrLenOrInd eq SQL_NO_TOTAL then
                                    set-size(mColumnData) = integer(exp(2, TypeMap:MaxCTypeSize(cast(ttStmtCol.CType, CTypeEnum)))) + 1.
                                else
                                    /* The iStrLenOrInd parameter contains the total number of characters to be returned, regardless 
                                       of the number of chunks.
                                       
                                       We use that plus a null terminator. */
                                    set-size(mColumnData) = iStrLenOrInd + 1.
                                
                                /* Start at the beginning ... */
                                assign iPutPos = 1
                                       lDataChunked = true.
                            end.    /* data chunk check */
                            
                            /* This tells us about the data contents */
                            case iStrLenOrInd:
                                when SQL_NULL_DATA then
                                do:
                                    assign mColumnData = mDataChunk.
                                    leave GET-DATA-LOOP.
                                end.
                                otherwise
                                do:
                                    /* Driver signals that there's more data via the 01004 code */
                                    if lDataChunked then
                                    do:
                                        if iStrLenOrInd eq SQL_NO_TOTAL then
                                        do:
                                            /* Thumb-suck guess that the chunk will typically be quite full; thus the null
                                               terminator is near the end of the data, so loop backwards */
                                            iMax = get-size(mDataChunk).
                                            do iDataLength = iMax to 1 by -1:
                                                /* find first non-null character*/
                                                if get-byte(mDataChunk, iDataLength) ne 0 then
                                                    leave.
                                            end.
                                        end.
                                        else
                                            /* iStrLenOrInd tells us how many bytes are left to be returned from the driver. 
                                               Take the smaller of that and the actual data returned. */
                                            assign iDataLength = min(iStrLenOrInd, get-size(mDataChunk) - 1).   
                                        
                                        /* If the data chunks are larger that then column data structure, then blow up. */
                                        if (iPutPos + iDataLength) gt get-size(mColumnData) then
                                            undo, throw new AppError(
                                                substitute('Data returned is larger (&1 bytes) than the defined type (&2 bytes)', 
                                                        (iPutPos + iDataLength),
                                                        get-size(mColumnData)),
                                                0).
                                        
                                        /* Append the chunk to the existing data */
                                        put-bytes(mColumnData, iPutPos) =
                                                /* Only return the actual non-null bytes in the case that fewer bytes are returned
                                                   than the chink is capable of holding. */
                                                get-bytes(mDataChunk, 1, min(iDataLength, get-size(mDataChunk) - 1)).
                                        
                                        /* Move the PutPos cursor to the next position. */
                                        iPutPos = iPutPos + iDataLength.
                                                                                
                                        /* and if we are here, we know that there's at least another call to be made,
                                           so don't leave the loop */ 
                                    end.    /* chunking */
                                    else
                                    do:
                                        /* assignment sets mColumnData size too */
                                        assign mColumnData = mDataChunk.
                                        leave GET-DATA-LOOP.
                                    end.    /* simple */
                                end.    /* not null data */
                            end case.   /* StrLenOrInd value */
                        end.    /* SQL_SUCCESS_WITH_INFO and  SQL_SUCCESS */
                    end case.   /* returncode */
                    
                    catch eError as Error:
                        if type-of(eError, ODBCCallError) then
                            eAppError = cast(eError, ODBCCallError).
                        else
                        if valid-object(oReturnCode) then 
                            eAppError = new ODBCCallError(oReturnCode, 'SQLGetData', oDiagnosticRecord).
                        else
                            eAppError = new AppError('SQLGetData', 0). 

                        eAppError:AddMessage(substitute('Column Num: &1', ttStmtCol.ColumnNum), 0).
                        eAppError:AddMessage(substitute('Column Name: &1', ttStmtCol.ColumnName), 0).
                        eAppError:AddMessage(substitute('C Type: &1', ttStmtCol.CType:ToString()), 0).
                        eAppError:AddMessage(substitute('ABL Type: &1', ttStmtCol.AblType), 0).
                        eAppError:AddMessage(substitute('SQL Type: &1', TypeMap:CToSql(cast(ttStmtCol.CType, CTypeEnum)):ToString()), 0).
                        
                        if not eAppError:Equals(eError) then
                        do:
                            if type-of(eError, AppError) then
                                eAppError:AddMessage(cast(eError, AppError):ReturnValue, 0).
                            
                            do iLoop = 1 to eError:NumMessages:
                                eAppError:AddMessage(eError:GetMessage(iLoop), eError:GetMessageNum(iLoop)).
                            end.
                        end.
                        
                        undo, throw eAppError.                     
                    end catch.                    
                    finally:
                        set-size(mDataChunk) = 0.
                    end finally.
                end. /* end GET-DATA-LOOP: */
                
                FieldRead:Publish(this-object,
                    new FieldReadEventArgs(
                            pcTargetType,
                            poTargetReference,
                            oRowReadArgs:RowReference,          /* parent reference */
                            ttStmtCol.ColumnName,
                            cast(ttStmtCol.CType, CTypeEnum),
                            (iStrLenOrInd eq SQL_NULL_DATA ),   /* IsNull? */
                            get-pointer-value(mColumnData))).
                
                finally:
                    set-size(mColumnData) = 0.
                    set-size(mStrLenOrInd) = 0.
                end finally.
            end.
            
            RowReadComplete:Publish(this-object, oRowReadArgs).
            
            /* get next record */
            run SQLFetch(input this-object:StatementHandle, output iReturnCode).
            lHasNext = (iReturnCode eq SqlReturnCodeEnum:SQL_SUCCESS:Value).
        end.
    end method.
    
    method protected void CloseCursor():
        define variable iReturnCode as integer no-undo.
        
        run SQLCloseCursor (input  this-object:StatementHandle,
                            output iReturnCode).                
        SqlCommonLib:ProcessReturnCode(iReturnCode, 'SQLCloseCursor').
    end method.
    
    /** Returns a datetime represented by a SQL_TYPE_TIMESTAMP structure.
        
        @param  memptr   A data structure containing the a SQL_TYPE_TIMESTAMP structure
        @param  SqlTypeEnum The SQL type of the data.
        @return datetime    The ABL date represented by the input structure. */    
    method protected datetime ColumnDataToDateTime(input pmColumnValue as memptr,
                                             input poSqlType as SqlTypeEnum):
        define variable iYear as integer no-undo.
        define variable iMonth as integer no-undo.
        define variable iDay as integer no-undo.
        define variable iHour as integer no-undo.
        define variable iMinute as integer no-undo.
        define variable iSecond as integer no-undo.
        define variable iFraction as integer no-undo.
        
        /* The SQL_TYPE_TIMESTAMP has the following structure as defined at 
            http://msdn.microsoft.com/en-us/library/windows/desktop/ms714556%28v=vs.85%29.aspx
            typedef struct tagTIMESTAMP_STRUCT {
                SQLSMALLINT year;
                SQLUSMALLINT month;
                SQLUSMALLINT day;
                SQLUSMALLINT hour;
                SQLUSMALLINT minute;
                SQLUSMALLINT second;
                SQLUINTEGER fraction;
            } TIMESTAMP_STRUCT;
            
            SQLSMALLINT  = short  = 2 bytes
            SQLUSMALLINT = ushort = 2 bytes
            SQLUINTEGER  = ulong  = 4 bytes
        */
        assign iYear     = get-short(pmColumnValue,  1)
               iMonth    = get-short(pmColumnValue,  3)
               iDay      = get-short(pmColumnValue,  5)
               iHour     = get-short(pmColumnValue,  7)
               iMinute   = get-short(pmColumnValue,  9)
               iSecond   = get-short(pmColumnValue, 11)
               iFraction = get-long(pmColumnValue,  13).
        
        return datetime(iMonth, iDay, iYear, iHour, iMinute, iSecond, iFraction).
        /* NOTE: do not clean up the pmColumnValue memptr here, because it has been passed by reference.
           Let the caller (actually BuildResultSet) deal with cleanup. */
    end method.

    /** Returns a date represented by a SQL_TYPE_DATE structure.
        
        @param  memptr   A data structure containing the a SQL_TYPE_DATE structure
        @param  SqlTypeEnum The SQL type of the data.
        @return date    The ABL date represented by the input structure. */
    method protected date ColumnDataToDate(input pmColumnValue as memptr,
                                     input poSqlType as SqlTypeEnum):
        define variable iYear as integer no-undo.
        define variable iMonth as integer no-undo.
        define variable iDay as integer no-undo.
        
        /* The SQL_TYPE_DATE has the following structure as defined at 
            http://msdn.microsoft.com/en-us/library/windows/desktop/ms714556%28v=vs.85%29.aspx
            typedef struct tagDATE_STRUCT {
                SQLSMALLINT year;
                SQLUSMALLINT month;
                SQLUSMALLINT day;
            } DATE_STRUCT;
            
            SQLSMALLINT  = short  = 2 bytes
            SQLUSMALLINT = ushort = 2 bytes
        */
        assign iYear  = get-short(pmColumnValue, 1)
               iMonth = get-short(pmColumnValue, 3)
               iDay   = get-short(pmColumnValue, 5).
        
        return date(iMonth, iDay, iYear).
        /* NOTE: do not clean up the pmColumnValue memptr here, because it has been passed by reference.
           Let the caller (actually BuildResultSet) deal with cleanup. */
    end method.
    
    /** Returns the seconds since midnight (since ABL has no built-in TIME data type).
        This behaviour emulates the TIME built-in function.
        
        @param memptr   A data structure containing the a SQL_TYPE_TIME structure
        @param  SqlTypeEnum The SQL type of the data.
        @return integer Number of seconds since midnight based on the input */ 
    method protected integer ColumnDataToTime(input pmColumnValue as memptr,
                                        input poSqlType as SqlTypeEnum):
        define variable iHour as integer no-undo.
        define variable iMinute as integer no-undo.
        define variable iSecond as integer no-undo.
        
        /* The SQL_TYPE_TIME has the following structure as defined at 
            http://msdn.microsoft.com/en-us/library/windows/desktop/ms714556%28v=vs.85%29.aspx
            typedef struct tagTIME_STRUCT {
                SQLUSMALLINT hour;
                SQLUSMALLINT minute;
                SQLUSMALLINT second;
            } TIME_STRUCT;
            
            SQLUSMALLINT = ushort = 2 bytes
        */
        assign iHour   = get-short(pmColumnValue, 1)
               iMinute = get-short(pmColumnValue, 3)
               iSecond = get-short(pmColumnValue, 5).
               
        return (iHour * 60 * 60) + (iMinute * 60) + iSecond.
        /* NOTE: do not clean up the pmColumnValue memptr here, because it has been passed by reference.
           Let the caller (actually BuildResultSet) deal with cleanup. */
    end method.

    /** Returns a GUID represented by a SQL_GUID structure.
        
        @param  memptr   A data structure containing the a SQL_TYPE_DATE structure
        @param  SqlTypeEnum The SQL type of the data.
        @return date    The ABL date represented by the input structure. */
    method protected character ColumnDataToGuid(input pmColumnValue as memptr,
                                           input poSqlType as SqlTypeEnum):
        /* The SQL_GUID has the following structure as defined at 
            http://msdn.microsoft.com/en-us/library/windows/desktop/ms714556%28v=vs.85%29.aspx
            struct tagSQLGUID {
               DWORD Data1;
               WORD Data2;
               WORD Data3;
               BYTE Data4[8];
            } SQLGUID
            
            DWORD   = 4 bytes
            WORD    = 2 bytes
            BYTE[8] = 8 bytes 
        */
        
        /*XXXXXXXX—XXXX—XXXX—XXXX—XXXXXXXXXXXX*/
        return substitute('&1-&2-&3-&4-&5', 
                get-string(pmColumnValue, 1, 4),
                get-string(pmColumnValue, 5, 2),
                get-string(pmColumnValue, 7, 2),
                get-string(pmColumnValue, 9, 2),
                get-string(pmColumnValue, 11, 6)).
        /* NOTE: do not clean up the pmColumnValue memptr here, because it has been passed by reference.
           Let the caller (actually BuildResultSet) deal with cleanup. */
    end method.    
    
    /** Returns a GUID represented by a SQL_NUMERIC structure.
        
        @param  memptr   A data structure containing the a SQL_TYPE_DATE structure
        @param  SqlTypeEnum The SQL type of the data.
        @return date    The ABL date represented by the input structure. */
    method protected decimal ColumnDataToNumeric(input pmColumnValue as memptr,
                                           input poSqlType as SqlTypeEnum):
        define variable dValue as decimal no-undo.
        
        /* The SQL_TYPE_DATE has the following structure as defined at 
            http://msdn.microsoft.com/en-us/library/windows/desktop/ms714556%28v=vs.85%29.aspx
            struct tagSQL_NUMERIC_STRUCT {
               SQLCHAR precision;
               SQLSCHAR scale;
               SQLCHAR sign[g];
               SQLCHAR val[SQL_MAX_NUMERIC_LEN];[e], [f] 
            } SQL_NUMERIC_STRUCT;
            
            SQLCHAR                      = bytes
            SQLCHAR[SQL_MAX_NUMERIC_LEN] = SQL_MAX_NUMERIC_LEN bytes 
        */
        undo, throw new AppError('DataToNumeric function not implemented', 0).
        
        return dValue.
        /* NOTE: do not clean up the pmColumnValue memptr here, because it has been passed by reference.
           Let the caller (actually BuildResultSet) deal with cleanup. */
    end method.

    method protected longchar ColumnDataToClob(input pmColumnData as memptr,
                                         input poSqlType as SqlTypeEnum):
        define variable lcValue as longchar no-undo.
                                                     
        lcValue = ?.
                    
        if poSqlType:Equals(SqlTypeEnum:SQL_WLONGVARCHAR) and
           session:cpinternal ne 'UTF-8' then
            fix-codepage(lcValue) = 'UTF-8'.
                    
        lcValue = get-string(pmColumnData, 1).
        
        return lcValue.
        /* NOTE: do not clean up the pmColumnValue memptr here, because it has been passed by reference.
           Let the caller (actually BuildResultSet) deal with cleanup. */
    end method.

    method protected logical ColumnDataToLogical(input pmColumnData as memptr,
                                           input poSqlType as SqlTypeEnum):
        return logical(get-string(pmColumnData, 1, 1) eq '1').
        /* NOTE: do not clean up the pmColumnValue memptr here, because it has been passed by reference.
           Let the caller (actually BuildResultSet) deal with cleanup. */
    end method.

    method protected int64 ColumnDataToInt64(input pmColumnData as memptr,
                                       input poSqlType as SqlTypeEnum):
        return get-int64(pmColumnData, 1).
        /* NOTE: do not clean up the pmColumnValue memptr here, because it has been passed by reference.
           Let the caller (actually BuildResultSet) deal with cleanup. */
    end method.

    method protected character ColumnDataToCharacter(input pmColumnData as memptr,
                                               input poSqlType as SqlTypeEnum):
        return get-string(pmColumnData, 1).
        /* NOTE: do not clean up the pmColumnValue memptr here, because it has been passed by reference.
           Let the caller (actually BuildResultSet) deal with cleanup. */
    end method.
        
    method protected decimal ColumnDataToDecimal(input pmColumnData as memptr,
                                           input poSqlType as SqlTypeEnum):
        define variable dValue as decimal no-undo.
         
        case poSqlType:
            when SqlTypeEnum:SQL_FLOAT      then dValue = get-float(pmColumnData, 1).
            when SqlTypeEnum:SQL_NUMERIC    then dValue = ColumnDataToNumeric(pmColumnData, poSqlType).
            otherwise                            dValue = get-double (pmColumnData, 1).
        end case.
        
        return dValue.
        /* NOTE: do not clean up the pmColumnValue memptr here, because it has been passed by reference.
           Let the caller (actually BuildResultSet) deal with cleanup. */
    end method.
        
    method protected integer ColumnDataToInt(input pmColumnData as memptr,
                                       input poSqlType as SqlTypeEnum):
        define variable iValue as integer no-undo.
        
        case poSqlType:
            when SqlTypeEnum:SQL_SMALLINT or
            when SqlTypeEnum:SQL_TINYINT then
                iValue = get-short(pmColumnData, 1).
            /* We have no TIME data type in ABL so convert to integer */
            when SqlTypeEnum:SQL_TYPE_TIME then
                iValue = ColumnDataToTime(pmColumnData, poSqlType).
            otherwise 
                iValue = get-long(pmColumnData, 1).
        end case.
        
        return iValue.
        /* NOTE: do not clean up the pmColumnValue memptr here, because it has been passed by reference.
           Let the caller (actually BuildResultSet) deal with cleanup. */
    end method.
    
end class.
