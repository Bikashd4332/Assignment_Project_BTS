// Dashboard counters
let assignedReports = 0;
let openedReports = 0;
let closedReports = 0;

// FileUpload Ajax request array.
let fileUploadRequests = [];

// FileUploadXHR
let fileUploadXHR = undefined;

//The name of directory to remember.
let uploadedDirectory = '';

// Caching the results of reprots
let reportsAssignedToMe = undefined;
let reportsInterestedIn = undefined;

// The response to cache from backend.
let assigneeNames = [];
let reportTypes = undefined;

// File uploaing global variables
let totalFileSize = 0;
let fileUploaded = 0;
let numberOfFiles = 0;
let temp = 0;

$(document).ready(function () {

  CanvasJS.addColorSet("reportColorSet",
    [ //colorSet Array
      "#87CEFA",
      "#51CDA0",
    ]);

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

  // Getting the name of the user logged in.
  $.ajax({
    type: 'POST',
    url: '../CFCs/DashboardComponent.cfc?method=GetUserName',
    async: true
  }).done(function (response) {
    const responseInJson = JSON.parse(response);
    $('#usrName').text(responseInJson.userName.split(' ')[0]);
  });

  // The CanvasJs here is used to show charts. [about to change].
  $.ajax({
    url: '../CFCs/DashboardComponent.cfc?method=GetPercentageOf&reportState=OPEN',
    type: 'POST'
  }).done(function (percentage) {

    let openChart = new CanvasJS.Chart("open-chart", {
      theme: "light2", // "light1", "light2", "dark1", "dark2"
      exportEnabled: false,
      colorSet: 'reportColorSet',

      data: [{
        type: "pie",
        startAngle: 25,
        toolTipContent: "<b>{label}</b>: {y}%",
        showInLegend: false,
        dataPoints: [{
            y: parseInt(percentage),
            label: "Open Reports"
          },
          {
            y: 100 - parseInt(percentage),
            label: "Others"
          }
        ]
      }]
    });
    openChart.render();

  })

  $.ajax({
    url: '../CFCs/DashboardComponent.cfc?method=GetPercentageOf&reportState=IN PROGRESS',
    type: 'POST'
  }).done(function (percentage) {

    let inProgressChart = new CanvasJS.Chart("in-progress-chart", {
      theme: "light2", // "light1", "light2", "dark1", "dark2"
      exportEnabled: false,

      colorSet: 'reportColorSet',
      data: [{
        type: "pie",
        startAngle: 25,
        toolTipContent: "<b>{label}</b>: {y}%",
        showInLegend: false,
        dataPoints: [{
            y: parseInt(percentage),
            label: "In Progress Reports"
          },
          {
            y: 100 - parseInt(percentage),
            label: "Others"
          }
        ]
      }]
    });
    inProgressChart.render();
  });

  $.ajax({
    url: '../CFCs/DashboardComponent.cfc?method=GetPercentageOf&reportState=CLOSED',
    type: 'POST'
  }).done(function (percentage) {

    let closedChart = new CanvasJS.Chart("closed-chart", {
      theme: "light2", // "light1", "light2", "dark1", "dark2"
      exportEnabled: false,
      colorSet: 'reportColorSet',
      data: [{
        type: "pie",
        startAngle: 25,
        toolTipContent: "<b>{label}</b>: {y}%",
        showInLegend: false,
        dataPoints: [{
            y: parseInt(percentage),
            label: "Closed Reports"
          },
          {
            y: 100 - parseInt(percentage),
            label: "Others"
          }
        ]
      }]
    });
    closedChart.render();
  });

  // Log out button functionality.
  $('#logOutButton').on('click', function () {
    $.ajax({
      type: 'POST',
      url: '../CFCs/UtilComponent.cfc?method=LogUserOut'
    }).done(function (response) {
      if (JSON.parse(response) === true) {
        // Move user to login.cfm
        window.location = 'login.cfm';
      }
    });
  });

  // Drop Down functionality.
  $('div.drag-drop-box-container')
    .on('dragenter dragover', function (event) {
      event.preventDefault();
      event.stopPropagation();
      $(this).css('backgroundColor', 'white');
    })
    .on('dragleave', function (event) {
      event.preventDefault();
      event.stopPropagation();
      $(this).css('backgroundColor', 'whitesmoke');
    })
    .on('drop', function (event) {
      event.preventDefault();
      event.stopPropagation();
      let fileList = [...event.originalEvent.dataTransfer.files];
      if (!$(this).hasClass('busy')) {
        uploadFile(fileList);
      }
    });

  // Bringing the modal in on click.
  $('.new-report-btn').on('click', function () {
    $('.background-popup').fadeIn('fast', function () {
      $('.modal').fadeIn('fast');
    });
  });

  // Bringing the modal out on click.
  $('.modal-close-btn, .cancel-btn').on('click', function (event) {
    $('.background-popup').fadeOut('fast', function () {
      $('.modal').fadeOut('fast');
    });

    if (uploadedDirectory !== '') {
      const myFormData = makeFormDataWith({
        directoryName: uploadedDirectory
      });

      $.ajax({
        url: '../CFCs/ReportComponent.cfc?method=DeleteTempAttachments',
        type: 'POST',
        processData: false,
        contentType: false,
        data: myFormData
      }).done(function (response) {
        console.log(response);
      });
    }
    uploadedDirectory = '';
    $('.modal-body form').get(0).reset();
    $('.modal-body .input-group').removeClass('invalid');
    $('.error-invalid, .error-empty').hide();
    $('.success-drop-msg').fadeOut('fast', function () {
      $('#not-uploading').fadeIn('fast');
    });
    abortFileUploads();
    $('#uploading').fadeOut('fast', function () {
      $('.intial-upload-msg').fadeIn();
    });
    $('.busy').removeClass('busy');
  });

  //To show autocomplete suggestion list.
  $('.auto-complete .form-control').on('input', function (event) {
    getAssigneeNames().then(function (responseInJson) {
      assigneeNames = responseInJson;
      showSuggestion(event);
    });
  });

  //To show autocomplete suggestion list.
  $('.auto-complete .form-control').on('focus', function (event) {
    getAssigneeNames().then(function (responseInJson) {
      assigneeNames = responseInJson;
      showSuggestion(event);
    });
  });

  // Hide the previously shown autocomplete on blur input.
  $('.auto-complete .form-control').on('blur', function () {
    setTimeout(() => {
      $(this).parent('div.form-wrapper').find('div.auto-complete-container').hide();
    }, 100);
  });

  // Hide the previously shown autocomplete on click of autocomplete items.
  $('.auto-complete-list').on('click', '.auto-complete-item', function () {
    const $inputGroup = $(this).parents('div.input-group');
    $(this).addClass('auto-complete-selected');
    if ($inputGroup.hasClass('invalid')) {
      $inputGroup.removeClass('invalid');
      $inputGroup.find('.error-invalid, .error-empty').hide();
    }
    
    $inputGroup.find('.label-control').removeClass('label-under');

    $inputGroup.find('.form-control').val($(this).find('.suggestion-name').text());
  
  });

  // Asynchronously load report types.
  getReportTypes().then(function (resolveData) {
    populateSelect($('#reportTypeSelect'), resolveData, 1);
  });

  // Validate form-control on blur.
  $('.form-control').on('blur', function (event) {
    if (event.target.id === 'asigneeInput') {
      checkValidityAssignee($(event.target))
    } else {
      checkValidity(event.target);
    }
  });

  // Prepare data and send on click submit button.
  $('.modal-actions > .submit-btn').on('click', function () {
    let allFilledUp = true;
    $('.modal-body .form-control').each(function (index, formElement) {
      if (formElement.value === '') {
        allFilledUp = false;
        checkValidity(formElement);
      }
      if (formElement.id === 'asigneeInput') {
        if (!$('.auto-complete-list').find('.auto-complete-item').hasClass('auto-complete-selected')) {
          checkValidityAssignee($(formElement));
        }
      }
    });

    if (!$('.modal-body .input-group').hasClass('invalid') && allFilledUp) {
      const myFormData = makeFormDataWith({
        form: $('.modal-body .form-group > form').get(0)
      });
      myFormData.delete('files[]');
      myFormData.append('attachmentsTempDirectory', uploadedDirectory);
      myFormData.set('reportAssignee', $('.auto-complete-selected').attr('data-person-id'));
      $.ajax({
        type: 'POST',
        url: '../CFCs/ReportComponent.cfc?method=CreateReport',
        processData: false,
        contentType: false,
        data: myFormData
      }).done(function (response) {
        $('.background-popup').fadeOut('fast', function () {
          $('.modal').fadeOut('fast');
        });
        window.location = 'report.cfm?id=' + response;
      });
    }
  });
  // Upload files as soon as selected by the file input.
  $('#dragDropFileInput').on('change', function () {
    const fileList = [...$(this).prop('files')];
    $(this).parents('div.drag-drop-box-container').addClass('busy');
    if (fileList.length >= 1) {
      uploadFile(fileList);
    }
  });

  // Change the the preferred item by arrow kyes and enter.
  $('#asigneeInput').on('keydown', function (event) {
    event.stopPropagation();
    switch (event.key) {
      case 'ArrowDown':
        if ($('.preferred-item').next().length) {
          $('.preferred-item').removeClass('preferred-item').next().addClass('preferred-item');
        }
        break;
      case 'ArrowUp':
        if ($('.preferred-item').prev().length) {
          $('.preferred-item').removeClass('preferred-item').prev().addClass('preferred-item');
        }
        break;
      case 'Enter':
        $('.preferred-item').click();
        break;
    }
  });

  // Fetching and populating all the assigned reports and reports being watched.
  populateReports($('#assignedToMe'), getAllReportsAssignedToMe());
  populateReports($('#watchedByMe'), getAllReportsWatchedByMe());

  // Intializing the counters with the values fetching from backend.
  $.ajax({
    url: '../CFCs/DashBoardComponent.cfc?method=GetDashBoardCounts&counterOf=open',
    type: 'POST'
  }).done(function (response) {
    openedReports = parseInt(response);
    $('.open-info').find('span.number-badge').text(openedReports);
  });


  // Intializing the counters with the values fetching from backend.
  $.ajax({
    url: '../CFCs/DashBoardComponent.cfc?method=GetDashBoardCounts&counterOf=closed',
    type: 'POST'
  }).done(function (response) {
    openedReports = parseInt(response);
  });
  $('.closed-info').find('span.number-badge').text(openedReports);

  // Intializing the counters with the values fetching from backend.
  $.ajax({
    url: '../CFCs/DashBoardComponent.cfc?method=GetDashBoardCounts&counterOf=assigned',
    type: 'POST'
  }).done(function (response) {
    openedReports = parseInt(response);
    $('.assigned-info').find('span.number-badge').text(openedReports);
  });

  // Run whenever user clicks on any of the reports.The report will be opened in another page with all the details.
  $('#assignedToMe').on('click', 'div.report', function (event) {
    let reportId;
    if ($(event.target).hasClass('report')) {
      reportId = $(event.target).find('div.report-id > span').text();
    } else {
      reportId = $(event.target).parents('div.report').find('div.report-id > span').text();
    }
    window.location = 'report.cfm?id=' + reportId;
  });
}); // End of document ready.

/**
 * @desc This function uplodds the provided file by ajax. 
 * @param {File} initialFileItem - The file object which to upload. 
 * @returns {Promise}
 */
function getInitialFileUploadPromise(initialFileItem) {
  return new Promise(function (resolve, reject) {
    const myFormData = makeFormDataWith({
      uploadedFile: initialFileItem,
      clientFileInfo: initialFileItem.name,
      uploadedDirectory: uploadedDirectory
    });
    fileUploadRequests.push($.ajax({
      type: 'POST',
      url: '../CFCs/ReportComponent.cfc?method=UploadAttachment',
      xhr: function () {
        let xhr = new XMLHttpRequest();
        xhr.upload.addEventListener('progress', uploadProgressVisualizer);
        return xhr;
      },
      contentType: false,
      processData: false,
      data: myFormData
    }).done(function (response) {
      temp = 0;
      resolve(response);
    }));
  });
}

/**
 * @desc This function is responsilbe for showing progress bar.
 */
function showUploading(callback) {
  $('#not-uploading').fadeOut('fast', function () {
    $('.success-drop-msg').fadeOut('fast', function () {
      $('#uploading').fadeIn('fast');
      callback();
    });
  });
}

/**
 * @desc This function is responsible for hiding progress bar which is previously shown.
 */
function finishedUploading() {
  $('#uploading').fadeOut('fast', function () {
    $('.success-drop-msg').fadeIn('fast');
  });
}

/**
 * @desc This function is responsible for fetching the names of assignee.
 */
function getAssigneeNames() {
  return new Promise(function (resolve, reject) {
    $.ajax({
      type: 'POST',
      url: '../CFCs/ReportComponent.cfc?method=GetAssigneeNames'
    }).done(function (response) {
      const responseInJson = JSON.parse(response);
      resolve(responseInJson);
    });
  });
}

/**
 * @desc This function is responsible for showing suggestion.
 * @param {InputEvent} event - This argument is the event fired by 
 * any input which shows suggestion.
 */
function showSuggestion(event) {
  const enteredValue = $(event.target).val()
  const autoCompleteContainer = $(event.target).parent('.form-wrapper').find('.auto-complete-container').css('display', 'none');
  autoCompleteContainer.find('li.auto-complete-item').remove();
  if (enteredValue !== '') {
    const reducedValues = assigneeNames.filter(function (assigneeObj) {
      return assigneeObj.name.toLowerCase().startsWith(enteredValue.toLowerCase());
    });
    makeUnorderedListOf(autoCompleteContainer.find('ul.auto-complete-list'), reducedValues);
    autoCompleteContainer.css('display', 'block');
  } else {
    makeUnorderedListOf(autoCompleteContainer.find('ul.auto-complete-list'), assigneeNames);
    autoCompleteContainer.css('display', 'block');
  }
}

/**
 * @desc This function is responsilbe for building <li> and populating inside $autoCompleteList 
 * @param {jqObject} $autoCompleteList - This contains the jquery obj of HTMLUListElement. 
 * @param {Array} reducedValues - This contains the values to show up in suggesion.
 */
function makeUnorderedListOf($autoCompleteList, reducedValues) {
  reducedValues.forEach(function (assigneeObj, index) {
    if (index === 0) {
      $('<li class="auto-complete-item preferred-item" data-person-id=' + assigneeObj.id + '> <span class="suggestion-name">' + assigneeObj.name + '</span>' + '<span class="suggestion-email">' + assigneeObj.email + '</span>' + '</li>').appendTo($autoCompleteList);
    } else {
      $('<li class="auto-complete-item" data-person-id=' + assigneeObj.id + '> <span class="suggestion-name">' + assigneeObj.name + '</span>' + '<span class="suggestion-email">' + assigneeObj.email + '</span>' + '</li>').appendTo($autoCompleteList);
    }
  });
}

/**
 * @desc This function is responsible for fetching the types of report by ajax.
 */
function getReportTypes() {
  return new Promise(function (resolve, reject) {
    $.ajax({
      type: 'POST',
      url: '../CFCs/ReportComponent.cfc?method=GetReportType',
    }).done(function (response) {
      const responseInJson = JSON.parse(response);
      reportTypes = responseInJson;
      resolve(responseInJson);
    });
  });
}

/**
 * @param {jqObject} $selectElement - The jquery object of HTMLSelectElement to populate. 
 * @param {Object} selectData - The object having index as the key and names as the value.
 * @param {Number} defaultIndex - The numeric value to specify the default index.
 */
function populateSelect($selectElement, selectData, defaultIndex) {
  $($selectElement).find('option').remove();
  for (let key in selectData) {
    if (defaultIndex === key) {
      $selectElement.append('<option value="' + key + '" selected>' + selectData[key] + '</option>');
    } else {
      $selectElement.append('<option value="' + key + '">' + selectData[key] + '</option>');
    }
  }
}

/**
 * @desc This function does validate the provided htmlElement.
 * @param {HTMLElement} formElement - This is the element having the class [.form-contro].  
 */
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

/**
 * @desc This function validates one formcontrol for assignee selecion.
 * @param {jquery} $formElement - FormElement jquery element for validation. 
 */
function checkValidityAssignee($formElement) {

  const $inputGroup = $formElement.parents('div.input-group');
  const $errorInvalid = $inputGroup.find('.error-invalid');
  const $errorEmpty = $inputGroup.find('.error-empty');

  if (!$formElement.find('.auto-complete-item').hasClass('auto-complete-selected') && $formElement.val() !== '') {
    $inputGroup.addClass('invalid');
    $errorInvalid.css('display', 'block');
    $errorEmpty.css('display', 'none');
  } else if (!$formElement.find('.auto-complete-item').hasClass('auto-complete-selected') && $formElement.val() === '') {
    $inputGroup.addClass('invalid');
    $errorEmpty.css('display', 'block');
    $errorInvalid.css('display', 'none');
  } else {
    $inputGroup.removeClass('invalid');
    $errorInvalid.css('display', 'none');
    $errorEmpty.css('display', 'none');
  }

}


/**
 * 
 * @param {jqObject} progressBarss - This is the jquery object of the progress bar container.
 * @param {Number} progressValue - This is the numeric progress to visualize which is between [0-100]%.
 */
function progressInProgressBar($progressBar, progressValue) {
  $($progressBar).find('.bar').css('width', `${progressValue}%`);
  $($progressBar).find('.percentage-info').text(`${progressValue}%`)
}

/**
 * @desc This function  determines the total size of files in filelist. 
 * @param {Array} fileList - This is the array of filelist. 
 * @returns {Number} it returns the size of all the filed in bytes.
 */
function getTotalFileSize(fileList) {
  let filesize = 0;
  fileList.forEach(function (fileItem) {
    filesize += fileItem.size;
  });
  return filesize;
}

/**
 * @desc This function is responsible for uploading files and returning promise.
 * @param {Array} fileList - this is the array of filelist to upload.
 * @returns {Promise}.  
 */
function uploadMultipleFiles(fileList) {
  let myPromise = getInitialFileUploadPromise(fileList.shift());
  fileList.forEach(function (fileItem) {
    myPromise = myPromise.then(function (resolvedData) {
      const responseInJson = JSON.parse(resolvedData);
      const myFormData = makeFormDataWith({
        uploadedFile: fileItem,
        clientFileInfo: fileItem.name,
        uploadedDirectory: responseInJson.uploadDirectory
      });
      uploadedDirectory = responseInJson.uploadDirectory;
      return new Promise(function (resolve, reject) {
        fileUploadRequests.push($.ajax({
          type: 'POST',
          xhr: function () {
            let xhr = new XMLHttpRequest();
            xhr.upload.addEventListener('progress', uploadProgressVisualizer);
            return xhr;
          },
          url: '../CFCs/ReportComponent.cfc?method=UploadAttachment',
          contentType: false,
          processData: false,
          data: myFormData,
        }).done(function (response) {
          temp = 0;
          resolve(response);
        }));
      });
    });
  });
  return myPromise;
}

/**
 * @desc This function responsible for updating the progress of progress bar.
 * @param {ProgressEvent} event - This is the progress event generated by XMLHttpRequest.upload
 */
function uploadProgressVisualizer(event) {
  if (event.lengthComputable) {
    if (temp === 0) {
      temp = event.loaded;
      fileUploaded += temp;
    } else {
      fileUploaded += (event.loaded - temp);
    }
    const percentage = parseInt((fileUploaded / totalFileSize) * 100);
    if (percentage >= 100) {
      progressInProgressBar($('.progress-container'), 100);
    } else {
      progressInProgressBar($('.progress-container'), percentage);
    }
    temp = event.loaded;
  }
}

/**
 * @desc This function is responsible for constructing {FormData} with the provided settings.
 * @param {Object} settings - This is the object with field that should be in FormData obj. 
 * @returns {FormData}
 */
function makeFormDataWith(settings) {
  let myFormData;

  if (settings.hasOwnProperty('form')) {
    myFormData = new FormData(settings.form);
    return myFormData;
  } else {
    myFormData = new FormData();
  }

  for (let key in settings) {
    myFormData.append(key, settings[key]);
  }
  return myFormData;
}


/**
 * @desc This function accepts an array of files to upload. 
 * @param {Array} fileList - Array of file items to upload.
 */
function uploadFile(fileList) {
  numberOfFiles = fileList.length;
  totalFileSize = getTotalFileSize(fileList);
  if (numberOfFiles > 1) {
    showUploading(function () {
      uploadMultipleFiles(fileList).then(function (resolvedData) {
        finishedUploading();
        $('.progress-container').find('.bar').css({
          width: '0%'
        });
        const responseInJson = JSON.parse(resolvedData);
        uploadedDirectory = responseInJson.uploadDirectory;
        temp = 0;
        fileUploaded = 0;
        $('div.drag-drop-box-container').removeClass('busy');
      });
    });
  } else {
    showUploading(function () {
      getInitialFileUploadPromise(fileList[0]).then(function (resolvedData) {
        finishedUploading();
        $('.progress-container').find('.bar').css({
          width: '0%'
        });
        const responseInJson = JSON.parse(resolvedData);
        uploadedDirectory = responseInJson.uploadDirectory;
        temp = 0;
        fileUploaded = 0;
        $('div.drag-drop-box-container').removeClass('busy');
      });
    });
  }
}

/**
 * @desc This function requests server to retrieve the reports assigned to the loggedn in user.
 * @returns {Promise} A promise which resolved when the request completes.
 */
function getAllReportsAssignedToMe() {
  return new Promise(function (resolve, reject) {
    $.ajax({
      type: 'POST',
      url: '../CFCs/DashBoardComponent.cfc?method=GetAllAssignedReports',
    }).done(function (response) {
      const responseInJson = JSON.parse(response);
      reportsAssignedToMe = responseInJson;
      resolve(responseInJson);
    });
  });
}

/**
 * @desc This funciton is responsible for retrieving all the reports watched by the loggen is user.
 * @returns {Promise} A Promise resolved on finishing retrival.
 */
function getAllReportsWatchedByMe() {
  return new Promise(function (resolve, reject) {
    $.ajax({
      type: 'POST',
      url: '../CFCs/DashBoardComponent.cfc?method=GetAllWatchingReports',
    }).done(function (response) {
      const responseInJson = JSON.parse(response);
      reportsAssignedToMe = responseInJson;
      resolve(responseInJson);
    });
  });
}

/**
 * @desc This helps populating the reports with the help of functions for retrieving reports.
 * @param {jquery} $parentReport - This is parent container where to put all the dynamcally generated reports.
 * @param {Promise} dataPromise - This is the promise of fetching reports.
 */
function populateReports($parentReport, dataPromise) {
  dataPromise.then(function (responseInJson) {
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
                <div class="report-desc">${reportObjInJson.description.split(' ').slice(0, 10).join(' ')}</div>
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
}

function abortFileUploads() {
  if (fileUploadRequests.length >= 1) {
    fileUploadRequests.forEach(function (jqxhr) {
      jqxhr.abort();
    });
  }
}