let toastService;

$(document).ready(function () {

  toastService = new ToastMaker(3000, $('.toast-container').get(0));
  
  $('form').on('submit', function () {
    return false;
  });

  $('.form-control').on('blur', function (event) {
    checkValidity(event.target);
  });

  $('#loginButton').on('click', function () {

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
        if (JSON.parse(response) === true) {
          window.location = "overview.cfm";
          window.URL = "overview.cfm"
        } else {
          $('#login-error-msg').fadeIn('fast');
        }
      });
    } else {
      $('.form-control:required').each(function (index, formElement) {
        if (formElement.value === '' || !formElement.validity.valid) {
          checkValidity(formElement)
        }
      });
    }
  });

  $(document).ajaxError(function (event, jqXHR, ajaxSettings, thrownError) {
    toastService.show("The server dealt with an error!");
  });

});


function checkValidity(formElement) {

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