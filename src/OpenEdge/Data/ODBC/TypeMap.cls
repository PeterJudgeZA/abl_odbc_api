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
    File        : TypeMap
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Tue Jul 16 13:23:50 EDT 2013
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Data.ODBC.CTypeEnum.
using OpenEdge.Data.ODBC.SqlTypeEnum.
using Progress.Lang.AppError.
using Progress.Lang.Object.

class OpenEdge.Data.ODBC.TypeMap:
    
    /* 1 ABL type can have many SQL types (so sql:abl::1:1)*/
    define private static temp-table SqlAblMap no-undo
        field AblType   as character
        field SqlType   as Object       /* OpenEdge.Data.ODBC.SqlTypeEnum */
        field MaxBytes  as int64      /* expressed as power of 2; 2^10 = 32KB for all but CLOB, BLOB, which are 2^33 = 1GB */
        index idx1 as primary unique SqlType
        index idx2 AblType
        .
    
    /* 1 SQL type can have many C types  (so c:sql::1:1)*/
    define private static temp-table SqlCMap no-undo
        field CType     as Object       /* OpenEdge.Data.ODBC.CTypeEnum */
        field CTypeSize as int64
        field SqlType   as Object       /* OpenEdge.Data.ODBC.SqlTypeEnum */
        index idx1 as primary unique CType
        index idx2 CType
        index idx3 SqlType
        .
    
    constructor static TypeMap():
        /* SQL <-> C: C type , Size/bytes, SQL Type, default sizes */
        /* Character data in ~1K chunks */
        CreateCMap(CTypeEnum:SQL_C_CHAR,            (1024 + 1),  SqlTypeEnum:SQL_CHAR).
        CreateCMap(CTypeEnum:SQL_C_WCHAR,           (1024 + 1),  SqlTypeEnum:SQL_WCHAR).
        CreateCMap(CTypeEnum:SQL_C_BIT,             (1 + 1),     SqlTypeEnum:SQL_BIT).
        CreateCMap(CTypeEnum:SQL_C_BINARY,          int64(exp(2, 33) + 1),          SqlTypeEnum:SQL_BINARY).
        CreateCMap(CTypeEnum:SQL_C_GUID,            int64(exp(2, 33) + 1),          SqlTypeEnum:SQL_GUID).
        CreateCMap(CTypeEnum:SQL_C_STINYINT,        2,          SqlTypeEnum:SQL_TINYINT).
        CreateCMap(CTypeEnum:SQL_C_UTINYINT,        2,          SqlTypeEnum:SQL_TINYINT).
        CreateCMap(CTypeEnum:SQL_C_SSHORT,          2,          SqlTypeEnum:SQL_SMALLINT).
        CreateCMap(CTypeEnum:SQL_C_USHORT,          2,          SqlTypeEnum:SQL_SMALLINT).
        CreateCMap(CTypeEnum:SQL_C_SLONG,           4,          SqlTypeEnum:SQL_INTEGER).
        CreateCMap(CTypeEnum:SQL_C_ULONG,           4,          SqlTypeEnum:SQL_INTEGER).
        CreateCMap(CTypeEnum:SQL_C_TYPE_TIME,       8,          SqlTypeEnum:SQL_TYPE_TIME).
        CreateCMap(CTypeEnum:SQL_C_TYPE_DATE,       10,         SqlTypeEnum:SQL_TYPE_DATE).
        CreateCMap(CTypeEnum:SQL_C_TYPE_TIMESTAMP,  19,         SqlTypeEnum:SQL_TYPE_TIMESTAMP).
        CreateCMap(CTypeEnum:SQL_C_SBIGINT,         8,          SqlTypeEnum:SQL_BIGINT).
        CreateCMap(CTypeEnum:SQL_C_UBIGINT,         8,          SqlTypeEnum:SQL_BIGINT).
        CreateCMap(CTypeEnum:SQL_C_DOUBLE,          8,          SqlTypeEnum:SQL_DOUBLE).
        
        /* SQL_C_NUMERIC */
        /* SQL_C_DOUBLE  */
        
        /* SQL <-> ABL */
        CreateAblMap('CHARACTER',   SqlTypeEnum:SQL_CHAR, 10).
        CreateAblMap('CHARACTER',   SqlTypeEnum:SQL_WCHAR, 10).

        CreateAblMap('BLOB',        SqlTypeEnum:SQL_BINARY, 33).
        CreateAblMap('BLOB',        SqlTypeEnum:SQL_LONGVARBINARY, 33).
        
        CreateAblMap('CLOB',        SqlTypeEnum:SQL_GUID, 33).
        CreateAblMap('CLOB',        SqlTypeEnum:SQL_LONGVARCHAR, 33).
        CreateAblMap('CLOB',        SqlTypeEnum:SQL_WLONGVARCHAR, 33).
        
        CreateAblMap('INTEGER',     SqlTypeEnum:SQL_TINYINT, 10).
        CreateAblMap('INTEGER',     SqlTypeEnum:SQL_SMALLINT, 10).
        CreateAblMap('INTEGER',     SqlTypeEnum:SQL_INTEGER, 10).
        CreateAblMap('INTEGER',     SqlTypeEnum:SQL_TYPE_TIME, 10).
        
        CreateAblMap('INT64',       SqlTypeEnum:SQL_BIGINT, 10).
        
        CreateAblMap('DATETIME',    SqlTypeEnum:SQL_TYPE_TIMESTAMP, 10).
        CreateAblMap('DATE',        SqlTypeEnum:SQL_TYPE_DATE, 10).
        
        CreateAblMap('LOGICAL',     SqlTypeEnum:SQL_BIT, 10).
        
        CreateAblMap('DECIMAL',       SqlTypeEnum:SQL_DOUBLE, 10).
        
        CreateAblMap('DECIMAL',       SqlTypeEnum:SQL_DECIMAL, 10).
        CreateAblMap('DECIMAL',       SqlTypeEnum:SQL_NUMERIC, 10).
        CreateAblMap('DECIMAL',       SqlTypeEnum:SQL_FLOAT, 10).
        CreateAblMap('DECIMAL',       SqlTypeEnum:SQL_REAL, 10).
    end constructor.
    
    method static private void CreateCMap(input poCType as CTypeEnum,
                                          input piCTypeSize as int64,
                                          input poSqlType as SqlTypeEnum):
        
        if not can-find(SqlCMap where SqlAblMap.SqlType eq poSqlType) then
        do:
            create SqlCMap.
            assign SqlCMap.SqlType = poSqlType
                   SqlCMap.CType = poCType
                   SqlCMap.CTypeSize = piCTypeSize.
        end.
    end method.
    
    method static private void CreateAblMap(input pcAblType as character,
                                            input poSqlType as SqlTypeEnum,
                                            input piMaxBytes as int64):
        
        if not can-find(SqlAblMap where SqlAblMap.SqlType eq poSqlType) then
        do:
            create SqlAblMap.
            assign SqlAblMap.AblType = pcAblType
                   SqlAblMap.SqlType = poSqlType
                   SqlAblMap.MaxBytes = piMaxBytes.
        end.
    end method.
        
    method static public character SqlToAbl(input poSqlType as SqlTypeEnum):
        find SqlAblMap where SqlAblMap.SqlType eq poSqlType no-error.
        if available SqlAblMap then
            return SqlAblMap.AblType.
        
        /* sensible? default */
        return 'CLOB'.
    end method.
    
    method static public character CToAbl(input poCType as CTypeEnum):
        find SqlCMap where SqlCMap.CType eq poCType no-error.
        if available SqlCMap then
            return SqlToAbl(cast(SqlCMap.SqlType, SqlTypeEnum)).
        
        /* sensible? default */
        return 'CLOB'.
    end method.
    
    method static public SqlTypeEnum CToSql(input poCType as CTypeEnum):
        find SqlCMap where SqlCMap.CType eq poCType no-error.
        if available SqlCMap then
            return cast(SqlCMap.SqlType, SqlTypeEnum).
        
        return SqlTypeEnum:SQL_UNKNOWN_TYPE.
    end method.
    
    method static public int64 MaxCTypeSize(input poCType as CTypeEnum):
        define variable iSize as int64 no-undo.
        
        define buffer SqlCMap for SqlCMap.
        define buffer SqlAblMap for SqlAblMap.
        
        iSize = ?.
        find SqlCMap where SqlCMap.CType eq poCType no-error.
        if available SqlCMap then
            find SqlAblMap where SqlAblMap.SqlType eq SqlCMap.SqlType no-error.
        if available SqlAblMap then
            return SqlAblMap.MaxBytes.
        else
            return SqlCMap.CTypeSize.
        
        undo, throw new AppError(
                    substitute('No C type found for &1', poCType:ToString())
                    ,0).
    end method.
    
    method static public int64 CTypeSize(input poCType as CTypeEnum):
        define variable iSize as int64 no-undo.
        
        iSize = ?.
        find SqlCMap where SqlCMap.CType eq poCType no-error.
        if available SqlCMap then
            iSize = SqlCMap.CTypeSize.
        
        if iSize eq ? then
            undo, throw new AppError(
                    substitute('No C type found for &1', poCType:ToString())
                    ,0).
        return iSize.                    
    end method.
    
    method static public CTypeEnum DefaultCType(input piSqlType as int64):
        define variable oSqlType as SqlTypeEnum no-undo.
        define variable oCType as CTypeEnum no-undo.
        
        oSqlType = SqlTypeEnum:ValueToEnum(integer(piSqlType)).
        
        /* Pick a default value, even though there are multiple C types per SQL type */
        case oSqlType:
            when SqlTypeEnum:SQL_CHAR           then assign oCType = CTypeEnum:SQL_C_CHAR.
            when SqlTypeEnum:SQL_WCHAR          then assign oCType = CTypeEnum:SQL_C_WCHAR.
            when SqlTypeEnum:SQL_SMALLINT       then assign oCType = CTypeEnum:SQL_C_SSHORT.
            when SqlTypeEnum:SQL_INTEGER        then assign oCType = CTypeEnum:SQL_C_SLONG.
            when SqlTypeEnum:SQL_DOUBLE         then assign oCType = CTypeEnum:SQL_C_DOUBLE.
            when SqlTypeEnum:SQL_BIGINT         then assign oCType = CTypeEnum:SQL_C_SBIGINT.
            when SqlTypeEnum:SQL_BIT            then assign oCType = CTypeEnum:SQL_C_BIT.
            when SqlTypeEnum:SQL_GUID           then assign oCType = CTypeEnum:SQL_C_GUID.
            when SqlTypeEnum:SQL_TYPE_DATE      then assign oCType = CTypeEnum:SQL_C_TYPE_DATE.
            when SqlTypeEnum:SQL_TYPE_TIME      then assign oCType = CTypeEnum:SQL_C_TYPE_TIME.
            when SqlTypeEnum:SQL_TYPE_TIMESTAMP then assign oCType = CTypeEnum:SQL_C_TYPE_TIMESTAMP.
            otherwise                            assign oCType = CTypeEnum:SQL_C_CHAR.
        end case.
        
        return oCType.
    end method.
    
end class.
