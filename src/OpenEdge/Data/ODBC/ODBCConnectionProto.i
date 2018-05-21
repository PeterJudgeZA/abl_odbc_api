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
    File        : OpenEdge/Data/ODBC/ODBCConnectionProto.i
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
  
/* Current ODBC 3.0 Complint call for connection via DSN */
/* http://msdn.microsoft.com/en-us/library/windows/desktop/ms711810%28v=vs.85%29.aspx */
procedure SQLConnect external "{&ODBC-DLL}" persistent.
    define input        parameter ConnectionHandle  as {&SQLHANDLE-TYPE}.       /* SQLHDBC:SQLHANDLE  */   
    define input        parameter ServerName        as character.  /* SQLCHAR* */
    define input        parameter NameLength1       as short.      /* SQLSMALLINT */
    define input        parameter UserName          as character.  /* SQLCHAR* */
    define input        parameter NameLength2       as short.      /* SQLSMALLINT */
    define input        parameter Authentication    as character.  /* SQLCHAR* */
    define input        parameter NameLength3       as short.      /* SQLSMALLINT */
    define return       parameter returnValue       as short.      /* [Return] SQLRETURN */
end procedure.

/* DOc at http://msdn.microsoft.com/en-us/library/windows/desktop/ms713946%28v=vs.85%29.aspx */
procedure SQLDisconnect external "{&ODBC-DLL}" persistent.
    define input        parameter ConnectionHandle  as {&SQLHANDLE-TYPE}.       /* SQLHDBC:SQLHANDLE  */
    define return       parameter returnValue       as short.      /* [Return] SQLRETURN */
end procedure.

/* Doc at http://msdn.microsoft.com/en-us/library/windows/desktop/ms709285%28v=vs.85%29.aspx */
procedure SQLSetEnvAttr external "{&ODBC-DLL}" persistent.
    define input        parameter EnvironmentHandle as {&SQLHANDLE-TYPE}.    /* SQLHENV:SQLHANDLE */
    define input        parameter Attribute         as long.    /* SQLINTEGER */
    define input        parameter ValuePtr          as long.    /* SQLPOINTER */
    define input        parameter StringLength      as long.    /* SQLINTEGER */     
    define return       parameter returnValue       as short.   /* [Return] SQLRETURN */
end procedure.
     
/* Doc at http://msdn.microsoft.com/en-us/library/windows/desktop/ms713605%28v=vs.85%29.aspx */
procedure SQLSetConnectAttr external "{&ODBC-DLL}" persistent.
    define input        parameter ConnectionHandle  as {&SQLHANDLE-TYPE}.    /* SQLHDBC:SQLHANDLE  */
    define input        parameter Attribute         as long.    /* SQLINTEGER */
    define input        parameter ValuePtr          as long.    /* SQLPOINTER */
    define input        parameter StringLength      as long.    /* SQLINTEGER */     
    define return       parameter returnValue       as short.   /* [Return] SQLRETURN */
end procedure.

/* Doc at http://msdn.microsoft.com/en-us/library/windows/desktop/ms711681%28v=vs.85%29.aspx */
procedure SQLGetInfo external "{&ODBC-DLL}" persistent.
    define input        parameter ConnectionHandle  as {&SQLHANDLE-TYPE}.    /* SQLHDBC:SQLHANDLE  */
    define input        parameter InfoType          as long.    /* SQLUSMALLINT */
    define input-output parameter InfoValuePtr      as memptr.  /* SQLPOINTER */
    define input        parameter BufferLength      as short.   /* SQLSMALLINT */
    define input-output parameter StringLengthPtr   as memptr.  /* SQLSMALLINT* */
    define return       parameter returnValue       as short.   /* [Return] SQLRETURN */
end procedure.

