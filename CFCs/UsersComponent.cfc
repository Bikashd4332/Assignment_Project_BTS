<!---
	--- ReportsComponent
	--- ----------------
	---
	--- This component defines all the functions for managing the page itself.
	---
	--- author: mindfire
	--- date:   4/10/19
	--->
<cfcomponent name="UsersComponent" displayname="UsersComponent" hint="This component defines all the functions for managing the page itself." accessors="true" output="true" persistent="false">


	<cffunction access="remote" output="true" returnformat="JSON" returntype="array" name="fetchUserRecords" displayname="fetchUserRecords" hint="This function helps to fetch the user records for paginating.">
		<cfset UtilComponentInstance = CreateObject('component', 'UtilComponent')>
		<cfset loggedInUserProjectId = UtilComponentInstance.GetProjectIdOf()>
		<cfset DashBoardComponentInstance = CreateObject('component', 'DashboardComponent')>
		<cfset userArray = ArrayNew(1)>
		<cfquery name="queryGetUserRecords">
		SELECT [PersonID]
			,CONCAT(
			  	[FirstName], ' '
		      	,[MiddleName], ' '
		      	,[LastName]
			 ) AS [Name]
		      ,[ContactNumber]
		      ,[EmailID]
		      ,[ProjectID]
		      ,PT.[Name] AS [TitleName]
		      ,[SignedUpDate]
		  FROM [PERSON] P
		  INNER JOIN [PERSON_TITLE] PT
		  ON P.[TitleID] = PT.[TitleID]
		  WHERE [ProjectID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#loggedInUserProjectId#">
		</cfquery>
		<cfloop query="queryGetUserRecords">
			<cfset user = ArrayNew(1)>
			<cfset userProfileImage = DeserializeJSON(DashBoardComponentInstance.GetProfileImage(40, 40, PersonID))>
			<cfset ArrayAppend(user, "#PersonID#")>
			<cfset ArrayAppend(user, "#userProfileImage['base64ProfileImage']#")>
			<cfset ArrayAppend(user, "#Name#")>
			<cfset ArrayAppend(user, "#EmailID#")>
			<cfset ArrayAppend(user, "#ContactNumber#")>
			<cfset ArrayAppend(user, "#TitleName#")>
			<cfset ArrayAppend(user, "#DateFormat(SignedUpDate, 'long')#")>
			<cfset ListAppend(user[2], "#userProfileImage['extension']#", ",")>
			<cfset ArrayAppend(userArray, user)>
		</cfloop>
		<cfreturn userArray>
	</cffunction>


	<cffunction access="remote" output="false" returntype="boolean" returnformat="JSON" name="SendInvitationToEmails" displayname="SendInvitationToEmails">
		<cfargument type="array" name="userEmails" required="true">
		<cfset ReportComponentInstance = CreateObject('component', 'ReportComponent')>
		<cfloop array = "#userEmails#" item="userEmail">
			<cfset ReportComponentInstance.SendEmailTo('#userEmail#')>
		</cfloop>
	</cffunction>
</cfcomponent>
