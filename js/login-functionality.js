$(document).ready(function () {
  $('form').on('submit', function(event) {
    return false;
  });

  $('.form-control').on('blur', function (event) {
   checkValidity(event.target);
  });

  $('#loginButton').on('click', function (event) {

    let allFiledUp = true;

    let myFormData = getFromDataInJson(new FormData($('form').get(0)));

    $('.form-control:required').each(function (index, formElement) {
      if (formElement.value === '') {
        allFiledUp = false;
      }
    });

    if (!$('div.input-group').hasClass('invalid') && allFiledUp) {
      $.ajax({
        type: 'POST',
        url: '../CFCs/UtilComponent.cfc?method=LogUserIn',
        async: true,
        data: {
          userEmail: myFormData.userEmail,
          userPassword: myFormData.userPassword
        }
      }).done(function (response) {
        console.log(response);
        if (JSON.parse(response) === true) {
          window.location = "overview.cfm";
          window.URL = "overview.cfm"
        } else {
          $('#login-error-msg').fadeIn('fast');
        }
      });
    } else {
      $('.form-control:required').each(function (index, formElement) {
        if (formElement.value === ''  || !formElement.validity.valid ) 
          { checkValidity(formElement) }
      });
    }
  });
});


function checkValidity (formElement) {

  const parentInputGroupDiv = $(formElement).parent('div.form-wrapper').parent('div.input-group');
  const invalidMsg = parentInputGroupDiv.find('.error-invalid');
  const emptyMsg = parentInputGroupDiv.find('.error-empty');

  if (!formElement.validity.valid) {
    parentInputGroupDiv.addClass('invalid');
    if (formElement.validity.valueMissing) {
      emptyMsg.fadeIn('fast');
      invalidMsg.fadeOut('fast');
    } else {
      emptyMsg.fadeOut('fast');
      invalidMsg.fadeIn('fast');
    }
  } else {
    invalidMsg.fadeOut('fast');
    parentInputGroupDiv.removeClass('invalid');
    emptyMsg.fadeOut('fast');
  }
}