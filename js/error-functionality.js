$(document).ready(function () {
  const errorUrl = window.location.pathname;

  if ($('.error-code').text().trim() === '404') {
    $('.error-text').html(`The url <span class="error-url">${errorUrl}</span> is not found.`);
  }

  // Loading the profile picture of the logged in person.
  $.ajax({
    type: 'POST',
    url: '/Assignment_Project_BTS/CFCs/DashboardComponent.cfc?method=GetProfileImage',
    data: {
      height: '40',
      width: '40'
    }
  }).done(function (response) {
    const responseInJson = JSON.parse(response);
    if (!responseInJson.isDefaultProfileImage) {
      $('.profile-img').attr('src', `data:image/${responseInJson.extension};base64,` + responseInJson.base64ProfileImage);
    }
  });

  // Log out button functionality.
  $('#logOutButton').on('click', function () {
    $.ajax({
      type: 'POST',
      url: '/Assignment_Project_BTS/CFCs/UtilComponent.cfc?method=LogUserOut'
    }).done(function (response) {
      if (JSON.parse(response) === true) {
        // Move user to login.cfm
        window.location = 'login.cfm';
      }
    });
  });

});