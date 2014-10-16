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
    File        : ODBCCallError
    Purpose     : Purposed type for raising errors resulting from a call to ODBC. 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Tue Aug 06 11:30:59 EDT 2013
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.Assert.
using OpenEdge.Data.ODBC.SqlReturnCodeEnum.
using Progress.Json.ObjectModel.JsonArray.
using Progress.Lang.AppError.

class OpenEdge.Data.ODBC.ODBCCallError inherits AppError:
    define public property ReturnCode as SqlReturnCodeEnum no-undo get. private set.
    define public property ExternalProcedure as character no-undo get. private set.
    define public property DiagnosticRecord as JsonArray no-undo get. set.
    
	constructor public ODBCCallError (input poReturnCode as SqlReturnCodeEnum,
	                                  input pcExternalProcedure as character,
	                                  input poDiagnosticRecord as JsonArray):
        this-object(poReturnCode, pcExternalProcedure).
        
        assign DiagnosticRecord = poDiagnosticRecord.	                                        
	end constructor.
	
    constructor public ODBCCallError (input poReturnCode as SqlReturnCodeEnum,
                                      input pcExternalProcedure as character):
        Assert:NotNull(poReturnCode, 'Return Code').
        Assert:NotNullOrEmpty(pcExternalProcedure, 'External Procedure').
        
        assign ReturnCode = poReturnCode
               ExternalProcedure = pcExternalProcedure.                                            
    end constructor.
    
end class.
