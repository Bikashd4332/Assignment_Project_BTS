<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <link rel="shortcut icon" href="../favicon.ico" type="image/x-icon">
  
  <link rel="stylesheet" href="../css/global-style.css">
  <link rel="stylesheet" href="../css/font-awesome.min.css">
  <link rel="stylesheet" href="../css/signup-style.css">
  <link rel="stylesheet" href="../css/form-styling.css">
  <link rel="stylesheet" href="../css/setup_account-styling.css">

  <script src="../js/jquery-3.0.0.min.js"></script>
  <script src="../js/form-functionality.js"></script>
  <script src="../setup_account-functionality.js"></script>
  
  <title>User Setup | Ticket Tracking System</title>
  
</head>
<body>
  <div class="container-fluid">
    <div class="container">
      <div class="signup">
        <div class="signup-header">
          <img class="logo" src="../img/insect.png" alt="Bug" >
          <p class="project-info">Will be working on the project <span id="projectName">Ticket Tracking</span></p>
        </div>
        <div class="signup-form-container">
          <form action="" method="" novalidate>
            <div class="tab-window" id="signup-window">
              <div class="form-group">
                <h2 class="form-header">Setting Up Your Account.</h2>
                <div class="input-group">
                  <div class="form-wrapper">
                    <input type="text" pattern="[a-zA-Z]+" maxlength="40" class="form-control" name="firstName"
                      id="firstNameInput" required>
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
                    <input type="text" pattern="[a-zA-Z]+" class="form-control" name="middleName" maxlength="40"
                      id="middleNameInput">
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
                    <input type="text" class="form-control" maxlength="40" pattern="([a-zA-Z]'?)+" name="lastName"
                      id="lastNameInput" required>
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
                    <input type="text" pattern="^(\+?[0-9]{1,3}(-[0-9]{3,4})?)?[0-9]{10}" class="form-control"
                      name="contactNumber" id="contactNumberInput" required>
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
                    <input type="password" required minlength="8" maxlength="32" class="form-control" name="password"
                      id="passwordInput">
                    <div class="label-control label-under">Password</div>
                  </div>
                  <div class="validation-feedback" id="passwordFeedback">
                    <p class="error-empty">You can not omit password.</p>
                    <p class="error-invalid"></p>
                    <p class="assist-valid">This should at least have one special charachter and between 8 to 32.
                    </p>
                  </div>
                </div>

                <div class="input-group">
                  <div class="form-wrapper">
                    <input type="password" class="form-control" required name="confirmationPassword"
                      id="confirmationPasswordInput">
                    <div class="label-control label-under">Confirm Password</div>
                  </div>
                  <div class="validation-feedback" id="confirmPasswordFeedback">
                    <p class="error-empty">This is needed to ensure that you have typed your password correctly.</p>
                    <p class="error-invalid"></p>
                    <p class="assist-valid">Enter the same password again.</p>
                  </div>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</body>

</html>