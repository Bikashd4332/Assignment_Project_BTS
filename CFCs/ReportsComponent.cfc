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

    <cffunction access="private" returnformat="JSON" returntype="array" output="true" name="GetCurrentYearStatsOfOpen" hint="This function returns the history of all the opened reports in each month in the current year.">
      
      <cfquery name="queryGetCurrentYearStatOfOpen">
        -- Getting the month index and numer of tickets opened.
        SELECT DATEPART(MONTH, [DateReported]) AS [MonthIndex], COUNT(*) AS [TicketRaised]  
        FROM [REPORT_INFO] RI
        INNER JOIN [REPORT_TYPE] RT
        ON RT.[ReportTypeID] = RI.[ReportTypeID]
        WHERE RT.[Title] LIKE '%'
        GROUP BY DATEPART(MONTH, [DateReported]), DATEPART(YEAR, [DateReported])
      </cfquery>
      <cfset arrayStat = ArrayNew(1)>
      <cfloop from="1" to="12" index="index">
        <cfset arrayAppend(arrayStat, 0)>
      </cfloop>
      
      <cfloop query="queryGetCurrentYearStatOfOpen"> 
        <cfset arrayStat[queryGetCurrentYearStatOfOpen.MonthIndex] = queryGetCurrentYearStatOfOpen.TicketRaised>
      </cfloop>

      <cfreturn arrayStat />      
    </cffunction>

    <cffunction access="private" output="false" returnformat="JSON" returntype="array" name="GetCurrentYearStatsOfFixed" hint="This function returns an array of inde months and number of reports closed counts for chart." >
      <cfquery name="queryGetCurrentYearStatOfFixed">
        SELECT DATEPART(MONTH, [DateCommented]) AS [MonthIndex], COUNT(*) AS [FixedCount]
        FROM [REPORT_COMMENTS] RC
        WHERE [IsActivity] = 1
        AND [Comment] LIKE '%has closed this report.'
        GROUP BY DATEPART(MONTH, [DateCommented]), DATEPART(YEAR, [DateCommented])
      </cfquery>

      <cfset arrayStat = ArrayNew(1)>
      <cfloop from="1" to="12" index="index">
        <cfset arrayAppend(arrayStat, 0)>
      </cfloop>

      <cfloop query="queryGetCurrentYearStatofFixed"> 
        <cfset arrayStat[queryGetCurrentYearStatofFixed.MonthIndex] = queryGetCurrentYearStatofFixed.FixedCount>
      </cfloop>

      <cfreturn arrayStat />    
      
    </cffunction>

    <cffunction access="remote" output="false" returnformat="JSON" returntype="array" name="GetAllStatsZipped">

      <cfset currentYearOpenStat = GetCurrentYearStatsOfOpen()>
      <cfset currentYearFixedStat = GetCurrentYearStatsOfFixed()>
      <cfset googleChartData = ArrayNew(2)>
      
      <cfloop from="1" to="12" index="index">
        <cfset ArrayAppend(googleChartData, [])>
        <cfset ArrayAppend(googleChartData[index], GetMonthNameFromIndex(int(index)))>
        <cfset ArrayAppend(googleChartData[index], currentYearOpenStat[index])>
        <cfset ArrayAppend(googleChartData[index], currentYearFixedStat[index])>
      </cfloop>

      <cfreturn googleChartData/>
    </cffunction>

    <cffunction access="private" output="false" returntype="string" name="GetMonthNameFromIndex">
      <cfargument type="numeric" required="true" name="monthIndex">
      <cfset monthArray = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']>
      <cfif arguments.monthIndex LTE 12>
        <cfreturn monthArray[arguments.monthIndex]>
      </cfif>
    </cffunction>
    
    
  </cfcomponent> 