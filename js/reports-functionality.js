$(document).ready(function () {
  const reportsPromise = $.ajax({
    url: '../CFCs/ReportsComponent.cfc?',
    data: {
      method: 'GetAllReportsOfProject',
    }
  }).promise();
  populateReports($('.report-list'), reportsPromise);


  // Loading the profile picture of the logged in person.
  $.ajax({
    type: 'POST',
    url: '../CFCs/DashboardComponent.cfc?method=GetProfileImage',
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

  // Run whenever user clicks on any of the reports.The report will be opened in another page with all the details.
  $('.report-container').on('click', 'div.report', function (event) {
    let reportId;
    if ($(event.target).hasClass('report')) {
      reportId = $(event.target).find('div.report-id > span').text();
    } else {
      reportId = $(event.target).parents('div.report').find('div.report-id > span').text();
    }
    window.location = 'report.cfm?id=' + reportId;
  });


// Handle the search of any reports in the report search bar.
$('#reportSearchInput').on('input', function () {
const enteredText = $(this).val().trim();
const $reportList = $('.report-list');
if (enteredText !== "") {
  const reportsPromise = $.ajax({
    url: '../CFCs/ReportsComponent.cfc?',
    data: {
      method: 'GetAllReportsOfProject',
      searchString: `${enteredText}`
    }
  }).promise();
  showSpinner().then(function () {
    populateReports($reportList, reportsPromise).then(function () {
      hideSpinner();
    });
  });
} else {
  const reportsPromise = $.ajax({
    url: '../CFCs/ReportsComponent.cfc?',
    data: {
      method: 'GetAllReportsOfProject',
    }
  }).promise();
  showSpinner().then(function () {
    populateReports($reportList, reportsPromise).then(function () {
      hideSpinner();
    });
  });
}
});
});

/**
 * A helper function for populating reports in the specified container.
 * @param {jqueryObj} $parentReport - jquery elment of the container where to populate the reports.
 * @param {Promse} dataPromise - the response object containing all the reports in json string.
 */
function populateReports($parentReport, dataPromise) {
  $parentReport.find('.report, .empty-msg').remove();
  dataPromise.then(function (response) {
    const responseInJson = JSON.parse(response);
    if (responseInJson.length === 0) {
      $($parentReport).append('<h2 class="empty-msg">None reports available in this section.</h2>')
    } else {
      responseInJson.forEach(function (reportObj) {
        const reportObjInJson = JSON.parse(reportObj);
        $parentReport
          .append(
            `<div class="report">
              <div class="report-id">#<span class="id">${reportObjInJson.id}</span></div>
              <div class="report-info">
                <div class="report-name">${reportObjInJson.title}</div>
                <div class="report-desc">${reportObjInJson.description.substring(0, 55)}</div>
              </div>
              <div class="report-type-priority">
                <div class="badge">
                  <div class="badge-label">Report type</div>
                  <div class="badge-value ${reportObjInJson.type.toLowerCase()}"><i></i> ${reportObjInJson.type.toLowerCase()}</div>
                </div>
                <div class="badge">
                  <div class="badge-label">Report priority</div>
                  <div class="badge-value ${reportObjInJson.priority}">${reportObjInJson.priority}</div>
                </div>
            </div>
        `);
      });
    }
  });
  return dataPromise;
}

/**
 * @desc This is responsible for showing spinner.
 * @returns {Promise} A promise of showing the spinner.
 */
function showSpinner() {
  return $('.report-list').fadeOut('fast', function () {
    $('.spinner-container').fadeIn('fast').css('display', 'flex');
  }).promise();
}

/**
 * @desc This function is responsible for hiding spinner.
 * @returns {Promise} A promise to hide the spinner.
 */
function hideSpinner() {
  return $('.spinner-container').fadeOut('fast', function () {
    $('.report-list').fadeIn('fast');
  }).promise();
}