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
    File        : DriverManagerLib.i
    Purpose     : Contains the location of the ODBC DLL/SO on this system 
    Author(s)   : pjudge 
    Created     : Mon Jul 29 12:32:12 EDT 2013
    Notes       : * This value will change depending on the platform and potentially
                    bitness
                  * This include uses the OPSYS and PROCESS-ARCHITECTURE
                    preprocessors to determine which ODBC driver manager to load.
  ----------------------------------------------------------------------*/
/* Uncomment this line if you want to override the defaults, for instance
   when dealing with 32-bit OE on 64-bit Windows (the SysWOW thing). We
   know about this condition but cannot deal with it via preprocessors.
&global-define ODBC-DLL c:\windows\system32\odbc32.dll
*/

&if defined(ODBC-DLL) eq 0 &then 
/* check for Unix (since Windows values are overridable).
   
   From the Help: ABL supports an override option that enables applications that need to return the value of MS-DOS for all 
   Microsoft® operating systems to do so. For example, if you do not want the value WIN32 to be returned when the operating
   system is recognized, you can override this return value by defining the Opsys key in the Startup section of the current
   environment, which can be in the registry or in an initialization file. If the Opsys key is located, the OPSYS function 
   returns the value associated with the Opsys key on all platforms. */
&if '{&OPSYS}' eq 'UNIX' &then
    &if {&PROCESS-ARCHITECTURE} = 64 &then
        /* 64-bit UNIX */
        &global-define ODBC-DLL /opt/bin/odbc.dll
    &else 
        /* 32-bit UNIX */
        &global-define ODBC-DLL /opt/bin/odbc.dll 
    &endif 
&else
    /* This DLL is correct for Windows when OE bitness and Windows bitness are the same.
       See earlier note for the 32-bit OE on 64-bit Windows case. */
    &global-define ODBC-DLL c:\windows\system32\odbc32.dll  
&endif  /* opsys: windows */
&endif  /* if defined() */
