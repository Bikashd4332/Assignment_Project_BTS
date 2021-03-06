<cfif session.userEmail EQ "">
    <cflocation url="login.cfm" addtoken="false">
</cfif>

<cftry>
    <cfif isDefined('url.id')>
        <cfinvoke component="Assignment_Project_BTS.CFCs.ReportComponent" method="IsReportValidForUser"
            argumentcollection="#{reportId: url.Id}#" returnvariable="local.isValid" />
        <cfelse>
            <h1>Error. Something wrong happened. </h1>
            <cfabort>
    </cfif>

    <cfif NOT local.isValid>
        <h1>Error 404 not found!</h1>
        <cfabort>
    </cfif>

    <cfinvoke component="Assignment_Project_BTS.CFCs.UtilComponent" method="GetTotalNumberOfReports"
        returnvariable="local.reportCount" />
    <cfcatch type="any">
        <cfinclude template="maintenance.cfm">
        <cfabort>
    </cfcatch>
        
</cftry>

<cfwebsocket name="cfWebSocketObj" onMessage="onMessageHandler" onOpen="onOpenHandler" />
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="theme-color" content="#87ceeb">
    <link rel="shortcut icon" href="../favicon.ico" type="image/x-icon">
    <link rel="stylesheet" href="../css/font-awesome.min.css">

    <link rel="stylesheet" href="../css/global-style.css">
    <link rel="stylesheet" href="../css/navbar-style.css">
    <link rel="stylesheet" href="../css/logged-in-navbar-style.css">
    <link rel="stylesheet" href="../css/footer-style.css">
    <link rel="stylesheet" href="../css/form-styling.css">
    <link rel="stylesheet" href="../css/modal-style.css">
    <link rel="stylesheet" href="../css/progress-bar-style.css">
    <link rel="stylesheet" href="../css/spinner-style.css">
    <link rel="stylesheet" href="../css/toast-style.css">
    <link rel="stylesheet" href="../css/report-style.css">

    <script src="../js/jquery-3.0.0.min.js"></script>
    <script src="../js/navbar-functionality.js"></script>
    <script src="../js/form-functionality.js"></script>
    <script src="../js/toast_service.js"></script>
    <script src="../js/report-functionality.js"></script>

    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Report | Ticket Tracking System</title>

</head>

<body>
    <div class="navbar">
        <div class="container-fluid">
            <div class="container">
                <nav>
                    <div class="branding">
                        <img class="brand-icon" src="../img/insect.png">
                        <p class="brand-text">Ticket Tracking System</p>
                        <img src="../img/placeholder-person.png" alt="Profile Imamge" class="profile-img">
                    </div>
                    <ul class="navlist">
                        <li id="profile-img-li"><a href="#" class="navlink"><img class="profile-img"
                                    src="../img/placeholder-person.png" /></a>
                        </li>
                        <li><a href="overview.cfm" class="navlink"><i class="fa fa-dashboard"></i>
                                Overview</a>
                        </li>
                        <cfoutput>
                            <li><a href="reports.cfm" class="navlink"><i class="number-badge">#local.reportCount#</i>
                                    Reports</a></li>
                        </cfoutput>

                        <li><a href="users.cfm" class="navlink"><i class="fa fa-user"></i> Users</a></li>

                        <li><a href="#" class="navlink log-out-btn"><i class="fa fa-sign-out"></i> Log out</a>
                        </li>
                    </ul>
                    <div class="nav-toggler">
                        <a href="#" class="fa fa-arrow-up"></a>
                    </div>
                </nav>
            </div>
        </div>
    </div>

    <div class="container-fluid">
        <div class="sticky-container">
            <div class="report">
                <div class="report-title">
                    <span class="report-id"></span>
                    <span class="report-title"></span>
                </div>
            </div>
            <div class="report-info-status">
                <div class="report-status">
                </div>
                <div class="badge report-priority">
                    <span class="badge-label">report priority</span>
                    <span class="badge-value "></span>
                </div>
                <div class="badge report-type">
                    <span class="badge-label">report status</span>
                    <span class="badge-value "></span>
                </div>
                <button class="watch-btn"></button>
                <button class="edit-btn"><i class="fa fa-pencil-square-o"></i> Edit</button>
                <div class="status-action">
                </div>
            </div>
        </div>
    </div>

    <div class="container-fluid">
        <div class="container" id="pageBody">
            <div class="report">
                <div class="report-title">
                    <span class="report-id"></span>
                    <span class="report-title"></span>
                </div>
            </div>
            <div class="report-info-status">
                <div class="report-status">
                </div>
                <div class="badge report-priority">
                    <span class="badge-label">report priority</span>
                    <span class="badge-value "></span>
                </div>
                <div class="badge report-type">
                    <span class="badge-label">report status</span>
                    <span class="badge-value "></span>
                </div>
                <button class="watch-btn"></button>
                <button class="edit-btn"><i class="fa fa-pencil-square-o"></i> Edit</button>
                <div class="status-action">
                </div>
            </div>
            <div class="extended-info" id="reporterInfo">
                <span class="user-name"></span> Added the report <span class="date-info"></span>.
            </div>
            <div class="extended-info" id="assigneeInfo">
                <span class="user-name">Bikash Das</span><span class="msg"> is assigned but not currently
                    working.</span>
            </div>
            <div class="report-description"></div>
            <div class="attachments">
                <div class="file-section">
                    <div class="upload-btn">
                        <input type="file" name="file[]" id="fileUploadInput" multiple>
                        <label for="fileUploadInput"><i class="fa fa-plus"></i></label>
                    </div>
                </div>
                <div class="spinner-container">
                    <div class="lds-ring">
                        <div></div>
                    </div>
                </div>
                <div class="file-upload">
                    <div class="progress-container">
                        <div class="bar">
                            <div class="percentage-info">
                                0%
                            </div>
                        </div>
                    </div>
                    <button class="file-cancel-btn"><i class="fa fa-times"></i></button>
                </div>
            </div>
            <div class="tab">
                <ul class="tab-navs">
                    <li class="tab-nav" id="activityTab">All</li>
                    <li class="tab-nav selected" id="commentsTab">Comments</li>
                </ul>
                <div class="tab-window" id="commentWindow">
                    <div class="comment-poster-container">
                        <div class="profile-image-container">
                            <img src="../img/placeholder-person.png" width="40" height="40" class="profile-img">
                        </div>
                        <div class="comment-editor-container">
                            <div class="comment-editor">
                                <p class="comment-editor-header">Write Comment here.</p>
                                <textarea id="commentTextArea"></textarea>
                            </div>
                            <a href="#" class="comment-submit-btn">Post it</a>
                        </div>
                    </div>
                    <div class="history">

                    </div>
                </div>

                <div class="tab-window" id="activityWindow">
                    <div class="history">

                    </div>
                    <div class="spinner-container">
                        <div class="lds-ring">
                            <div></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </div>

    <div class="background-popup">
        <div class="modal" id="deleteConfirmationModal">
            <div class="modal-header">
                <h3>Confirm Deletion</h3>
                <a href="#" class="modal-close-btn"><i class="fa fa-times"></i></a>
            </div>
            <div class="modal-body">
                <h3 class="confirmation-msg">This attachment will be permanently deleted.</h3>
            </div>
            <div class="modal-actions">
                <button class="submit-btn">Yes, Delete it.</button>
                <button class="cancel-btn">No, Don't Delete it.</button>
            </div>
        </div>

        <div class="modal" id="chooseAssigneeModal">
            <div class="modal-header">
                <h3>Choose Assignee</h3>
                <a href="#" class="modal-close-btn"><i class="fa fa-times"></i></a>
            </div>
            <div class="modal-body">
                <h3 class="confirmation-msg">Choose someone who can do this better.</h3>
                <div class="form-group">
                    <div class="input-group">
                        <div class="form-wrapper auto-complete">
                            <input type="text" class="form-control" name="reportAssignee" id="asigneeInput" required>
                            <div class="label-control label-under">Asignee</div>
                            <div class="auto-complete-container">
                                <ul class="auto-complete-list">

                                </ul>
                            </div>
                        </div>
                        <div class="validation-feedback" id="asigneeFeedback">
                            <p class="assist-valid">Type and click on the suggestion for selection.</p>
                            <p class="error-invalid">The name you typed not belongs to any of your teammates.</p>
                            <p class="error-empty">You need to assign this to somebody or yourself.</p>
                        </div>
                    </div>
                </div>
                <div class="modal-actions">
                    <button class="submit-btn">Choose</button>
                    <button class="cancel-btn">Cancel</button>
                </div>
            </div>
        </div>
        <div class="modal" id="changeInfoModal">
            <div class="modal-header">
                <h3>Change In Report</h3>
                <a href="#" class="modal-close-btn"><i class="fa fa-times"></i></a>
            </div>
            <div class="modal-body">
                <h3 class="confirmation-msg">Change report priority and type.</h3>
                <div class="form-group">
                    <div class="input-group">
                        <div class="form-wrapper">
                            <select class="form-control" name="reportType" id="reportTypeSelect">
                            </select>
                            <div class="label-control label-over">Select Report Type</div>
                        </div>
                        <div class="validation-feedback" id="reportTypeFeedback">
                            <p class="error-empty">Report type is needed for development.</p>
                            <p class="assist-valid">This specifies what type of report it is.</p>
                        </div>
                    </div>
                    <div class="input-group">
                        <div class="form-wrapper">
                            <select class="form-control" name="reportPriority" id="reportPrioritySelect">
                                <option value="high">HIGH</option>
                                <option value="medium">MED</option>
                                <option selected value="low">LOW</option>
                            </select>
                            <div class="label-control label-over">Select Report Priority</div>
                        </div>
                        <div class="validation-feedback" id="reportPriorityFeedback">
                            <p class="assist-valid">This specifies how important it is.</p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-actions">
                <button class="submit-btn">Change</button>
            </div>
        </div>
    </div>
    </div>

    <div class="footer">
        <div class="container">
            <div class="footer-wrapper">
                <div class="branding">
                    <img class="brand-icon" src="../img/insect.png">
                    <p class="brand-text">Ticket Tracking System</p>
                </div>
                <ul class="navlist">
                    <li><a href="overview.cfm" class="navlink">Overview</a></li>
                    <li><a href="reports.cfm" class="navlink">Reports</a></li>
                    <li><a href="users.cfm" class="navlink">Users</a></li>
                    <li><a href="#" class="navlink log-out-btn">Log out</a></li>
                </ul>
            </div>
            <hr />
            <div class="footer-wrapper">
                <p class="copyright-info">Ticket Tracking System <i class="fa fa-copyright"></i></p>
                <div class="social-links">
                    <a href="#"><i class="fa fa-facebook-square"></i></a>
                    <a href="#"><i class="fa fa-twitter"></i></a>
                    <a href="#"><i class="fa fa-github"></i></a>
                </div>
            </div>
        </div>

    <div class="toast-container"></div>

</body>

</html>