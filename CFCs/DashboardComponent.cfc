<cfcomponent displayname="DashboardComponent" hint="This component defines all the function needed for the dashboard to work.">

	<!-- GetProfileImage and GetUserName seems to be an utility function which should be open to all the function for use -->

	<cffunction access="remote" returnformat="JSON" returntype="string" output="false" name="GetProfileImage" displayname="GetProfileImage" hint="This function gets the profile image of a user." >
		<cfargument name="width" type="numeric" required="false" hint="This holds the width of the returned image.">
		<cfargument name="height" type="numeric" required="false" hint="This holds the height of the returned image.">
		<cfargument name="personId" type="string" required="false" default="" hint="This argument contains the id of the person.">
		<cfset response = StructNew()>
		<cfif arguments.personId NEQ ''>
			<cfquery name="queryGetProfileImagePath">
				SELECT [ProfileImage] FROM [PERSON] WHERE [PersonID] = <cfqueryparam cfsqltype="cf_sql_varchar" null="false" value="#arguments.personId#">
			</cfquery>
		<cfelse>
			<cfquery name="queryGetProfileImagePath">
				SELECT [ProfileImage] FROM [PERSON] WHERE [EmailID] = <cfqueryparam cfsqltype="cf_sql_varchar" null="false" value="#session.userEmail#">
			</cfquery>
		</cfif>
		<cfloop query="queryGetProfileImagePath" >
			<cfif ProfileImage NEQ ''>
				<cfset response['isDefaultProfileImage'] = false >
				<cfif isDefined("arguments.width") AND isDefined("arguments.height")>
						<cfset processedImageFileName = "#ExpandPath('../assets/profile_image_processed/#ListFirst(GetFileFromPath(ProfileImage), '.')&arguments.width&'x'&arguments.height&'.'&ListLast(GetFileFromPath(ProfileImage), '.')#')#">
						<cfif FileExists(processedImageFileName)>
							<cfset profileImageContent = FileReadBinary(processedImageFileName)>
						<cfelse>
							<cfset personProfileImage = imageNew("#ProfileImage#")>
							<cfset imageResize(personProfileImage,arguments.width,arguments.height, "mediumQuality", "1")>
							<cffile action="write" file="#processedImageFileName#" output="#ImageGetBlob(personProfileImage)#" >
							<cfset profileImageContent = imageGetBlob("#personProfileImage#")>
						</cfif>
				</cfif>
				<cfset response['base64ProfileImage'] = '#ToBase64(profileImageContent)#'>
				<cfset response['extension'] = ListLast('#GetFileFromPath(ProfileImage)#', '.')>
			<cfelse>
				<cfset response['isDefaultProfileImage'] = true >
			</cfif>
		</cfloop>
		<cfreturn SerializeJSON('#response#')>
	</cffunction>


	<cffunction access="remote"  returnType="struct" returnFormat="JSON" name="GetUserName"  output="false"  hint="This function retrieves the name of the logged in user.">
		<cfargument required="false" name="personId" type="numeric" hint="If value provided in argument it gives the specified users name.">
		<cfset response = StructNew()>
		<cfif NOT isDefined('arguments.personId')>
			<cfquery name="queryGetUserName">
				SELECT CONCAT([FirstName], ' ', [LastName]) AS Name FROM [PERSON] WHERE [EmailId] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.userEmail#">
			</cfquery>
		<cfelse>
			<cfquery name="queryGetUserName">
				SELECT CONCAT([FirstName], ' ', [LastName]) AS Name FROM [PERSON] WHERE [PersonId] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.personId#">
			</cfquery>
		</cfif>
		<cfloop query="queryGetUserName">
			<cfset response['userName'] = "#Name#">
		</cfloop>
		<cfreturn response />
	</cffunction>


	<cffunction access="remote" returnType="array" returnFormat="JSON" name="GetAllAssignedReports" output="false" hint="This function retrieves all the reports which are assigned to the currently logged in user.">
		<cfset utilComponentInstance = CreateObject('component', 'UtilComponent')>
		<cfquery name="queryGetAllAssignedReports">
		SELECT RI.[ReportID], RT.[Title] AS Type, RI.[Priority] , RI.[ReportTitle], RI.[Description] FROM
				[REPORT_INFO] AS RI
				INNER JOIN
				[REPORT_TYPE] AS RT
				ON RI.ReportTypeID =  RT.ReportTypeID
				INNER JOIN
				[REPORT_STATUS_TYPE] AS RST
				ON RI.StatusID = RST.StatusID
				WHERE [Assignee] = <cfqueryparam cfsqltype="cf_sql_integer" value="#utilComponentInstance.GetLoggedInPersonID()#">;
		</cfquery>
		<cfset responseArray = ArrayNew(1)>
		<cfif queryGetAllAssignedReports.RecordCount GT 0>
			<cfloop query="queryGetAllAssignedReports">
				<cfset ArrayAppend(responseArray, '{ "id": "#ReportID#", "title": "#ReportTitle#", "description": "#Description#", "type": "#Type#", "priority": "#Priority#"}')>
			</cfloop>
		</cfif>
		<cfreturn responseArray />
	</cffunction>


	<cffunction access="remote" returnType="array" returnFormat="JSON" name="GetAllWatchingReports" output="false" hint="This function retrieves all the reports which are being watched by the currently logged in user.">
		<cfset utilObjectInstance = CreateObject('component', 'UtilComponent')>
		<cfquery name="queryGetAllWatchingReports">

		SELECT RI.[ReportID], RT.[Title] AS Type, RI.[Priority] , RI.[ReportTitle], RI.[Description] FROM
				[REPORT_INFO] AS RI
				INNER JOIN
				[REPORT_TYPE] AS RT
				ON RI.ReportTypeID =  RT.ReportTypeID
				INNER JOIN
				[REPORT_STATUS_TYPE] AS RST
				ON RI.StatusID = RST.StatusID
				WHERE RI.[ReportID] IN (SELECT [ReportID] FROM [WATCHER] WHERE [PersonID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#utilObjectInstance.GetLoggedInPersonID()#"> );
		</cfquery>
		<cfset responseArray = ArrayNew(1)>
		<cfif queryGetAllWatchingReports.RecordCount GT 0>
			<cfloop query="queryGetAllWatchingReports">
				<cfset ArrayAppend(responseArray, '{ "id": "#ReportID#", "title": "#ReportTitle#", "description": "#Description#", "type": "#Type#", "priority": "#Priority#"}')>
			</cfloop>
		</cfif>
		<cfreturn responseArray />
	</cffunction>


	<cffunction access="remote" returnType="numeric" returnformat="JSON" output="false" name="getDashBoardCounts" displayname="getDashBoardCounters" hint="This function is for fetching all the required counters for populating dashboard.">
		<cfargument type="string" required="true" name="counterOf">
		<cfset utilObjectInstance = CreateObject('component', 'UtilComponent')>
		<cfif counterOf EQ 'assigned'>
			<cfquery name="queryGetAssignedReportCount">
		 			SELECT COUNT(*) AS AssignedReports FROM
		 			[REPORT_INFO]
		 			WHERE
		 			[Assignee] = <cfqueryparam cfsqltype="cf_sql_integer" value="#utilObjectInstance.GetLoggedInPersonId()#">
		 	</cfquery>
			<cfloop query = "queryGetAssignedReportCount">
				<cfset response = "#AssignedReports#">
			</cfloop>
			<cfreturn response />
		<cfelse>
			<cfquery name="queryGetRerportCount">
				SELECT COUNT(*) AS ReportCounts
					FROM
					[REPORT_INFO] RI
					INNER JOIN
					[PERSON] P
					ON
					RI.PersonID = P.PersonID
					WHERE RI.[StatusID] = (SELECT [StatusID] FROM [REPORT_STATUS_TYPE] WHERE [Name] = UPPER(<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.counterOf#">))
					AND
					P.[ProjectID] = ( SELECT [ProjectId] FROM [PERSON] WHERE [PersonID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#utilObjectInstance.GetLoggedInPersonID()#"> )
			</cfquery>
			<cfloop query = "queryGetRerportCount">
				<cfset response = "#ReportCounts#">
			</cfloop>
			<cfreturn response />
		</cfif>
	</cffunction>


	<cffunction access="remote" output="false" returnType="numeric" returnformat="JSON" name="GetPercentageOf" displayName="GetPercentageOf" hint="This function gets the percentage of the specified report.">
		<cfargument type="string" requried="true" name="reportState" hint="This is the argument containing the state of reports of which we need the percentage of.">
		<cfset utilComponentInstance = CreateObject("component",'UtilComponent')>
		<cfquery name="queryGetCountOfAllReport">
			SELECT COUNT(*) AS ReportCount
			FROM [REPORT_INFO] RI
			INNER JOIN
			[PERSON] P ON
			RI.[PersonID] = RI.[PersonID]
			WHERE P.[ProjectID] = (SELECT [ProjectID] FROM [PERSON] WHERE [PersonID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#utilComponentInstance.GetLoggedInPersonID()#">)
		</cfquery>
		<cfset specifiedReportStateCount = Val('#getDashBoardCounts(arguments.reportState)#')>
		<cfloop query = "queryGetCountOfAllReport">
			<cfset allReportCount = Val('#ReportCount#')>
		</cfloop>
		<cfif allReportCount NEQ 0>
			<cfreturn Round((specifiedReportStateCount / allReportCount) * 100) >
		<cfelse>
			<cfreturn 0>
		</cfif>
	</cffunction>
</cfcomponent>
