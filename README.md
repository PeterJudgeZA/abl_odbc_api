Introduction
================
OpenEdge applications are often deployed alongside other business systems that are responsible for key pieces of the overall business process. In these scenarios it is imperative that OE also connect (or integrate) with these other applications in order  to execute the business process. DataDirect Cloud is a tool that facilitates this integration with SaaS applications like 
Salesforce, Microsoft Dynamics CRM, Oracle RightNow, and a number of other sources in the development pipeline. More information about DataDirect Cloud is available at (http://www.datadirectcloud.com/why-datadirect-cloud.html) .

The sample ABL shows how you can interact with the DataDirect Cloud (D2C) and Easyl servers, using a set of OOABL classes. These classes provide a simplified wrapper around a series of DLL calls to the D2C Driver via the ODBC Driver Manager. This simplification is  primarily around removing the need to work directly with the ODBC API via memptrs and the like. The classes simplify the calls  a consumer of the API must make in order to execute a SQL statement, gather corresponding metaschema and data results. By  encapsulating the process,  the ABL programmer needs only to formulate a SQL query and designate a target for its results while the classes handle all the handle allocations, state transitions and cleanup. 

The API returns the data from the query executed (the result set) in one of three containers:
- a JSON Object, 
- a dynamically-created temp-table, which is created from the column information of the query, and
- a temp-table defined in the calling code. 

The sample code allows you to connect to any D2C or ODBC data source, and to query it in any way you see fit.

Setup & environment
=========================
There are a number of prerequisite steps in order to access data via the DataDirect Cloud. These steps are detailed in the "Integrating_DataDirectCloud_into_OpenEdge_Applications" PDF document in the doc folder of this project.

Basically, you will need an account on a Cloud data provider, an account on DataDirect Cloud, and some drivers installed on your local machine.
 
Running the sample
=========================
This project has been set up so that you can run the sample via a Run Configuration called "Run D2C Sample". More information about the types of operations supported are in the "Integrating_DataDirectCloud_into_OpenEdge_Applications" document.

Feedback and comments
=========================
This readme and the associated project code is also available on Progress Communities, on the following page. 
    Home > Community Groups > OpenEdge Architecture 
        > Wiki
            > Integrating DataDirect Cloud and Progress Easyl into OpenEdge using the ODBC Bridge Sample Applications 
The direct URL for that page is currently https://community.progress.com/community_groups/openedge_architecture/w/openedgecloudarcade/2179.integrating-datadirect-cloud-and-progress-easyl-into-openedge-using-the-odbc-bridge-sample-applications.aspx . 

Please feel free to provide comments and feedback, and questions you might have to that page and its parent community.  

This project is licensed under the Apache 2.0 license. See the LICENSE and NOTICE file in the project root for details.
#eof