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
    File        : CTypeEnum
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Fri Jul 26 11:12:07 EDT 2013
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.EnumMember.
using OpenEdge.Data.ODBC.CTypeEnum.
using OpenEdge.Data.ODBC.SqlTypeEnum.

class OpenEdge.Data.ODBC.CTypeEnum inherits EnumMember:
    {Consultingwerk/EnumMember.i SQL_C_CHAR              SqlTypeEnum:SQL_CHAR:Value              CTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_C_WCHAR             SqlTypeEnum:SQL_WCHAR:Value             CTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_C_SSHORT            SqlTypeEnum:SQL_SMALLINT:Value          CTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_C_USHORT            ?               CTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_C_SLONG             SqlTypeEnum:SQL_INTEGER:Value           CTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_C_ULONG             ?               CTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_C_DOUBLE            SqlTypeEnum:SQL_DOUBLE:Value            CTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_C_BIT               SqlTypeEnum:SQL_CHAR:Value              CTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_C_STINYINT          ?               CTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_C_UTINYINT          SqlTypeEnum:SQL_CHAR:Value              CTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_C_SBIGINT           SqlTypeEnum:SQL_BIGINT:Value            CTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_C_UBIGINT           ?               CTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_C_BINARY            SqlTypeEnum:SQL_CHAR:Value              CTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_C_BOOKMARK          ?               CTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_C_VARBOOKMARK       SqlTypeEnum:SQL_CHAR:Value              CTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_C_TYPE_DATE         SqlTypeEnum:SQL_TYPE_DATE:Value         CTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_C_TYPE_TIME         SqlTypeEnum:SQL_TYPE_TIME:Value         CTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_C_TYPE_TIMESTAMP    SqlTypeEnum:SQL_TYPE_TIMESTAMP:Value    CTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_C_NUMERIC           SqlTypeEnum:SQL_NUMERIC:Value           CTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_C_GUID              SqlTypeEnum:SQL_GUID:Value              CTypeEnum}.
		
	constructor protected CTypeEnum ( input piValue as integer, input pcName as character ):
		super (input piValue, input pcName).
	end constructor.
	
	method static public CTypeEnum ValueToEnum (input piValue as integer):
	    define variable oEnum as CTypeEnum no-undo.
	    
	    case piValue:
            when CTypeEnum:SQL_C_CHAR:Value then oEnum = CTypeEnum:SQL_C_CHAR.
            when CTypeEnum:SQL_C_WCHAR:Value then oEnum = CTypeEnum:SQL_C_WCHAR.
            when CTypeEnum:SQL_C_SSHORT:Value then oEnum = CTypeEnum:SQL_C_SSHORT.
            when CTypeEnum:SQL_C_USHORT:Value then oEnum = CTypeEnum:SQL_C_USHORT.
            when CTypeEnum:SQL_C_SLONG:Value then oEnum = CTypeEnum:SQL_C_SLONG.
            when CTypeEnum:SQL_C_ULONG:Value then oEnum = CTypeEnum:SQL_C_ULONG.
            when CTypeEnum:SQL_C_DOUBLE:Value then oEnum = CTypeEnum:SQL_C_DOUBLE.
            when CTypeEnum:SQL_C_BIT:Value then oEnum = CTypeEnum:SQL_C_BIT.
            when CTypeEnum:SQL_C_STINYINT:Value then oEnum = CTypeEnum:SQL_C_STINYINT.
            when CTypeEnum:SQL_C_UTINYINT:Value then oEnum = CTypeEnum:SQL_C_UTINYINT.
            when CTypeEnum:SQL_C_SBIGINT:Value then oEnum = CTypeEnum:SQL_C_SBIGINT.
            when CTypeEnum:SQL_C_UBIGINT:Value then oEnum = CTypeEnum:SQL_C_UBIGINT.
            when CTypeEnum:SQL_C_BINARY:Value then oEnum = CTypeEnum:SQL_C_BINARY.
            when CTypeEnum:SQL_C_BOOKMARK:Value then oEnum = CTypeEnum:SQL_C_BOOKMARK.
            when CTypeEnum:SQL_C_VARBOOKMARK:Value then oEnum = CTypeEnum:SQL_C_VARBOOKMARK.
            when CTypeEnum:SQL_C_TYPE_DATE:Value then oEnum = CTypeEnum:SQL_C_TYPE_DATE.
            when CTypeEnum:SQL_C_TYPE_TIME:Value then oEnum = CTypeEnum:SQL_C_TYPE_TIME.
            when CTypeEnum:SQL_C_TYPE_TIMESTAMP:Value then oEnum = CTypeEnum:SQL_C_TYPE_TIMESTAMP.
            when CTypeEnum:SQL_C_NUMERIC:Value then oEnum = CTypeEnum:SQL_C_NUMERIC.
            when CTypeEnum:SQL_C_GUID:Value then oEnum = CTypeEnum:SQL_C_GUID.
        end case.
	    
	    return oEnum.
    end method.
    
end class.
