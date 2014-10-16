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
    File        : SqlDateTimeEnum
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Fri Jul 26 12:02:00 EDT 2013
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.EnumMember.
using OpenEdge.Data.ODBC.SqlDateTimeEnum.

class OpenEdge.Data.ODBC.SqlDateTimeEnum inherits EnumMember:
    define private static variable miIntervalOffset as integer no-undo init 100.
    
    
    {Consultingwerk/EnumMember.i SQL_CODE_YEAR               1 SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_CODE_MONTH              2 SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_CODE_DAY                3 SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_CODE_HOUR               4 SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_CODE_MINUTE             5 SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_CODE_SECOND             6 SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_CODE_YEAR_TO_MONTH      7 SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_CODE_DAY_TO_HOUR        8 SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_CODE_DAY_TO_MINUTE      9 SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_CODE_DAY_TO_SECOND      10 SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_CODE_HOUR_TO_MINUTE     11 SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_CODE_HOUR_TO_SECOND     12 SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_CODE_MINUTE_TO_SECOND   13 SqlDateTimeEnum}.
    
    {Consultingwerk/EnumMember.i SQL_INTERVAL_YEAR             "(SqlDateTimeEnum:miIntervalOffset + SqlDateTimeEnum:SQL_CODE_YEAR:Value)"               SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_INTERVAL_MONTH            "(SqlDateTimeEnum:miIntervalOffset + SqlDateTimeEnum:SQL_CODE_MONTH:Value)"              SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_INTERVAL_DAY              "(SqlDateTimeEnum:miIntervalOffset + SqlDateTimeEnum:SQL_CODE_DAY:Value)"                SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_INTERVAL_HOUR             "(SqlDateTimeEnum:miIntervalOffset + SqlDateTimeEnum:SQL_CODE_HOUR:Value)"               SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_INTERVAL_MINUTE           "(SqlDateTimeEnum:miIntervalOffset + SqlDateTimeEnum:SQL_CODE_MINUTE:Value)"             SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_INTERVAL_SECOND           "(SqlDateTimeEnum:miIntervalOffset + SqlDateTimeEnum:SQL_CODE_SECOND:Value)"             SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_INTERVAL_YEAR_TO_MONTH    "(SqlDateTimeEnum:miIntervalOffset + SqlDateTimeEnum:SQL_CODE_YEAR_TO_MONTH:Value)"      SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_INTERVAL_DAY_TO_HOUR      "(SqlDateTimeEnum:miIntervalOffset + SqlDateTimeEnum:SQL_CODE_DAY_TO_HOUR:Value)"        SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_INTERVAL_DAY_TO_MINUTE    "(SqlDateTimeEnum:miIntervalOffset + SqlDateTimeEnum:SQL_CODE_DAY_TO_MINUTE:Value)"      SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_INTERVAL_DAY_TO_SECOND    "(SqlDateTimeEnum:miIntervalOffset + SqlDateTimeEnum:SQL_CODE_DAY_TO_SECOND:Value)"      SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_INTERVAL_HOUR_TO_MINUTE   "(SqlDateTimeEnum:miIntervalOffset + SqlDateTimeEnum:SQL_CODE_HOUR_TO_MINUTE:Value)"     SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_INTERVAL_HOUR_TO_SECOND   "(SqlDateTimeEnum:miIntervalOffset + SqlDateTimeEnum:SQL_CODE_HOUR_TO_SECOND:Value)"     SqlDateTimeEnum}.
    {Consultingwerk/EnumMember.i SQL_INTERVAL_MINUTE_TO_SECOND "(SqlDateTimeEnum:miIntervalOffset + SqlDateTimeEnum:SQL_CODE_MINUTE_TO_SECOND:Value)"   SqlDateTimeEnum}.

	constructor protected SqlDateTimeEnum ( input piValue as integer, input pcName as character ):
		super (input piValue, input pcName).
	end constructor.

end class.
