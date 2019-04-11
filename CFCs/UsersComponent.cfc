<!---
	--- ReportsComponent
	--- ----------------
	---
	--- This component defines all the functions for managing the page itself.
	---
	--- author: mindfire
	--- date:   4/10/19
	--->
<cfcomponent name="ReportsComponent" displayname="ReportsComponent" hint="This component defines all the functions for managing the page itself." accessors="true" output="true" persistent="false">


	<cffunction access="remote" output="true" returnformat="JSON" returntype="struct" name="fetchUserRecords" displayname="fetchUserRecords" hint="This function helps to fetch the user records for paginating.">
		<cfargument required="true" name="recordCount" hint="The number of records to return in one page.">
		<cfargument required="true" name="pageNumber" hint="The offset of page for returning records.">
		<cfset UtilComponentInstance = CreateObject('component', 'UtilComponent')>
		<cfset loggedInUserProjectId = UtilComponentInstance.GetProjectIdOf()>
		<cfset DashBoardComponentInstance = CreateObject('component', 'DashboardComponent')>
		<cfset response = StructNew()>
		<cfquery name="queryGetUserRecords">
			EXEC [sp_paginateUser] @pageView = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.recordCount#">, @pageNumber = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageNumber#">, @projectId = <cfqueryparam cfsqltype="cf_sql_integer" value="#loggedInUserProjectId#">
		</cfquery>
		<cfloop query="queryGetUserRecords">
			<cfset userProfileImage = DeserializeJSON(DashBoardComponentInstance.GetProfileImage(40, 40, PersonID))>
			<cfset response['userName'] = "#Name#">
			<cfset response['EmailId'] = "#EmailID#">
			<cfset response['Title'] = "#TitleName#">
			<cfset response['profileImage'] = "#userProfileImage['base64ProfileImage']#">
		</cfloop>
		<cfreturn response>
	</cffunction>


</cfcomponent>
