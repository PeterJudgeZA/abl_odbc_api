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
    File        : SqlReturnCodeEnum
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Mon Aug 05 10:52:33 EDT 2013
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.EnumMember.
using OpenEdge.Data.ODBC.SqlReturnCodeEnum.

class OpenEdge.Data.ODBC.SqlReturnCodeEnum inherits EnumMember final: 
    {Consultingwerk/EnumMember.i SQL_SUCCESS             0   SqlReturnCodeEnum}
    {Consultingwerk/EnumMember.i SQL_SUCCESS_WITH_INFO   1   SqlReturnCodeEnum}
    {Consultingwerk/EnumMember.i SQL_STILL_EXECUTING     2   SqlReturnCodeEnum}
    {Consultingwerk/EnumMember.i SQL_NO_DATA             100 SqlReturnCodeEnum}
    {Consultingwerk/EnumMember.i SQL_ERROR               -1  SqlReturnCodeEnum}
    {Consultingwerk/EnumMember.i SQL_INVALID_HANDLE      -2  SqlReturnCodeEnum}

	constructor protected SqlReturnCodeEnum ( input piValue as integer, input pcName as character ):
		super (input piValue, input pcName).
	end constructor.
	
	method static public SqlReturnCodeEnum ValueToEnum (input piValue as integer):
	    define variable oEnum as SqlReturnCodeEnum no-undo.
	    
        case piValue:
            when SqlReturnCodeEnum:SQL_SUCCESS:Value then oEnum = SqlReturnCodeEnum:SQL_SUCCESS.
            when SqlReturnCodeEnum:SQL_SUCCESS_WITH_INFO:Value then oEnum = SqlReturnCodeEnum:SQL_SUCCESS_WITH_INFO.
            when SqlReturnCodeEnum:SQL_STILL_EXECUTING:Value then oEnum = SqlReturnCodeEnum:SQL_STILL_EXECUTING.
            when SqlReturnCodeEnum:SQL_NO_DATA:Value then oEnum = SqlReturnCodeEnum:SQL_NO_DATA.
            when SqlReturnCodeEnum:SQL_ERROR:Value then oEnum = SqlReturnCodeEnum:SQL_ERROR.
            when SqlReturnCodeEnum:SQL_INVALID_HANDLE:Value then oEnum = SqlReturnCodeEnum:SQL_INVALID_HANDLE.
        end case.
        	    
	    return oEnum.
    end method.

end class.
