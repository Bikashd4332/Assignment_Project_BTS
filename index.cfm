<cfif session.userEmail NEQ "" >
  <cflocation  url="cfm/overview.cfm" addtoken = "false" >
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Home | Ticket Tracking System</title>
  <meta name="theme-color" content="#87ceeb">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">

  <link rel="icon" href="img/insect.png">
  <link rel="stylesheet" href="./css/font-awesome.min.css">
  <link rel="stylesheet" href="./css/global-style.css">
  <link rel="stylesheet" href="./css/navbar-style.css">
  <link rel="stylesheet" href="./css/footer-style.css">
  <link rel="stylesheet" href="./css/home-style.css">

  <script  src="js/jquery-3.0.0.min.js"></script>
  <script  src="js/navbar-functionality.js"></script>

  <style>
    @font-face {
      font-family: "Arial";
      src: local('Arial');
      font-display: optional;
    }
  </style>
  
	<script>
		$(document).ready(function() {
			$('#CTAButton').on('click', () => { window.location = 'cfm/signup.cfm' });
		});
	</script>
</head>
<body>
  <div class="navbar">
    <div class="container-fluid">
      <div class="container">
        <nav>
          <div class="branding">
            <img class="brand-icon" src="img/insect.png">
            <p class="brand-text">Ticket Tracking System</p>
          </div>
          <ul class="navlist">
            <li><a href="index.cfm" class="active navlink"><i class="fa fa-home"></i> Home</a></li>
            <li><a href="cfm/login.cfm" class="navlink"><i class="fa fa-sign-in"></i> Log In</a></li>
            <li><a href="cfm/About_This_Project.cfm" class="navlink"><i class="fa fa-info-circle"></i> About This Project</a></li>
          </ul>
          <div class="nav-toggler">
            <a href="#" class="fa fa-arrow-up"></a>
          </div>
        </nav>
      </div>
    </div>
  </div>

  <div class="container-fluid">
    <div class="header-section">
      <div class="container">
        <div class="header-wrapper">
          <div class="header">No more faulty application with the help of Ticket Tracking.</div>
          <div class="description">Now track all the bugs in an application and make it bug free.</div>
          <button id="CTAButton" class="signup-btn">Sign Up</button>
        </div>
      </div>
    </div>
      <div class="footer">
        <div class="container">
            <div class="footer-wrapper">
                <div class="branding">
                    <img class="brand-icon" src="img/insect.png">
                    <p class="brand-text">Ticket Tracking System</p>
                  </div>
                  <ul class="navlist">
                      <li><a href="index.cfm" class="navlink"></i> Home</a></li>
                      <li><a href="cfm/login.cfm" class="navlink"></i> Log In</a></li>
                      <li><a href="#" class="navlink">About This Project</a></li>
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
      </div>
  </div>
  </body>
  </html>