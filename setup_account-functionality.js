let userUUID ;

$(document).ready(function () {
  userUUID = window.location.search.split('=')[1];
  $('.form-control').on('blur', function (event) {
    if (event.target.id === 'passwordInput' || event.target.id === 'emailidInput' || event.target.id === 'confirmationPasswordInput') {
      return;
    } else {
      checkValidity(event.target);
    }
  });

  $('#passwordInput').on('blur', function (event) {
    const feedbackMsg = $(this).parent('div.form-wrapper').parent('div.input-group').find('.error-invalid').hide();
    const feedbackMsgEmpty = $(this).parent('div.form-wrapper').parent('div.input-group').find('.error-empty').hide();

    if (event.target.value === '') {
      $(this).parent('div.form-wrapper').parent("div.input-group").addClass("invalid");
      feedbackMsgEmpty.show()
      feedbackMsgEmpty.text('You can not omit password ');
    } else if (event.target.value.length < 8) {
      $(this).parent('div.form-wrapper').parent("div.input-group").addClass("invalid");
      feedbackMsg.show()
      feedbackMsg.text('Your password should be atleast 8 chars long.');
    } else if (!/[A-Z]/.test(event.target.value)) {
      $(this).parent('div.form-wrapper').parent("div.input-group").addClass("invalid");
      feedbackMsg.show()
      feedbackMsg.text('It should atleast have one uppercase letter.');
    } else if (!/[0-9]/.test(event.target.value)) {
      $(this).parent('div.form-wrapper').parent("div.input-group").addClass("invalid");
      feedbackMsg.show()
      feedbackMsg.text('It should atleast have one number.');
    } else if (!/[^a-zA-Z0-9]/.test(event.target.value)) {
      feedbackMsg.show()
      $(this).parent('div.form-wrapper').parent("div.input-group").addClass("invalid");
      feedbackMsg.text('It should atleast have one special character.');
    } else {
      $(this).parent('div.form-wrapper').parent("div.input-group").removeClass("invalid");
      feedbackMsg.css('display', 'none');
      feedbackMsgEmpty.css('display', 'none');
    }
  });

  $('#confirmationPasswordInput').on('blur', function (event) {
    const parentInputGroup = $(this).parent('div.form-wrapper').parent('div.input-group');
    const invalidMsg = parentInputGroup.find('.error-invalid').hide();
    const emptyMsg = parentInputGroup.find('.error-empty').hide();
    const passwordInputText = $('#passwordInput').val();

    if (passwordInputText === '') {
      invalidMsg.text('Please enter password in the password field first!');
      parentInputGroup.addClass('invalid');
      invalidMsg.show();
    } else if (event.target.validity.valueMissing) {
      parentInputGroup.addClass('invalid');
      emptyMsg.show();
    } else if (event.target.value !== passwordInputText) {
      parentInputGroup.addClass('invalid');
      invalidMsg.text('Password did not match.');
      invalidMsg.show();
    } else {
      parentInputGroup.removeClass('invalid');
    }

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



  $('.submit-btn').on('click', function (evet) {
    event.preventDefault();
    let allValid = true;
    let signUpParameters;

    $('.form-control:required').each(function (index, formElement) {
      if (!formElement.validity.valid) {
        allValid = false;
        checkValidity(formElement);
      }
    });

    if (allValid) {
      signUpParameters = new FormData($('form').get(0));
      signUpParameters.delete('confirmationPassword');
      signUpParameters.append('profileImageName', signUpParameters.get('profileImage').name);
      signUpParameters.append('userUUID', userUUID);
      $.ajax({
        type: 'POST',
        url: '../CFCs/UtilComponent.cfc?method=SignUpMember',
        enctype: 'multipart/form-data',
        processData: false,
        contentType: false,
        async: true,
        data: signUpParameters,
      });
    }
  });
});

/**
 *
 * @param {HTMLInputElement} formElement - The form element to do validation on.
 */
function checkValidity(formElement) {
  $(formElement).parent('div.form-wrapper').parent('div.input-group').find('.validation-feedback').find('.error-empty, .error-invalid').css('display', 'none');
  if (!formElement.validity.valid) {
    $(formElement).parent('div.form-wrapper').parent('div.input-group').addClass('invalid');
    if (formElement.validity.valueMissing) {
      $(formElement).parent('div.form-wrapper').parent('div.input-group').find('.validation-feedback').find('.error-empty').show()
    } else {
      $(formElement).parent('div.form-wrapper').parent('div.input-group').find('.validation-feedback').find('.error-invalid').show()
    }
  } else {
    $(formElement).parent('div.form-wrapper').parent('div.input-group').removeClass('invalid');
  }



}