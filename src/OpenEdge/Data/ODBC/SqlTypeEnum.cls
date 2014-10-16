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
    File        : SqlTypeEnum
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Fri Jul 26 11:42:01 EDT 2013
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.EnumMember.
using OpenEdge.Data.ODBC.SqlTypeEnum.

class OpenEdge.Data.ODBC.SqlTypeEnum inherits EnumMember: 
    {Consultingwerk/EnumMember.i SQL_ALL_TYPES        0      SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_UNKNOWN_TYPE     0      SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_CHAR             1      SqlTypeEnum}.        
    {Consultingwerk/EnumMember.i SQL_VARCHAR          12     SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_LONGVARCHAR      -1     SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_WCHAR            -8     SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_WVARCHAR         -9     SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_WLONGVARCHAR     -10    SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_DECIMAL          3      SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_NUMERIC          2      SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_SMALLINT         5      SqlTypeEnum}. 
    {Consultingwerk/EnumMember.i SQL_INTEGER          4      SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_REAL             7      SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_FLOAT            6      SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_DOUBLE           8      SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_BIT              -7     SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_TINYINT          -6     SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_BIGINT           -5     SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_BINARY           -2     SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_LONGVARBINARY    -4     SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_TYPE_DATE        91     SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_TYPE_TIME        92     SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_TYPE_TIMESTAMP   93     SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_TYPE_UTCDATETIME ?      SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_TYPE_UTCTIME     ?      SqlTypeEnum}.
    {Consultingwerk/EnumMember.i SQL_GUID             -11    SqlTypeEnum}.

	constructor protected SqlTypeEnum ( input piValue as integer, input pcName as character ):
		super (input piValue, input pcName).
	end constructor.
	
	method static public SqlTypeEnum ValueToEnum(input piValue as integer):
	    define variable oEnum as SqlTypeEnum no-undo.
	    
	    case piValue:
            when SqlTypeEnum:SQL_ALL_TYPES:Value then oEnum = SqlTypeEnum:SQL_ALL_TYPES.
            when SqlTypeEnum:SQL_CHAR:Value then oEnum = SqlTypeEnum:SQL_CHAR.       
            when SqlTypeEnum:SQL_VARCHAR:Value then oEnum = SqlTypeEnum:SQL_VARCHAR.
            when SqlTypeEnum:SQL_LONGVARCHAR:Value then oEnum = SqlTypeEnum:SQL_LONGVARCHAR.
            when SqlTypeEnum:SQL_WCHAR:Value then oEnum = SqlTypeEnum:SQL_WCHAR.
            when SqlTypeEnum:SQL_WVARCHAR:Value then oEnum = SqlTypeEnum:SQL_WVARCHAR.
            when SqlTypeEnum:SQL_WLONGVARCHAR:Value then oEnum = SqlTypeEnum:SQL_WLONGVARCHAR.
            when SqlTypeEnum:SQL_DECIMAL:Value then oEnum = SqlTypeEnum:SQL_DECIMAL.
            when SqlTypeEnum:SQL_NUMERIC:Value then oEnum = SqlTypeEnum:SQL_NUMERIC.
            when SqlTypeEnum:SQL_SMALLINT:Value then oEnum = SqlTypeEnum:SQL_SMALLINT. 
            when SqlTypeEnum:SQL_INTEGER:Value then oEnum = SqlTypeEnum:SQL_INTEGER.
            when SqlTypeEnum:SQL_REAL:Value then oEnum = SqlTypeEnum:SQL_REAL.
            when SqlTypeEnum:SQL_FLOAT:Value then oEnum = SqlTypeEnum:SQL_FLOAT.
            when SqlTypeEnum:SQL_DOUBLE:Value then oEnum = SqlTypeEnum:SQL_DOUBLE.
            when SqlTypeEnum:SQL_BIT:Value then oEnum = SqlTypeEnum:SQL_BIT.
            when SqlTypeEnum:SQL_TINYINT:Value then oEnum = SqlTypeEnum:SQL_TINYINT.
            when SqlTypeEnum:SQL_BIGINT:Value then oEnum = SqlTypeEnum:SQL_BIGINT.
            when SqlTypeEnum:SQL_BINARY:Value then oEnum = SqlTypeEnum:SQL_BINARY.
            when SqlTypeEnum:SQL_LONGVARBINARY:Value then oEnum = SqlTypeEnum:SQL_LONGVARBINARY.
            when SqlTypeEnum:SQL_TYPE_DATE:Value then oEnum = SqlTypeEnum:SQL_TYPE_DATE.
            when SqlTypeEnum:SQL_TYPE_TIME:Value then oEnum = SqlTypeEnum:SQL_TYPE_TIME.
            when SqlTypeEnum:SQL_TYPE_TIMESTAMP:Value then oEnum = SqlTypeEnum:SQL_TYPE_TIMESTAMP.
            when SqlTypeEnum:SQL_TYPE_UTCDATETIME:Value then oEnum = SqlTypeEnum:SQL_TYPE_UTCDATETIME.
            when SqlTypeEnum:SQL_TYPE_UTCTIME:Value then oEnum = SqlTypeEnum:SQL_TYPE_UTCTIME.
            when SqlTypeEnum:SQL_GUID:Value then oEnum = SqlTypeEnum:SQL_GUID.
            
            otherwise oEnum = SqlTypeEnum:SQL_UNKNOWN_TYPE.
        end case.
        
        return oEnum.
    end method.

end class.
