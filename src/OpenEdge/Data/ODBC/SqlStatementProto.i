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
    File        : OpenEdge/Data/ODBC/SqlStatementProto.i
    Purpose     : Forward declarations of the D2C Cloud ODBC DLL calls
    Author(s)   : pjudge
    Created     : Tue Jul 02 13:50:17 EDT 2013
    Notes       :  
  ----------------------------------------------------------------------*/
/* platform-specific DLL location */
{OpenEdge/Data/ODBC/DriverManagerLib.i}
  
/* Doc at http://msdn.microsoft.com/en-us/library/windows/desktop/ms712631%28v=vs.85%29.aspx */
procedure SQLSetStmtAttr external "{&ODBC-DLL}" persistent.
    define input        parameter StatementHandle   as long.    /* [Input] SQLHSTMT:SQLHANDLE */
    define input        parameter Attribute         as long.    /* SQLINTEGER */
    define input        parameter ValuePtr          as long.    /* SQLPOINTER */
    define input        parameter StringLength      as long.    /* SQLINTEGER */     
    define return       parameter returnValue       as short.   /* SQLRETURN */
end procedure.

/* Doc at http://msdn.microsoft.com/en-us/library/windows/desktop/ms713611%28v=vs.85%29.aspx */
procedure SQLExecDirect external "{&ODBC-DLL}" persistent.
    define input        parameter StatementHandle   as long.        /* [Input] SQLHSTMT:SQLHANDLE */
    define input        parameter StatementText     as character.   /* [Input] SQLCHAR* */
    define input        parameter TextLength        as int64.       /* [Input] SQLINTEGER */
    define return       parameter returnValue       as short.       /* [Return] SQLRETURN */
end procedure.

/* Doc at http://msdn.microsoft.com/en-us/library/windows/desktop/ms712424%28v=vs.85%29.aspx */
procedure SQLFetch external "{&ODBC-DLL}" persistent.
    define input        parameter StatementHandle   as long.        /* [Input] SQLHSTMT:SQLHANDLE */
    define return       parameter returnValue       as short.       /* [Return] SQLRETURN */
end procedure.

/* Doc at http://msdn.microsoft.com/en-us/library/windows/desktop/ms715393%28v=vs.85%29.aspx */
procedure SQLNumResultCols external "{&ODBC-DLL}" persistent.
    define input        parameter StatementHandle   as long.        /* [Input] SQLHSTMT:SQLHANDLE */
    define input-output parameter ColumnCountPtr    as memptr.      /* SQLSMALLINT* */    
    define return       parameter returnValue       as short.       /* [Return] SQLRETURN */
end procedure.

/* Doc at http://msdn.microsoft.com/en-us/library/windows/desktop/ms711010%28v=vs.85%29.aspx */
procedure SQLBindCol external "{&ODBC-DLL}" persistent.
    define input        parameter StatementHandle   as long.        /* [Input] SQLHSTMT:SQLHANDLE */
    define input        parameter ColumnNumber      as long.        /* [Input] SQLSMALLINT */
    define input        parameter TargetType        as long.        /* [Input] SQLUSMALLINT */
    define input-output parameter TargetValuePtr    as memptr.      /* [Deferred Input/Output] SQLPOINTER */
    define input        parameter BufferLength      as long.        /* [Input] SQLLEN */
    define input-output parameter StrLenOrInd       as memptr.      /* [Deferred Input/Output]  SQLLEN* */
    define return       parameter returnValue       as short.       /* [Return] SQLRETURN */
end procedure.

/* Doc at http://msdn.microsoft.com/en-us/library/windows/desktop/ms716289%28v=vs.85%29.aspx */
procedure SQLDescribeCol external "{&ODBC-DLL}" persistent.
    define input        parameter StatementHandle   as long.        /* [Input]  SQLHSTMT:SQLHANDLE */
    define input        parameter ColumnNumber      as long.        /* [Input]  SQLUSMALLINT */
    define input-output parameter ColumnName        as memptr.      /* [Output] SQLCHAR* */
    define input        parameter BufferLength      as long.        /* [Input]  SQLSMALLINT */
    define input-output parameter NameLengthPtr     as memptr.      /* [Output] SQLSMALLINT* */
    define input-output parameter DataTypePtr       as memptr.      /* [Output] SQLSMALLINT* */
    define input-output parameter ColumnSizePtr     as memptr.      /* [Output] SQLULEN* */ 
    define input-output parameter DecimalDigitsPtr  as memptr.      /* [Output] SQLSMALLINT* */
    define input-output parameter NullablePtr       as memptr.      /* [Output] SQLSMALLINT* */
    define return       parameter returnValue       as short.       /* [Return] SQLRETURN */
end procedure.

/* Doc at http://msdn.microsoft.com/en-us/library/windows/desktop/ms711831%28v=vs.85%29.aspx */
procedure SQLTables external "{&ODBC-DLL}" persistent.
    define input        parameter StatementHandle   as long.        /* SQLHSTMT:SQLHANDLE */
    define input        parameter CatalogName       as character.   /* SQLCHAR* */
    define input        parameter NameLength1       as short.       /* SQLSMALLINT */
    define input        parameter SchemaName        as character.   /* SQLCHAR* */
    define input        parameter NameLength2       as short.       /* SQLSMALLINT */
    define input        parameter TableName         as character.   /* SQLCHAR* */
    define input        parameter NameLength3       as short.       /* SQLSMALLINT */
    define input        parameter TableType         as character.   /* SQLCHAR* */
    define input        parameter NameLength4       as short.       /* SQLSMALLINT */
    define return       parameter returnValue       as short.       /* [Return] SQLRETURN */
end procedure.

/* Doc at http://msdn.microsoft.com/en-us/library/windows/desktop/ms715441%28v=vs.85%29.aspx */
procedure SQLGetData external "{&ODBC-DLL}" persistent.
    define input        parameter StatementHandle   as long.        /* [Input] SQLHSTMT:SQLHANDLE */
    define input        parameter Col_or_Param_Num  as long.        /* [Input] SQLUSMALLINT */
    define input        parameter TargetType        as long.        /* [Input] SQLUSMALLINT */
    define input-output parameter TargetValuePtr    as memptr.      /* [Output] SQLPOINTER */
    define input        parameter BufferLength      as long.        /* [Input] SQLLEN */
    define input-output parameter StrLen_or_IndPtr  as memptr.      /* [Output] SQLPOINTER */
    define return       parameter returnValue       as short.       /* [Return] SQLRETURN */
end procedure.

/* Doc at http://msdn.microsoft.com/en-us/library/windows/desktop/ms714632%28v=vs.85%29.aspx */
procedure SQLGetTypeInfo external "{&ODBC-DLL}" persistent.
    define input        parameter StatementHandle   as long.        /* [Input] SQLHSTMT:SQLHANDLE */
    define input        parameter DataType          as long.        /* [Input] SQLUSMALLINT */
    define return       parameter returnValue       as short.       /* [Return] SQLRETURN */
end procedure.

/* Doc at http://msdn.microsoft.com/en-us/library/windows/desktop/ms711683%28v=vs.85%29.aspx */
procedure SQLColumns external "{&ODBC-DLL}" persistent.
    define input        parameter StatementHandle   as long.        /* [Input] SQLHSTMT:SQLHANDLE */
    define input        parameter CatalogName       as character.   /* [Input] SQLCHAR* */
    define input        parameter NameLength1       as short.       /* [Input] SQLSMALLINT */
    define input        parameter SchemaName        as character.   /* [Input] SQLCHAR* */
    define input        parameter NameLength2       as short.       /* [Input] SQLSMALLINT */
    define input        parameter TableName         as character.   /* [Input] SQLCHAR* */
    define input        parameter NameLength3       as short.       /* [Input] SQLSMALLINT */
    define input        parameter ColumnName        as character.   /* [Input] SQLCHAR* */
    define input        parameter NameLength4       as short.       /* [Input] SQLSMALLINT */
    define return       parameter returnValue       as short.       /* [Return] SQLRETURN */
end procedure.

/* Doc at http://msdn.microsoft.com/en-us/library/windows/desktop/ms709301%28v=vs.85%29.aspx */
procedure SQLCloseCursor external "{&ODBC-DLL}" persistent.
    define input        parameter StatementHandle   as long.        /* [Input] SQLHSTMT:SQLHANDLE */
    define return       parameter returnValue       as short.       /* [Return] SQLRETURN */
end procedure.

/** TEMPLATE 
/* Doc at */
procedure  external "{&ODBC-DLL}" persistent.
    define input        parameter StatementHandle   as long.        /* [Input] SQLHSTMT:SQLHANDLE */
    define return       parameter returnValue       as short.       /* [Return] SQLRETURN */
end procedure.
**/
