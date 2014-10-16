&IF 1=0 &THEN
/** ****************************************************************************
  Copyright 2013 Consultingwerk Ltd.
  
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  
    http://www.apache.org/licenses/LICENSE-2.0
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
**************************************************************************** **/ 
/*------------------------------------------------------------------------
    File        : EnumFromString.i
    Purpose     : Default method to turn a CHARACTER Value into an 
                  Enum member reference

    Syntax      : {Consultingwerk/EnumFromString.i EnumPackage.EnumClassName} 
        
    Description : 

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Tue Feb 12 16:17:11 CEST 2013
    Notes       :
  ----------------------------------------------------------------------*/
&ENDIF

    /*------------------------------------------------------------------------------
        Purpose: Returns the reference to the Enum member with the given name
        Notes:   
        @param pcMemberName The name of the Enum member to return
        @return The reference to the Enum member 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC {1} FromString (pcMemberName AS CHARACTER):
        
        RETURN DYNAMIC-PROPERTY ("{1}":U, pcMemberName) .
        
        CATCH err AS Progress.Lang.Error:
            RETURN ? .  
        END CATCH.

    END METHOD .
