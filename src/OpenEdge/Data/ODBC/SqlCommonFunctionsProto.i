&if false &then
/* ****
Copyright 2013, 2018 Progress Software Corporation

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
    File        : OpenEdge/Data/ODBC/SqlCommonFunctionsProto.i
    Purpose     : 
    Author(s)   : pjudge
    Created     : Tue Jul 02 13:50:17 EDT 2013
    Notes       :  
  ----------------------------------------------------------------------*/
&endif
/* platform-specific DLL location */
{OpenEdge/Data/ODBC/DriverManagerLib.i}
  
&if {&PROCESS-ARCHITECTURE} = 64 &then
&scoped-define SQLHANDLE-TYPE int64
&else 
&scoped-define SQLHANDLE-TYPE long
&endif
  
/* Current ODBC 3.0 Compliant call for handles */
/* Doc at http://msdn.microsoft.com/en-us/library/windows/desktop/ms712455%28v=vs.85%29.aspx */
procedure SQLAllocHandle external "{&ODBC-DLL}" persistent.
    define input        parameter HandleType        as short.   /* SQLSMALLINT */
    define input        parameter InputHandle       as {&SQLHANDLE-TYPE}.    /* SQLHANDLE */
    define input-output parameter OutputHandlePtr   as memptr.  /* SQLHANDLE* */
    define return       parameter returnValue       as short.   /* [Return] SQLRETURN */
end procedure.

/* doc at http://msdn.microsoft.com/en-us/library/windows/desktop/ms710123%28v=vs.85%29.aspx */
procedure SQLFreeHandle  external "{&ODBC-DLL}" persistent.
    define input        parameter HandleType    as short.   /* SQLSMALLINT */
    define input        parameter Handle        as {&SQLHANDLE-TYPE}.    /* SQLHANDLE */
    define return       parameter returnValue   as short.   /* [Return] SQLRETURN */
end procedure.

/* Doc at http://msdn.microsoft.com/en-us/library/windows/desktop/ms716256%28v=vs.85%29.aspx */
procedure SQLGetDiagRec external "{&ODBC-DLL}" persistent.
    define input        parameter HandleType        as short.           /* SQLSMALLINT */
    define input        parameter Handle            as {&SQLHANDLE-TYPE}.            /* SQLHANDLE */
    define input        parameter RecNumber         as short.           /* SQLSMALLINT */
    define input-output parameter SQLState          as memptr.          /* SQLCHAR* */
    define input-output parameter NativeErrorPtr    as memptr.          /* SQLINTEGER* */
    define input-output parameter MessageText       as memptr.          /* SQLCHAR* */
    define input        parameter BufferLength      as short.           /* SQLSMALLINT */
    define input-output parameter TextLengthPtr     as memptr.          /* SQLSMALLINT */
    define return       parameter returnValue       as short.           /* [Return] SQLRETURN */
end procedure.
