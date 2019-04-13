<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <link rel="shortcut icon" href="../favicon.ico" type="image/x-icon">
  <link rel="stylesheet" href="../css/global-style.css">
  <link rel="stylesheet" href="../css/form-styling.css">
  <link rel="stylesheet" href="../css/font-awesome.min.css">
  <link rel="stylesheet" href="../css/navbar-style.css">
  <link rel="stylesheet" href="../css/logged-in-navbar-style.css">
  <link rel="stylesheet" href="../css/footer-style.css">
  <link rel="stylesheet" href="../css/jquery.dataTables.css">
  <link rel="stylesheet" href="../css/responsive.dataTables.css">
  <link rel="stylesheet" href="../css/tab-style.css">
  <link rel="stylesheet" href="../css/users-style.css">
  <link rel="stylesheet" href="../css/modal-style.css">

  <script src="../js/jquery-3.0.0.min.js"></script>
  <script src="../js/navbar-functionality.js"></script>
  <script src="../js/jquery.dataTables.js"></script>
  <script src="../js/dataTables.responsive.js"></script>
  <script src="../js/form-functionality.js"></script>
  <script src="../js/users-functionality.js"></script>


  <title>Users | Ticket Tracking System</title>
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
            <li><a href="reports.cfm" class="navlink"><i class="number-badge">0</i> Reports</a></li>
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
    <div class="container" id="pageBody">

      <div class="tab">
        <ul class="tab-navs">
          <li class="tab-nav-active" id="usersListWindowTab"><i class="fa fa-user"></i><span class="tab-info">
              <p>Users in this project</p>
            </span></li>
          <li class="tab-nav-active" id="inviteUsersWindowTab"><i class="fa fa-user-plus"></i><span class="tab-info">
              <p>Invite Users to the project</p>
            </span></li>
        </ul>
        <div class="tab-windows">
          <form action="" method="" novalidate>
            <div class="tab-window" id="userListWindow">
              <div class="header-wrapper">
                <h1 class="header">Users List</h1>
                <div class="header-info">This is a list of users currently in your project.</div>
              </div>
              <table class="data-table">
                <thead>
                  <th>#</th>
                  <th>Avatar</th>
                  <th>FullName</th>
                  <th>EmailID</th>
                  <th>Contact</th>
                  <th>Title</th>
                  <th>Since</th>
                </thead>
                <tbody>

                </tbody>
              </table>
            </div>
        </div>
        <div class="tab-window" id="inviteUserWindow">
          <div class="header-wrapper">
            <div class="header-text">
              <h1 class="header">Invited Users</h1>
              <div class="header-info">This is a list of users currently has got invitation to join.</div>
            </div>
            <div class="action-buttons">
              <button class="invite-btn">Invite a User</button>
              <button class="bulk-invite-btn">Bulk Invite</button>
            </div>
          </div>

          <div class="background-popup">
            <div class="modal" id="bulkInviteModal">
              <div class="modal-header">
                <h3>Invite Users</h3>
                <a href="#" class="modal-close-btn"><i class="fa fa-times"></i></a>
              </div>
              <div class="modal-body">
                <h3>Adding multiple users.</h2>
                  <div class="form-group">
                    <div class="input-group">
                      <div class="form-wrapper">
                        <textarea required class="form-control" name="emailLists" id="emailListTextArea" cols="15"
                          rows="5"></textarea>
                        <div class="label-control label-over">Email Lists</div>
                      </div>
                      <div class="validation-feedback" id="emailListFeedback">
                        <p class="error-empty">Email lists should at least have 2 emails.</p>
                        <p class="error-invalid">Please double check the email list.</p>
                        <p class="assist-valid">Please enter email list with ';' separated.</p>
                      </div>
                    </div>
                  </div>
              </div>
              <div class="modal-actions">
                <button class="submit-btn">Send Invitation</button>
                <button class="cancel-btn">Cancel </button>
              </div>
            </div>

            <div class="modal" id="inviteModal">
              <div class="modal-header">
                <h3>Invite A User</h3>
                <a href="#" class="modal-close-btn"><i class="fa fa-times"></i></a>
              </div>
              <div class="modal-body">
                <h3>Adding a single user.</h2>
                  <div class="form-group">
                    <div class="input-group">
                      <div class="form-wrapper">
                        <input type="text" name="userEmail" class="form-control" id="userEmailInput" required
                          pattern="[a-zA-Z]+(\.?[a-zA-Z0-9]+)+@[a-zA-Z]+(\.co)?\.([a-z]{2,3})">
                        <div class="label-control label-under">User Email</div>
                      </div>
                      <div class="validation-feedback" id="fail">
                        <p class="error-empty">User email is required.</p>
                        <p class="error-invalid"></p>
                        <p class="assist-valid">The user must not be an already registered user.</p>
                      </div>
                    </div>
                    <div class="input-group">
                      <input type="checkbox" class="form-control-checkbox" id="userTitleCheckBox">
                      <label for="userTitleCheckBox">Let me decide the title of the user</label>
                    </div>
                    <div class="input-group">
                      <div class="form-wrapper">
                        <select class="form-control" name="reportPriority" id="reportPrioritySelect" disabled>
                          <option value="1">Developer</option>
                          <option value="2">Reviewer</option>
                          <option selected value="3">Tester</option>
                        </select>
                        <div class="label-control label-over">Select Title</div>
                      </div>
                      <div class="validation-feedback" id="reportPriorityFeedback">
                        <p class="assist-valid">This specifies how important it is.</p>
                      </div>
                    </div>

                  </div>
              </div>
              <div class="modal-actions">
                <button class="submit-btn">Send Invitation</button>
                <button class="cancel-btn">Cancel </button>
              </div>
            </div>

          </div>


          <table class="data-table">

          </table>

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
          <li><a href="users.cfm" class="navlink"></i> Users</a></li>
          <li><a href="reports.cfm" class="navlink"> Reports</a></li>
          <li><a href="#" class="navlink"> About Project</a></li>
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
  </div>
  </div>
</body>

</html>