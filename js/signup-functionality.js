$(document).ready(function () {
  $('form').on('submit', function (event) {
    return false;
  });
  
  $('#profileImage').on('change', function (event) {
    let reader = new FileReader();
    reader.onload = function (e) {
      $('.file-preview > img').attr('src', e.target.result);
    }
    if (event.target.files[0].type.includes('image')) {
      reader.readAsDataURL(event.target.files[0]);
    }
  });

  $('.form-control').on('blur', function (event) {
    if (event.target.id === 'passwordInput' || event.target.id === 'emailidInput' || event.target.id === 'confirmationPasswordInput') {
      return;
    } else {
      checkValidity(event.target);
    }
  });


  $('#passwordInput').on('blur', function (event) {
    const feedbackMsg = $(this).parent('div.form-wrapper').parent('div.input-group').find('.error-invalid').css('display', 'none');
    const feedbackMsgEmpty = $(this).parent('div.form-wrapper').parent('div.input-group').find('.error-empty').css('display', 'none');
    
    if (event.target.value === '') {
      $(this).parent('div.form-wrapper').parent("div.input-group").addClass("invalid");
      feedbackMsgEmpty.css('display', 'block');
      feedbackMsgEmpty.text('You can not omit password ');
    } else if (event.target.value.length < 8) {
      $(this).parent('div.form-wrapper').parent("div.input-group").addClass("invalid");
      feedbackMsg.css('display', 'block');
      feedbackMsg.text('Your password should be atleast 8 chars long.');
    } else if (!/[A-Z]/.test(event.target.value)) {
      $(this).parent('div.form-wrapper').parent("div.input-group").addClass("invalid");
      feedbackMsg.css('display', 'block');
      feedbackMsg.text('It should atleast have one uppercase letter.');
    } else if (!/[0-9]/.test(event.target.value)) {
      $(this).parent('div.form-wrapper').parent("div.input-group").addClass("invalid");
      feedbackMsg.css('display', 'block');
      feedbackMsg.text('It should atleast have one number.');
    } else if (!/[^a-zA-Z0-9]/.test(event.target.value)) {
      feedbackMsg.css('display', 'block');
      $(this).parent('div.form-wrapper').parent("div.input-group").addClass("invalid");
      feedbackMsg.text('It should atleast have one special character.');
    } else {
      $(this).parent('div.form-wrapper').parent("div.input-group").removeClass("invalid");
      feedbackMsg.css('display', 'none');
      feedbackMsgEmpty.css('display', 'none');
    }
  });

  $('#emailidInput').on('blur', function (event) {
    const emailId = event.target.value;
    const parentInputGroup = $(this).parent('div.form-wrapper').parent('div.input-group');
    const feedbackMsg = parentInputGroup.find('.error-invalid');

    if (event.target.validity.valid) {
      parentInputGroup.find('.error-invalid, .error-empty').css('display', 'none');
      parentInputGroup.removeClass('invalid');

      $.ajax({
        type: 'POST',
        url: '../CFCs/UtilComponent.cfc?method=IsEmailValid',
        async: true,
        data: {
          emailid: emailId
        }
      }).done(response => {
        const responsesInJson = JSON.parse(response);
        if (!responsesInJson.valid) {
          $(this).parent('div.form-wrapper').parent('div.input-group').addClass('invalid');
          feedbackMsg.css('display', 'block');
          feedbackMsg.text(responsesInJson.feedback);
        } else {
          feedbackMsg.css('display', 'none');
          feedbackMsg.parent('div.input-group').removeClass('invalid');
        }
      });
    } else if (event.target.validity.valueMissing) {
      parentInputGroup.find('.error-empty').css('display', 'block');
      feedbackMsg.css('display', 'none');
      parentInputGroup.addClass('invalid');
    } else {
      feedbackMsg.text('The email format seems to invalid').css('display', 'block');
      parentInputGroup.addClass('invalid');
      parentInputGroup.find('.error-empty').css('display', 'none');
    }
  });

  $('#confirmationPasswordInput').on('blur', function (event) {
    const parentInputGroup = $(this).parent('div.form-wrapper').parent('div.input-group');
    const invalidMsg = parentInputGroup.find('.error-invalid').css('display', 'none');
    const emptyMsg = parentInputGroup.find('.error-empty').css('display', 'none');
    const passwordInputText = $('#passwordInput').val();

    if (passwordInputText === '') {
      invalidMsg.text('Please enter password in the password field first!');
      parentInputGroup.addClass('invalid');
      invalidMsg.css('display', 'block');
    } else if (event.target.validity.valueMissing) {
      parentInputGroup.addClass('invalid');
      emptyMsg.css('display', 'block');
    } else if (event.target.value !== passwordInputText) {
      parentInputGroup.addClass('invalid');
      invalidMsg.text('Password did not match.');
      invalidMsg.css('display', 'block');
    } else {
      parentInputGroup.removeClass('invalid');
    }

  });


  $("#nextStepButton").on('click', function (event) {
    let allFilledUP = true;

    $('#signup-window .form-control:required').each(function (index, formElement) {
      if (formElement.value === '') {
        allFilledUP = false;
        checkValidity(formElement);
      }
    });

    if (!$('div.input-group').hasClass('invalid') && allFilledUP) {
      $('#signup-window').fadeOut('fast', function () {
        $('#project-window').fadeIn('fast', function () {
          $('#project-window-tab').addClass('tab-nav-active');
        });
      });
    }

  });


  $('#signup-window-tab').on('click', function (event) {

    if ($(this).hasClass('tab-nav-active')) {
      $('#project-window').fadeOut('fast', function () {
        $('#signup-window').fadeIn('fast');
      });
    }
  });

  $('#project-window-tab').on('click', function (event) {

    if ($(this).hasClass('tab-nav-active')) {
      $('#signup-window').fadeOut('fast', function () {
        $('#project-window').fadeIn('fast');
      });
    }
  });


  $('#signup-button').on('click', function (event) {
    let allFilledUP = true;

    const signUpParameters = new FormData($('form').get(0));
    signUpParameters.delete('confirmationPassword');
    signUpParameters.append('profileImageName', signUpParameters.get('profileImage').name);

    $('.form-control:required').each(function (index, formElement) {
      if (formElement.value === '' || !formElement.validity.valid) {
        allFilledUP = false;
        checkValidity(formElement);
      }
    });

    if (!$('div.input-group').hasClass('invalid') && allFilledUP) {
      $.ajax({
        type: 'POST',
        url: '../CFCs/UtilComponent.cfc?method=SignAdminUp',
        enctype: 'multipart/form-data',
        processData: false,
        contentType: false,
        async: true,
        data: signUpParameters
      }).done(function (response) {
        if (JSON.parse(response) === true) {
          const loginParameters = new FormData();
          loginParameters.append('userEmail', signUpParameters.get('emailId'));
          loginParameters.append('userPassword', signUpParameters.get('password'));
          $.ajax({
            type: 'POST',
            url: '../CFCs/UtilComponent.cfc?method=LogUserIn',
            async: true,
            processData: false,
            contentType: false,
            data: loginParameters
          }).done(function (response) {
            if (JSON.parse(response) === true) {
              window.location = 'overview.cfm'
            }
          });
        }
      });
    } else {
      $('#signup-error-msg').fadeIn('fast');
    }
  });
});

function checkValidity(formElement) {
  $(formElement).parent('div.form-wrapper').parent('div.input-group').find('.validation-feedback').find('.error-empty, .error-invalid').css('display', 'none');

  if (!formElement.validity.valid) {
    $(formElement).parent('div.form-wrapper').parent('div.input-group').addClass('invalid');
    if (formElement.validity.valueMissing) {
      $(formElement).parent('div.form-wrapper').parent('div.input-group').find('.validation-feedback').find('.error-empty').css('display', 'block');
    } else {
      $(formElement).parent('div.form-wrapper').parent('div.input-group').find('.validation-feedback').find('.error-invalid').css('display', 'block');
    }
  } else {
    $(formElement).parent('div.form-wrapper').parent('div.input-group').removeClass('invalid');
  }

}