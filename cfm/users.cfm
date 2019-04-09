<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <link rel="stylesheet" href="../css/global-style.css">
  <link rel="stylesheet" href="../css/form-styling.css">
  <link rel="stylesheet" href="../css/font-awesome.min.css">
  <link rel="stylesheet" href="../css/navbar-style.css">
  <link rel="stylesheet" href="../css/logged-in-navbar-style.css">
  <link rel="stylesheet" href="../css/footer-style.css">
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


  <div class="fluid-container">
    <div class="container">
      
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
</body>

</html>