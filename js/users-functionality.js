let userDataTable;
let invitationDataTable;

$(document).ready(function () {

    fetchAllUsers().then(function (responseInJson) {
        userDataTable = $('.data-table').DataTable({
            data: responseInJson,
            responsive: true,
            columnDefs: [{
                className: 'nowrap'
            }],
            autoWidth: true,
            columns: [{
                    title: "#"
                },
                {
                    title: "Avatar",
                    serchable: false,
                    render: processBase64Data
                },
                {
                    title: "Name"
                },
                {
                    title: "EmailID"
                },
                {
                    title: "Number"
                },
                {
                    title: "Title"
                },
                {
                    title: "Since"
                }
            ],
        });
    });

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

    $('#inviteUsersWindowTab.tab-nav-active').on('click', function () {
        const $userListWindow = $(this).parents('.tab').find('#userListWindow');
        const $inviteUserWindow = $(this).parents('.tab').find('#inviteUserWindow');
        $userListWindow.fadeOut('fast', function () {
            $inviteUserWindow.fadeIn('fast');
            if (invitationDataTable === undefined) {
                populateInvitationDataTable();
            } else {
                invitationDataTable.destroy();
                populateInvitationDataTable();
            }
        });
    });

    $('#usersListWindowTab').on('click', function () {
        const $userListWindow = $(this).parents('.tab').find('#userListWindow');
        const $inviteUserWindow = $(this).parents('.tab').find('#inviteUserWindow');
        $inviteUserWindow.fadeOut('fast', function () {
            $userListWindow.fadeIn('fast');
        });
    });

    $('.invite-btn').on('click', function (event) {
        event.preventDefault();
        $('.background-popup').fadeIn('fast', function () {
            $('#inviteModal').fadeIn('fast');
        });
    });

    $('.bulk-invite-btn').on('click', function (event) {
        event.preventDefault();
        $('.background-popup').fadeIn('fast', function () {
            $('#bulkInviteModal').fadeIn('fast');
        });
    });

    $('.modal-close-btn, .cancel-btn').on('click', function (event) {
        event.preventDefault();
        const $modal = $(this).parents('.modal');

        $modal.fadeOut('fast', function () {
            $('.background-popup').fadeOut('fast');
        });
        $modal.find('#emailListTextArea').val('');
        $modal.find('.input-group').removeClass('invalid');
        $modal.find('.error-invalid, .error-empty').hide();
    });

    $('#userEmailInput').on('blur', function (event) {
        const $inputGroup = $(this).parents('div.input-group');
        const $errorInvalid = $inputGroup.find('.error-invalid').hide();
        const $errorEmpty = $inputGroup.find('.error-empty').hide();

        if (event.target.validity.valid) {
            $.ajax({
                url: '../CFCs/UtilComponent.cfc',
                data: {
                    method: 'IsEmailValid',
                    emailId: `${event.target.value}`
                }
            }).done(function (response) {
                const responseInJson = JSON.parse(response);
                if (!responseInJson.valid) {
                    $inputGroup.addClass('invalid');
                    $errorInvalid.text('This Email is already registered.').show();
                } else {
                    $inputGroup.removeClass('invalid');
                }
            });
        } else if (event.target.validity.patternMismatch) {
            $inputGroup.addClass('invalid');
            $errorInvalid.text('This is not a valid email address.').show();
        } else if (event.target.validity.valueMissing) {
            $inputGroup.addClass('invalid');
            $errorEmpty.show();
        }
    });

    $("#userTitleCheckBox").on('change', function () {
        if ($(this).prop('checked')) {
            $('#personTitleSelect').prop('disabled', false);
        } else {
            $('#personTitleSelect').prop('disabled', true);
        }
    });

    $('#inviteModal .submit-btn').on('click', function (event) {
        event.preventDefault();
        const isEmailValid = !$('#userEmailInput').parents('div.input-group').hasClass('invalid');
        const dataToSend = {
            method: 'InviteUser'
        };

        if ($('#userTitleCheckBox').prop('checked')) {
            dataToSend['titleId'] = $('#personTitleSelect').val();
        }

        if (isEmailValid) {
            dataToSend['userEmailList'] = [$('#userEmailInput').val()];
            $.ajax({
                url: '../CFCs/UsersComponent.cfc',
                data: dataToSend
            }).done(function () {
                $('#inviteModal').fadeOut('fast', function () {
                    $('.background-popup').fadeOut('fast');
                });
            });
        }
    });

    $('#emailListTextArea').on('blur', function (event) {
        const eneterdEmailListString = $(this).val();
        const $inputGroup = $(this).parents('.input-group');

        $inputGroup.find('.error-empty, .error-invalid').hide();

        if (!validateEmailList(eneterdEmailListString)) {
            $inputGroup.addClass('invalid');
            if (eneterdEmailListString === '') {
                $inputGroup.find('.error-empty').show();
            } else {
                $inputGroup.find('.error-invalid').show();
            }
        }
    });

    $('#emailListTextArea').on('input', function () {
        const $inputGroup = $(this).parents('.input-group');
        $inputGroup.removeClass('invalid');
        $inputGroup.find('.error-invalid, .error-exist, .error-empty').hide();
    });

    $("#bulkInviteModal .submit-btn").on('click', function (event) {
        event.preventDefault();
        const $emailListTextArea = $('#emailListTextArea');
        const $errorExist = $emailListTextArea.parents('.input-group').find('.error-exist').hide();
        if (!$emailListTextArea.parents('.input-group').hasClass('invalid')) {
            $(this).addClass('busy');
            $emailListTextArea.prop('disable', true);
            const emailList = $emailListTextArea.val().split(';');
            $.ajax({
                url: '../CFCs/UtilComponent.cfc',
                data: {
                    method: 'IsMultipleEmailValid',
                    userEmailList: emailList
                }
            }).done(function (response) {
                const responseInJson = JSON.parse(response);
                if (responseInJson.length !== 0) {
                    $emailListTextArea.parents('.input-group').addClass('invalid');
                    let errorString = "";
                    responseInJson.forEach(function (existingEmail) {
                        errorString += `${existingEmail} is already exists.<br/>`;
                    });
                    $errorExist.html(errorString);
                    $errorExist.show();
                } else {
                    $.ajax({
                        url: '../CFCs/UsersComponent.cfc',
                        data: {
                            method: 'InviteUser',
                            userEmailList: emailList
                        }
                    }).done(function (response) {
                        if (JSON.parse(response) === true) {
                            $('#bulkInviteModal').fadeOut('fast', function () {
                                $('.background-popup').fadeOut('fast');
                            });
                            invitationDataTable.destroy();
                            populateInvitationDataTable();
                        }
                    });
                }
            });
        }
    });

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
    })

});

function processBase64Data(data, type, row, meta) {
    const splitedData = data.split(',');
    return `<img class="profile-img" src="data:image/${splitedData[1]};base64,` + splitedData[0] + '">';
}

function fetchAllUsers() {
    return new Promise(function (resolve, reject) {
        $.ajax({
            url: '../CFCs/UsersComponent.cfc?method=fetchUserRecords',
        }).done(function (response) {
            const responseInJson = JSON.parse(response);
            resolve(responseInJson);
        });
    });
}

function fetchAllUserInvitation() {
    return new Promise(function (resolve, reject) {
        $.ajax({
            url: '../CFCs/UsersComponent.cfc?method=fetchUserInvitationRecords'
        }).done(function (response) {
            const responseInJson = JSON.parse(response);
            resolve(responseInJson);
        });
    });
}

function populateInvitationDataTable() {
    fetchAllUserInvitation().then(function (responseInJson) {
        invitationDataTable = $('.data-table-invite').DataTable({
            data: responseInJson,
            responsive: true,
            paging: true,
            searching: true,
            columnDefs: [{
                className: 'nowrap'
            }],
            autoWidth: true,
            columns: [{
                    title: "EmailID"
                },
                {
                    title: "UUID",
                },
                {
                    title: "Date"
                },
                {
                    title: "Status"
                },
                {
                    title: "Title"
                }
            ],
        });
    });
}

function validateEmailList(emailListString) {
    const emailListPattern = /^([a-zA-Z]+(\.?[a-zA-Z0-9]+)+@[a-zA-Z]+(\.co)?\.([a-z]{2,3});?\b)+$/;
    return emailListString !== '' ? emailListPattern.test(emailListString) : false;
}