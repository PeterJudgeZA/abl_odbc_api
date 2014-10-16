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
    File        : SqlCommonFunctions
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Wed Jul 10 15:12:06 EDT 2013
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Data.ODBC.ODBCCallError.
using OpenEdge.Data.ODBC.SqlHandleTypeEnum.
using OpenEdge.Data.ODBC.SqlReturnCodeEnum.
using Progress.Json.ObjectModel.JsonArray.
using Progress.Json.ObjectModel.JsonObject.

class OpenEdge.Data.ODBC.SqlCommonFunctions:
    /* DLL forward declarations */
    {OpenEdge/Data/ODBC/SqlCommonFunctionsProto.i}
    
    method public int64 AllocateHandle(input poHandleType as SqlHandleTypeEnum,
                                       input piParentHandle as int64):
        define variable mHandle as memptr no-undo.
        define variable iReturnCode as integer no-undo.
        
        set-size(mHandle) = 4.
        
        run SQLAllocHandle (
                    input        poHandleType:Value,
                    input        piParentHandle,
                    input-output mHandle,
                          output iReturnCode).
        ProcessReturnCode(
            SqlReturnCodeEnum:ValueToEnum(iReturnCode), 
            substitute('SQLAllocHandle:&1', poHandleType:Name)).
        
        return get-long(mHandle, 1).
        
        finally:
            set-size(mHandle) = 0.
        end finally.
    end method.
    
    method public void FreeHandle(input poHandleType as SqlHandleTypeEnum,
                                  input piHandle as int64):
        define variable iReturnCode as integer no-undo.
        
        if not piHandle gt 0 then
            return.
        
        run SQLFreeHandle(
               input  poHandleType:Value,
               input  piHandle,
               output iReturnCode).
        ProcessReturnCode(
            SqlReturnCodeEnum:ValueToEnum(iReturnCode),
            substitute('SQLFreeHandle:&1', poHandleType:Name)).
    end method.
        
    method public void ProcessReturnCode(input poReturnCode as SqlReturnCodeEnum,
                                         input pcExternalProcedure as character):
        ProcessReturnCode(
                poReturnCode, 
                pcExternalProcedure, 
                ?, 
                ?).
    end method.

    method public void ProcessReturnCode(input piReturnCode as integer,
                                         input pcExternalProcedure as character):
        ProcessReturnCode(
                SqlReturnCodeEnum:ValueToEnum(piReturnCode), 
                pcExternalProcedure, 
                ?, 
                ?).
    end method.
    
    method public JsonArray ProcessReturnCode(input poReturnCode as SqlReturnCodeEnum,
                                              input pcExternalProcedure as character,
                                              input poHandleType as SqlHandleTypeEnum,
                                              input piHandle as int64):
        define variable oError as ODBCCallError no-undo.
        define variable oDiagnosticRecord as JsonArray no-undo.
        
        case poReturnCode:
            when SqlReturnCodeEnum:SQL_SUCCESS_WITH_INFO then
                if valid-object(poHandleType) then
                    return GetDiagnosticRecord(poHandleType, piHandle).
            
            when SqlReturnCodeEnum:SQL_ERROR then
            do:
                oError = new ODBCCallError(poReturnCode, pcExternalProcedure).
                if valid-object(poHandleType) then
                    oError:DiagnosticRecord = GetDiagnosticRecord(poHandleType, piHandle).
            end.
            when SqlReturnCodeEnum:SQL_SUCCESS then
                /* NO-OP */ .
            when SqlReturnCodeEnum:SQL_NO_DATA then
                /* NO-OP */ .
            otherwise
                oError = new ODBCCallError(poReturnCode, pcExternalProcedure).
        end case.
        
        if valid-object(oError) then
            undo, throw oError.
    end method.
    
    method public JsonArray GetDiagnosticRecord (input poHandleType as SqlHandleTypeEnum,        
                                                 input piHandle as int64):
        define variable oDiagRec as JsonArray no-undo.
        define variable oDiagFld as JsonObject no-undo.
        define variable iReturnCode as integer no-undo.
        define variable iRecordNum as integer no-undo.
        define variable mSqlState as memptr no-undo.
        define variable mNativeError as memptr no-undo.
        define variable mMessageText as memptr no-undo.
        define variable mTextLength as memptr no-undo.
        define variable oReturnCode as SqlReturnCodeEnum no-undo.
        
        set-size(mSqlState) = 6.
        set-size(mNativeError) = 4.
        set-size(mMessageText) = 512.    /* SQL_MAX_MESSAGE_LENGTH */
        set-size(mTextLength) = 2.
        
        assign oReturnCode = SqlReturnCodeEnum:SQL_SUCCESS
               iRecordNum = 1
               oDiagRec = new JsonArray().
        
        do while oReturnCode ne SqlReturnCodeEnum:SQL_NO_DATA:
            run SQLGetDiagRec(
                   input        poHandleType:Value,
                   input        piHandle,
                   input        iRecordNum,
                   input-output mSqlState,
                   input-output mNativeError,
                   input-output mMessageText,
                   input        length(mMessageText),
                   input-output mTextLength,
                         output iReturnCode).
                                     
            oDiagFld = new JsonObject().
            oDiagRec:add(oDiagFld).
            oDiagFld:add('SQLState', get-string(mSqlState, 1)).
            oDiagFld:add('MessageText', get-string(mMessageText, 1)).
            oDiagFld:add('NativeErrorCode', get-long(mNativeError, 1)).
            
            iRecordNum = iRecordNum + 1.
            oReturnCode = SqlReturnCodeEnum:ValueToEnum(iReturnCode).
        end.
        
        return oDiagRec.
        finally:
            set-size(mSqlState) = 0.
            set-size(mNativeError) = 0.
            set-size(mMessageText) = 0.
            set-size(mTextLength) = 0.
        end finally.
    end method.        
end class.
