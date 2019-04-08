<!---
	--- Application
	--- -----------
	---
	--- This is the default configuration for this project.
	---
	--- author: mindfire
	--- date:   3/14/19
	--->
<cfcomponent displayname="My Application cfc" hint="This is the default configuration for this project." accessors="true" output="false">

	<cfset this.name = "Bug Trakcing System" >
	<cfset this.sessionManagement = true >
	<cfset this.datasource = "MySqlServerSource">
	<cfset this.wschannels = [{name="report-file-upload"}, {name="report-file-delete"}, {name="report-status-update"}, {name="report-comment-post"}]>

	<cffunction name="OnRequestStart" returntype="boolean" displayname="OnRequestStart" access="public" >
		<cfargument name="targetPage" required="true">
		<cfreturn true />
	</cffunction>


	<cffunction name="OnSessionStart" displayname="OnSessionStart" access="public" hint="Sets the required session values">
		<cfif not isDefined('session.userEmail')>
			<cfset session.userEmail = ''>
		</cfif>
	</cffunction>


	<cffunction name="OnRequest" returntype="void" displayname="OnRequest" hint="Called when ever a requested." access="public" output="true">
		<cfargument name="targetPage" displayName="targetPage" type="string" hint="The target page which will be opened" required="true" />
		<cfset validPagesForLoggedInUsers = ["overview.cfm", "report.cfm"]>
		<cfset validPagesForNonLoggedInUsers = ["home.cfm", "login.cfm", "signup.cfm", "index.cfm"]>
		<cfif session.userEmail NEQ ''>
			<cfif ArrayContains(variables.validPagesForLoggedInUsers, getFileFromPath('#targetPage#'))>
				<cfinclude template="#arguments.targetPage#" >
			<cfelse>
				<cfif  GetFileFromPath('#arguments.targetPage#') EQ 'index.cfm'>
					<cflocation url="cfm/overview.cfm" addToken="false">
				<cfelse>
					<cflocation url="overview.cfm" addToken="false">
				</cfif>
			</cfif>
		<cfelse>
			<cfif ArrayContains(variables.validPagesForNonLoggedInUsers, getFileFromPath('#targetPage#'))>
				<cfinclude template="#targetPage#">
			<cfelse>
				<cflocation url="login.cfm" addtoken="false">
			</cfif>
		</cfif>
		<cfreturn />
	</cffunction>


</cfcomponent>
