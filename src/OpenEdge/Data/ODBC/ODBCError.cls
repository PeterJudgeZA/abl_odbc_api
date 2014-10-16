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
/**
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
**/
/*------------------------------------------------------------------------
    File        : ODBCError
    Purpose     : Errors that are raised as a result of RUN SQL* calls. other error will return as AppError.
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Tue Jul 30 09:30:02 EDT 2013
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.AppError.

class OpenEdge.Data.ODBC.ODBCError inherits AppError: 
		
	constructor public ODBCError ( input p0 as character ):
		super (input p0).
	end constructor.

	constructor public ODBCError ( input p0 as character, input p1 as integer ):
		super (input p0, input p1).
	end constructor.

	constructor public ODBCError (  ):
		super ().
	end constructor.


end class.
