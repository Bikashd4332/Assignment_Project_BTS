<!---
	--- ReportsComponent.cfc
	--- ---------------
	--- 
	--- author: mindfire
	--- date:   4/22/19
  --->
  
  <cfcomponent displayname="ReportsComponent" accessors="true" output="false" persistent="false">
    <cffunction access="remote" output="false" returnformat="JSON" returntype="array" name="GetAllReportsOfProject" >
      <cfargument required="false" default="" type="string" name="searchString">

      <cfset utilComponentInstance = CreateObject('component', 'UtilComponent')>

      <cfquery name="queryGetAllReports">
        SELECT RI.[ReportID], RT.[Title] AS Type, RI.[Priority] , RI.[ReportTitle], RI.[Description] FROM
				[REPORT_INFO] AS RI
				INNER JOIN
				[REPORT_TYPE] AS RT
				ON RI.ReportTypeID =  RT.ReportTypeID
				INNER JOIN
				[REPORT_STATUS_TYPE] AS RST
				ON RI.StatusID = RST.StatusID
        INNER JOIN [PERSON] P
        ON P.[PersonID] = RI.[PersonID]
        WHERE P.[ProjectID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#utilComponentInstance.GetProjectIdOf()#">
        -- If the searchString is not empty then search the specified keyword in the title only
        <cfif arguments.searchString NEQ ''>
          AND RI.[ReportTitle] LIKE <cfqueryparam value="%#arguments.searchString#%" cfsqltype="cf_sql_varchar">
        </cfif>
      </cfquery>

      <cfset responseArray = ArrayNew(1)>
      <cfif queryGetAllReports.RecordCount GT 0>
        <cfloop query="queryGetAllReports">
          <cfset ArrayAppend(responseArray, '{ "id": "#ReportID#", "title": "#ReportTitle#", "description": "#Description#", "type": "#Type#", "priority": "#Priority#"}')>
        </cfloop>
      </cfif>
      <cfreturn responseArray />
        
    </cffunction>
  </cfcomponent> 