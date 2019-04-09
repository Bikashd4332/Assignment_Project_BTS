<!---
	--- ReportComponent
	--- ---------------
	---
	--- author: mindfire
	--- date:   3/19/19
	--->
<cfcomponent displayname="ReportComponent" accessors="true" output="false" persistent="false">


	<cffunction access="remote" output="false" returnformat="JSON" returntype="struct" name="UploadAttachment" displayname="UploadAttachment" hint="This function uploads report attachments and stores into a directory." >
		<cfargument required="true" type="any" name="uploadedFile" hint="This argument contains the path of the uploaded file."/>
		<cfargument required="true" type="string" name="clientFileInfo" hint="This argument contains extra info of the client file.">
		<cfargument required="true"  type="string" name="uploadedDirectory" hint="This arguments will only have values when any files have been uploaded before.">
		<cfif arguments.uploadedDirectory EQ ''>
			<cfset uploadDirectoryName = "#Replace(TimeFormat(now(),'hh:mm:ss'),':','','ALL')#">
			<cfdirectory action="create" directory="#ExpandPath('../assets/report-attachments/'& uploadDirectoryName)#">
		<cfelse>
			<cfset uploadDirectoryName = "#arguments.uploadedDirectory#">
		</cfif>
		<cfset uploadedRenamedFilePath = "#ExpandPath('../assets/report-attachments/' & variables.uploadDirectoryName)#/#arguments.clientFileInfo#">
		<cffile action="move" source="#uploadedFile#" destination="#ExpandPath('../assets/report-attachments/' & variables.uploadDirectoryName)#">
		<cfif IsFileAlreadyExist(arguments.clientFileInfo, arguments.uploadedDirectory)>
			<cfset renamedFile = "#ExpandPath('../assets/report-attachments/' & variables.uploadDirectoryName)#/#ListFirst(arguments.clientFileInfo, '.')&Replace(TimeFormat(now(),'hh:mm:ss'),':','','ALL')&'.'&ListLast(arguments.clientFileInfo, '.')#">
			<cffile action="rename"
				source="#ExpandPath('../assets/report-attachments/' & variables.uploadDirectoryName )#\#GetFileFromPath(arguments.uploadedFile)#"
				destination="#renamedFile#"
				>
			<cfreturn { "uploadDirectory" : #variables.uploadDirectoryName#, "renamedFileName": "#renamedFile#" } />
		<cfelse>
			<cffile action="rename"
				source="#ExpandPath('../assets/report-attachments/' & variables.uploadDirectoryName )#\#GetFileFromPath(arguments.uploadedFile)#"
				destination="#ExpandPath('../assets/report-attachments/' & variables.uploadDirectoryName)#/#arguments.clientFileInfo#"
				>
			<cfreturn { "uploadDirectory" : #variables.uploadDirectoryName# } />
		</cfif>
	</cffunction>


	<cffunction access="remote" output="false" returnformat="JSON" returntype="any" name="CreateReport" displayname="CreateReport" hint="This function create a new report with the required info and insert into the db." >
		<cfargument  required="true" name="reportTitle" type="string" hint="This is the name of the title of report">
		<cfargument  required="true" name="reportType" type="string" hint="This is the type of report.">
		<cfargument  required="true" name="reportPriority" type="string" hint="This is the priority of the report.">
		<cfargument  required="true" name="reportDescription" type="string" hint="This is a long description of the report.">
		<cfargument  required="false" default="" name="attachmentsTempDirectory" type="string" hint="This is the directory name of the report directory." >
		<cfargument required="false"  name="reportAssignee" type="numeric" hint="This holds the id of the person responsible to solve this.">
		<cfset utilComponent = createObject("component" ,'UtilComponent' )>
		<cfset getPersonId = "#variables.utilComponent.GetLoggedInPersonID()#">
		<cfquery name="queryInsertReport" result="resultInsertReport">
			INSERT INTO [REPORT_INFO] ([ReportTypeID], [ReportTitle], [Description], [PersonID], [Priority], [Assignee])
			VALUES
			(
			 <cfqueryparam cfsqltype="cf_sql_integer" null="false" value="#arguments.reportType#">,
			 <cfqueryparam cfsqltype="cf_sql_varchar" null="false" value="#arguments.reportTitle#">,
			 <cfqueryparam cfsqltype="cf_sql_varchar" null="false" value="#arguments.reportDescription#">,
			 <cfqueryparam cfsqltype="cf_sql_integer" null="false" value="#variables.getPersonId#"> ,
			 <cfqueryparam cfsqltype="cf_sql_varchar" null="false" value="#arguments.reportPriority#">,
			 <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportAssignee#">
			 )
		</cfquery>
		<cfif arguments.attachmentsTempDirectory NEQ "">
			<cfdirectory action="rename" directory="#ExpandPath('../assets/report-attachments/')&arguments.attachmentsTempDirectory#" newdirectory="#ExpandPath('../assets/report-attachments/')&resultInsertReport['IDENTITYCOL']#" >
			<cfdirectory action="list" directory="#ExpandPath('../assets/report-attachments/')&resultInsertReport['IDENTITYCOL']#" name="uploadedFiles">
			<cfset utilComponentInstance = CreateObject('component', 'UtilComponent')>
			<cfloop query="uploadedFiles">
				<cfquery name="queryInsertAttachments">
				INSERT INTO [REPORT_ATTACHMENTS] ([ReportId], [Attachment], [Uploader])
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_integer" null="false" value="#resultInsertReport['IDENTITYCOL']#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" null="false" value="#ExpandPath('../assets/report-attachments/#resultInsertReport['IDENTITYCOL']#/')&NAME#">,
					<cfqueryparam cfsqltype="cf_sql_integer" null="false" value="#utilComponentInstance.GetLoggedInPersonID()#">
				)
			</cfquery>
			</cfloop>
			<cfset AddComment('Created this report.', resultInsertReport['IDENTITYCOL'], 1)>
			<cfset AddComment('Added #uploadedFiles.RecordCount# Files intially.', resultInsertReport['IDENTITYCOL'], 1)>
			<cfreturn resultInsertReport['IDENTITYCOL']/>
		<cfelse>
			<cfset AddComment('Created this report.', resultInsertReport['IDENTITYCOL'], 1)>
			<cfreturn resultInsertReport['IDENTITYCOL']/>
		</cfif>
	</cffunction>


	<cffunction access="remote" output="false" returnType="string" returnFormat="JSON" name="DeleteTempAttachments" displayName="DeleteTempAttachment" hint="This function deletes the directory where the attachments uploded.">
		<cfargument required="true" type="string" name="directoryName" hint="This contains the name of the  directory">
		<cfdirectory action="delete" recurse="true" directory="#ExpandPath('../assets/report-attachments/')&arguments.directoryName#">
		<cfreturn true />
	</cffunction>


	<cffunction access="remote" output="false" returnType="array" returnFormat="JSON" name="GetAssigneeNames" displayName="GetAssigneeNames" hint="This function gets all the names of person who are working under the project.">
		<cfset assigneeNames = ArrayNew(1)>
		<cfquery name="queryGetProjectId">
				SELECT   [PersonID], [EmailID], CONCAT([FirstName], ' ', [LastName]) AS NAME FROM [PERSON] WHERE [ProjectID] = (SELECT [ProjectID] FROM [PERSON] where [EmailID] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.userEmail#">)
		</cfquery>
		<cfloop query="queryGetProjectId">
			<cfset ArrayAppend(variables.assigneeNames,{ 'id': '#PersonID#', 'name': '#NAME#', 'email': '#EmailID#' })>
		</cfloop>
		<cfreturn variables.assigneeNames>
	</cffunction>


	<cffunction access="remote" output="false" returnformat="JSON" returntype="struct" displayname="GetReportType" name="GetReportType" hint="This function return the list of available report types accepted." >
		<cfset reportTypes = StructNew()>
		<cfquery name="queryGetReportTypes">
			SELECT [ReportTypeID], [Title] FROM [REPORT_TYPE];
		</cfquery>
		<cfloop query="queryGetReportTypes">
			<cfset reportTypes['#ReportTypeID#'] = "#Title#">
		</cfloop>
		<cfreturn variables.reportTypes />
	</cffunction>


	<cffunction access="remote" output="false" returnformat="JSON" returnType="struct" name="GetReportOfId" displayname="GetReportOfId" hint="This function returns all information of a given report id.">
		<cfargument type="numeric" required="true" name="reportId" hint="This contains the id of any report.">
		<cfset response = StructNew()>
		<cfset dashBoardComponentInstance = CreateObject('component', 'DashboardComponent')>
		<cfquery name="queryGetReportInfo">
			SELECT RI.[ReportID], RT.[Title] AS Type, RI.[Priority] , RI.[ReportTitle], RI.[Description], RI.[DateReported], RI.[PersonID], RST.[Name] AS Status FROM
				[REPORT_INFO] AS RI
				INNER JOIN
				[REPORT_TYPE] AS RT
				ON RI.ReportTypeID =  RT.ReportTypeID
				INNER JOIN
				[REPORT_STATUS_TYPE] AS RST
				ON RI.StatusID = RST.StatusID
				WHERE RI.[ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
		</cfquery>
		<cfloop query="queryGetReportInfo">
			<cfset reporterName = dashBoardComponentInstance.GetUserName(PersonID)>
			<cfset response['id'] = "#ReportID#" >
			<cfset response['title'] = "#ReportTitle#">
			<cfset response['type'] = "#Type#">
			<cfset response['description'] ="#Description#">
			<cfset response['priority'] = "#Priority#">
			<cfset response['dateReported'] = "#DateReported#">
			<cfset response['personId'] = "#PersonID#">
			<cfset response['personName'] = "#reporterName['userName']#">
			<cfset response['status'] = "#Status#">
		</cfloop>
		<cfset UtilComponentInstance = CreateObject('component', 'UtilComponent')>
		<cfset response['dateReported'] = "#UtilComponentInstance.RelativeDate(response['dateReported'])#">
		<cfreturn response />
	</cffunction>


	<cffunction access="remote" returnformat="JSON" returntype="array" name="GetAllAttachmentsOfReport" displayname="GetAllAttachmentsOfReport" hint="This function retrieves all the attachments files uploaded for a report.">
		<cfargument required="true" name="reportId" type="string" hint="This contains the id of report to retrieve the attachments.">
		<cfset response = ArrayNew(1)>
		<cfset UtilComponentInstance = CreateObject('component', 'UtilComponent')>
		<cfquery name="queryGetAttachmentDirectoryPath">
			SELECT [DateAttached], [Attachment], [Uploader], [AttachmentID]
				FROM [REPORT_ATTACHMENTS]
				WHERE [ReportID] = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.reportId#">
		</cfquery>
		<cfloop query="queryGetAttachmentDirectoryPath">
			<cfif Uploader EQ utilComponentInstance.GetLoggedInPersonID()>
				<cfset isRemovableByUser = true>
			<cfelse>
				<cfset isRemovableByUser = false >
			</cfif>
			<cfset ArrayAppend(response,'{ "id": "#AttachmentID#", "uploader": "#Uploader#", "date" : "#DateAttached#", "file" : "#GetFileFromPath(Attachment)#", "fileType": "#ListFirst(FileGetMimeType(Attachment), "/")#", "isRemovable": "#isRemovableByUser#"}')>
		</cfloop>
		<cfreturn response />
	</cffunction>


	<cffunction access="remote" name="DownloadFile" displayName="DownloadFile" hint="This function downloads file attachment of project.">
		<cfargument required="false" name='path' displayname="path" hint="This contains the path of the file to download.">
		<cfheader name="Content-Type" value="application/octet-stream">
		<cfheader name="Content-Disposition" value="attachment;filename=#GetFileFromPath(arguments.path)#">
		<cfheader name="Content-Location" value="#URLEncodedFormat(ExpandPath(arguments.path))#">
		<cfcontent  type="application/octet-stream" file="#ExpandPath(arguments.path)#">
	</cffunction>


	<cffunction access="remote" output="false" returntype="string" returnformat="JSON"  name="DeleteAttachment" displayname="DeleteAttachment">
		<cfargument required="true"  name="attachmentId" displayname="attachmentId">
		<cfset utilComponentInstance = createObject('component', 'UtilComponent')>
		<cfquery name="queryGetAttachmentFilePath">
			SELECT [Attachment], [Uploader], [ReportID]
			FROM [REPORT_ATTACHMENTS]
			WHERE [AttachmentID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.attachmentId#">
		</cfquery>
		<cfloop query="queryGetAttachmentFilePath">
			<cfif '#Uploader#' EQ '#utilComponentInstance.GetLoggedInPersonID()#'>
				<cffile action="delete" file="#Attachment#">
				<cfquery>
					DELETE FROM [REPORT_ATTACHMENTS]
					WHERE [AttachmentId] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.attachmentId#">
				</cfquery>
				<cfset commentId =  addComment("deleted file #GetFileFromPath(AttachMent)#",ReportID, 1 )>
				<cfset wsPublish('report-file-delete', { "commentId": "#commentId#", "isDeleted": true }) >
			</cfif>
		</cfloop>
	</cffunction>


	<cffunction access="remote" output="false" returntype="string" returnformat="JSON" name="UploadAttachmentForReport" displayname="UplaodAttachmentForReport" hint="This function is for handling of attachment upload after once a report is made.">
		<cfargument required="true" type="string" name="reportId" hint="This contains the id of report to upload the attachment of.">
		<cfargument required="true" type="any" name="uploadedFile" hint="This argument contains the path of the uploaded file."/>
		<cfargument required="true" type="string" name="clientFileInfo" hint="This argument contains extra info of the client file.">
		<cfargument required="true"  type="string" name="uploadedDirectory" hint="This arguments will only have values when any files have been uploaded before.">
		<cfset utilComponentInstance = createObject('component', 'UtilComponent')>
		<cfset uploadStatus = UploadAttachment(arguments.uploadedFile, arguments.clientFileInfo, arguments.uploadedDirectory)>
		<cfif structKeyExists(uploadStatus,'renamedFileName')>
			<cfquery name="queryInsertAttachmentInTable" result="resultInsertAttachmentInTable">
				INSERT INTO [REPORT_ATTACHMENTS] ([ReportID], [Attachment] , [Uploader] ) VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#uploadStatus['renamedFileName']#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value='#utilComponentInstance.getLoggedInPersonID()#'>
				)
			</cfquery>
			<cfset commentId =  AddComment("added a file #arguments.clientFileInfo#.",arguments.reportId, 1)>
			<cfset wsPublish('report-file-upload',{"attachmentId": "#resultInsertAttachmentInTable['IDENTITYCOL']#"}) >
		<cfelse>
			<cfquery name="queryInsertAttachmentInTable" result="resultInsertAttachmentInTable">
				INSERT INTO [REPORT_ATTACHMENTS] ([ReportID], [Attachment] , [Uploader] ) VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value='#ExpandPath("../assets/report-attachments/#arguments.uploadedDirectory#/#arguments.clientFileInfo#")#'>,
					<cfqueryparam cfsqltype="cf_sql_integer" value='#utilComponentInstance.getLoggedInPersonID()#'>
				)
			</cfquery>
			<cfset commentId =  AddComment("added a file #arguments.clientFileInfo#.",arguments.reportId, 1)>
		</cfif>
	</cffunction>


	<cffunction access="remote" output="false" returntype="numeric" returnformat="JSON" name="AddComment" displayname="AddComment" hint="This function stores the given comment in to the databse.">
		<cfargument required="true" name="commentText" type="string" hint="It contains the comment itself.">
		<cfargument requried="true" name="reportId" type="numeric" hint="It contains the report id to which the comment will be added.">
		<cfargument required="false" default="0" name="isActivity" type="numeric" hint="Wheather the comment will be an activity or a simple content.">
		<cfset utilComponent = CreateObject('component', 'UtilComponent')>
		<cfset dashBoardComponent = CreateObject('component', 'DashboardComponent')>
		<cfquery result="resultAddComment">
			INSERT INTO [REPORT_COMMENTS] ( [ReportID], [Comment], [PersonID], [isActivity])
			VALUES (
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.commentText#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#utilComponent.GetLoggedInPersonID()#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.isActivity#">
			)
		</cfquery>
		<cfif arguments.isActivity EQ 1>

			<!---<cfset NotifyAllWatchers("#dashBoardComponent.getUserName(utilComponent.GetLoggedInPersonID())# #arguments.commentText#", arguments.reportId)>--->
			<cfset wsPublish('report-comment-post', {"commentId" : "#resultAddComment['IDENTITYCOL']#", "isActivity": "#arguments.isActivity#"})>
		<cfelse>
			<!---<cfset NotifyAllWatchers("#dashBoardComponent.getUserName(utilComponent.GetLoggedInPersonID())# has commented #arguments.commentText#", arguments.reportId)>--->
			<cfset wsPublish('report-comment-post', {"commentId" : "#resultAddComment['IDENTITYCOL']#", "isActivity": "#arguments.isActivity#"})>
		</cfif>
		<cfreturn resultAddComment['IDENTITYCOL']  />
	</cffunction>


	<cffunction access="remote" output="false" returntype="array" returnformat="JSON" name="GetCommentsForReport" displayname="GetCommentsForReport" hint="This function fetches all the comments form database of any specific report.">
		<cfargument required="true" type="numeric" name="reportId" hint="The report id of which to fetch all the comments.">
		<cfargument required="false"  type="numeric" name="activity" hint="A boolean for returning activity.">
		<cfset response = ArrayNew(1)>
		<cfset dashboardComponent = CreateObject('component', 'DashboardComponent')>
		<cfset utilComponent = CreateObject('component', 'UtilComponent')>
		<cfif IsDefined('arguments.activity')>
			<cfquery name="queryGetCommentsForReport">
			SELECT P.[PersonID], P.[FirstName], RC.[DateCommented], RC.[Comment], RC.[CommentID], RC.[IsActivity]
			FROM [REPORT_COMMENTS] RC
			INNER JOIN [PERSON] P
			ON P.[PersonID] = RC.[PersonID]
			WHERE [ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
			AND RC.[isActivity] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.activity#">
			ORDER BY RC.[DateCommented] ASC
		</cfquery>
		<cfelse>
			<cfquery name="queryGetCommentsForReport">
			SELECT P.[PersonID], P.[FirstName], RC.[DateCommented], RC.[Comment], RC.[CommentID], RC.[IsActivity]
			FROM [REPORT_COMMENTS] RC
			INNER JOIN [PERSON] P
			ON P.[PersonID] = RC.[PersonID]
			WHERE [ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
			ORDER BY RC.[DateCommented] ASC
		</cfquery>
		</cfif>
		<cfloop query="queryGetCommentsForReport">
			<cfset profileImage = DeserializeJSON(dashboardComponent.GetProfileImage(40, 40, PersonID))>
			<cfset ArrayAppend(response, '{ "userName":"#FirstName#", "id":"#CommentID#", "personId": "#PersonID#", "profileImage":"#profileImage["base64ProfileImage"]#", "comment": "#Comment#", "date":"#utilComponent.RelativeDate(DateCommented)#", "extension": "#profileImage["extension"]#", "isActivity": "#isActivity#" }')>
		</cfloop>
		<cfreturn response />
	</cffunction>


	<cffunction access="remote" output="true" returnformat="JSON" returntype="struct" name="GetCommentInfoOf" >
		<cfargument required="true" type="numeric" name="commentId">
		<cfset resposne = StructNew()>
		<cfset dashboardComponent = CreateObject('component', 'DashboardComponent')>
		<cfquery name="queryGetCommentInfo">
		SELECT RC.[DateCommented], P.[ProfileImage],RC.[isActivity], RC.[CommentID], RC.[PersonID], RC.[ReportID], RC.[Comment], CONCAT([FirstName],' ',[LastName]) AS Name
		FROM [REPORT_COMMENTS] RC
		INNER JOIN
		[PERSON] P
		ON P.[PersonID] = RC.[PersonID]
		WHERE [CommentID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.commentId#" >
	</cfquery>
		<cfloop query="queryGetCommentInfo">
			<cfset processedProfileImage = DeserializeJSON(dashboardComponent.GetProfileImage(40, 40, PersonID))>
			<cfset response['userName'] =  "#Name#">
			<cfset response['id'] = "#CommentID#">
			<cfset response['personID'] = "#PersonID#">
			<cfset response['profileImage'] = "#processedProfileImage['base64ProfileImage']#">
			<cfset response['isActivity'] = "#isActivity#">
			<cfset response['date'] = "#DateCommented#">
			<cfset response['extension'] = "#processedProfileImage['extension']#">
			<cfset response['comment'] = "#Comment#">
		</cfloop>
		<cfreturn response>
	</cffunction>


	<cffunction access="remote" output="false" returnformat="JSON" returntype="string" name="GetStatusOfReport" displayname="GetStatusOfReport" hint="This function fetches the status of the specified report id.">
		<cfargument required="true" type="numeric" name="reportId" >
		<cfquery name="queryGetStatusOfReport">
			SELECT RST.[Name], RST.[StatusID]
			FROM [REPORT_STATUS_TYPE] RST
			INNER JOIN [REPORT_INFO] RI
			ON RI.[StatusID] = RST.[StatusID]
			WHERE RI.[ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
		</cfquery>
		<cfloop query="queryGetStatusOfReport">
			<cfreturn '{ "status": "#Name#", "statusId": #StatusID# }'>
		</cfloop>
	</cffunction>


	<cffunction access="remote" output="false" returnformat="JSON" returntype="string" name="GetAssignedPersonID"  hint="This function finds if the report is assigned to someone or not.">
		<cfargument name="reportId" required="true" type="numeric">
		<cfquery name="queryGetAssignedPersonID">
			SELECT P.[FirstName], P.[PersonID]
			FROM [Person] P
			INNER JOIN [REPORT_INFO] RI
			ON RI.[Assignee] = P.[PersonID]
			WHERE RI.[ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
		</cfquery>
		<cfloop query="queryGetAssignedPersonID">
			<cfset response = '{ "assigneeName": "#FirstName#", "personId": "#PersonID#" }'>
		</cfloop>
		<cfreturn response>
	</cffunction>


	<cffunction access="remote" output="false" returntype="string" returnformat="JSON" name="IsWorkingAssignee" displayname="IsWorkingAssignee" hint="This function finds if any assignee is currently working on the report.">
		<cfargument required="true" name="reportId">
		<cfquery name="queryGetIsWorkingAssignee">
			SELECT [isWorking] FROM [REPORT_INFO] WHERE [ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
		</cfquery>
		<cfloop query="queryGetIsWorkingAssignee">
			<cfif isWorking EQ 1>
				<cfreturn true >
			<cfelse>
				<cfreturn false>
			</cfif>
		</cfloop>
	</cffunction>


	<cffunction access="remote" output="false" returntype="string" returnformat="JSON" name="StartWorkingOnReport" displayname="StartWorkingOnReport">
		<cfargument required="true" type="numeric" name="reportId" hint="This contains the working report id">
		<cfset reportStatus = DeserializeJSON(GetStatusOfReport(arguments.reportId))>
		<cfif reportStatus['status'] EQ 'OPEN' OR reportStatus['status'] EQ 'REOPEN'>
			<cfquery name="queryChangeOpenToInProgress">
				UPDATE [REPORT_INFO] SET [isWorking] = 1, [StatusID] = 2;
			</cfquery>
			<cfset commentId =  AddComment('changed the status from OPEN to IN PROGRESS', arguments.reportId, 1)>
			<cfset wsPublish('report-status-update', {"commentId": "#commentId#"})>
			<cfreturn '{ "commentId": #commentId# }'>
		<cfelse>
			<cfquery name="querySetIsWorking">
				UPDATE [REPORT_INFO] SET [isWorking] = 1;
			</cfquery>
			<cfset wsPublish('report-status-update', "Report working string changed.")>
		</cfif>
	</cffunction>


	<cffunction access="remote" returntype="string" returnformat="JSON" name="StopWorkingOnReport" displayname="StopWorkingOnReport" hint="This function stops progress on the specified report.">
		<cfargument required="true" name="reportId" type="numeric" hint="This function contains the working report id.">
		<cfset reportStatus = DeserializeJSON(GetStatusOfReport(arguments.reportId))>
		<cfif reportStatus['status'] EQ 'IN PROGRESS'>
			<cfif hasGoneToDone(reportId)>
				<cfquery name="queryChangeToReopen">
					UPDATE [REPORT_INFO] SET [isWorking] = 0, [StatusID] = 6;
				</cfquery>
				<cfset commentId =  AddComment('chaged the status from IN PROGRESS to REOPEN', arguments.reportId, 1)>
				<cfset ChangeAssignee(arguments.reportId,GetLastAssignee(arguments.reportId))>
				<cfset wsPublish('report-status-update', {"commentId": "#commentId#"})>
				<cfreturn '{"commentId": #commentId#}'>
			<cfelse>
				<cfquery name="queryChageToOpen">
					UPDATE [REPORT_INFO] SET [isWorking] = 0, [StatusID] = 1;
				</cfquery>
				<cfset commentId =  AddComment('changed the status from IN PROGRESS to OPEN', arguments.reportId, 1)>
				<cfset ChangeAssignee(arguments.reportId,GetLastAssignee(arguments.reportId))>
				<cfset wsPublish('report-status-update', {"commentId": "#commentId#"})>
				<cfreturn '{"commentId": #commentId# }'>
			</cfif>
		<cfelse>
			<cfquery name="queryStopIsWorking">
				UPDATE [REPORT_INFO] SET [isWorking] = 0;
			</cfquery>
			<cfset wsPublish('report-status-update',"Report working string changed.")>
		</cfif>
	</cffunction>


	<cffunction access="public" output="false" name="GetStatusNameOfStatusID">
		<cfargument type="numeric" name="statusId" required="true">
		<cfquery name="queryGetStatusNameFromStatusId">
			SELECT [Name] FROM [REPORT_STATUS_TYPE] WHERE [StatusID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.statusId#">
		</cfquery>
		<cfloop query="queryGetStatusNameFromStatusId">
			<cfreturn Name>
		</cfloop>
	</cffunction>


	<cffunction access="remote" output="false" returntype="string" returnformat="JSON"  name="SendReportToNextStatus" displayname="SendReportToNextStatus" hint="This function progresses the status of specified report." >
		<cfargument required="true" name="reportId" hint="This contains the report id of which to restore the state." >
		<cfargument required="true" name="assignee" hint="This conains the id of the person who will be responsible for the next process." >
		<cfset reportStatus = DeserializeJSON(GetStatusOfReport(arguments.reportId))>
		<cfif reportStatus['status'] EQ 'IN PROGRESS' OR reportStatus['status'] EQ 'IN REVIEW'>
			<cfquery name="querySendReportToNextStatus">
				UPDATE [REPORT_INFO]
				SET [StatusID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#reportStatus['statusId'] + 1#">,
				[isWorking] = 0,
				[Assignee] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.assignee#">
			</cfquery>
			<cfset commentId = AddComment("changed the status from #reportStatus['status']# to #GetStatusNameOfStatusID(reportStatus['statusId'] + 1)#", arguments.reportId, 1)>
			<cfset ChangeAssignee(arguments.reportId,GetLastAssignee(arguments.reportId))>
			<cfset wsPublish('report-status-update', { "commentId": "#commentId#" })>
			<cfreturn '{ "commentId": #commentId# }'>
		</cfif>
	</cffunction>


	<cffunction access="remote" output="false" returntype="string" returnformat="JSON"  name="FallBackToPreviousStatus" displayname="FallBackToPreviousState" hint="This function makes reports go back in state." >
		<cfargument required="true" name="reportId" hint="This contains the report id of which to restore the state." >
		<cfset reportStatus = DeserializeJSON(GetStatusOfReport(arguments.reportId))>
		<cfif reportStatus['status'] EQ 'IN REVIEW' OR reportStatus['status'] EQ 'DONE'>
			<cfquery name="querySendReportToPreviousStatus">
				UPDATE [REPORT_INFO] SET [StatusID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#reportStatus['statusId'] - 1#">,  [isWorking] = 1
			</cfquery>
			<cfset commentId =  AddComment('changed the state from #reportStatus["status"]# to #GetStatusNameOfStatusID(reportStatus["statusId"] - 1)#', arguments.reportId, 1)>
			<cfset ChangeAssignee(arguments.reportId, GetLastAssignee(arguments.reportId))>
			<cfset wsPublish('report-status-update', {"commentId": "#commentId#"})>
			<cfreturn '{ "commentId": #commentId# }'>
		</cfif>
	</cffunction>


	<cffunction access="remote" output="false" name="CloseReport" displayname="CloseReport" hint="This function closes the report by changing its state to closed.">
		<cfargument required="true" type="numeric" name="reportId" >
		<cfquery name="queryCloseReport">
			UPDATE [REPORT_INFO] SET [StatusID] = 5
		</cfquery>
		<cfset commentId = AddComment("has closed this report.", arguments.reportId, 1)>
		<cfset wsPublish('report-status-update', {"commentId": "#commentId#"}) >
		<cfreturn '{ "commentId": #commentId# }'>
	</cffunction>


	<cffunction access="remote" output="false" returntype="string" returnformat="JSON" name="ReopenReport" displayname="ReopenReport" hint="This function reopens the report by chagning the state to report.">
		<cfargument required="true" type="numeric" name="reportId">
		<cfquery name="queryCloseReport">
			UPDATE [REPORT_INFO] SET [StatusID] = 6;
		</cfquery>
		<cfset commentId = AddComment("has reopened this report.", arguments.reportId, 1)>
		<cfset wsPublish('report-status-update', {"commentId": "#commentId#"}) >
		<cfreturn '{ "commentId": #commentId# }'>
	</cffunction>


	<cffunction access="remote"  output="false" name="ChangeAssignee" displayname="ChangeAssignee"  hint="This function changes the assignee of the report.">
		<cfargument required="true" name="reportId" type="numeric" hint="Contains the report whose assignee will be changed." >
		<cfargument required="true" name="personId" type="numeric" hint="This contains the personId whom it will be assigned." >
		<cfquery name="queryChangeAssignee">
			UPDATE [REPORT_INFO] SET [Assignee] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.personId#">
		</cfquery>
	</cffunction>


	<cffunction access="remote" output="false" name="GetLastAssignee" displayname="GetLastAssignee" hint="This function finds the assigne to whom the report was assigned before." >
		<cfargument name="reportId" type="numeric" required="true"  >
		<cfquery name="queryGetLastAssignee">
			SELECT TOP(1) [PersonID]
			FROM [REPORT_COMMENTS]
			WHERE [ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
			AND [isActivity] = 1
			ORDER BY [DateCommented] DESC
		</cfquery>
		<cfloop query="queryGetLastAssignee">
			<cfreturn PersonID />
		</cfloop>
	</cffunction>


	<cffunction access="remote" output="true" returntype="any" returnformat="JSON" name="HasGoneToDone" displayname="HasGoneToDone" hint="This Function is responsible for finding if the report has ever gone to the state done.">
		<cfargument type="numeric" required="true" name="reportId" >
		<cfquery name="queryCheckHasGoneToDone">
			SELECT TOP(1) [PersonId]
			FROM [REPORT_COMMENTS]
			WHERE [Comment] LIKE '%to DONE%'
			AND [ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
			AND [isActivity] = 1
 			ORDER BY [DateCommented] DESC
		</cfquery>
		<cfloop query="queryCheckHasGoneToDone">
			<cfreturn true>
		</cfloop>
		<cfreturn false>
	</cffunction>


	<cffunction access="remote" output="false" returntype="string" returnformat="plain" name="GetHTMLInterfaceForReportButtons">
		<cfargument required="true" name="reportId" type="numeric" hint="This has the report id.">
		<cfset reportStatus = DeserializeJSON(GetStatusOfReport(arguments.reportId))>
		<cfset utilComponentInstance = CreateObject('component', 'UtilComponent')>
		<cfset assigneeInfo = DeserializeJSON(GetAssignedPersonID(arguments.reportId))>
		<cfif assigneeInfo['personId'] EQ utilComponentInstance.GetLoggedInPersonID()>
			<cfswitch expression="#reportStatus['status']#">
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
		<cfset assigneeInfo = DeserializeJSON(GetAssignedPersonID(arguments.reportId))>
		<cfif IsWorkingAssignee(arguments.reportId)>
			<cfreturn '{ "userName": "#assigneeInfo["assigneeName"]#", "msg": "is assigned and working currently." }'>
		<cfelse>
			<cfreturn '{ "userName": "#assigneeInfo["assigneeName"]#", "msg":"is assigned but not working currently." }' >
		</cfif>
	</cffunction>


	<cffunction access="remote" returnformat="JSON" returntype="boolean" name="IsFileAlreadyExist" >
		<cfargument required="true" type="string" name="fileName" >
		<cfargument required="true" name="reportId" type="any">
		<cfdirectory action="list" directory="#ExpandPath('../assets/report-attachments/#arguments.reportId#')#" name="queryDirectoryList" >
		<cfloop query="queryDirectoryList">
			<cfif arguments.fileName EQ Name>
				<cfreturn true>
			</cfif>
		</cfloop>
		<cfreturn false>
	</cffunction>


	<cffunction access="remote" output="false" name="NotifyAllWatchers" displayname="NotifyAllWatchers">
		<cfargument required="true" name="message" type="string">
		<cfargument required="true" name="reportId" type="numeric">
		<cfset utilComponentInstance = CreateObject('component', 'UtilComponent')>
		<cfset loggedInPersonId = "#utilComponentInstance.GetLoggedInPersonId()#">
		<cfquery name="queryGetAllWatcher">
			SELECT [EmailID]
			FROM [WATCHER] RW
			INNER JOIN
			[PERSON] P
			ON P.[PersonID] = RW.[PersonID]
			WHERE
			[ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
			AND
			[PersonID] <> <cfqueryparam cfsqltype="cf_sql_integer" value="#loggedInPersonId#">
		</cfquery>
		<cfloop query="queryGetAllWatcher">
			<cfset sendEmailTo(EmailID, "#arguments.message#")>
		</cfloop>
	</cffunction>


	<cffunction access="remote" output="false" returntype="boolean" returnformat="JSON"  name="CheckIfWatching" displayname="CheckIfWatching">
		<cfargument required="true" name="reportId" type="numeric">
		<cfset utilComponentInstance = CreateObject('component', 'UtilComponent')>
		<cfset loggedInPersonId = "#utilComponentInstance.GetLoggedInPersonId()#">
		<cfquery name="queryCheckIfAlredyWatching">
			SELECT [PersonID]
			FROM [WATCHER]
			WHERE
			[PersonID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#loggedInPersonId#">
			AND [ReportID] = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reportId#">
		</cfquery>
		<cfif queryCheckIfAlredyWatching.RecordCount EQ 0>
			<cfreturn false>
		<cfelse>
			<cfreturn true>
		</cfif>
	</cffunction>


	<cffunction access="remote" output="false" returnformat="JSON"  name="ToggleWatcher" displayname="AddToWatcher">
		<cfargument required="true" name="reportId" type="numeric">
		<cfset utilComponentInstance = CreateObject('component', 'UtilComponent')>
		<cfset loggedInPersonId = "#utilComponentInstance.GetLoggedInPersonId()#">
		<cfif NOT CheckIfWatching(arguments.reportId) EQ 'true'>
			<cfquery name="queryAddToWatcher">
				INSERT INTO [WATCHER] ([PersonID], [ReportID]) VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#loggedInPersonId#">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.reportId#">
				)
			</cfquery>
			<cfreturn true>
		<cfelse>
			<cfquery name="queryDeleteWatcher">
				DELETE FROM [WATCHER]
				WHERE [PersonID] = <cfqueryparam cfsqltype="cf_sql_numeric" value="#loggedInPersonId#">
				AND [ReportID] = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.reportId#">
			</cfquery>
			<cfreturn false>
		</cfif>
	</cffunction>


	<cffunction access="remote" output="false" name="sendEmailTo" returnformat="JSON" returntype="boolean" >
		<cfargument required="true" type="string" name="emailId" >
		<cfargument required="true" name="messgae" type="string">
		<cfmail from="trackingticket@gmail.com" to="#arguments.emailId#" subject="Greetings" >
				#arguments.message#
		</cfmail>
		<cfreturn true>
	</cffunction>


</cfcomponent>
