<cfif session.userEmail NEQ "">
  <cflocation  url="overview.cfm" addtoken = "false">
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <meta name="theme-color" content="#87ceeb">

  <link rel="stylesheet" href="../css/font-awesome.min.css">
  <link rel="icon" href="../img/insect.png">
  <link rel="stylesheet" href="../css/global-style.css">
  <link rel="stylesheet" href="../css/navbar-style.css">
  <link rel="stylesheet" href="../css/footer-style.css">
  <link rel="stylesheet" href="../css/form-styling.css">
  <link rel="stylesheet" href="../css/tab-style.css">
  <link rel="stylesheet" href="../css/signup-style.css">

  <script src="../js/jquery-3.0.0.min.js"></script>
  <script src="../js/navbar-functionality.js"></script>
  <script src="../js/form-functionality.js"></script>
  <script src="../js/signup-functionality.js"></script>
  
  <title>Sign up | Ticket Tracking System</title>
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
            <li><a href="login.cfm" class="navlink"><i class="fa fa-sign-in"></i> Log In</a></li>
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
    <div class="container">
      <div class="signup">
        <div class="signup-header">
          <h2>Join Ticket Tracking without any cost</h2>
          <p>Hassle free experiece of making an application bug free.</p>
        </div>
        <div class="signup-form-container">
          <div class="tab">
            <h4 id="signup-error-msg">You might not have filled some of the required fields.</h4>
            <ul class="tab-navs">
              <li class="tab-nav-active" id="signup-window-tab"><i class="fa fa-user"></i><span class="tab-info"><p>Step 1</p><p>Setting up your account.</p></span></li>
              <li id="project-window-tab"><i class="fa fa-tasks"></i><span class="tab-info"><p>Step 2</p><p>Setting up your project.</p></span></li>
            </ul>
            <div class="tab-windows">
              <form action="" method="" novalidate>
              <div class="tab-window" id="signup-window">
                  <div class="form-group">
                    <h2 class="form-header">Creating your personal account</h2>
                    
                      <div class="input-group">
                        <div class="form-wrapper">
                          <input  type="text" pattern="[a-zA-Z]+" maxlength="40" class="form-control" name="firstName" id="firstNameInput" required>
                          <div class="label-control label-under">First Name</div>
                        </div>
                        <div class="validation-feedback" id="firstNameFeedBack">
                          <p class="error-empty">Your first name is required to identify.</p>
                          <p class="error-invalid">This Field can only accept alphabets [a-z].</p>
                          <p class="assist-valid">You can enter only alphabets [a-z].</p>
                        </div>
                      </div>
                      <div class="input-group">
                        <div class="form-wrapper">
                          <input type="text" pattern="[a-zA-Z]+" class="form-control" name="middleName" maxlength="40" id="middleNameInput" >
                          <div class="label-control label-under ">Middle Name</div>
                        </div>
                          <div class="validation-feedback" id="middleNameFeedback">
                                <p class="error-empty"></p>
                                <p class="error-invalid">You mightn't have middle name like this.</p>
                                <p class="assist-valid">You can leave this if not applicable.</p>
                          </div>
                      </div>
                      <div class="input-group">
                        <div class="form-wrapper">
                          <input type="text" class="form-control"  maxlength="40" pattern="([a-zA-Z]'?)+" name="lastName" id="lastNameInput" required>
                          <div class="label-control label-under">Last Name</div>
                        </div>
                        <div class="validation-feedback" id="lastNameFeedback">
                            <p class="error-empty"> Your last name is needed to complete your name.</p>
                            <p class="error-invalid">You can enter alphabets and apostrophe.</p>
                            <p class="assist-valid">You may enter an apostrophe in you surname.</p>
                          </div>
                      </div>
                      <div class="input-group">
                        <div class="form-wrapper">
                          <input  type="text"  pattern="^(\+?[0-9]{1,3}(-[0-9]{3,4})?)?[0-9]{10}" class="form-control" name="contactNumber" id="contactNumberInput" required>
                          <div class="label-control label-under">Contact Number</div>
                        </div>
                        <div class="validation-feedback" id="contactNumberFeedback">
                          <p class="error-empty">Your contact number is required to contact.</p>
                          <p class="error-invalid">This Field can only accept numbers</p>
                          <p class="assist-valid">This Field can only accept numbers.</p>
                        </div>
                      </div>
                      <div class="input-group">
                        <div class="form-wrapper">
                          <input type="email" required pattern="[a-zA-Z]+(\.?[a-zA-Z0-9]+)+@[a-zA-Z]+(\.co)?\.([a-z]{2,3})" class="form-control" name="emailId" id="emailidInput">
                          <div class="label-control label-under">Email Id</div>
                        </div>
                        <div class="validation-feedback" id="emailFeedBack">
                            <p class="error-empty">Email is needed to be in touch with you.</p>
                            <p class="error-invalid"></p>
                            <p class="assist-valid">This needs to be unique per user.</p>
                          </div>
                      </div>
                      <div class="input-group">
                        <div class="form-wrapper">
                          <input type="password" required minlength="8" maxlength="32" class="form-control" name="password" id="passwordInput">
                          <div class="label-control label-under">Password</div>
                        </div>
                        <div class="validation-feedback" id="passwordFeedback">
                            <p class="error-empty">You can not omit password.</p>
                            <p class="error-invalid"></p>
                            <p class="assist-valid">This should at least have one special charachter and between 8 to 32.</p>
                          </div>
                      </div>

                      <div class="input-group">
                        <div class="form-wrapper">
                          <input type="password" class="form-control" required name="confirmationPassword" id="confirmationPasswordInput" >
                          <div class="label-control label-under">Confirm Password</div>
                        </div>
                        <div class="validation-feedback" id="confirmPasswordFeedback">
                            <p class="error-empty">This is needed to ensure that you have typed your password correctly.</p>
                            <p class="error-invalid"></p>
                            <p class="assist-valid">Enter the same password again.</p>
                          </div>
                      </div>

                      
                      <div class="input-group" id="profileImageContainer">
                        <div class="file-preview">
                          <img src="../img/placeholder-person.png" alt="Default Person Image" srcset="">
                          <div class="file-input-label"><label for="profileImage"><i class="fa fa-upload"></i> Upload your photo</label></div>
                        </div>
                        <input type="file" name="profileImage" id="profileImage" accept="image/*" multiple="false">
                      </div>
                        <div class="validation-feedback" id="profileImageFeedback">
                          <p class="error-empty"></p>
                          <p class="error-invalid"></p>
                          <p class="assist-valid"></p>
                        </div>
                    <button class="submit-btn" id="nextStepButton">Next step <i class="fa fa-arrow-right"></i></button>  
                  </div>
                </div>
                <div class="tab-window" id="project-window">
                  <div class="form-group">
                    <h2 class="form-header">Creating your project</h2>
                    <div class="input-group">
                      <div class="form-wrapper">
                        <input type="text" required class="form-control" name="projectName" id="projectNameInput">
                          <div class="label-control label-under">Project Name</div>
                        </div>
                        <div class="validation-feedback">
                          <p class="error-empty">You cant have a project without name.</p>
                          <p class="error-invalid"></p>
                          <p class="assist-valid">You need enter the name of the project you will work on.</p>
                        </div>
                      </div>  
                      <div class="input-group">
                        <div class="control-label label-under">Project Description</div>
                        <div class="form-wrapper">
                          <textarea name="projectDescription" required class="form-control" id="projectDescriptionTextarea" cols="30" rows="10"></textarea>
                        </div>
                        <div class="validation-feedback">
                          <p class="error-empty">You should enter the description of the project.</p>
                          <p class="error-invalid"></p>
                          <p class="assist-valid">The description of the project will go inside.</p>
                        </div>
                      </div>
                    </div>
                    <button id="signup-button" class="submit-btn">Finish Signing up</button>
                  </div>
                </form>
              </div>
            </div>
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
                    <li><a href="../index.cfm" class="navlink"></i> Home</a></li>
                    <li><a href="login.cfm" class="navlink"></i> Log In</a></li>
                    <li><a href="About_This_Project.cfm" class="navlink"> About This Project</a></li>
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