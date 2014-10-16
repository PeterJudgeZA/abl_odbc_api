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
    File        : RowReadEventArgs
    Purpose     : Event args for Row
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Mon Jul 15 13:48:03 EDT 2013
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.System.EventArgs.
using Progress.Lang.Object.

class OpenEdge.Data.ODBC.RowReadEventArgs inherits EventArgs:
    /* JSON or Table, and associated reference */        
    define public property TargetType as character no-undo get. set.
    define public property TargetReference as Object no-undo get. set.
    define public property RowReference as Object no-undo get. set.
    
    constructor public RowReadEventArgs():
    end constructor.
    
    constructor public RowReadEventArgs(input pcTargetType as character,
                                        input poTargetReference as Object):
        assign TargetType = pcTargetType
               TargetReference = poTargetReference.
    end constructor.
    
end class.
