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
    File        : ODBCConnectionParameters
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Tue Jul 02 13:02:40 EDT 2013
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.ServerConnection.ConnectionParameters.
using OpenEdge.Core.ServerConnection.FormatMaskEnum.
using Progress.Json.ObjectModel.JsonObject.

class OpenEdge.Core.ServerConnection.ODBCConnectionParameters inherits ConnectionParameters: 
    define public property DataSourceName as character no-undo get. private set.
    define public property UserName as character no-undo get. private set.
    define public property Password as character no-undo get. private set.
    
    /** Returns true if the connection parameters include more options than just
        the DataSourceName, UserName,Password. */
    define public property SupportsDriverConnect as logical no-undo get. private set.
    
	constructor public ODBCConnectionParameters (input pcOptions as character):
		super (input pcOptions, input FormatMaskEnum:Custom).
	end constructor.
		
	constructor public ODBCConnectionParameters ( input poOptions as JsonObject):
		super (input poOptions, input FormatMaskEnum:Custom).
	end constructor.
	
	method override protected void Initialise():
	    assign DataSourceName = this-object:Options:GetCharacter('DataSourceName')
	           UserName = this-object:Options:GetCharacter('UserName')
	           Password = this-object:Options:GetCharacter('Password').
    end method.
    
	method override public character GetConnectionString(  ):
        /* Format of string doc'ed at  
           http://msdn.microsoft.com/en-us/library/windows/desktop/ms715433%28v=vs.85%29.aspx */
        return ''.
	end method.
    
	
end class.
