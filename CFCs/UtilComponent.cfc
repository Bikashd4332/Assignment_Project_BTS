<cfcomponent displayname="UtilComponent" hint="This Component Provides fetches some of the view data from database.">


	<cffunction name="IsEmailValid" displayname="isEmailValid" description="This function checks if there's any other account related to the email" hint="This function checks if there's any other account related to the email" access="remote" output="false" returnFormat="JSON" returntype="struct">
		<cfargument name="emailId" displayName="emailId" type="string" hint="This is the email id of which to test to validity." required="true" />
		<cfquery name="resultSet">
			SELECT COUNT(*) AS AVAILABLE FROM [Person] WHERE [EmailId] = <cfqueryparam value="#arguments.emailId#" cfsqltype="cf_sql_varchar" maxlength="50" null="false">
		</cfquery>
		<cfset returnValue = StructNew()>
		<cfloop query="#resultSet#" >
			<cfif resultSet.AVAILABLE GTE 1>
				<cfset returnValue['feedback'] = "This Email is already registered." />
				<cfset returnValue['valid'] = false>
			<cfelse>
				<cfset returnValue['feedback'] = "This Email is valid." />
				<cfset returnValue['valid'] = true>
			</cfif>
		</cfloop>
		<cfreturn returnValue />
	</cffunction>


	<cffunction access="remote" returnFormat="JSON" returntype="boolean" displayName="Signing Up User" name="SignAdminUp" output="false" hint="This function signs up users by adding them in the database.">
		<cfargument name="firstName" required="true" string="string" hint="The firstname of the registring user.">
		<cfargument name="middleNme" required="false" type="string" hint="The midle of the registering user.">
		<cfargument name="lastName" required="true" type="string" hint="The surname of the registering user.">
		<cfargument name="contactNumber" required="true" type="numeric" hint="The contact number of the registerging user.">
		<cfargument name="emailId" required="true" type="string" hint="The email of the registering user.">
		<cfargument name="titleId" required="false" type="numeric" default="1" hint="The title of the user who will be signed if not provided will default to '1'.">
		<cfargument name="password" required="true" type="string" hint="The password of the registering user.">
		<cfargument name="profileImage" default="" required="false" type="any" displayname="The profile picture of the admin whoever is signing up.">
		<cfargument name="projectName" required="true" type="string" hint="The name or title of the project which will be created along with the user.">
		<cfargument name="projectDescription" required="true" type="string" hint="The description of the project.">
		<cfargument name="profileImageName" default="" required="false" type="string" hint="The file name of the profile ">
		<cfset projectId = addProject('#arguments.projectName#', '#arguments.projectDescription#')>
		<cfset imagePath = ""/>
		<cfif arguments.profileImage NEQ ''>
			<cfset imagePath =  uploadProfileImage('#profileImage#', '#profileImageName#') />
		</cfif>
		<cfset response = StructNew()>
		<cftry>
			<cfquery name="queryAddAdmin">

				INSERT INTO [PERSON] (FirstName, MiddleName, LastName, ContactNumber, EmailID, ProjectID, TitleID, Password, ProfileImage) VALUES
					(
						<cfqueryparam cfsqltype="cf_sql_varchar" null="false" maxlength="30" value="#arguments.firstName#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" null="true" maxlength="30" value="#arguments.middleName#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" null="false" maxlength="30" value="#arguments.lastName#">,
						<cfqueryparam cfsqltype="cf_sql_bigint" null="false" value="#arguments.contactNumber#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" null="false" maxlength="50" value="#arguments.emailId#">,
						<cfqueryparam cfsqltype="cf_sql_integer" null="false" value="#variables.projectId#">,
						<cfqueryparam cfsqltype="cf_sql_integer" null="false" value="#arguments.titleId#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" null="false" value="#hash(arguments.password)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" null="false" value="#variables.imagePath#">
					)
			</cfquery>
			<cfreturn true />
			<cfcatch type="database">
				<cfreturn false />
			</cfcatch>
		</cftry>
	</cffunction>


	<cffunction access="public" returnType="numeric" outptu="false" name="addProject" displayName="This function adds project into database.">
		<cfargument name="projectName" required="true" type="string" hint="The name of the project.">
		<cfargument name="projectDesc" required="true" type="string" hint="The description of the project.">
		<cfquery result="queryAddProject">
			INSERT INTO [PROJECT] ([Name], [Desc]) VALUES
			(
				<cfqueryparam cfsqltype="cf_sql_varchar" maxlength="50" null="false" value="#arguments.projectName#">,
			 	<cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" null="false" value="#arguments.projectDesc#">
			)
		</cfquery>
		<!-- Returning the identity count -->
		<cfreturn queryAddProject['IDENTITYCOL'] />
	</cffunction>


	<cffunction access="remote" returnType="boolean" returnformat="JSON" name="LogUserIn" output="true" hint="This Function helps to sign in user." >
		<cfargument required="true" type="string" name="userEmail" hint="The user email which is uniquely per user.">
		<cfargument required="true" type="string" name="userPassword" hint="The user's password to authenticate.">
		<cfquery name="queryCheckUser" maxrows="1">
			SELECT [Password] FROM [PERSON] WHERE [EmailId] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userEmail#">
				AND [Password] = <cfqueryparam  cfsqltype="cf_sql_varchar" value="#hash(arguments.userPassword)#">
		</cfquery>
		<cfif queryCheckUser.RecordCount EQ 0 >
			<cfreturn false />
		</cfif>
		<cfset session.userEmail = '#arguments.userEmail#'>
		<cfreturn true />
	</cffunction>


	<cffunction access="remote" returnformat="JSON" returntype="boolean" name="LogUserOut" output="false" hint="This function helps to log out the currently logged in user." >
		<cfif session.userEmail NEQ ''>
			<cfset session.userEmail = ''>
			<cfreturn true />
		</cfif>
		<cfreturn false />
	</cffunction>


	<cffunction access="public" returnformat="plain" returnType="string" output="false" name="uploadProfileImage" hint="This Function helps to upload image files into temporary directory of the server.">
		<cfargument  name="imagePath" required="true" type="string" hint="The image to upload.">
		<cfargument name="imageName" required="false" type="string" hint="The name of image to set.">
		<cffile action="move" source="#imagePath#" destination="#ExpandPath('../assets/profile_image/')#" nameconflict="overwrite" >
		<cfif arguments.imageName NEQ ''>
			<cfset extension = ListLast('#imageName#', '.')>
			<cfset name = ListFirst("#arguments.imageName#", '.')>
			<cffile action="rename" source="#ExpandPath('../assets/profile_image')#\#getFileFromPath(arguments.imagePath)#" destination="#ExpandPath('../assets/profile_image')#\#name#.#extension#" >
			<cfreturn "#ExpandPath('../assets/profile_image/')#"&"#name#.#extension#" />
		</cfif>
		<cfreturn '#destinationToUpload#' & '#getFileFromPath(arguments.imagePath)#' />
	</cffunction>


	<cffunction access="remote" returnformat="plain" returnType="string" output="false" name="GetLoggedInPersonID" displayname="GetLoggedInPersonID" >
		<cfquery name="queryGetPersonId">
			SELECT [PersonID] FROM [PERSON] WHERE [EmailID] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.userEmail#">
		</cfquery>
		<cfloop query="queryGetPersonId" >
			<cfreturn "#PersonID#" />
		</cfloop>
	</cffunction>

	<cffunction  name="RelativeDate" returnType="string" access="public" output="false">
		<cfargument name="theDate" type="date">
		<cfset var x        = "" />
		<cfset var diff  = "" />
		<cfset var result   = "unknown" />
		<cfset var dateNow  = now() />
		<cfset var codes    = [ "yyyy", "m", "ww", "d", "h", "n", "s" ] />
		<cfset var names    = [ "year", "month", "week", "day", "hour", "minute", "second" ] />
		<cfif dateCompare(arguments.theDate, now()) gt 0>
			<!--- replace with other code to handle future dates ....--->
			<cfthrow message="Future date handling not implemented">
		</cfif>
		<!--- check each date period  ...--->
		<cfloop from="1" to="#arrayLen(codes)#" index="x">
			<cfset diff = abs( dateDiff(codes[x], arguments.theDate, dateNow) ) />
			<!--- this is the greatest date period --->
			<cfif diff gt 0 >
				<cfif diff  gt 1>
					<cfset result = "about "& diff &" "& names[x] &"s ago" />
				<cfelseif names[x] eq "hour">
					<cfset result = "about an "& names[x] &" ago" />
				<cfelse>
					<cfset result = "about a "& names[x] &" ago" />
				</cfif>
				<cfbreak>
			</cfif>
		</cfloop>
		<cfreturn result />
	</cffunction>
	
		


</cfcomponent>
