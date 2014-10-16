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
    File        : SqlHandleTypeEnum
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Mon Jul 15 11:28:31 EDT 2013
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.EnumMember.
using OpenEdge.Data.ODBC.SqlHandleTypeEnum.

class OpenEdge.Data.ODBC.SqlHandleTypeEnum inherits EnumMember final:
    {Consultingwerk/EnumMember.i SQL_NULL_HANDLE 0 SqlHandleTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_HANDLE_ENV  1 SqlHandleTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_HANDLE_DBC  2 SqlHandleTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_HANDLE_STMT 3 SqlHandleTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_HANDLE_DESC 4 SqlHandleTypeEnum}.
    
	constructor private SqlHandleTypeEnum ( input piValue as integer, input pcName as character ):
		super (input piValue, input pcName).
	end constructor.

end class.
