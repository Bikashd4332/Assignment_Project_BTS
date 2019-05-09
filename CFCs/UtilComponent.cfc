<cfcomponent displayname="UtilComponent" hint="This Component Provides fetches some of the view data from database.">


	<cffunction name="IsEmailValid" displayname="isEmailValid" description="This function checks if there's any other account related to the email" hint="This function checks if there's any other account related to the email" access="remote" output="false" returnFormat="JSON" returntype="struct">
		<cfargument name="emailId" displayName="emailId" type="string" hint="This is the email id of which to test to validity." required="true" />
		<cfquery name="local.resultSet">
			SELECT COUNT(*) AS AVAILABLE 
			FROM [Person] 
			WHERE [EmailId] = <cfqueryparam value="#arguments.emailId#" cfsqltype="cf_sql_varchar" maxlength="50" null="false">
		</cfquery>
		<cfset local.returnValue = StructNew()>
		<cfif local.resultSet.AVAILABLE GTE 1>
			<cfset local.returnValue['feedback'] = "This Email is already registered." />
			<cfset local.returnValue['valid'] = false>
		<cfelse>
			<cfset local.returnValue['feedback'] = "This Email is valid." />
			<cfset local.returnValue['valid'] = true>
		</cfif>
		<cfreturn local.returnValue />
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
		<cfset local.projectId = addProject('#arguments.projectName#', '#arguments.projectDescription#')>
		<cfset local.imagePath = ""/>
		<cfif arguments.profileImage NEQ ''>
			<cfset local.imagePath =  uploadProfileImage('#local.profileImage#', '#arguments.profileImageName#') />
		</cfif>
		<cftry>
			<cfquery name="local.queryAddAdmin">

				INSERT INTO [PERSON] (FirstName, MiddleName, LastName, ContactNumber, EmailID, ProjectID, TitleID, Password, ProfileImage) VALUES
					(
						<cfqueryparam cfsqltype="cf_sql_varchar" null="false" maxlength="30" value="#arguments.firstName#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" null="true" maxlength="30" value="#arguments.middleName#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" null="false" maxlength="30" value="#arguments.lastName#">,
						<cfqueryparam cfsqltype="cf_sql_bigint" null="false" value="#arguments.contactNumber#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" null="false" maxlength="50" value="#arguments.emailId#">,
						<cfqueryparam cfsqltype="cf_sql_integer" null="false" value="#local.projectId#">,
						<cfqueryparam cfsqltype="cf_sql_integer" null="false" value="#arguments.titleId#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" null="false" value="#hash(arguments.password)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" null="false" value="#local.imagePath#">
					)
			</cfquery>
			<cfreturn true />
			<cfcatch type="database">
				<cfreturn false />
			</cfcatch>
		</cftry>
	</cffunction>


	<cffunction access="public" returnType="numeric" output="false" name="addProject" displayName="This function adds project into database.">
		<cfargument name="projectName" required="true" type="string" hint="The name of the project.">
		<cfargument name="projectDesc" required="true" type="string" hint="The description of the project.">
		<cfquery result="local.queryAddProject">
			INSERT INTO [PROJECT] ([Name], [Desc]) VALUES
			(
				<cfqueryparam cfsqltype="cf_sql_varchar" maxlength="50" null="false" value="#arguments.projectName#">,
			 	<cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" null="false" value="#arguments.projectDesc#">
			)
		</cfquery>
		<!-- Returning the identity count -->
		<cfreturn local.queryAddProject['IDENTITYCOL'] />
	</cffunction>


	<cffunction access="remote" returnType="boolean" returnformat="JSON" name="LogUserIn" output="true" hint="This Function helps to sign in user." >
		<cfargument required="true" type="string" name="userEmail" hint="The user email which is uniquely per user.">
		<cfargument required="true" type="string" name="userPassword" hint="The user's password to authenticate.">
		<cfquery name="local.queryCheckUser" maxrows="1">
			SELECT [Password] 
			FROM [PERSON] 
			WHERE [EmailId] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userEmail#">
			AND [Password] = <cfqueryparam  cfsqltype="cf_sql_varchar" value="#hash(arguments.userPassword)#">
		</cfquery>
		<cfif local.queryCheckUser.RecordCount EQ 0 >
			<cfreturn false />
		<cfelse>
			<cfset session.userEmail = '#arguments.userEmail#'>
			<cfreturn true />
		</cfif>
	</cffunction>


	<cffunction access="remote" returnformat="JSON" returntype="boolean" name="LogUserOut" output="false" hint="This function helps to log out the currently logged in user." >
		<cfif session.userEmail NEQ ''>
			<cfset session.userEmail = ''>
			<cfreturn true />
		</cfif>
		<cfreturn false />
	</cffunction>


	<cffunction access="public" returnformat="plain" returnType="any" output="false" name="uploadProfileImage" hint="This Function helps to upload image files into temporary directory of the server.">
		<cfargument  name="imagePath" required="true" type="string" hint="The image to upload.">
		<cfargument name="imageName" required="false" type="string" hint="The name of image to set.">
		<cftry>
			<cffile action="move" source="#imagePath#" destination="#ExpandPath('../assets/profile_image/')#" nameconflict="overwrite" >

			<cfif arguments.imageName NEQ ''>
				<cfset local.extension = ListLast('#imageName#', '.')>
				<cfset local.name = ListFirst("#arguments.imageName#", '.')>
				<cffile action="rename" source="#ExpandPath('../assets/profile_image')#\#getFileFromPath(arguments.imagePath)#" destination="#ExpandPath('../assets/profile_image')#\#name#.#extension#" >
				<cfreturn "#ExpandPath('../assets/profile_image/')#"&"#name#.#extension#" />
			</cfif>
			<cfreturn '#ExpandPath('../assets/profile_image/')#' & '#getFileFromPath(arguments.imagePath)#' />
			
			<cfcatch type="any">
				<cfreturn false />
			</cfcatch>
			
		</cftry>
	</cffunction>


	<cffunction access="remote" returnformat="plain" returnType="numeric" output="false" name="GetLoggedInPersonID" displayname="GetLoggedInPersonID" >
		<cfquery name="local.queryGetPersonId" maxrows="1">
			SELECT [PersonID] 
			FROM [PERSON] 
			WHERE [EmailID] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.userEmail#">
		</cfquery>
		<cfreturn local.queryGetPersonId.PersonID />
	</cffunction>


	<cffunction  name="RelativeDate" returnType="string" access="public" output="false">
		<cfargument name="theDate" type="date">
		<cfset local.x        = "" />
		<cfset local.diff  	  = "" />
		<cfset local.result   = "unknown" />
		<cfset local.dateNow  = now() />
		<cfset local.codes    = [ "yyyy", "m", "ww", "d", "h", "n", "s" ] />
		<cfset local.names    = [ "year", "month", "week", "day", "hour", "minute", "second" ] />
		<cfif dateCompare(arguments.theDate, now()) gt 0>
			<!--- replace with other code to handle future dates ....--->
			<cfthrow message="Future date handling not implemented">
		</cfif>
		<!--- check each date period  ...--->
		<cfloop from="1" to="#arrayLen(local.codes)#" index="x">
			<cfset local.diff = abs( dateDiff(local.codes[x], arguments.theDate, local.dateNow) ) />
			<!--- this is the greatest date period --->
			<cfif local.diff gt 0 >
				<cfif local.diff  gt 1>
					<cfset local.result = "about "& diff &" "& local.names[x] &"s ago" />
				<cfelseif local.names[x] eq "hour">
					<cfset local.result = "about an "& local.names[x] &" ago" />
				<cfelse>
					<cfset local.result = "about a "& local.names[x] &" ago" />
				</cfif>
				<cfbreak>
			</cfif>
		</cfloop>
		<cfreturn local.result />
	</cffunction>


	<cffunction  access="remote" output="false" name="GetProjectIdOf" displayname="GetProjctIdOf">
		<cfargument required="false" type="numeric" name="personId">
			<cfquery name="local.queryGetProjectId" maxrows="1">
				SELECT [ProjectID]
				FROM [PERSON]
				<cfif isDefined('arguments.personId')>
					WHERE [PersonID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.personId#">
				<cfelse>
					WHERE [PersonID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#GetLoggedInPersonId()#">
				</cfif>
			</cfquery>
		<cfreturn local.queryGetProjectId.ProjectID>
	</cffunction>

	<cffunction access="remote" output="false" returntype="string" returnformat="JSON" name="GetNameOfProject" displayname="GetNameOfProject">
		<cfargument required="true" name="projectId" type="numeric">
		<cfquery name="local.queryGetProjectName" maxrows="1">
			SELECT [Name]
			FROM [PROJECT]
			WHERE [ProjectID] = <cfqueryparam value="#arguments.projectId#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfreturn local.queryGetProjectName.Name>
	</cffunction>

	<cffunction access="public" output="false" returnformat="JSON" returntype="boolean" name="ValidateUUID">
		<cfargument type="uuid"	required="true" name="userUUID" hint="This is the uuid to check if valid.">

		<cfquery name="local.querySearchUUID" maxrows="1">
			SELECT [DateInvited], [IsValid] 
			FROM [INVITE_PERSON] 
			WHERE [UUID] = <cfqueryparam value="#arguments.userUUID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfif local.querySearchUUID.RecordCount EQ 1>
			<cfreturn (dateDiff('h', local.querySearchUUID.DateInvited, now()) LT 24) AND (local.querySearchUUID.IsValid EQ 1)>
		</cfif>
		<cfreturn false/>

	</cffunction>

	<cffunction access="public" output="false" returnformat="JSON" returntype="struct" name="GetTitleInfo" displayname="GetTitleInfo">
		<cfargument type="uuid" required="true" name="userUUID" hint="The unique uuid of user.">

		<cfquery name="local.queryTitleInfo">
			SELECT IP.[TitleID], T.[Name]
			FROM [INVITE_PERSON] IP 
			INNER JOIN [PERSON_TITLE] T 
			ON T.[TitleID] = IP.[titleID]
			WHERE [UUID] = <cfqueryparam value="#arguments.userUUID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfif local.queryTitleInfo.RecordCount EQ 1 AND local.queryTitleInfo.TitleID NEQ ''>
			<cfreturn { isTitleGiven: true, titleId: queryTitleInfo.TitleID, titleName: "#local.queryTitleInfo.Name#" }>
		</cfif>
		<cfreturn {isTitleGiven: false}>
	</cffunction>
	
	<cffunction access="public" output="false" returnformat="JSON" returntype="struct" name="GetProjectInfoFromUUID" displayName="GetProjectIdFromUUID">
		<cfargument required="true" type="uuid" name="userUUID">
		<cfquery name="local.queryGetProjectInfo" maxrows="1">
			SELECT IP.[ProjectID], P.[Name]
			FROM [INVITE_PERSON] IP
			INNER JOIN [PROJECT] P
			ON P.[ProjectID] = IP.[ProjectID]
			WHERE IP.[UUID] = <cfqueryparam value="#arguments.userUUID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn { projectId: local.queryGetProjectInfo.ProjectID, projectName: local.queryGetProjectInfo.Name }>
	</cffunction>

	<cffunction access="remote" output="false" returnformat="JSON" returntype="boolean" name="SignUpMember" displayname="SignUpMember">
		<cfargument name="firstName" required="true" string="string" hint="The firstname of the registring user.">
		<cfargument name="middleNme" required="false" type="string" hint="The midle of the registering user.">
		<cfargument name="lastName" required="true" type="string" hint="The surname of the registering user.">
		<cfargument name="contactNumber" required="true" type="numeric" hint="The contact number of the registerging user.">
		<cfargument name="titleId" required="false" default="0" type="numeric" hint="The title of the user who will be signed if not provided will default to '1'.">
		<cfargument name="password" required="true" type="string" hint="The password of the registering user.">
		<cfargument name="profileImage" default="" required="false" type="any" displayname="The profile picture of the admin whoever is signing up.">
		<cfargument name="profileImageName" default="" required="false" type="string" hint="The file name of the profile ">
		<cfargument name="userUUID" required="true" type="uuid" hint="The token of the member.">

		<cfif arguments.profileImage NEQ ''>
			<cfset local.imagePath =  uploadProfileImage('#arguments.profileImage#', '#arguments.profileImageName#') />
		</cfif>
		
		<cfif arguments.titleId EQ 0>
			<cfset arguments.titleId = GetTitleInfo(arguments.userUUID).titleId>					
		</cfif>

		<cfset local.memberEmail = GetEmailFromUUID(arguments.userUUID)>
		<cfset local.projectId = GetProjectInfoFromUUID(arguments.userUUID).projectId>

		<cfquery name="local.queryAddMember">
			INSERT INTO [PERSON] (
				[FirstName], 
				[MiddleName], 
				[LastName], 
				[ContactNumber], 
				[EmailID], 
				[ProjectID], 
				[TitleID], 
				[Password],
				[ProfileImage]
			) VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_varchar" null="false" maxlength="30" value="#arguments.firstName#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" null="true" maxlength="30" value="#arguments.middleName#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" null="false" maxlength="30" value="#arguments.lastName#">,
					<cfqueryparam cfsqltype="cf_sql_bigint" null="false" value="#arguments.contactNumber#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" null="false" maxlength="50" value="#local.memberEmail#">,
					<cfqueryparam cfsqltype="cf_sql_integer" null="false" maxlength="50" value="#local.projectId#">,
					<cfqueryparam cfsqltype="cf_sql_integer" null="false" value="#arguments.titleId#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" null="false" value="#hash(arguments.password)#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" null="false" value="#local.imagePath#">
				)
		</cfquery>

		<cfquery>
			UPDATE [INVITE_PERSON] 
			SET [IsValid] = 0 
			WHERE [UUID] = <cfqueryparam value="#arguments.userUUID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfset LogUserIn(local.memberEmail, arguments.password)>
		<cfreturn true />
	</cffunction>
	

	<cffunction access="public" output="false" returnformat="plain" returntype="string" name="GetEmailFromUUID" displayname="GetEmailFromUUID">
		<cfargument required="true" type="uuid" name="userUUID">

		<cfquery name="local.queryGetMemberMail" maxrows="1">
			SELECT [EmailID] 
			FROM [INVITE_PERSON] 
			WHERE [UUID] = <cfqueryparam value="#arguments.userUUID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfreturn local.queryGetMemberMail.EmailID>
	</cffunction>
	

	<cffunction access="remote" output="false" returnformat="plain" returntype="boolean" name="IsLoggedInPersonAnAdmin" displayname="IsAnAdmin">
		<cfquery name="local.queryGetLoggedInfo" maxrows="1">
			SELECT PT.[Name] 
			FROM [PERSON_TITLE] PT 
			INNER JOIN [PERSON] P 
			ON PT.[TitleID] = P.[TitleID] 
			WHERE [EmailID] = <cfqueryparam value="#session.userEmail#" cfsqltype="cf_sql_varchar"> 
		</cfquery>
		<cfreturn local.queryGetLoggedInfo.Name EQ 'ADMIN' />
	</cffunction>

	<cffunction access="public" output="false" returntype="numeric" returnformat="plain" name="GetTotalNumberOfReports" displayname="GetTotalNumberOfReports">
		<cfset local.utilComponentInstance = CreateObject("component",'UtilComponent')>
		<cfquery name="local.queryGetTotalNumberOfReports" maxrows="1">
				SELECT COUNT([ReportID]) AS TotalReports 
				FROM [REPORT_INFO] RI
				INNER JOIN [PERSON] P
				ON P.[PersonID] = RI.[PersonID]
				WHERE P.[ProjectID] = <cfqueryparam value="#local.utilComponentInstance.GetProjectIdOf()#" cfsqltype="cf_sql_numeric">
		</cfquery>
	<cfreturn local.queryGetTotalNumberOfReports.TotalReports>
</cffunction>


<cffunction access="remote" output="false" returnFormat="JSON" returntype="array" name="IsMultipleEmailValid" displayname="IsMultipleEmailValid" description="This function checks if there's any other account related to any of the email in the array." hint="This function checks if there's any other account related to the email" >
	<cfargument name="userEmailList" displayName="emailId" type="any" hint="This is the email id of which to test to validity." required="true" />
	<cfset arguments.userEmailList=RemoveDuplicates(arguments.userEmailList)>
	<cfset local.availableEmails = []>
	<cfloop array="#arguments.userEmailList#" item="local.userEmail">
		<cfquery name="local.resultSet" maxrows="1">
			SELECT COUNT(*) AS AVAILABLE 
			FROM [Person] 
			WHERE [EmailId] = <cfqueryparam value="#local.userEmail#" cfsqltype="cf_sql_varchar" maxlength="50" null="false">
		</cfquery>		
		<cfif local.resultSet.AVAILABLE GTE 1>
			<cfset ArrayAppend(local.availableEmails, local.userEmail)>
		</cfif>
	</cfloop>
	<cfreturn local.availableEmails />
</cffunction>

<cffunction access="private" output="false" returntype="array" name="RemoveDuplicates" hint="This function eliminates any duplicate values inside an array.">
	<cfargument type="array" required="true" name="myArray" />
	<cfset local.arrayList =[]>
	<cfloop list="#arrayToList(arguments.myArray)#" item="local.userEmail">
		<cfif NOT ArrayFindNoCase(local.arrayList, local.userEmail)>
			<cfset ArrayAppend(local.arrayList, local.userEmail)>
		</cfif>
	</cfloop>
	<cfreturn local.arrayList>
</cffunction>

</cfcomponent>
