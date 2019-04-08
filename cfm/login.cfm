<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <meta name="theme-color" content="#87ceeb">
  
  <link rel="icon" href="../img/insect.png">
  <link rel="stylesheet" href="../css/global-style.css">
  <link rel="stylesheet" href="../css/navbar-style.css">
  <link rel="stylesheet" href="../css/footer-style.css">
  <link rel="stylesheet" href="../css/form-styling.css">
  <link rel="stylesheet" href="../css/login-style.css">
  <link rel="stylesheet" href="../css/font-awesome.min.css">

  <script src="../js/jquery-3.0.0.min.js"></script>
  <script src="../js/navbar-functionality.js"></script>
  <script src="../js/form-functionality.js"></script>
  <script src="../js/login-functionality.js"></script>
  <title>Log In | Ticket Tracking System</title>
</head>
<body>
  <div class="navbar">
    <div class="container-fluid">
      <div class="container">
        <nav>
          <div class="branding">
            <img class="brand-icon" src="../img/insect.png">
            <p class="brand-text">Ticket Tracking System</p>
          </div>
          <ul class="navlist">
            <li><a href="../index.cfm" class="navlink"><i class="fa fa-home"></i> Home</a></li>
            <li><a href="login.cfm" class="active navlink"><i class="fa fa-sign-in"></i> Log In</a></li>
            <li><a href="About_This_Project.cfm" class="navlink"><i class="fa fa-info-circle"></i> About This Project</a></li>
          </ul>
          <div class="nav-toggler">
            <a href="#" class="fa fa-arrow-up"></a>
          </div>
        </nav>
      </div>
    </div>
  </div>

  <div class="container-fluid">
    <div class="container" style="padding: 30px;">
        <div class="login">
          <div class="login-user-select-container">
            <img class="login-img" src="../img/login-placeholder.jpg" alt="" srcset="">
          </div>
          <div class="login-form-container">
            <h4 id="login-error-msg">Incorrect Email or Password.</h4>
              <img src="../img/insect.png" alt="" srcset="" class="brand-icon">
              <h3 class="login-header">Please Login</h3>
              <div class="form-group">
                  <form action="#" novalidate>
                    <div class="input-group">
                      <div class="form-wrapper">
                        <input type="text" required name="userEmail" pattern="[a-zA-Z]+(\.?[a-zA-Z0-9]+)+@[a-zA-Z]+(\.co)?\.([a-z]{2,3})" class="form-control">
                        <div class="label-control label-under">Email ID</div>
                      </div>
                      <div class="validation-feedback">
                          <p class="error-empty">You can't keep this field empty.</p>
                          <p class="error-invalid">Please enter valid and registered email address.</p>
                        </div>
                    </div>
                    <div class="input-group">
                      <div class="form-wrapper">
                        <input type="password" required name="userPassword" class="form-control">
                        <div class="label-control label-under">Password</div>
                      </div>
                      <div class="validation-feedback">
                          <p class="error-empty">You can't keep this field empty.</p>
                        </div>
                    </div>

                    <button id="loginButton" class="submit-btn">Log In</button>
                  </form>
                </div>
              <h4 class="signup-msg">Don't have an account <wbr><a href="signup.cfm">Make One</a>.</h4>
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
                    <li><a href="../index.cfm" class="navlink"></i> Home</a></li>
                    <li><a href="login.cfm" class="navlink"></i> Log In</a></li>
                    <li><a href="About_This_Project.cfm" class="navlink">About This Project</a></li>
                  </ul>
            </div>
            <hr/>
            <div class="footer-wrapper">
              <p class="copyright-info"><i class="fa fa-copyright"></i> Ticket Tracking System</p>
              <div class="social-links">
                <a href="#"><i class="fa fa-facebook-square"></i></a>
                <a href="#"><i class="fa fa-twitter"></i></a>
                <a href="#"><i class="fa fa-github"></i></a>
              </div>
            </div>
          </div>

</body>
</html>