$(document).ready(function () {

    fetchAllUsers().then(function (responseInJson) {
        $('.data-table').DataTable({
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

    $('#inviteUsersWindowTab').on('click', function () {
        const $userListWindow = $(this).parents('.tab').find('#userListWindow');
        const $inviteUserWindow = $(this).parents('.tab').find('#inviteUserWindow');
        $userListWindow.fadeOut('fast', function () {
            $inviteUserWindow.fadeIn('fast');
        });
    });

    $('#usersListWindowTab').on('click', function () {
        const $userListWindow = $(this).parents('.tab').find('#userListWindow');
        const $inviteUserWindow = $(this).parents('.tab').find('#inviteUserWindow');
        $inviteUserWindow.fadeOut('fast', function () {
            $userListWindow.fadeIn('fast');
        });
    });

    $('.invite-btn').on('click', function(event){
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
        $(this).parents('.modal').fadeOut('fast', function () {
            $('.background-popup').fadeOut('fast');
        });
    });

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