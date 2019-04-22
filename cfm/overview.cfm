<cfif session.userEmail EQ "">
  <cflocation  url="login.cfm" addtoken="false">
</cfif>

<cfinvoke component="Assignment_Project_BTS.CFCs.UtilComponent" method="IsLoggedInPersonAnAdmin" returnvariable="isAdmin" />
<cfinvoke component="Assignment_Project_BTS.CFCs.UtilComponent" method="GetTotalNumberOfReports" returnvariable="reportCount" />

<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="theme-color" content="#87ceeb">

  <link rel="icon" href="../img/insect.png">
  <link rel="stylesheet" href="../css/font-awesome.min.css">
  <link rel="stylesheet" href="../css/global-style.css">
  <link rel="stylesheet" href="../css/navbar-style.css">
  <link rel="stylesheet" href="../css/form-styling.css">
  <link rel="stylesheet" href="../css/logged-in-navbar-style.css">
  <link rel="stylesheet" href="../css/footer-style.css">
  <link rel="stylesheet" href="../css/modal-style.css">
  <link rel="stylesheet" href="../css/progress-bar-style.css">
  <link rel="stylesheet" href="../css/overview-style.css">

  <script src="../js/jquery-3.0.0.min.js"></script>
  <script src="https://canvasjs.com/assets/script/canvasjs.min.js"></script>
  <script src="../js/navbar-functionality.js"></script>
  <script src="../js/form-functionality.js"></script>
  <script src="../js/overview-functionality.js"></script>
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>Overview | Ticket Tracking System</title>
</head>

<body>

  <div class="navbar">
    <div class="container-fluid">
      <div class="container">
        <nav>
          <div class="branding">
            <img class="brand-icon" src="../img/insect.png">
            <p class="brand-text">Ticket Tracking System</p>
            <img class="profile-img" src="../img/placeholder-person.png" alt="Profile Imamge" class="profile-img">
          </div>
          <ul class="navlist">
            <li id="profile-img-li"><a href="#" class="navlink"><img class="profile-img"
                  src="../img/placeholder-person.png" /></a></li>
            <li><a href="overview.cfm" class="navlink active"><i class="fa fa-dashboard"></i> Overview</a></li>
            <cfoutput>
              <li><a href="reports.cfm" class="navlink"><i class="number-badge">#reportCount#</i> Reports</a></li>
            </cfoutput>
            <li><a href="users.cfm" class="navlink"><i class="fa fa-user"></i> Users</a></li>
            <li><a href="#" id="logOutButton" class="navlink"><i class="fa fa-sign-out"></i> Log out</a></li>
          </ul>
          <div class="nav-toggler">
            <a href="#" class="fa fa-arrow-up"></a>
          </div>
        </nav>
      </div>
    </div>
  </div>

  <div class="container-fluid">
    <div class="container" id="page-body">

      <div class="welcome-header">
        <h1 class="header">Welcome, <span id="usrName"></span></h1>
        <div class="header-info">This is your dashboard where you can get all the infomration of your project.</div>
      </div>

      <div class="grid-box">
        <div class="reports-info">

          <div class="summary-info-heading">
            <div class="info open-info">
              <p><span class="number-badge">0</span> Opened</p>
            </div>
            <div class="info assigned-info">
              <p><span class="number-badge">0</span> Assigned</p>
            </div>
            <div class="info closed-info">
              <p><span class="number-badge">0</span> Closed</p>
            </div>
          </div>
          <div id="assignedToMe" class="report-section">
            <div class="heading-info">
              <i class="fa fa-user"></i>
              <div class="heading">Assigned To Me</div>
              <div class="desc">These are the reports that have been assigned to me.</div>
            </div>
          </div>
          <div class="report-section" id="watchedByMe">
            <div class="heading-info">
              <i class="fa fa-eye"></i>
              <div class="heading">Watching Reports</div>
              <div class="desc">These are the reports that I am intrested in.</div>
            </div>
          </div>
        </div>
        <div class="new-report-btn">
          <button class="report-btn"><i class="fa fa-plus"></i> New Report</button>
        </div>
        <div class="report-statistics">
          <div class="statistics">
            <div id="open-chart"></div>
            <p class="stat-desc">Currently Opened Reports</p>
          </div>

          <div class="statistics">
            <div id="in-progress-chart"></div>
            <p class="desc">In progress reports</p>
          </div>

          <div class="statistics">
            <div id="closed-chart"></div>
            <p class="stat-desc">Closed Reports</p>
          </div>
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
          <li><a href="overview.cfm" class="navlink"></i>Overview</a></li>
          <li><a href="users.cfm" class="navlink">Users</a></li>
          <li><a href="reports.cfm" class="navlink"> Reports</a></li>
          <li><a href="./about_this_project.cfm" class="navlink"> About Project</a></li>
        </ul>
      </div>
      <hr />
      <div class="footer-wrapper">
        <p class="copyright-info"><i class="fa fa-copyright"></i> Ticket Tracking System</p>
        <div class="social-links">
          <a href="#"><i class="fa fa-facebook-square"></i></a>
          <a href="#"><i class="fa fa-twitter"></i></a>
          <a href="#"><i class="fa fa-github"></i></a>
        </div>
      </div>
    </div>

    <div class="background-popup">
      <div class="modal">
        <div class="modal-header">
          <h3>Create New Report</h3>
          <a href="#" class="modal-close-btn"><i class="fa fa-times"></i></a>
        </div>
        <div class="modal-body">

          <div class="form-group">
            <form>
              <div class="input-group">
                <div class="form-wrapper">
                  <input type="text" maxlength="200" class="form-control" name="reportTitle" id="reportTitleInput"
                    required>
                  <div class="label-control label-under">Report Title</div>
                </div>
                <div class="validation-feedback" id="firstNameFeedBack">
                  <p class="error-empty">You can not skip a report's title.</p>
                  <p class="assist-valid">Report Title should be concise and meaningfull.</p>
                </div>
              </div>
              <div class="flex-wrapper">
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
              <div class="input-group">
                <div class="form-wrapper">
                  <textarea required minlength="50" class="form-control" name="reportDescription"
                    id="reportDescriptionTextarea" cols="30" rows="10" maxlength="255"></textarea>
                  <div class="label-control label-over">Report description</div>
                </div>
                <div class="validation-feedback" id="reportDescriptionFeedback">
                  <p class="error-empty">Report must have some information about something.</p>
                  <p class="error-invalid">Please elaborate with some sentences</p>
                  <p class="assist-valid">The description should be precise, to the point and informative.</p>
                </div>
              </div>
              <div class="drag-drop-box-container">
                <div class="drag-drop-info">
                  <i class="fa fa-upload"></i>
                  <div class="upload-info">
                    <input type="file" id="dragDropFileInput" name="files[]" multiple />
                    <span id="not-uploading" class="initial-drop-msg"><label for="dragDropFileInput"
                        class="upload-action">Choose a file </label>
                      or drag it here.</span>
                    <span class="success-drop-msg">Uploaded. <label for="dragDropFileInput" class="upload-action">Have
                        more?</label></span>
                    <div id="uploading">
                      <div class="progress-container">
                        <div class="bar">
                          <div class="percentage-info">
                            0%
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="label-control">Please Enter file not more than 2MB.</div>
          </div>
          </form>
        </div>
        <div class="modal-actions">
          <button class="submit-btn">Report This</button>
          <button class="cancel-btn">Cancel </button>
        </div>
      </div>
</body>

</html>