//The name of directory to remember.
let uploadedDirectory = undefined;

// Array containing all the ajax requests of file upload.
let fileUploadXHR = [];

// The response to cache from backend.
let assigneeNames = [];

// File uploaing global variables
let totalFileSize = 0;
let fileUploaded = 0;
let numberOfFiles = 0;
let temp = 0;

// Getting the report id from url param.
const reportId = parseInt(window.location.search.substring(1).split('=')[1]);

$(document).ready(function () {
  uploadedDirectory = reportId;

  // Get the intial report action button.
  updateActionButton();

  // Loading the profile picture of the logged in person.
  $.ajax({
    type: 'POST',
    url: '../CFCs/DashboardComponent.cfc?method=GetProfileImage',
    data: {
      height: 40,
      width: 40
    }
  }).done(function (response) {
    const responseInJson = JSON.parse(response);
    if (!responseInJson.isDefaultProfileImage) {
      $('.profile-img').attr('src', `data:image/${responseInJson.extension};base64,` + responseInJson.base64ProfileImage);
    }
  });

  //To show autocomplete suggestion list.
  $('.auto-complete .form-control').on('input', function (event) {
    getAssigneeNames().then(function (responseInJson) {
      assigneeNames = responseInJson;
      showSuggestion(event);
    });
  });

  $('.log-out-btn').on('click', function () {
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

  $.ajax({
    url: '../CFCs/ReportComponent.cfc?method=CheckIfWatching',
    data: {
      reportId: reportId
    }
  }).done(function (response) {
    if (response === "true") {
      $('#toggleWatch').addClass('stop-watching').text('Stop Watching');
    } else {
      $('#toggleWatch').addClass('start-watching').text('Watch');
    }
  });

  $('#toggleWatch').on('click', function (event) {
    if (!$(this).hasClass('busy')) {
      $(this).addClass('busy');
      $.ajax({
        url: '../CFCs/ReportComponent.cfc?method=ToggleWatcher',
        data: {
          reportId: reportId
        }
      }).done(function (response) {
        if (response === "true") {
          $(event.target).removeClass('start-watching').addClass('stop-watching').text('Stop Watching');
        } else {
          $(event.target).removeClass('stop-watching').addClass('start-watching').text('Watch');
        }
        $(event.target).removeClass('busy');
      });
    }
  });

  // Hide the previously shown autocomplete on blur input.
  $('.auto-complete .form-control').on('blur', function () {
    setTimeout(() => {
      $(this).parent('div.form-wrapper').find('div.auto-complete-container').css('display', 'none');
    }, 100);
  });

  // Populate the file attachment initially.
  populateFileAttachment(function () {});
  $.ajax({
    url: '../CFCs/ReportComponent.cfc?method=GetReportOfId',
    type: 'POST',
    data: {
      reportId: reportId
    }
  }).done(function (response) {
    const responseInJson = JSON.parse(response);
    const $reportTitle = $('.report-title');
    const $reportInfoStatus = $('.report-info-status');
    const $extendedInfo = $('#reporterInfo');

    $reportTitle.find('.report-id').text('#' + responseInJson.id);
    $reportTitle.find('.report-title').text(responseInJson.title);
    $reportInfoStatus.find('.report-status').text(responseInJson.status).addClass(responseInJson.status.toLowerCase().replace(' ', '-'));
    $reportInfoStatus.find('.report-priority').find('.badge-value').text(responseInJson.priority).addClass(responseInJson.priority);
    $reportInfoStatus.find('.report-type').find('.badge-value').text(responseInJson.type.toLowerCase().substring(0, 3)).addClass(responseInJson.type.toLowerCase());
    $extendedInfo.find('.user-name').text(responseInJson.personName);
    $extendedInfo.find('.date-info').text(responseInJson.dateReported);
    $('.report-description').text(responseInJson.description);
    updateAssigneeInfo();
  });


  // Show delete confirmation modal and delete depending on the buttons clicked.
  $('.attachments').on('click', '.attachment .file-delete-btn', function (event) {
    event.preventDefault();
    const $attachmentDiv = $(event.target).parents('div.attachment');
    const id = $(event.target).parents('a.file-delete-btn').data('id');
    deleteConfirmationModal().then(function (responseFromModal) {
      if (responseFromModal) {
        showSpinner().then(function () {
          $.ajax({
            url: '../CFCs/ReportComponent.cfc?method=DeleteAttachment',
            data: {
              attachmentId: `${id}`
            }
          }).done(function (response) {
            const responseInJson = JSON.parse(response);
            if (responseInJson.isDeleted) {
              hideSpinner().then(function () {
                $attachmentDiv.fadeOut('slow', function () {
                  $(this).remove();
                });
              });
            } else {
              hideSpinner();
              console.log("File could not be deleted");
            }
          });
        });
      } else {
        hideSpinner();
      }
      $('.modal').fadeOut('fast', function () {
        $('.background-popup').fadeOut('fast');
      });
    });
  });

  // On choosing files to upload upload those files.
  $('#fileUploadInput').on('change', function (event) {
    const fileList = [...$(this).prop('files')];
    if (fileList.length > 0) {
      uploadFile(fileList);
    }
  });

  // Post on clicking the comment submit after writing on the comment textarea
  $('.comment-submit-btn').on('click', function (event) {
    event.preventDefault();
    const $commentPosterContainer = $(this).parents('div.comment-poster-container');
    const $commentTextArea = $($commentPosterContainer).find('#commentTextArea');
    const commentText = $commentTextArea.val();
    if (commentText !== '') {
      $.ajax({
        url: '../CFCs/ReportComponent.cfc?method=AddComment',
        data: {
          reportId: reportId,
          commentText: commentText
        }
      });
      $commentTextArea.val('');
    }
  });

  // Populating the comments of all peoples for the report.
  $.ajax({
    url: '../CFCs/ReportComponent.cfc?method=GetCommentsForReport',
    data: {
      reportId: reportId,
      activity: 0
    }
  }).done(function (response) {
    const responseInJson = JSON.parse(response);
    responseInJson.forEach(function (commentString) {
      const commentInJson = JSON.parse(commentString);
      $('#commentWindow .history').append(generateCommentUI(commentInJson));
    });
  });
  $.ajax({
    url: '../CFCs/ReportComponent.cfc?method=GetCommentsForReport',
    data: {
      reportId: reportId,
    }
  }).done(function (response) {
    const responseInJson = JSON.parse(response);
    responseInJson.forEach(function (commentString) {
      const commentInJson = JSON.parse(commentString);
      if (commentInJson.isActivity === '0') {
        $('#activityWindow .history').append(generateCommentUI(commentInJson));
      } else {
        $('#activityWindow .history').append(generateActivityUI(commentInJson));
      }
    });
  });

  // On clicking on the activityTab  showing the activty tab window accordingly.
  $('#activityTab').on('click', function (event) {
    event.preventDefault();
    $('.selected').removeClass("selected");
    $(this).addClass('selected');
    $('#commentWindow').fadeOut('fast', function () {
      $('#activityWindow').fadeIn('fast');
    });
  });

  // On clicking on the comments tag showing the comments tab.
  $('#commentsTab').on('click', function (event) {
    event.preventDefault();
    $('.selected').removeClass("selected");
    $(this).addClass('selected');
    $('#activityWindow').fadeOut('fast', function () {
      $('#commentWindow').fadeIn('fast');
    });
  });

  // On clicking the button start working make all the other button busy and disabled until the process completes.
  $('.status-action').on('click', '#startWorkingButton', function (event) {
    if (!$(this).hasClass('busy')) {
      $(event.target).parent('div.status-action').children().addClass('busy');
      $.ajax({
        url: '../CFCs/ReportComponent.cfc?method=StartWorkingOnReport',
        type: 'POST',
        data: {
          reportId: reportId
        }
      }).done(function () {
        updateActionButton(function () {
          $(event.target).parent('div.status-action').children().removeClass('busy');
          updateReportStatus();
        });
        updateAssigneeInfo();
      });
    }
  });

  // On clicking on the butotn stop working button disable all the other button and makey it busy until the process completes.
  $('.status-action').on('click', '#stopWorkingButton', function (event) {
    if (!$(this).hasClass('busy')) {
      $(event.target).parent('div.status-action').children().addClass('busy');
      $.ajax({
        url: '../CFCs/ReportComponent.cfc?method=StopWorkingOnReport',
        type: 'POST',
        data: {
          reportId: reportId
        }
      }).done(function (response) {
        const responseInJson = JSON.parse(response);
        updateActionButton(function () {
          $(event.target).parent('div.status-action').children().removeClass('busy');
          updateReportStatus();
        });
        updateAssigneeInfo();
      });
    }
  });

  // On click of sendToNextStatus show a modal for choosing an assignee for the next state of the report.
  $('.status-action').on('click', '#sendToNextStatusButton', function (event) {
    if (!$(this).hasClass('busy')) {
      $(event.target).parent('div.status-action').children().addClass('busy');
      getAssigneeNames().then(function (responseInJson) {
        assigneeNames = responseInJson;
        chooseAssigneeModal().then(function (operation) {
          if (operation) {
            const assigneeId = $('.auto-complete-selected').attr('data-person-id');
            $.ajax({
              url: '../CFCs/ReportComponent.cfc?method=SendReportToNextStatus',
              type: 'POST',
              data: {
                reportId: reportId,
                assignee: assigneeId
              }
            }).done(function (response) {
              const responseInJson = JSON.parse(response);
              updateActionButton(function () {
                $(event.target).parent('div.status-action').children().removeClass('busy');
                updateReportStatus();
              });
              updateAssigneeInfo();
            });
          } else {
            $(event.target).parent('div.status-action').children().removeClass('busy');
          }
        });
      });
    }
  });

  $('.status-action').on('click', '#assignToMeButton', function (event) {
    if (!$(this).hasClass('busy')) {
      $(this).addClass('busy');
      $.ajax({
        url: '../CFCs/ReportComponent.cfc',
        data: {
          method: 'AssignToMe',
          reportId: reportId
        }
      }).done(function (response) {
        if (JSON.parse(response) === true) {
          updateActionButton(function () {
            $(event.target).removeClass('busy');
            updateReportStatus();
          });
          updateAssigneeInfo();
        }
      })
    }
  });

  // On clicking of the button reopen make all the other button busy until the process completes.
  $('.status-action').on('click', '#reopenButton', function (event) {
    if (!$(this).hasClass('busy')) {
      $(this).parent('div.status-action').children().addClass('busy');
      $.ajax({
        url: '../CFCs/ReportComponent.cfc?method=ReopenReport',
        type: 'POST',
        data: {
          reportId: reportId
        }
      }).done(function (response) {
        const responseInJson = JSON.parse(response);
        updateActionButton(function () {
          $(event.target).parent('div.status-action').children().removeClass('busy');
          updateReportStatus();
        });
        updateAssigneeInfo();
      });
    }
  });

  // On click of the close button make all the other button busy untill the process completes.
  $('.status-action').on('click', '#closeButton', function (event) {
    if (!$(this).hasClass('busy')) {
      $(this).parent('div.status-action').children().addClass('busy');
      $.ajax({
        url: '../CFCs/ReportComponent.cfc?method=CloseReport',
        type: 'POST',
        data: {
          reportId: reportId
        }
      }).done(function (respoonse) {
        updateActionButton(function () {
          $(event.target).parent('div.status-action').children().removeClass('busy');
          updateReportStatus();
          updateAssigneeInfo();
        });
      });
    }
  });

  // On click of the button make all the other busy until the process completes.
  $('.status-action').on('click', '#fallBackToPreviousButton', function (event) {
    if (!$('#fallBackToPreviousButton').hasClass('busy')) {
      $(event.target).parent('div.status-action').children().addClass('busy');
      $.ajax({
        url: '../CFCs/ReportComponent.cfc?method=FallBackToPreviousStatus',
        type: 'POST',
        data: {
          reportId: reportId
        }
      }).done(function (response) {
        const respooonseInJson = JSON.parse(response);
        updateActionButton(function () {
          $(event.target).parent('div.status-action').children().removeClass('busy');
          updateReportStatus();
        });
        updateAssigneeInfo();
      });
    }
  });

  //To show autocomplete suggestion list.
  $('.auto-complete .form-control').on('focus', function (event) {
    getAssigneeNames().then(function (responseInJson) {
      assigneeNames = responseInJson;
      showSuggestion(event);
    });
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

  $('.file-cancel-btn').on('click', function () {
    fileUploadXHR.forEach(function (ajaxObject) {
      ajaxObject.abort();
    });
    $('.progress-container').find('.bar').css('width', '0px');
    finishedUploading(true);
  });
});

/**
 * @desc A confirmation modal to show up when ever user tries to delete any attachment.
 */
function deleteConfirmationModal() {
  return new Promise(function (resolve, rejec) {
    $('.background-popup').fadeIn('fast', function () {
      $('#deleteConfirmationModal').fadeIn('fast');
    });
    $('#deleteConfirmationModal .modal-actions').find('.submit-btn').on('click', function () {
      resolve(true);
    });
    $('#deleteConfirmationModal .modal-actions').find('.cancel-btn').on('click', function () {
      resolve(false);
    });
    $('#deleteConfirmationModal').find('.modal-close-btn').on('click', function (event) {
      event.preventDefault();
      resolve(false);
    });
  });
}

/**
 * @desc This function is responsilbe for showing progress bar.
 * @returns {Promise} A promise of showing progress bar.
 */
function showUploading() {
  return $('.file-section').fadeOut('fast', function () {
    $('.file-upload').fadeIn('fast');
    $('.file-upload').css('display', 'flex');
  }).promise();
}

/**
 * @desc This function accepts an array of files to upload. 
 * @param {Array} fileList - Array of file items to upload.
 */
function uploadFile(fileList) {
  numberOfFiles = fileList.length;
  totalFileSize = getTotalFileSize(fileList);
  if (numberOfFiles > 1) {
    showUploading().then(function () {
      uploadMultipleFiles(fileList).then(function (resolvedData) {
        finishedUploading(false).then(function () {
          showSpinner().then(function () {
            $('.progress-container').find('.bar').css({
              width: '0%'
            });
            uploadedDirectory = reportId;
            temp = 0;
            fileUploaded = 0;
            /*
             * After uploading all the files send a publish message 
             * to update all other clients  viewing this page. 
             */
            cfWebSocketObj.publish('report-file-upload', 'Update ya all!');
          });
        });
      });
    });
  } else {
    showUploading().then(function () {
      getInitialFileUploadPromise(fileList[0]).then(function (resolvedData) {
        finishedUploading(false).then(function () {
          showSpinner().then(function () {
            $('.progress-container').find('.bar').css({
              width: '0%'
            });
            /*
             * After uploading the file send a publish message 
             * to update all other clients  viewing this page. 
             */
            cfWebSocketObj.publish('report-file-upload', 'Update ya all!');
            uploadedDirectory = reportId;
            temp = 0;
            fileUploaded = 0;
          });
        });
      });
    });
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
 * @desc This function uplodds the provided file by ajax. 
 * @param {File} initialFileItem - The file object which to upload. 
 * @returns {Promise}
 */
function getInitialFileUploadPromise(initialFileItem) {
  const myFormData = makeFormDataWith({
    reportId: reportId,
    uploadedFile: initialFileItem,
    clientFileInfo: initialFileItem.name,
    uploadedDirectory: uploadedDirectory
  });
  return new Promise(function (resolve, reject) {
    fileUploadXHR.push($.ajax({
      type: 'POST',
      url: '../CFCs/ReportComponent.cfc?method=UploadAttachmentForReport',
      xhr: function () {
        let xhr = new XMLHttpRequest();
        xhr.upload.addEventListener('progress', uploadProgressVisualizer);
        return xhr;
      },
      contentType: false,
      processData: false,
      data: myFormData
    }).done(function (response) {
      const responseInJson = JSON.parse(response);
      temp = 0;
      // fetchActivityComment(responseInJson.commentId);
      resolve(response);
    }));
  });
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
 * @desc This function is responsible for uploading files and returning promise.
 * @param {Array} fileList - this is the array of filelist to upload.
 * @returns {Promise}.  
 */
function uploadMultipleFiles(fileList) {
  let myPromise = getInitialFileUploadPromise(fileList.shift());
  fileList.forEach(function (fileItem) {

    // reportId, UploadedDirectory will be same among all the file upload.
    const myFormData = makeFormDataWith({
      reportId: reportId,
      uploadedFile: fileItem,
      clientFileInfo: fileItem.name,
      uploadedDirectory: uploadedDirectory
    });

    myPromise = myPromise.then(function (resolvedData) {
      return new Promise(function (resolve, reject) {
        fileUploadXHR.push($.ajax({
          type: 'POST',
          xhr: function () {
            let xhr = new XMLHttpRequest();
            xhr.upload.addEventListener('progress', uploadProgressVisualizer);
            return xhr;
          },
          url: '../CFCs/ReportComponent.cfc?method=UploadAttachmentForReport',
          contentType: false,
          processData: false,
          data: myFormData,
        }).done(function (response) {
          const responseInJson = JSON.parse(response);
          temp = 0;
          resolve(response);
        }));
      });
    });
  });
  return myPromise;
}
/**
 * @desc This function is responsible for hiding progress bar which is previously shown.
 * @returns {Promise} A promise of hiding progress bar.
 */
function finishedUploading(flagToShowFileSection) {
  return $('.file-upload').fadeOut('fast', function () {
    if (flagToShowFileSection) {
      $('.file-section').fadeIn('fast');
    }
  }).promise();
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
 * @desc This function is responsinble for fetching attachment fro server and displaying with 
 * generateAttachment().
 */
function populateFileAttachment(callback) {
  $('.attachments').find('.attachment').fadeOut('slow').remove();
  const $container = $('.file-section');
  $.ajax({
    url: '../CFCs/ReportComponent.cfc?method=GetAllAttachmentsOfReport',
    data: {
      reportId: reportId
    }
  }).done(function (response) {
    const responseInJson = JSON.parse(response);
    responseInJson.forEach(function (report) {
      const reportInJson = JSON.parse(report);
      $container.append(generateAttachmentHTML(reportInJson));
    });
    callback();
  });
}

/**
 * @desc This function creates attachments of report  dynamically .
 * @param {Object} report - This is the report object containing information for creating report ui.
 * @returns {HTMLDivElement} A div with attachment class
 */
function generateAttachmentHTML(report) {
  const $attachment = $('<div class="attachment"></div>');
  if (report.fileType === 'image') {
    $attachment.append(' <i class="fa fa-file-image-o"></i>')
  } else {
    $attachment.append(' <i class="fa fa-file-text"></i>')
  }

  if (report.file.length > 10) {
    $attachment.append(`<div class="file-name underline tooltip-on-hover" data-full-name="${report.file}">${report.file.substring(0, 10)+'...'}<span class="triangle"></span></div>`);
  } else {
    $attachment.append(`<div class="file-name">${report.file.substring(0, 10)}</div>`);
  }
  $attachment.append('<div class="file-action"></div>')

  if (report.isRemovable) {
    $attachment.find('div.file-action').append(`
      <a href="#" data-id="${report.id}" class="file-delete-btn"><i class="fa fa-trash"></i></a>`)
  }
  $attachment.find('div.file-action').append(` 
      <a href="../CFCs/ReportComponent.cfc?method=DownloadFile&path=../assets/report-attachments/${reportId}/${report.file}" class="file-download-btn"><i class="fa fa-download"></i></a>`)
  return $attachment;
}

/**
 * @desc This is responsible for showing spinner.
 * @returns {Promise} A promise of showing the spinner.
 */

function showSpinner() {
  return $('.file-section').fadeOut('fast', function () {
    $('.spinner-container').fadeIn('fast').css('display', 'flex');
  }).promise();
}

/**
 * @desc This function is responsible for hiding spinner.
 * @returns {Promise} A promise to hide the spinner.
 */
function hideSpinner() {
  return $('.spinner-container').fadeOut('fast', function () {
    $('.file-section').fadeIn('fast');
  }).promise();
}

/**
 * @desc This is responsible for making the UI of comment.
 * @param {Object} comment 
 * @returns {jquery} The comment ui jquery object.
 */
function generateCommentUI(comment) {
  return $('<div class="comment"></div>').append(`
    <div class="profile-image-container">
      <img class="profile-img" src="data:image/${comment.ext};base64, ${comment.profileImage}">
    </div>
    <div class="comment-body">
      <div class="comment-header">
          <div class="user-info">
              <img class="profile-img" src="data:image/${comment.ext};base64, ${comment.profileImage}">
              <span class="wrapper">
                  <span class="user-name">${comment.userName}</span>
                  <span class="comment-date">${comment.date}</span>
              </span>
          </div>
       <span class="comment-date">${comment.date}</span>
    </div>
    <p class="text">${comment.comment}</p>
</div>
</div>
`);
}

/**
 * @desc This function generates html structure dynamically for activity information. 
 * @param {Objeect} activity 
 * @returns {jquery} - A jquery object containing all the html structure.
 */
function generateActivityUI(activity) {
  return $(`<div class="activity" data-date-commented="${activity.date}">
  <div class="profile-image-container">
    <img class="profile-img" src="data:image/${activity.ext};base64, ${activity.profileImage}">
  </div>
  <div class="angle"></div>
  <div class="text">
      <span class="user-name">${activity.userName}</span>
      ${activity.comment}
  </div>
</div>`);
}

/**
 * @desc This function fetches the particular comment by taking a comment id.
 * @param {String} commentId 
 * @returns {Promise} - Promise to resolve the comment response.
 */
function fetchComment(commentId) {
  return $.ajax({
    url: '../CFCs/ReportComponent.cfc?method=GetCommentInfoOf',
    type: 'POST',
    data: {
      commentId: commentId
    }
  }).promise();
}

/**
 * @desc This function gets the User Interface of button from the backend by making a request.
 * @callback {callback}
 */
function updateActionButton(callback) {
  $.ajax({
    url: '../CFCs/ReportComponent.cfc?method=GetHTMLInterfaceForReportButtons',
    type: 'POST',
    data: {
      reportId: reportId
    }
  }).done(function (response) {
    const $statusAction = $('.status-action').empty();
    $(response).hide().appendTo($statusAction).fadeIn('fast');
    if ((typeof callback) === 'function') {
      callback();
    }
  });
}


/**
 * @desc This function updates the status of the report.
 * @callback callback 
 */
function updateReportStatus(callback) {
  $.ajax({
    url: '../CFCs/ReportComponent.cfc?method=GetStatusOfReport',
    type: 'POST',
    data: {
      reportId: reportId
    }
  }).done(function (response) {
    const responseInJson = JSON.parse(response);
    $('.report-status').removeClass('open in-review in-progress done fixed reopen').text(responseInJson.status).addClass(responseInJson.status.toLowerCase().replace(' ', '-'));
  });
}

/**
 * @desc This function shows a modal for choosing assignee and returns promise on choosing.
 * @returns {Promise} true on valid selection and false on canceling it.
 */
function chooseAssigneeModal() {
  return new Promise(function (resolve, reject) {
    const $chooseAssigneeModal = $('#chooseAssigneeModal');
    const $assigneeInput = $chooseAssigneeModal.find('#asigneeInput');

    $('.background-popup').fadeIn('fast', function () {
      $chooseAssigneeModal.fadeIn('fast');
    });

    $chooseAssigneeModal.find('.submit-btn').on('click', function (event) {
      checkValidityAssignee($assigneeInput);
      if (!$assigneeInput.parents('div.input-group').hasClass('invalid')) {
        resolve(true);
        $chooseAssigneeModal.fadeOut('fast', function () {
          $('.background-popup').fadeOut('fast');
        });
        $assigneeInput.val('');
      } else {
        resolve(false);
      }

      /**
       * 😆 Since everytime I execute the function the handler gets attached each time. 
       *  So for that reason it keeps executig. 
       */

      $(event.target).off();
    });

    $chooseAssigneeModal.find('.cancel-btn').on('click', function (event) {
      resolve(false);
      $chooseAssigneeModal.find('div.input-group').removeClass('invalid').find('.error-invalid, .error-empty').css('dispay', 'none');
      $chooseAssigneeModal.fadeOut('fast', function () {
        $('.background-popup').fadeOut('fast');
      });
      $chooseAssigneeModal.find('.error-invalid,.error-empty').css('display', 'none');
      $assigneeInput.val('');
    });

    $chooseAssigneeModal.find('.modal-close-btn').on('click', function () {
      resolve(false);
      $chooseAssigneeModal.find('.error-invalid,.error-empty').css('display', 'none');
      $chooseAssigneeModal.find('.input-group').removeClass('invalid');
      $chooseAssigneeModal.fadeOut('fast', function () {
        $('.background-popup').fadeOut('fast');
      });
      $assigneeInput.val('');
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
  });;
}

/**
 * @desc This function validates one formcontrol for assignee selecion.
 * @param {jquery} $formElement - FormElement jquery element for validation. 
 */
function checkValidityAssignee($formElement) {

  const $inputGroup = $formElement.parents('div.input-group');
  const $errorInvalid = $inputGroup.find('.error-invalid');
  const $errorEmpty = $inputGroup.find('.error-empty');

  if (!$('.auto-complete-item').hasClass('auto-complete-selected') && $formElement.val() !== '') {
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
 * @desc This function does the update of Assignee Name when changed.
 */
function updateAssigneeInfo() {
  $.ajax({
    url: '../CFCs/ReportComponent.cfc?method=GetAssigneeWorkingString',
    type: 'POST',
    data: {
      reportId: reportId
    }
  }).done(function (response) {
    const responseInJson = JSON.parse(response);
    $('#assigneeInfo').html(`<span class="user-name">${responseInJson.userName}</span> <span class="msg">${responseInJson.msg}</span>`);
  });
}

function onMessageHandler(message) {
  switch (message.channelname) {
    case 'report-status-update':
      updateAssigneeInfo();
      updateReportStatus();
      updateActionButton();
      break;
    case 'report-comment-post':
      fetchComment(message.data.commentId).then(function (response) {
        const responseInJson = JSON.parse(response);
        if (responseInJson.isActivity) {
          $(generateActivityUI(responseInJson)).hide().appendTo('#activityWindow .history').fadeIn('fast');
        } else {
          $(generateCommentUI(responseInJson)).hide().appendTo('#commentWindow .history').fadeIn('fast');
        }
      });
      break;
    case 'report-file-delete':
      showSpinner().then(function () {
        populateFileAttachment(function () {
          hideSpinner();
        });
      });
      break;
    case 'report-file-upload':
      showSpinner().then(function () {
        populateFileAttachment(function () {
          hideSpinner();
        });
      });
      break;
    default:
      console.log(message);
      break;
  }
}

function onOpenHandler() {
  cfWebSocketObj.subscribe('report-file-upload');
  cfWebSocketObj.subscribe('report-status-update');
  cfWebSocketObj.subscribe('report-file-delete');
  cfWebSocketObj.subscribe('report-comment-post');
}