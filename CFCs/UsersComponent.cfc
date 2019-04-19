<!---
	--- ReportsComponent
	--- ----------------
	---
	--- This component defines all the functions for managing the page itself.
	---
	--- author: mindfire
	--- date:   4/10/19
	--->
<cfcomponent name="UsersComponent" displayname="UsersComponent" hint="This component defines all the functions for managing the page itself." accessors="true" output="false" persistent="false">

	<cfset this.reportComponentInstance = CreateObject("component",'ReportComponent')>

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
			<cfset ArrayAppend(user, "#userProfileImage['base64ProfileImage'] & ',' &userProfileImage['extension']#")>
			<cfset ArrayAppend(user, "#Name#")>
			<cfset ArrayAppend(user, "#EmailID#")>
			<cfset ArrayAppend(user, "#ContactNumber#")>
			<cfset ArrayAppend(user, "#TitleName#")>
			<cfset ArrayAppend(user, "#DateFormat(SignedUpDate, 'long')#")>
			<cfset ArrayAppend(userArray, user)>
		</cfloop>
		<cfreturn userArray>
	</cffunction>


	<cffunction access="remote" output="false" name="InviteUser" displayname="InviteUser" >
		<cfargument required="true" type="array" name="userEmailList" hint="This argument contains the list of user emails for adding into the project.">
		<cfargument required="false" default="" type="string" name="titleId" hint="This contains the title id of the user decided by admin.">
		<cfset utilComponentInstance = CreateObject('component', 'UtilComponent')>
		<cfset reportComponentInstance = CreateObject('component', 'ReportComponent')>
		<cfset projectId = utilComponentInstance.GetProjectIdOf()>
		<cfloop array="#arguments.userEmailList#" item="userEmail">
			<cfset uuidForUser = createUUID()>
			<cfquery name="queryInviteUser">
				INSERT INTO [INVITE_PERSON] ([EmailID], [UUID], [TitleID], [ProjectID])
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#userEmail#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#uuidForUser#">,
					<cfqueryparam cfsqltype="cf_sql_integer" null="true" value="#arguments.titleId#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#projectId#">
				)
			</cfquery>
			<cfset reportComponentInstance.SendEmailTo(userEmail, "http://[server-name]/setup_account.cfm?uuid=#uuidForUser#")>
		</cfloop>
	</cffunction>

	
	<cffunction access="remote" output="false" returnformat="JSON" returntype="array" name="FetchUserInvitationRecords" displayname="FetchUserInvitationRecords">
		<cfset arrayOfInvitations = ArrayNew(1)>
		<cfset utilComponentInstance = CreateObject('component', 'UtilComponent') >
		<cfquery name="queryGetInvitations">
				SELECT [EmailID], 
		   [UUID], 
		   [DateInvited], 
		   CASE [isValid] WHEN  0 THEN 'Not Valid' ELSE 'Valid' END AS [ValidityStatus],
		   PT.[Name]
			FROM [INVITE_PERSON] IP
			INNER JOIN [PERSON_TITLE] PT
			ON PT.[TitleID] = IP.[TitleID]
			WHERE IP.[ProjectID] = <cfqueryparam value="#utilComponentInstance.GetProjectIdOf()#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfloop query="queryGetinvitations">
			<cfset invitationRecord = ArrayNew(1)>
			<cfset ArrayAppend(invitationRecord, EmailID)>
			<cfset ArrayAppend(invitationRecord, UUID)>
			<cfset ArrayAppend(invitationRecord, DateInvited)>
			<cfset ArrayAppend(invitationRecord, ValidityStatus)>
			<cfset ArrayAppend(invitationRecord, Name)>
			<cfset ArrayAppend(arrayOfInvitations, invitationRecord)>
		</cfloop>
		<cfreturn arrayOfInvitations />
	</cffunction>


</cfcomponent>
