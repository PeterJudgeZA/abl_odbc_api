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
/* ------------------------------------------------------------------------
    File        : EventArgs
    Purpose     : Generic event arguments class, including static 'Empty'
                  option. 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Jul 27 11:45:09 EDT 2009
    Notes       : * This class based on the AutoEdge|TheFactory version 
                  * Using EventArgs allows us to extend arguments without
                    changing event signatures.
                  * this class is likely to be specialised, but there's no 
                    requirement for that to happen. although outside of 
                    'empty' this is a somewhat useless class :)
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Core.System.EventArgs.

class OpenEdge.Core.System.EventArgs:

    /** A single instance of this class so that we don't have
        to pass nulls around (ie we can depend on there always being
        a value if we so desire).   */
    define static public property Empty as EventArgs 
        get():
            if not valid-object(EventArgs:Empty) then
                EventArgs:Empty = new EventArgs().
             
             return EventArgs:Empty.
        end.
        private set.
    
    constructor public EventArgs():
    end constructor.
    
end class.
