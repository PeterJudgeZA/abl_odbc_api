## Introduction
OpenEdge applications are often deployed alongside other business systems that are responsible for key pieces of the overall business process. The data in these other systems are typically accessible via ODBC for on-premise data stores, or SaaS applications via [DataDirect Cloud](https://www.progress.com/products/datadirect-cloud) or [Easyl](https://www.progress.com/products/easyl).

This ABL project uses a set of OOABL classes that provide a simplified wrapper around a series of DLL calls to the ODBC Driver Manager. This simplification is primarily around removing the need to work directly with the ODBC API via memptrs and the like. The classes simplify the calls a consumer of the API must make in order to execute a SQL statement, gather corresponding metaschema and data results. By  encapsulating the process, the ABL programmer needs only to formulate a SQL query and designate a target for its results while the classes handle all the handle allocations, state transitions and cleanup. 

The API returns the data from the query executed (the result set) in one of three containers:
- a JSON Object, 
- a dynamically-created temp-table, which is created from the column information of the query, or
- a temp-table defined in the calling code. 

## Setup & environment
The `doc/` folder in this project contains a document named "Integrating_DataDirect_Cloud_and_Progress_Easyl_into_OpenEdge_using_the_ODBC_Bridge_Sample_Applications.pdf" which contains detailed setup instructions.

HTML documentation for the classes has been generated and is accessible from the `doc/html/index.html` page.

### Prerequisites
* This project assumes you are using OpenEdge 11.4.0+. For a version of this sample that works with 11.3 and earlier, please use the code and instructions from [Integrating DataDirect Cloud and Progress Easyl into OpenEdge using the ODBC Bridge Sample Applications](https://community.progress.com/community_groups/openedge_architecture/w/openedgecloudarcade/2179.integrating-datadirect-cloud-and-progress-easyl-into-openedge-using-the-odbc-bridge-sample-applications.aspx) on Progress Communities.
* You will need the appropriate ODBC drivers installed.
* The API assumes that you are running a version of OE that has the same bitness as the underlying OS (ie 32-bit OE on 32-bit Windows). The default OpenEdge Windows install is a 32-bit install, although as of 11.3.0 there will be a 64-bit version. Trying to run 32-bit OpenEdge with the 64-bit drivers results in an error. There are some tweaks needed to install the 32-bit DLLs on a 64-bit OS, like Windows 7; these tweaks involve the registry settings and won't be described here.

## Running the sample
The tests/ folder contains ABL procedures for running the ODBC API. These procedures all start with `run_`. Make sure you've updated the `conf/d2c.json` file with the correct details first. 


## Meta
This project is licensed under the Apache 2.0 license. See the LICENSE and NOTICE file in the project root for details.
