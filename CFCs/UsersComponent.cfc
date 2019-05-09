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

	<cfset this.UtilComponentInstance = CreateObject('component', 'UtilComponent')>
	<cfset this.DashBoardComponentInstance = CreateObject('component', 'DashboardComponent')>	
	
	<cffunction access="remote" output="true" returnformat="JSON" returntype="array" name="fetchUserRecords" displayname="fetchUserRecords" hint="This function helps to fetch the user records for paginating.">
		
		<cfset local.loggedInUserProjectId = this.UtilComponentInstance.GetProjectIdOf()>
		<cfset local.userArray = ArrayNew(1)>

		<cfquery name="local.queryGetUserRecords">
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
		  WHERE [ProjectID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.loggedInUserProjectId#">
		</cfquery>

		<cfloop query="local.queryGetUserRecords">
			<cfset local.user = ArrayNew(1)>
			<cfset local.userProfileImage = DeserializeJSON(this.DashBoardComponentInstance.GetProfileImage(40, 40, PersonID))>
			<cfset ArrayAppend(local.user, "#PersonID#")>
			<cfset ArrayAppend(local.user, "#userProfileImage['base64ProfileImage'] & ',' &userProfileImage['extension']#")>
			<cfset ArrayAppend(local.user, "#Name#")>
			<cfset ArrayAppend(local.user, "#EmailID#")>
			<cfset ArrayAppend(local.user, "#ContactNumber#")>
			<cfset ArrayAppend(local.user, "#TitleName#")>
			<cfset ArrayAppend(local.user, "#DateFormat(SignedUpDate, 'long')#")>
			<cfset ArrayAppend(local.userArray, user)>
		</cfloop>

		<cfreturn local.userArray>
	</cffunction>


	<cffunction access="remote" output="false" returntype="boolean" returnformat="JSON"  name="InviteUser" displayname="InviteUser" >
		<cfargument required="true" type="array" name="userEmailList" hint="This argument contains the list of user emails for adding into the project.">
		<cfargument required="false" default="" type="string" name="titleId" hint="This contains the title id of the user decided by admin.">
		<cfset local.reportComponentInstance = CreateObject('component', 'ReportComponent')>
		<cfset projectId = this.utilComponentInstance.GetProjectIdOf()>
		<cfloop array="#arguments.userEmailList#" item="local.userEmail">
			<cfset local.uuidForUser = createUUID()>
			<cfquery name="local.queryInviteUser">
				INSERT INTO [INVITE_PERSON] ([EmailID], [UUID], [TitleID], [ProjectID])
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.userEmail#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.uuidForUser#">,
					<cfqueryparam cfsqltype="cf_sql_integer" null="true" value="#arguments.titleId#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#local.projectId#">
				)
			</cfquery>
			<cfset local.reportComponentInstance.SendEmailTo(local.userEmail, "http://[server-name]/setup_account.cfm?uuid=#local.uuidForUser#")>
		</cfloop>
		<cfreturn true />
	</cffunction>

	
	<cffunction access="remote" output="false" returnformat="JSON" returntype="array" name="FetchUserInvitationRecords" displayname="FetchUserInvitationRecords">
		<cfset local.arrayOfInvitations = ArrayNew(1)>
		<cfquery name="local.queryGetInvitations">
			 SELECT [EmailID], 
		   [UUID], 
		   [DateInvited], 
		   CASE [isValid] WHEN  0 THEN 'Not Valid' ELSE 'Valid' END AS [ValidityStatus],
		   CASE WHEN IP.[TitleID] IS NULL THEN 'Unassigned' ELSE PT.[Name] END AS [Name]
			FROM [INVITE_PERSON] IP
			LEFT JOIN [PERSON_TITLE] PT
			ON PT.[TitleID] = IP.[TitleID]
			WHERE IP.[ProjectID] = <cfqueryparam value="#this.utilComponentInstance.GetProjectIdOf()#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfloop query="local.queryGetinvitations">
			<cfset local.invitationRecord = ArrayNew(1)>
			<cfset ArrayAppend(local.invitationRecord, EmailID)>
			<cfset ArrayAppend(local.invitationRecord, UUID)>
			<cfset ArrayAppend(local.invitationRecord, DateInvited)>
			<cfset ArrayAppend(local.invitationRecord, ValidityStatus)>
			<cfset ArrayAppend(local.invitationRecord, Name)>
			<cfset ArrayAppend(local.arrayOfInvitations, local.invitationRecord)>
		</cfloop>
		<cfreturn local.arrayOfInvitations />
	</cffunction>


</cfcomponent>
