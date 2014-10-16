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
    File        : SqlAttributeConstants.i
    Purpose     : 
    Author(s)   : pjudge 
    Created     : Mon Jul 15 11:14:21 EDT 2013
    Notes       :
  ----------------------------------------------------------------------*/
/* ***************************  Definitions  ************************** */
/* attribute names/values */
define {&STATIC} {&ACCESS-LEVEL} property SQL_ATTR_ODBC_VERSION   as integer initial 200  no-undo get.

define {&STATIC} {&ACCESS-LEVEL} property SQL_OV_ODBC2            as integer initial 2    no-undo get.
define {&STATIC} {&ACCESS-LEVEL} property SQL_OV_ODBC3            as integer initial 3    no-undo get.
