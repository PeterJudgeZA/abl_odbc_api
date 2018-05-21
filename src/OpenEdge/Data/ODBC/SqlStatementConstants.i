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
    File        : SqlStatementConstants.i
    Purpose     : Constant values for SQL
    Author(s)   : pjudge 
    Created     : Mon Jul 15 10:53:52 EDT 2013
    Notes       :
  ----------------------------------------------------------------------*/
define {&STATIC} {&ACCESS-LEVEL} property SQL_TRUE    as integer initial 1 no-undo get.
define {&STATIC} {&ACCESS-LEVEL} property SQL_FALSE   as integer initial 0 no-undo get.

define {&STATIC} {&ACCESS-LEVEL} property SQL_PRED_NONE       as integer initial 0 no-undo get.
define {&STATIC} {&ACCESS-LEVEL} property SQL_PRED_CHAR       as integer initial 1 no-undo get.
define {&STATIC} {&ACCESS-LEVEL} property SQL_PRED_BASIC      as integer initial 2 no-undo get.
define {&STATIC} {&ACCESS-LEVEL} property SQL_SEARCHABLE      as integer initial 3 no-undo get.
define {&STATIC} {&ACCESS-LEVEL} property SQL_PRED_SEARCHABLE as integer no-undo get(): return SQL_SEARCHABLE. end get.

define {&STATIC} {&ACCESS-LEVEL} property SQL_NO_NULLS            as integer initial 0 no-undo get.
define {&STATIC} {&ACCESS-LEVEL} property SQL_NULLABLE            as integer initial 1 no-undo get.
define {&STATIC} {&ACCESS-LEVEL} property SQL_NULLABLE_UNKNOWN    as integer initial 2 no-undo get.

/* QUERY CONSTANTS */
define {&STATIC} {&ACCESS-LEVEL} property SQL_ALL_CATALOGS      as character no-undo initial '%' get.
define {&STATIC} {&ACCESS-LEVEL} property SQL_ALL_SCHEMAS       as character no-undo initial '%' get.
define {&STATIC} {&ACCESS-LEVEL} property SQL_ALL_TABLE_TYPES   as character no-undo initial '%' get.

/* SqlGetData return values */
define {&STATIC} {&ACCESS-LEVEL} property SQL_NULL_DATA   as integer initial -1  no-undo get.
define {&STATIC} {&ACCESS-LEVEL} property SQL_NO_TOTAL    as integer initial -4  no-undo get.

/* SIZES */
define {&STATIC} {&ACCESS-LEVEL} property SQL_MAX_COLUMN_NAME_LEN as integer initial 30 no-undo get.
define {&STATIC} {&ACCESS-LEVEL} property SQL_MAX_MESSAGE_LENGTH  as integer initial 512 no-undo get.
