$(document).ready(function() {
  $('.form-control').on('focus', makeLabelFlyOnFocus);
  $('.form-control').on('blur', makeLabelLandOnBlur);
  $('.label-control').on('click', function(event) {
    $(event.target).parent('.form-wrapper').find('.form-control').focus();
  });
});

/**
 *
 * @param {FocusEvent} event
 */
function makeLabelFlyOnFocus(event) {
  $(event.target).parent('.form-wrapper')
      .find('.label-control')
      .removeClass('label-under')
      .addClass('label-over');

  $(event.target).parent('div.input-group').find('.form-control').focus();
}

/**
 *
 * @param {*} event
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
