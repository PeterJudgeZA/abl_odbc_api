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
    File        : FieldReadEventArgs
    Purpose     : Event args for Row
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Mon Jul 15 13:48:03 EDT 2013
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Data.ODBC.CTypeEnum.
using OpenEdge.Core.System.EventArgs.
using Progress.Lang.Object.

class OpenEdge.Data.ODBC.FieldReadEventArgs inherits EventArgs:
    /* JSON or Table, and associated reference */        
    define public property TargetType as character no-undo get. set.
    define public property TargetReference as Object no-undo get. set.
    
    /* Row or field, and appropriate table/field name */
    define public property ParentReference as Object no-undo get. set.
    define public property FieldReference as character no-undo get. set.
    
    /* data values */
    define public property CType as CTypeEnum no-undo get. set.
    define public property IsNullValue as logical no-undo get. set.
    define public property ValuePointer as int64 no-undo get. set.
    
    constructor public FieldReadEventArgs():
    end constructor.
    
    constructor public FieldReadEventArgs(input pcTargetType as character,
                                          input poTargetReference as Object,
                                          input poParentReference as Object,
                                          input pcFieldReference as character,
                                          input poCType as CTypeEnum,
                                          input plIsNullValue as logical,
                                          input piValuePointer as int64):
        assign this-object:TargetType = pcTargetType
               this-object:TargetReference = poTargetReference
               this-object:ParentReference = poParentReference 
               this-object:FieldReference = pcFieldReference
               this-object:IsNullValue = plIsNullValue
               this-object:ValuePointer = piValuePointer
               this-object:CType = poCType.
    end constructor.
    
end class.
