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
	<cfset this.wschannels = [{name="report-file-upload"}, {name="report-file-delete"}, {name="report-status-update"}, {name="report-comment-post"}, {name="report-type-priority-change"}]>

	<cffunction name="OnSessionStart" displayname="OnSessionStart" access="public" hint="Sets the required session values">
		<cfif not isDefined('session.userEmail')>
			<cfset session.userEmail = ''>
		</cfif>
	</cffunction>


	<cffunction name="OnRequestStart" returntype="boolean" displayname="OnRequestStart" access="public" >
		<cfargument name="targetPage" required="true">
		<!--- Cleaning the key value of the url for calling remote function with arrays --->
		<cfloop collection="#url#" item="LOCAL.key">
			<cfif find("[]", LOCAL.key)>
				<cfset LOCAL.cleanKey = replace(LOCAL.key, "[]", "", "one") >
				<cfset url[LOCAL.cleanKey] = ListToArray(url[LOCAL.key]) >
				<cfset StructDelete(url, "LOCAL.key")>
			</cfif>
		</cfloop>
		<cfreturn true />
	</cffunction>

<!--- To check if any ajax request is performed when the session is timed-out. --->
	<cffunction  output="false" displayname="OnCFCRequest" name="OnCFCRequest" hint="Called whenever a CFC method is requested">
		<cfargument type="string" name="cfcname"> 
		<cfargument type="string" name="method"> 
		<cfargument type="struct" name="args"> 

		<cfif session.userEmail EQ '' AND arguments.method NEQ 'LogUserIn' AND arguments.cfcname NEQ 'UtilComponent.cfc'>
			<cflocation url="../cfm/login.cfm" addtoken="false" /> 
		</cfif>

		<cfinvoke 
		component = "#arguments.cfcname#" 
		method = "#arguments.method#" 
		returnVariable = "result" 
		argumentCollection = "#arguments.args#" /> 
		<cfreturn result/>
	</cffunction>

	<cffunction name="OnRequest" returntype="void" displayname="OnRequest" hint="Called whenever a requested." access="public" output="true">
		<cfargument name="targetPage" displayName="targetPage" type="string" hint="The target page which will be opened" required="true" />
		<cfinclude template="#arguments.targetPage#">
	</cffunction>


</cfcomponent>
