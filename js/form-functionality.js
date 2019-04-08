$(document).ready(function () {
    $('input.form-control,select.form-control').on('focus', makeLabelFlyOnFocus);
    $('input.form-control,select.form-control').on('blur', makeLabelLandOnBlur);
    $('.label-control').on('click', function (event) {
        $(event.target).parent('.form-wrapper').find('.form-control').focus();
    });

  $('input.form-input').each( function(index, formElement) {
    if ( $(this).val() === '') {
      $(this).parents('.form-wrapper').find('.label-control').addClass('label-over');
    }
  });

/**
 * @desc This function helps to move the label up. 
 * @param {FocusEvent} event - The event info raised by the inpub.
 */
function makeLabelFlyOnFocus(event) {

    if (event.target.nodeName === 'textarea') {
      return;
    }
  
    $(event.target).parent('div.form-wrapper')
      .find('.label-control')
      .removeClass('label-under')
      .addClass('label-over');
  
    $(event.target).parent('div.input-group').find('.form-control').focus();
  }
  
  /**
   * @desc This function helps to move the label to the center of the input.
   * @param {FocusEvent} event
   */
  function makeLabelLandOnBlur(event) {
    if (event.target.value === '') {
      $(event.target)
        .parent('.form-wrapper')
        .find('.label-control')
        .addClass('label-under')
        .remove('label-over');
    } else {
      $(event.target)
        .parent('.input-group')
        .find('.label-control');
    }
  }

  
});
/**
 * @desc This function helps to extract values from a form data object.
 * @param {FormData} formData - The FormData to extract values from. 
 */
function getFromDataInJson(formData) {
  var myObj = {};

  for (let entry of formData.entries()) {
    myObj[entry[0]] = entry[1];
  }
  console.log(myObj);
  return myObj;
}