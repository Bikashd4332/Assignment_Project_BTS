<!---
	--- ReportComponent
	--- ---------------
	---
	--- author: mindfire
	--- date:   3/19/19
	--->
<cfcomponent displayname="ReportComponent" accessors="true" output="false" persistent="false">

	<cfset this.utilComponentInstance = CreateObject('component', 'UtilComponent')>

	<cffunction access="remote" output= "false" returnformat="JSON" returntype="struct" name="UploadAttachment" displayname="UploadAttachment" hint="This function uploads report attachments and stores into a directory." >
		<cfargument required="true" type="any" name="uploadedFile" hint="This argument contains the path of the uploaded file."/>
		<cfargument required="true" type="string" name="clientFileInfo" hint="This argument contains extra info of the client file.">
		<cfargument required="true"  type="string" name="uploadedDirectory" hint="This arguments will only have values when any files have been uploaded before.">
		
		<cfif arguments.uploadedDirectory EQ ''>
			<cfset local.uploadDirectoryName = "#Replace(TimeFormat(now(),'hh:mm:ss'),':','','ALL')#">
			<cfdirectory action="create" directory="#ExpandPath('../assets/report-attachments/'& local.uploadDirectoryName)#">
		<cfelse>
			<cfdirectory action="list" directory="#ExpandPath('../assets/report-attachments/')#" name="local.queryCheckDirectoryExist"> 
			<cfset local.isExist = false>
			<cfset local.uploadDirectoryName = "#arguments.uploadedDirectory#">
			<cfloop query="local.queryCheckDirectoryExist">
				<cfif Name EQ arguments.uploadedDirectory>
					<cfset local.isExist = true>
				</cfif>
			</cfloop>
			<cfif NOT local.isExist>
				<cfdirectory action="create" directory="#ExpandPath('../assets/report-attachments/'& local.uploadDirectoryName)#">
			</cfif>
		</cfif>
		
		<cfset local.uploadedRenamedFilePath = "#ExpandPath('../assets/report-attachments/' & local.uploadDirectoryName)#/#arguments.clientFileInfo#">
		<cffile action="move" source="#arguments.uploadedFile#" destination="#ExpandPath('../assets/report-attachments/' & local.uploadDirectoryName)#">
		
		<cfif IsFileAlreadyExist(arguments.clientFileInfo, arguments.uploadedDirectory)>
			<cfset local.renamedFile = "#ExpandPath('../assets/report-attachments/' & local.uploadDirectoryName)#/#ListFirst(arguments.clientFileInfo, '.')&Replace(TimeFormat(now(),'hh:mm:ss'),':','','ALL')&'.'&ListLast(arguments.clientFileInfo, '.')#">
			<cffile action="rename"
				source="#ExpandPath('../assets/report-attachments/' & local.uploadDirectoryName )#\#GetFileFromPath(arguments.uploadedFile)#"
				destination="#local.renamedFile#"
				>
			<cfreturn { "uploadDirectory" : #local.uploadDirectoryName#, "renamedFileName": "#local.renamedFile#" } />
		<cfelse>
			<cffile action="rename"
				source="#ExpandPath('../assets/report-attachments/' & local.uploadDirectoryName )#\#GetFileFromPath(arguments.uploadedFile)#"
				destination="#ExpandPath('../assets/report-attachments/' & local.uploadDirectoryName)#/#arguments.clientFileInfo#"
				>
			<cfreturn { "uploadDirectory" : #local.uploadDirectoryName# } />
		</cfif>
		
	</cffunction>


	<cffunction access="remote" output="false" returnformat="JSON" returntype="any" name="CreateReport" displayname="CreateReport" hint="This function create a new report with the required info and insert into the db." >
		<cfargument  required="true" name="reportTitle" type="string" hint="This is the name of the title of report">
		<cfargument  required="true" name="reportType" type="string" hint="This is the type of report.">
		<cfargument  required="true" name="reportPriority" type="string" hint="This is the priority of the report.">
		<cfargument  required="true" name="reportDescription" type="string" hint="This is a long description of the report.">
		<cfargument  required="false" default="" name="attachmentsTempDirectory" type="string" hint="This is the directory name of the report directory." >
		<cfargument required="true"  name="reportAssignee" type="numeric" hint="This holds the id of the person responsible to solve this.">

		<cfset local.getPersonId = "#this.utilComponentInstance.GetLoggedInPersonID()#">
s
		<cfquery name="local.queryInsertReport" result="local.resultInsertReport">
			INSERT INTO [REPORT_INFO] ([ReportTypeID], [ReportTitle], [Description], [PersonID], [Priority], [Assignee])
			VALUES
			(
			 <cfqueryparam cfsqltype="cf_sql_integer" null="false" value="#arguments.reportType#">,
			 <cfqueryparam cfsqltype="cf_sql_varchar" null="false" value="#arguments.reportTitle#">,
			 <cfqueryparam cfsqltype="cf_sql_varchar" null="false" value="#arguments.reportDescription#">,
			 <cfqueryparam cfsqltype="cf_sql_integer" null="false" value="#local.getPersonId#"> ,
			 <cfqueryparam cfsqltype="cf_sql_varchar" null="false" value="#arguments.reportPriority#">,
			 <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportAssignee#">
			 )
		</cfquery>
		<cfif arguments.attachmentsTempDirectory NEQ "">
			<cfdirectory action="rename" directory="#ExpandPath('../assets/report-attachments/')&arguments.attachmentsTempDirectory#" newdirectory="#ExpandPath('../assets/report-attachments/')&resultInsertReport['IDENTITYCOL']#" >
			<cfdirectory action="list" directory="#ExpandPath('../assets/report-attachments/')&local.resultInsertReport['IDENTITYCOL']#" name="local.uploadedFiles">

			<cfloop query="local.uploadedFiles">
				<cfquery name="local.queryInsertAttachments">
				INSERT INTO [REPORT_ATTACHMENTS] ([ReportId], [Attachment], [Uploader])
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_integer" null="false" value="#local.resultInsertReport['IDENTITYCOL']#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" null="false" value="#ExpandPath('../assets/report-attachments/#resultInsertReport['IDENTITYCOL']#/')&NAME#">,
					<cfqueryparam cfsqltype="cf_sql_integer" null="false" value="#this.utilComponentInstance.GetLoggedInPersonID()#">
				)
			</cfquery>
			</cfloop>
			<cfset AddComment('Created this report.', local.resultInsertReport['IDENTITYCOL'], 1)>
			<cfset AddComment('Added #local.uploadedFiles.RecordCount# Files intially.', local.resultInsertReport['IDENTITYCOL'], 1)>
			<cfreturn local.resultInsertReport['IDENTITYCOL']/>
		<cfelse>
			<cfset AddComment('Created this report.', local.resultInsertReport['IDENTITYCOL'], 1)>
			<cfreturn local.resultInsertReport['IDENTITYCOL']/>
		</cfif>

		<cfset ToggleWatcher(local.resultInsertReport['IDENTITYCOL'], this.utilComponentInstance.GetLoggedInPersonID())>
		
	</cffunction>


	<cffunction access="remote" output="false" returnType="string" returnFormat="JSON" name="DeleteTempAttachments" displayName="DeleteTempAttachment" hint="This function deletes the directory where the attachments uploded.">
		<cfargument required="true" type="string" name="directoryName" hint="This contains the name of the  directory">
		<cfdirectory action="delete" recurse="true" directory="#ExpandPath('../assets/report-attachments/')&arguments.directoryName#">
		<cfreturn true />
	</cffunction>


	<cffunction access="remote" output="false" returnType="array" returnFormat="JSON" name="GetAssigneeNames" displayName="GetAssigneeNames" hint="This function gets all the names of person who are working under the project.">
		<cfset local.assigneeNames = ArrayNew(1)>
		<cfquery name="local.queryGetProjectId">
				SELECT  [PersonID], [EmailID], CONCAT([FirstName], ' ', [LastName]) AS NAME
				FROM [PERSON]
				WHERE
				[ProjectID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#this.utilComponentInstance.GetProjectIdOf()#">
		</cfquery>
		<cfloop query="local.queryGetProjectId">
			<cfset ArrayAppend(local.assigneeNames,{ 'id': '#PersonID#', 'name': '#NAME#', 'email': '#EmailID#' })>
		</cfloop>
		<cfreturn local.assigneeNames>
	</cffunction>


	<cffunction access="remote" output="false" returnformat="JSON" returntype="struct" displayname="GetReportType" name="GetReportType" hint="This function return the list of available report types accepted." >
		<cfset local.reportTypes = StructNew()>
		<cfquery name="local.queryGetReportTypes">
			SELECT [ReportTypeID], [Title] FROM [REPORT_TYPE];
		</cfquery>
		<cfset local.reportTypes['#local.queryGetReportTypes.ReportTypeID#'] = "#local.queryGetReportTypes.ReportTypeID#">
		<cfreturn local.reportTypes>	
	</cffunction>


	<cffunction access="remote" output="false" returnformat="JSON" returnType="struct" name="GetReportOfId" displayname="GetReportOfId" hint="This function returns all information of a given report id.">
		<cfargument type="numeric" required="true" name="reportId" hint="This contains the id of any report.">
		<cfset local.response = StructNew()>
		<cfset local.dashBoardComponentInstance = CreateObject('component', 'DashboardComponent')>
		<cfquery name="local.queryGetReportInfo">
			SELECT RI.[ReportID], RT.[Title] AS Type, RI.[Priority] , RI.[ReportTypeID], RI.[ReportTitle], RI.[Description], RI.[DateReported], RI.[PersonID], RST.[Name] AS Status FROM
				[REPORT_INFO] AS RI
				INNER JOIN
				[REPORT_TYPE] AS RT
				ON RI.[ReportTypeID] =  RT.[ReportTypeID]
				INNER JOIN
				[REPORT_STATUS_TYPE] AS RST
				ON RI.[StatusID] = RST.[StatusID]
				WHERE RI.[ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
		</cfquery>
		<cfloop query="local.queryGetReportInfo">
			<cfset local.reporterName = local.dashBoardComponentInstance.GetUserName(PersonID)>
			<cfset local.response['id'] = "#ReportID#" >
			<cfset local.response['title'] = "#ReportTitle#">
			<cfset local.response['type'] = "#Type#">
			<cfset local.response['description'] ="#Description#">
			<cfset local.response['priority'] = "#Priority#">
			<cfset local.response['dateReported'] = "#DateReported#">
			<cfset local.response['personId'] = "#PersonID#">
			<cfset local.response['personName'] = "#reporterName['userName']#">
			<cfset local.response['status'] = "#Status#">
			<cfset local.response['typeId'] = "#ReportTypeID#">
		</cfloop>
		<cfset local.response['dateReported'] = "#this.UtilComponentInstance.RelativeDate(local.response['dateReported'])#">
		<cfreturn local.response />
	</cffunction>


	<cffunction access="remote" returnformat="JSON" returntype="array" name="GetAllAttachmentsOfReport" displayname="GetAllAttachmentsOfReport" hint="This function retrieves all the attachments files uploaded for a report.">
		<cfargument required="true" name="reportId" type="string" hint="This contains the id of report to retrieve the attachments.">
		<cfset local.response = ArrayNew(1)>
		<cfquery name="local.queryGetAttachmentDirectoryPath">
			SELECT [DateAttached], [Attachment], [Uploader], [AttachmentID]
				FROM [REPORT_ATTACHMENTS]
				WHERE [ReportID] = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.reportId#">
		</cfquery>

		<cfloop query="local.queryGetAttachmentDirectoryPath">
			<cfif Uploader EQ this.utilComponentInstance.GetLoggedInPersonID()>
				<cfset local.isRemovableByUser = true>
			<cfelse>
				<cfset local.isRemovableByUser = false >
			</cfif>
			<cfset ArrayAppend(local.response,'{ "id": "#AttachmentID#", "uploader": "#Uploader#", "date" : "#DateAttached#", "file" : "#GetFileFromPath(Attachment)#", "fileType": "#ListFirst(FileGetMimeType(Attachment), "/")#", "isRemovable": #local.isRemovableByUser#}')>
		</cfloop>
		<cfreturn local.response />
	</cffunction>


	<cffunction access="remote" name="DownloadFile" displayName="DownloadFile" hint="This function downloads file attachment of project.">
		<cfargument required="false" name='path' displayname="path" hint="This contains the path of the file to download.">
		<cfheader name="Content-Type" value="application/octet-stream">
		<cfheader name="Content-Disposition" value="attachment;filename=#GetFileFromPath(arguments.path)#">
		<cfheader name="Content-Location" value="#URLEncodedFormat(ExpandPath(arguments.path))#">
		<cfcontent  type="application/octet-stream" file="#ExpandPath(arguments.path)#">
	</cffunction>

	<cffunction access="remote" output="false" returntype="boolean" returnformat="JSON"  name="DeleteAttachment" displayname="DeleteAttachment">
		<cfargument required="true"  name="attachmentId" displayname="attachmentId">

		<cfquery name="local.queryGetAttachmentFilePath">
			SELECT [Attachment], [Uploader], [ReportID]
			FROM [REPORT_ATTACHMENTS]
			WHERE [AttachmentID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.attachmentId#">
		</cfquery>
			<cfif "#local.queryGetAttachmentFilePath.Uploader#" EQ '#this.utilComponentInstance.GetLoggedInPersonID()#'>
				<cffile action="delete" file="#local.queryGetAttachmentFilePath.Attachment#">
				<cfquery>
					DELETE FROM [REPORT_ATTACHMENTS]
					WHERE [AttachmentId] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.attachmentId#">
				</cfquery>
				<cfset commentId =  addComment("deleted file #GetFileFromPath(local.queryGetAttachmentFilePath.AttachMent)#",queryGetAttachmentFilePath.ReportID, 1 )>
				<cfset wsPublish('report-file-delete', { "commentId": "#commentId#", "isDeleted": true }) >
				<cfreturn true />
			<cfelse>
				<cfreturn false />
			</cfif>
	</cffunction>


	<cffunction access="remote" output="false" returntype="boolean" returnformat="JSON" name="UploadAttachmentForReport" displayname="UplaodAttachmentForReport" hint="This function is for handling of attachment upload after once a report is made.">
		<cfargument required="true" type="string" name="reportId" hint="This contains the id of report to upload the attachment of.">
		<cfargument required="true" type="any" name="uploadedFile" hint="This argument contains the path of the uploaded file."/>
		<cfargument required="true" type="string" name="clientFileInfo" hint="This argument contains extra info of the client file.">
		<cfargument required="true"  type="string" name="uploadedDirectory" hint="This arguments will only have values when any files have been uploaded before.">
		
		<cfset local.uploadStatus = UploadAttachment(arguments.uploadedFile, arguments.clientFileInfo, arguments.uploadedDirectory)>
		
		<cfif structKeyExists(local.uploadStatus,'renamedFileName')>
			<cfquery name="local.queryInsertAttachmentInTable" result="local.resultInsertAttachmentInTable">
				INSERT INTO [REPORT_ATTACHMENTS] ([ReportID], [Attachment] , [Uploader] ) VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.uploadStatus['renamedFileName']#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value='#this.utilComponentInstance.getLoggedInPersonID()#'>
				)
			</cfquery>
			<cfset local.commentId =  AddComment("added a file #arguments.clientFileInfo#.",arguments.reportId, 1)>
			<cfset wsPublish('report-file-upload',{"attachmentId": "#local.resultInsertAttachmentInTable['IDENTITYCOL']#"}) >
			<cfreturn true />
		<cfelse>
			<cfquery name="local.queryInsertAttachmentInTable" result="local.resultInsertAttachmentInTable">
				INSERT INTO [REPORT_ATTACHMENTS] ([ReportID], [Attachment] , [Uploader] ) VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value='#ExpandPath("../assets/report-attachments/#arguments.uploadedDirectory#/#arguments.clientFileInfo#")#'>,
					<cfqueryparam cfsqltype="cf_sql_integer" value='#this.utilComponentInstance.getLoggedInPersonID()#'>
				)
			</cfquery>
			<cfset local.commentId =  AddComment("added a file #arguments.clientFileInfo#.",arguments.reportId, 1)>
			<cfreturn true />
		</cfif>
	</cffunction>


	<cffunction access="remote" output="false" returntype="numeric" returnformat="JSON" name="AddComment" displayname="AddComment" hint="This function stores the given comment in to the databse.">
		<cfargument required="true" name="commentText" type="string" hint="It contains the comment itself.">
		<cfargument requried="true" name="reportId" type="numeric" hint="It contains the report id to which the comment will be added.">
		<cfargument required="false" default="0" name="isActivity" type="numeric" hint="Wheather the comment will be an activity or a simple content.">
		
		<cfset local.dashBoardComponent = CreateObject('component', 'DashboardComponent')>
		
		<cfquery result="local.resultAddComment">
			INSERT INTO [REPORT_COMMENTS] ( [ReportID], [Comment], [PersonID], [isActivity])
			VALUES (
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.commentText#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#this.utilComponentInstance.GetLoggedInPersonID()#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.isActivity#">
			)
		</cfquery>
		
		<cfif arguments.isActivity EQ 1>
			<!---<cfset NotifyAllWatchers("#dashBoardComponent.getUserName(utilComponent.GetLoggedInPersonID())# #arguments.commentText#", arguments.reportId)>--->
			<cfset wsPublish('report-comment-post', {"commentId" : "#local.resultAddComment['IDENTITYCOL']#", "isActivity": "#arguments.isActivity#"})>
		<cfelse>
			<!---<cfset NotifyAllWatchers("#dashBoardComponent.getUserName(utilComponent.GetLoggedInPersonID())# has commented #arguments.commentText#", arguments.reportId)>--->
			<cfset wsPublish('report-comment-post', {"commentId" : "#local.resultAddComment['IDENTITYCOL']#", "isActivity": "#arguments.isActivity#"})>
		</cfif>
		<cfreturn local.resultAddComment['IDENTITYCOL']  />

	</cffunction>


	<cffunction access="remote" output="false" returntype="array" returnformat="JSON" name="GetCommentsForReport" displayname="GetCommentsForReport" hint="This function fetches all the comments form database of any specific report.">
		<cfargument required="true" type="numeric" name="reportId" hint="The report id of which to fetch all the comments.">
		<cfargument required="false" default="0"  type="numeric" name="activity" hint="A boolean for returning activity.">
		<cfset local.response = ArrayNew(1)>
		<cfset local.dashboardComponent = CreateObject('component', 'DashboardComponent')>

		<cfquery name="local.queryGetCommentsForReport">
			SELECT P.[PersonID], P.[FirstName], RC.[DateCommented], RC.[Comment], RC.[CommentID], RC.[IsActivity]
			FROM [REPORT_COMMENTS] RC
			INNER JOIN [PERSON] P
			ON P.[PersonID] = RC.[PersonID]
			WHERE [ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
			<cfif arguments.activity NEQ 2>
				AND RC.[isActivity] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.activity#">
			</cfif>
			ORDER BY RC.[DateCommented] ASC
		</cfquery>
		
		<cfloop query="local.queryGetCommentsForReport">
			<cfset local.profileImage = DeserializeJSON(local.dashboardComponent.GetProfileImage(40, 40, PersonID))>
			<cfset ArrayAppend(local.response, '{"userName":"#FirstName#","id":"#CommentID#","personId":"#PersonID#","profileImage":"#profileImage["base64ProfileImage"]#","comment":"#Comment#","date":"#DateCommented#","extension": "#profileImage["extension"]#","isActivity": "#isActivity#" }')>
		</cfloop>
		
		<cfreturn local.response />
	</cffunction>


	<cffunction access="remote" output="true" returnformat="JSON" returntype="struct" name="GetCommentInfoOf" >
		<cfargument required="true" type="numeric" name="commentId">
		<cfset local.resposne = StructNew()>
		<cfset local.dashboardComponent = CreateObject('component', 'DashboardComponent')>

		<cfquery name="local.queryGetCommentInfo">
		SELECT RC.[DateCommented], P.[ProfileImage],RC.[isActivity], RC.[CommentID], RC.[PersonID], RC.[ReportID], RC.[Comment], CONCAT([FirstName],' ',[LastName]) AS Name
		FROM [REPORT_COMMENTS] RC
		INNER JOIN
		[PERSON] P
		ON P.[PersonID] = RC.[PersonID]
		WHERE [CommentID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.commentId#" >
	</cfquery>
		<cfloop query="queryGetCommentInfo">
			<cfset local.processedProfileImage = DeserializeJSON(local.dashboardComponent.GetProfileImage(40, 40, PersonID))>
			<cfset local.response['userName'] =  "#Name#">
			<cfset local.response['id'] = "#CommentID#">
			<cfset local.response['personID'] = "#PersonID#">
			<cfset local.response['profileImage'] = "#local.processedProfileImage['base64ProfileImage']#">
			<cfset local.response['isActivity'] = "#isActivity#">
			<cfset local.response['date'] = "#DateCommented#">
			<cfset local.response['extension'] = "#local.processedProfileImage['extension']#">
			<cfset local.response['comment'] = "#Comment#">
		</cfloop>
		<cfreturn local.response>
	</cffunction>


	<cffunction access="remote" output="false" returnformat="JSON" returntype="string" name="GetStatusOfReport" displayname="GetStatusOfReport" hint="This function fetches the status of the specified report id.">
		<cfargument required="true" type="numeric" name="reportId" >
		<cfquery name="local.queryGetStatusOfReport">
			SELECT RST.[Name], RST.[StatusID]
			FROM [REPORT_STATUS_TYPE] RST
			INNER JOIN [REPORT_INFO] RI
			ON RI.[StatusID] = RST.[StatusID]
			WHERE RI.[ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
		</cfquery>
		<cfloop query="local.queryGetStatusOfReport">
			<cfreturn '{ "status": "#Name#", "statusId": #StatusID# }'>
		</cfloop>
	</cffunction>


	<cffunction access="remote" output="false" returnformat="JSON" returntype="string" name="GetAssignedPersonID"  hint="This function finds if the report is assigned to someone or not.">
		<cfargument name="reportId" required="true" type="numeric">
		<cfquery name="local.queryGetAssignedPersonID">
			SELECT P.[FirstName], P.[LastName], P.[PersonID]
			FROM [Person] P
			INNER JOIN [REPORT_INFO] RI
			ON RI.[Assignee] = P.[PersonID]
			WHERE RI.[ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
		</cfquery>
		<cfloop query="local.queryGetAssignedPersonID">
			<cfset local.response = '{ "assigneeName": "#FirstName & ' ' &LastName#", "personId": "#PersonID#" }'>
		</cfloop>
		<cfreturn local.response>
	</cffunction>


	<cffunction access="remote" output="false" returntype="string" returnformat="JSON" name="IsWorkingAssignee" displayname="IsWorkingAssignee" hint="This function finds if any assignee is currently working on the report.">
		<cfargument required="true" name="reportId">
		<cfquery name="local.queryGetIsWorkingAssignee">
			SELECT [isWorking] 
			FROM [REPORT_INFO] 
			WHERE [ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
		</cfquery>
		<cfloop query="local.queryGetIsWorkingAssignee">
			<cfif isWorking EQ 1>
				<cfreturn true >
			<cfelse>
				<cfreturn false>
			</cfif>
		</cfloop>
	</cffunction>


	<cffunction access="remote" output="false" returntype="string" returnformat="JSON" name="StartWorkingOnReport" displayname="StartWorkingOnReport">
		<cfargument required="true" type="numeric" name="reportId" hint="This contains the working report id">
		<cfset local.reportStatus = DeserializeJSON(GetStatusOfReport(arguments.reportId))>

		<cfset local.dashBoardComponent = CreateObject('component', 'DashboardComponent')>
		
		<cfif  local.reportStatus['status'] EQ 'OPEN' OR local.reportStatus['status'] EQ 'REOPEN'>
			<cfquery name="queryChangeOpenToInProgress">
				UPDATE [REPORT_INFO] 
				SET [isWorking] = 1, 
				[StatusID] = 2 
				WHERE [ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">;
			</cfquery>
			<cfset commentId =  AddComment('changed the status from OPEN to IN PROGRESS', arguments.reportId, 1)>
			<cfset wsPublish('report-status-update', {"commentId": "#commentId#"})>
			<cfset NotifyAllWatchers('#local.dashBoardComponent.GetUserName(this.utilComponentInstance.GetLoggedInPersonID()).userName# with person ID #this.utilComponentInstance.GetLoggedInPersonID()# has started working on the report #arguments.reportId#.', arguments.reportId)>
			<cfreturn '{ "commentId": #commentId# }'>
		<cfelse>
			<cfquery name="local.querySetIsWorking">
				UPDATE [REPORT_INFO] 
				SET [isWorking] = 1 
				WHERE [ReportID] = <cfqueryparam cfsqltype="cf_sql_integer"  value="#arguments.reportId#">;
			</cfquery>
			<cfset wsPublish('report-status-update', "Report working string changed.")>
		</cfif>
	</cffunction>


	<cffunction access="remote" returntype="string" returnformat="JSON" name="StopWorkingOnReport" displayname="StopWorkingOnReport" hint="This function stops progress on the specified report.">
		<cfargument required="true" name="reportId" type="numeric" hint="This function contains the working report id.">
		<cfset local.reportStatus = DeserializeJSON(GetStatusOfReport(arguments.reportId))>
		<cfif  local.reportStatus['status'] EQ 'IN PROGRESS'>
			<cfif hasGoneToDone(reportId)>
				<cfquery name="local.queryChangeToReopen">
					UPDATE [REPORT_INFO] 
					SET [isWorking] = 0, 
					[StatusID] = 6 
					WHERE [ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
				</cfquery>
				<cfset commentId =  AddComment('chaged the status from IN PROGRESS to REOPEN', arguments.reportId, 1)>
				<cfset ChangeAssignee(arguments.reportId,GetLastAssignee(arguments.reportId))>
				<cfset wsPublish('report-status-update', {"commentId": "#commentId#"})>
				<cfreturn '{"commentId": #commentId#}'>
			<cfelse>
				<cfquery name="local.queryChageToOpen">
					UPDATE [REPORT_INFO] SET [isWorking] = 0, [StatusID] = 1 
					WHERE [ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
				</cfquery>
				<cfset commentId =  AddComment('changed the status from IN PROGRESS to OPEN', arguments.reportId, 1)>
				<cfset ChangeAssignee(arguments.reportId,GetLastAssignee(arguments.reportId))>
				<cfset wsPublish('report-status-update', {"commentId": "#commentId#"})>
				<cfreturn '{"commentId": #commentId# }'>
			</cfif>
		<cfelse>
			<cfquery name="local.queryStopIsWorking">
				UPDATE [REPORT_INFO] SET [isWorking] = 0 
				WHERE [ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">;
			</cfquery>
			<cfset wsPublish('report-status-update',"Report working string changed.")>
		</cfif>
	</cffunction>


	<cffunction access="public" output="false" name="GetStatusNameOfStatusID">
		<cfargument type="numeric" name="statusId" required="true">
		<cfquery name="local.queryGetStatusNameFromStatusId">
			SELECT [Name] FROM [REPORT_STATUS_TYPE] 
			WHERE [StatusID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.statusId#">
		</cfquery>
		<cfloop query="local.queryGetStatusNameFromStatusId">
			<cfreturn Name>
		</cfloop>
	</cffunction>


	<cffunction access="remote" output="false" returntype="string" returnformat="JSON"  name="SendReportToNextStatus" displayname="SendReportToNextStatus" hint="This function progresses the status of specified report." >
		<cfargument required="true" name="reportId" hint="This contains the report id of which to restore the state." >
		<cfargument required="true" name="assignee" hint="This conains the id of the person who will be responsible for the next process." >
		
		<cfset local.reportStatus = DeserializeJSON(GetStatusOfReport(arguments.reportId))>
		<cfif  local.reportStatus['status'] EQ 'IN PROGRESS' OR local.reportStatus['status'] EQ 'IN REVIEW'>
			
			<cfquery name="local.querySendReportToNextStatus">
				UPDATE [REPORT_INFO]
				SET [StatusID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.reportStatus['statusId'] + 1#">,
				[isWorking] = 0,
				[Assignee] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.assignee#">
				WHERE [ReportID] = <cfqueryparam value="#arguments.reportId#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfset local.commentId = AddComment("changed the status from #local.reportStatus['status']# to #GetStatusNameOfStatusID(local.reportStatus['statusId'] + 1)#", arguments.reportId, 1)>
			<cfset ChangeAssignee(arguments.reportId,GetLastAssignee(arguments.reportId))>
			<cfset wsPublish('report-status-update', { "commentId": "#local.commentId#" })>
			<cfreturn '{ "commentId": #local.commentId# }'>
		</cfif>
	</cffunction>


	<cffunction access="remote" output="false" returntype="string" returnformat="JSON"  name="FallBackToPreviousStatus" displayname="FallBackToPreviousState" hint="This function makes reports go back in state." >
		<cfargument required="true" name="reportId" hint="This contains the report id of which to restore the state." >
		
		<cfset local.reportStatus = DeserializeJSON(GetStatusOfReport(arguments.reportId))>
		<cfif  local.reportStatus['status'] EQ 'IN REVIEW' OR local.reportStatus['status'] EQ 'DONE'>
			<cfquery name="local.querySendReportToPreviousStatus">
				UPDATE [REPORT_INFO] 
				SET [StatusID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.reportStatus['statusId'] - 1#">,  
				[isWorking] = 1
				WHERE [ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
			</cfquery>
			<cfset local.commentId =  AddComment('changed the state from #local.reportStatus["status"]# to #GetStatusNameOfStatusID(local.reportStatus["statusId"] - 1)#', arguments.reportId, 1)>
			<cfset ChangeAssignee(arguments.reportId, GetLastAssignee(arguments.reportId))>
			<cfset wsPublish('report-status-update', {"commentId": "#local.commentId#"})>
			<cfreturn '{ "commentId": #local.commentId# }'>
		</cfif>
	</cffunction>


	<cffunction access="remote" output="false" name="CloseReport" displayname="CloseReport" hint="This function closes the report by changing its state to closed.">
		<cfargument required="true" type="numeric" name="reportId" >
		<cfquery name="local.queryCloseReport">
			UPDATE [REPORT_INFO] SET [StatusID] = 5
			WHERE [ReportID] = <cfqueryparam value="#arguments.reportId#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfset commentId = AddComment("has closed this report.", arguments.reportId, 1)>
		<cfset wsPublish('report-status-update', {"commentId": "#local.commentId#"}) >
		<cfreturn '{ "commentId": #local.commentId# }'>
	</cffunction>


	<cffunction access="remote" output="false" returntype="string" returnformat="JSON" name="ReopenReport" displayname="ReopenReport" hint="This function reopens the report by chagning the state to report.">
		<cfargument required="true" type="numeric" name="reportId">
		<cfquery name="queryCloseReport">
			UPDATE [REPORT_INFO] SET [StatusID] = 6;
		</cfquery>
		<cfset local.commentId = AddComment("has reopened this report.", arguments.reportId, 1)>
		<cfset wsPublish('report-status-update', {"commentId": "#local.commentId#"}) >
		<cfreturn '{ "commentId": #local.commentId# }'>
	</cffunction>


	<cffunction access="remote"  output="false" name="ChangeAssignee"  displayname="ChangeAssignee"  hint="This function changes the assignee of the report.">
		<cfargument required="true" name="reportId" type="numeric" hint="Contains the report whose assignee will be changed." >
		<cfargument required="true" name="personId" type="numeric" hint="This contains the personId whom it will be assigned." >
		<cfquery name="local.queryChangeAssignee">
			UPDATE [REPORT_INFO] SET [Assignee] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.personId#"> 
			WHERE [ReportID] = <cfqueryparam value="#arguments.reportId#" cfsqltype="cf_sql_numeric" />
		</cfquery>
	</cffunction>


	<cffunction access="remote" output="false" name="GetLastAssignee" displayname="GetLastAssignee" hint="This function finds the assigne to whom the report was assigned before." >
		<cfargument name="reportId" type="numeric" required="true"  >
		<cfquery name="local.queryGetLastAssignee">
			SELECT TOP(1) [PersonID]
			FROM [REPORT_COMMENTS]
			WHERE [ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
			AND [isActivity] = 1
			ORDER BY [DateCommented] DESC
		</cfquery>
		<cfreturn local.queryGetLastAssignee.PersonID />
	</cffunction>


	<cffunction access="remote" output="true" returntype="any" returnformat="JSON" name="HasGoneToDone" displayname="HasGoneToDone" hint="This Function is responsible for finding if the report has ever gone to the state done.">
		<cfargument type="numeric" required="true" name="reportId" >
		<cfquery name="local.queryCheckHasGoneToDone">
			SELECT TOP(1) [PersonId]
			FROM [REPORT_COMMENTS]
			WHERE [Comment] LIKE '%to DONE%'
			AND [ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
			AND [isActivity] = 1
 			ORDER BY [DateCommented] DESC
		</cfquery>
		<cfif local.queryCheckHasGoneToDone.recordCount EQ 1>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>


	<cffunction access="remote" output="false" returntype="string" returnformat="plain" name="GetHTMLInterfaceForReportButtons">
		<cfargument required="true" name="reportId" type="numeric" hint="This has the report id.">

		<cfset local.reportStatus = DeserializeJSON(GetStatusOfReport(arguments.reportId))>
		<cfset local.assigneeInfo = DeserializeJSON(GetAssignedPersonID(arguments.reportId))>
		
		<cfif local.assigneeInfo['personId'] EQ this.utilComponentInstance.GetLoggedInPersonID()>
			<cfswitch expression="#local.reportStatus['status']#">
				<cfcase value='OPEN,REOPEN'>
					<cfreturn '<button id="startWorkingButton">Start Working</button>'>
				</cfcase>
				<cfcase value="IN PROGRESS">
					<cfreturn '<button id="stopWorkingButton">Stop Working</button><button id="sendToNextStatusButton">Send To Next Status</button>'>
				</cfcase>
				<cfcase value="IN REVIEW">
					<cfif IsWorkingAssignee(arguments.reportId)>
						<cfreturn '<button id="stopWorkingButton">Stop Working</button> <button id="sendToNextStatusButton">Send To Next Status</button> <button id="fallBackToPreviousButton">Send To Previous Status</button>' >
					<cfelse>
						<cfreturn '<button id="startWorkingButton">Start Working</button>'>
					</cfif>
				</cfcase>
				<cfcase value="DONE">
					<cfreturn '<button id="reopenButton">Reopen It</button><button id="closeButton">Close It</button>'>
				</cfcase>
			</cfswitch>
		<cfelse>
			<cfreturn '<button id="assignToMeButton">Assign To Me</button>'>
		</cfif>
	</cffunction>


	<cffunction access="remote" returntype="string" returnformat="JSON" name="GetAssigneeWorkingString" displayname="GetAssigneeWorkingString" hint="This function finds if the assignee is currenlty wokring on the report or not.">
		<cfargument type="numeric" required="true" name="reportId">

		<cfset local.assigneeInfo = DeserializeJSON(GetAssignedPersonID(arguments.reportId))>
		<cfif IsWorkingAssignee(arguments.reportId)>
			<cfreturn '{ "userName": "#local.assigneeInfo["assigneeName"]#", "msg": "is assigned and working currently." }'>
		<cfelse>
			<cfreturn '{ "userName": "#local.assigneeInfo["assigneeName"]#", "msg":"is assigned but not working currently." }' >
		</cfif>
	</cffunction>


	<cffunction access="remote" returnformat="JSON" returntype="boolean" name="IsFileAlreadyExist" >
		<cfargument required="true" type="string" name="fileName" >
		<cfargument required="true" name="reportId" type="any">
		<cfdirectory action="list" directory="#ExpandPath('../assets/report-attachments/#arguments.reportId#')#" name="local.queryDirectoryList" >

		<cfloop query="local.queryDirectoryList">
			<cfif arguments.fileName EQ Name>
				<cfreturn true>
			</cfif>
		</cfloop>
		<cfreturn false>
	</cffunction>


	<cffunction access="remote" output="false" name="NotifyAllWatchers" displayname="NotifyAllWatchers">
		<cfargument required="true" name="message" type="string">
		<cfargument required="true" name="reportId" type="numeric">
		
		<cfset local.loggedInPersonId = "#this.utilComponentInstance.GetLoggedInPersonId()#">
		
		<cfquery name="local.queryGetAllWatcher">
			SELECT [EmailID]
			FROM [WATCHER] RW
			INNER JOIN
			[PERSON] P
			ON P.[PersonID] = RW.[PersonID]
			WHERE
			[ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
			AND
			P.[PersonID] <> <cfqueryparam cfsqltype="cf_sql_integer" value="#local.loggedInPersonId#">
		</cfquery>
		
		<cfloop query="local.queryGetAllWatcher">
			<cfset sendEmailTo(EmailID, arguments.message)>
		</cfloop>

	</cffunction>


	<cffunction access="remote" output="false" returntype="boolean" returnformat="JSON"  name="CheckIfWatching" displayname="CheckIfWatching">
		<cfargument required="true" name="reportId" type="numeric">
		<cfargument required="false" name="personId" type="numeric">

		<cfquery name="local.queryCheckIfAlredyWatching">
			SELECT [PersonID]
			FROM [WATCHER]
			WHERE
			<cfif IsDefined('arguments.personId')>
				[PersonID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.personId#">
			<cfelse>
				[PersonID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#this.utilComponentInstance.GetLoggedInpersonID()#">
			</cfif>
			AND [ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
		</cfquery>
		<cfif local.queryCheckIfAlredyWatching.RecordCount EQ 0>
			<cfreturn false>
		<cfelse>
			<cfreturn true>
		</cfif>
	</cffunction>


	<cffunction access="remote" output="false" returnformat="JSON"  name="ToggleWatcher" displayname="ToggleWatcher">
		<cfargument required="true" name="reportId" type="numeric">
		<cfargument required="false" name="personId" type="numeric">

		<cfif IsDefined('arguments.personId')>
			<cfset local.watcher = arguments.personId>
		<cfelse>
			<cfset local.watcher = this.utilComponentInstance.GetLoggedInPersonID()>
		</cfif>
		
		<cfif NOT CheckIfWatching(arguments.reportId, local.watcher)>
			<cfquery name="local.queryAddToWatcher">
				INSERT INTO [WATCHER] ([PersonID], [ReportID]) VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#local.watcher#">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.reportId#">
				)
			</cfquery>
			<cfreturn true>
		<cfelse>
			<cfquery name="local.queryDeleteWatcher">
				DELETE FROM [WATCHER]
				WHERE [PersonID] = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.watcher#">
				AND [ReportID] = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.reportId#">
			</cfquery>
			<cfreturn false>
		</cfif>	
	</cffunction>


	<cffunction access="remote" output="false" name="sendEmailTo" returnformat="JSON" returntype="boolean" >
		<cfargument required="true" type="string" name="emailId" >
		<cfargument required="true" name="message" type="string">
		
		<cfmail from="trackingticket@gmail.com" to="#arguments.emailId#" subject="Greetings" >
				#arguments.message#
		</cfmail>

		<cfreturn true>
	</cffunction>

	<cffunction access="remote" output="false" name="AssignToMe" returnformat="JSON" returntype="boolean" hint="This function changes the assignee of any report to the current logged in person.">
		<cfargument required="true" type="numeric" name="reportId">
		<cfset local.dashBoardComponentInstance = CreateObject('component', 'DashBoardComponent') />
		<cfset ChangeAssignee(arguments.reportId, this.utilComponentInstance.GetLoggedInPersonID()) />
		<cfset local.commentId = AddComment("Assigne has been changed to #local.dashBoardComponentInstance.GetUserName()['userName']#", arguments.reportId, 1)>
		<cfset wsPublish('report-status-update', { "commentId": "#local.commentId#" }) >
		<cfreturn true />
	</cffunction>
	
	<cffunction access="public" output="false" returnformat="plain" returntype="boolean" name="IsReportValidForUser" displayname="IsReportValidForUser">
		<cfargument required="true" type="numeric" name="reportId" hint="This is the reportId to check if its related to the project in the with the logged in user iw workint on.">
		<cfquery name="local.queryGetProjectIdOfReport" maxrows="1">
			SELECT P.[ProjectID] 
			FROM [REPORT_INFO] RI
			INNER JOIN [PERSON] P
			ON RI.[PersonID] = P.[PersonID]
			WHERE RI.[ReportID] = <cfqueryparam value="#arguments.reportId#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfreturn local.queryGetProjectIdOfReport.ProjectID EQ this.utilComponentInstance.GetProjectIdOf()>
	</cffunction>
	
	<cffunction access="remote" output="false" returnformat="JSON"	returntype="boolean" name="ChangeReportPriorityType">
			<cfargument type="numeric" required="true" name="reportTypeId">
			<cfargument type="string" required="true" name="reportPriority">
			<cfargument type="numeric" required="true" name="reportId">

			<cfquery name="local.queryGetReportPriorityType" maxrows="1">
				SELECT RI.[Priority], RI.[ReportTypeID], RT.[Title] FROM [REPORT_INFO] RI
				INNER JOIN [REPORT_TYPE] RT 
				ON RI.[ReportTypeID] = RT.[ReportTypeID]
				WHERE [ReportID] = <cfqueryparam value="#arguments.reportId#" cfsqltype="cf_sql_integer">
			</cfquery>
			
			<cfquery name="local.queryGetReportTypeName">
				SELECT [Title] FROM [REPORT_TYPE] 
				WHERE [ReportTypeID] = <cfqueryparam value="#arguments.reportTypeId#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfquery name="local.queryChangeReportPriorityType">
				UPDATE [REPORT_INFO] SET 
				[Priority] = <cfqueryparam value="#lcase(arguments.reportPriority)#" cfsqltype="cf_sql_varchar">, 
				[reportTypeID] = <cfqueryparam value="#arguments.reportTypeId#" cfsqltype="cf_sql_numeric">
				WHERE [ReportID] = <cfqueryparam value="#arguments.reportId#" cfsqltype="cf_sql_integer"> 
			</cfquery>

			<cfif arguments.reportPriority NEQ local.queryGetReportPriorityType.Priority>
				<cfset AddComment('Priority is changed from #ucase(local.queryGetReportPriorityType.Priority)# to #ucase(arguments.reportPriority)#', arguments.reportId, 1)> 
			</cfif>

			<cfif arguments.reportTypeId NEQ local.queryGetReportPriorityType.ReportTypeID>
				<cfset AddComment('Report type is changed from #local.queryGetReportPriorityType.Title# to #local.queryGetReportTypeName.Title#', arguments.reportId, 1)>
			
			</cfif>
			
			<cfset wsPublish('report-type-priority-change', { "priority" : arguments.reportPriority, "type": local.queryGetReportTypeName.Title })>
			<cfreturn true />
	</cffunction>
</cfcomponent>
