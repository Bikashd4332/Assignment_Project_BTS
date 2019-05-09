<cfcomponent displayname="DashboardComponent" hint="This component defines all the function needed for the dashboard to work.">

	<!-- GetProfileImage and GetUserName seems to be an utility function which should be open to all the function for use -->

	<cffunction access="remote" returnformat="JSON" returntype="string" output="false" name="GetProfileImage" displayname="GetProfileImage" hint="This function gets the profile image of a user." >
		<cfargument name="width" type="numeric" required="false" hint="This holds the width of the returned image.">
		<cfargument name="height" type="numeric" required="false" hint="This holds the height of the returned image.">
		<cfargument name="personId" type="string" required="false" default="" hint="This argument contains the id of the person.">
		<cfset local.response = StructNew()>
		
		<cfquery name="local.queryGetProfileImagePath" maxrows="1">
				SELECT [ProfileImage] 
				FROM [PERSON] 
			<cfif arguments.personId NEQ ''>
				WHERE [PersonID] = <cfqueryparam cfsqltype="cf_sql_varchar" null="false" value="#arguments.personId#">
			<cfelse>
				WHERE [EmailID] = <cfqueryparam cfsqltype="cf_sql_varchar" null="false" value="#session.userEmail#">
			</cfif>
		</cfquery>
		
		<cfif local.queryGetProfileImagePath.ProfileImage NEQ ''>
			
			<cfset local.profileImage = local.queryGetProfileImagePath.ProfileImage >
			<cfset local.response['isDefaultProfileImage'] = false >

			<cfif isDefined("arguments.width") AND isDefined("arguments.height")>
				<cfset local.processedImageFileName = "#ExpandPath('../assets/profile_image_processed/#ListFirst(GetFileFromPath(local.profileImage), '.')&arguments.width&'x'&arguments.height&'.'&ListLast(GetFileFromPath(local.profileImage), '.')#')#">
				<cfif FileExists(local.processedImageFileName)>
					<cfset local.profileImageContent = FileReadBinary(local.processedImageFileName)>
				<cfelse>
					<cfset local.personProfileImage = imageNew("#local.profileImage#")>
					<cfset imageResize(local.personProfileImage,arguments.width,arguments.height, "mediumQuality", "1")>
					<cffile action="write" file="#local.processedImageFileName#" output="#ImageGetBlob(local.personProfileImage)#" >
					<cfset local.profileImageContent = imageGetBlob("#local.personProfileImage#")>
				</cfif>
			</cfif>
			
			<cfset local.response['base64ProfileImage'] = '#ToBase64(local.profileImageContent)#'>
			<cfset local.response['extension'] = ListLast('#GetFileFromPath(local.profileImage)#', '.')>
		<cfelse>
			<cfset local.response['isDefaultProfileImage'] = true >
		</cfif>
		
		<cfreturn SerializeJSON('#local.response#')>
	</cffunction>


	<cffunction access="remote"  returnType="struct" returnFormat="JSON" name="GetUserName"  output="false"  hint="This function retrieves the name of the logged in user.">
		<cfargument required="false" name="personId" type="numeric" hint="If value provided in argument it gives the specified users name.">
		<cfset local.response = StructNew()>
		<cfquery name="local.queryGetUserName">
		SELECT CONCAT([FirstName], ' ', [LastName]) AS Name
		FROM [PERSON] 
		<cfif NOT isDefined('arguments.personId')>
			WHERE [EmailId] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.userEmail#">
		<cfelse>
			WHERE [PersonId] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.personId#">
		</cfif>
		</cfquery>
		<cfset local.response['userName'] = "#local.queryGetUserName.Name#">
		<cfreturn local.response />
	</cffunction>


	<cffunction access="remote" returnType="array" returnFormat="JSON" name="GetAllAssignedReports" output="false" hint="This function retrieves all the reports which are assigned to the currently logged in user.">
		<cfset local.utilComponentInstance = CreateObject('component', 'UtilComponent')>
		<cfquery name="local.queryGetAllAssignedReports">
		SELECT RI.[ReportID], RT.[Title] AS Type, RI.[Priority] , RI.[ReportTitle], RI.[Description] FROM
				[REPORT_INFO] AS RI
				INNER JOIN
				[REPORT_TYPE] AS RT
				ON RI.[ReportTypeID] =  RT.[ReportTypeID]
				INNER JOIN
				[REPORT_STATUS_TYPE] AS RST
				ON RI.[StatusID] = RST.[StatusID]
				WHERE [Assignee] = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.utilComponentInstance.GetLoggedInPersonID()#">;
		</cfquery>
		<cfset local.responseArray = ArrayNew(1)>
		<cfif local.queryGetAllAssignedReports.RecordCount GT 0>
			<cfloop query="local.queryGetAllAssignedReports">
				<cfset ArrayAppend(local.responseArray, '{ "id": "#ReportID#", "title": "#ReportTitle#", "description": "#Description#", "type": "#Type#", "priority": "#Priority#"}')>
			</cfloop>
		</cfif>
		<cfreturn local.responseArray />
	</cffunction>


	<cffunction access="remote" returnType="array" returnFormat="JSON" name="GetAllWatchingReports" output="false" hint="This function retrieves all the reports which are being watched by the currently logged in user.">
		<cfset local.utilObjectInstance = CreateObject('component', 'UtilComponent')>

		<cfquery name="local.queryGetAllWatchingReports">
		SELECT RI.[ReportID], RT.[Title] AS Type, RI.[Priority] , RI.[ReportTitle], RI.[Description] FROM
				[REPORT_INFO] AS RI
				INNER JOIN
				[REPORT_TYPE] AS RT
				ON RI.[ReportTypeID] =  RT.[ReportTypeID]
				INNER JOIN
				[REPORT_STATUS_TYPE] AS RST
				ON RI.[StatusID] = RST.[StatusID]
				WHERE RI.[ReportID] IN (SELECT [ReportID] FROM [WATCHER] WHERE [PersonID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#utilObjectInstance.GetLoggedInPersonID()#"> );
		</cfquery>
		<cfset local.responseArray = ArrayNew(1)>
		<cfif local.queryGetAllWatchingReports.recordCount GT 0>
			<cfloop query="local.queryGetAllWatchingReports">
				<cfset ArrayAppend(local.responseArray, '{ "id": "#ReportID#", "title": "#ReportTitle#", "description": "#Description#", "type": "#Type#", "priority": "#Priority#"}')>
			</cfloop>
		</cfif>
		<cfreturn local.responseArray />
	</cffunction>


	<cffunction access="remote" returnType="numeric" returnformat="JSON" output="false" name="getDashBoardCounts" displayname="getDashBoardCounters" hint="This function is for fetching all the required counters for populating dashboard.">
		<cfargument type="string" required="true" name="counterOf">
		<cfset local.utilObjectInstance = CreateObject('component', 'UtilComponent')>
		
		<cfif arguments.counterOf EQ 'assigned'>
			<cfquery name="local.queryGetAssignedReportCount">
		 			SELECT COUNT(*) AS AssignedReports 
					FROM [REPORT_INFO]
		 			WHERE [Assignee] = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.utilObjectInstance.GetLoggedInPersonId()#">
		 	</cfquery>			
			<cfreturn local.queryGetAssignedReportCount.AssignedReports />
		<cfelse>
			<cfquery name="local.queryGetRerportCount">
				SELECT COUNT(*) AS ReportCounts
				FROM [REPORT_INFO] RI
				INNER JOIN [PERSON] P
				ON RI.[PersonID] = P.[PersonID]
				INNER JOIN [REPORT_STATUS_TYPE] RST 
				ON RST.[StatusID] = RI.[StatusID]
				WHERE RST.[Name] = UPPER(<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.counterOf#">)
				AND P.[ProjectID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.utilObjectInstance.GetProjectIdOf()#">
			</cfquery>
			<cfreturn local.queryGetRerportCount.ReportCounts />
		</cfif>

	</cffunction>


	<cffunction access="remote" output="false" returnType="numeric" returnformat="JSON" name="GetPercentageOf" displayName="GetPercentageOf" hint="This function gets the percentage of the specified report.">
		<cfargument type="string" requried="true" name="reportState" hint="This is the argument containing the state of reports of which we need the percentage of.">
		<cfset local.utilComponentInstance = CreateObject("component",'UtilComponent')>
		
		<cfquery name="local.queryGetCountOfAllReport">
			SELECT COUNT(*) AS ReportCount
			FROM [REPORT_INFO] RI
			INNER JOIN [PERSON] P 
			ON RI.[PersonID] = P.[PersonID]
			WHERE P.[ProjectID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.utilComponentInstance.GetProjectIdOf()#">
		</cfquery>

		<cfset local.specifiedReportStateCount = Val('#getDashBoardCounts(arguments.reportState)#')>
		<cfset local.allReportCount = Val('#local.queryGetCountOfAllReport.ReportCount#')>

		<cfif local.allReportCount NEQ 0>
			<cfreturn Round((local.specifiedReportStateCount / local.allReportCount) * 100) >
		<cfelse>
			<cfreturn 0>
		</cfif>
	</cffunction>
</cfcomponent>
