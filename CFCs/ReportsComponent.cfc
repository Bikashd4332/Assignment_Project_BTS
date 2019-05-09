<!---
	--- ReportsComponent.cfc
	--- ---------------
	--- 
	--- author: mindfire
	--- date:   4/22/19
  --->
  
  <cfcomponent displayname="ReportsComponent" accessors="true" output="false" persistent="false">
    <cffunction access="remote" output="false" returnformat="JSON" returntype="array" name="GetAllReportsOfProject" hint="This function returns all the list of reports if no searchString is given else only the report's title including the search are retured.">
      <cfargument required="false" default="" type="string" name="searchString">

      <cfset local.utilComponentInstance = CreateObject('component', 'UtilComponent')>

      <cfquery name="local.queryGetAllReports">
        SELECT RI.[ReportID], RT.[Title] AS Type, RI.[Priority] , RI.[ReportTitle], RI.[Description] 
        FROM [REPORT_INFO] AS RI
				INNER JOIN [REPORT_TYPE] AS RT
				ON RI.[ReportTypeID] =  RT.[ReportTypeID]
				INNER JOIN [REPORT_STATUS_TYPE] AS RST
				ON RI.[StatusID] = RST.[StatusID]
        INNER JOIN [PERSON] P
        ON P.[PersonID] = RI.[PersonID]
        WHERE P.[ProjectID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.utilComponentInstance.GetProjectIdOf()#">
        
        -- If the searchString is not empty then search the specified keyword in the title only
        <cfif arguments.searchString NEQ ''>
          AND RI.[ReportTitle] LIKE <cfqueryparam value="%#arguments.searchString#%" cfsqltype="cf_sql_varchar">
        </cfif>
      </cfquery>

      <cfset local.responseArray = ArrayNew(1)>
      <cfif local.queryGetAllReports.RecordCount GT 0>
        <cfloop query="local.queryGetAllReports">
          <cfset ArrayAppend(local.responseArray, '{ "id": "#ReportID#", "title": "#ReportTitle#", "description": "#Description#", "type": "#Type#", "priority": "#Priority#"}')>
        </cfloop>
      </cfif>
      <cfreturn local.responseArray />
        
    </cffunction>

    <cffunction access="private" returntype="array" output="true" name="GetCurrentYearStatsOfOpen" hint="This function returns the history of all the opened reports in each month in the current year.">
      
      <cfquery name="local.queryGetCurrentYearStatOfOpen">
        -- Getting the month index and numer of tickets opened.
        SELECT DATEPART(MONTH, [DateReported]) AS [MonthIndex], COUNT(*) AS [TicketRaised]  
        FROM [REPORT_INFO] RI
        INNER JOIN [REPORT_TYPE] RT
        ON RT.[ReportTypeID] = RI.[ReportTypeID]
        WHERE RT.[Title] LIKE '%'
        GROUP BY DATEPART(MONTH, [DateReported]), DATEPART(YEAR, [DateReported])
      </cfquery>
      <cfset local.arrayStat = ArrayNew(1)>
      <cfloop from="1" to="12" index="local.index">
        <cfset arrayAppend(local.arrayStat, 0)>
      </cfloop>
      
      <cfloop query="local.queryGetCurrentYearStatOfOpen"> 
        <cfset local.arrayStat[MonthIndex] = TicketRaised>
      </cfloop>

      <cfreturn local.arrayStat />      
    </cffunction>

    <cffunction access="private" output="false" returntype="array" name="GetCurrentYearStatsOfFixed" hint="This function returns an array of inde months and number of reports closed counts for chart." >
      <cfset local.utilComponentInstance = CreateObject('component', 'UtilComponent')>
      <cfquery name="local.queryGetCurrentYearStatOfFixed">
        SELECT DATEPART(MONTH, [DateCommented]) AS [MonthIndex], COUNT(*) AS [FixedCount]
        FROM [REPORT_COMMENTS] RC
        INNER JOIN [PERSON] P
        ON P.[PersonID] = RC.[PersonID]
        WHERE [IsActivity] = 1
        AND P.[ProjectID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.utilComponentInstance.GetProjectIdOf()#"> 
        AND [Comment] LIKE '%has closed this report.'
        GROUP BY DATEPART(MONTH, [DateCommented]), DATEPART(YEAR, [DateCommented])
      </cfquery>

      <cfset local.arrayStat = ArrayNew(1)>
      <cfloop from="1" to="12" index="index">
        <cfset arrayAppend(local.arrayStat, 0)>
      </cfloop>

      <cfloop query="local.queryGetCurrentYearStatofFixed"> 
        <cfset arrayStat[MonthIndex] = FixedCount>
      </cfloop>

      <cfreturn local.arrayStat />    
      
    </cffunction>

    <cffunction access="remote" output="false" returnformat="JSON" returntype="array" name="GetAllStatsZipped">

      <cfset local.currentYearOpenStat = GetCurrentYearStatsOfOpen()>
      <cfset local.currentYearFixedStat = GetCurrentYearStatsOfFixed()>
      <cfset local.googleChartData = ArrayNew(2)>
      
      <cfloop from="1" to="12" index="index">
        <cfset ArrayAppend(local.googleChartData, [])>
        <cfset ArrayAppend(local.googleChartData[index], GetMonthNameFromIndex(int(index)))>
        <cfset ArrayAppend(local.googleChartData[index], local.currentYearOpenStat[index])>
        <cfset ArrayAppend(local.googleChartData[index], local.currentYearFixedStat[index])>
      </cfloop>

      <cfreturn local.googleChartData/>
    </cffunction>

    <cffunction access="private" output="false" returntype="string" name="GetMonthNameFromIndex">
      <cfargument type="numeric" required="true" name="monthIndex">
      <cfset local.monthArray = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']>
      <cfif arguments.monthIndex LTE 12>
        <cfreturn local.monthArray[arguments.monthIndex]>
      </cfif>
    </cffunction>
    
    
  </cfcomponent> 