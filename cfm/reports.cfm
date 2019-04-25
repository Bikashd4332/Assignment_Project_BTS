<cfif session.userEmail EQ "">
    <cflocation url="login.cfm" addtoken="false">
</cfif>

<cfinvoke component="Assignment_Project_BTS.CFCs.UtilComponent" method="IsLoggedInPersonAnAdmin"
    returnvariable="isAdmin" />
<cfinvoke component="Assignment_Project_BTS.CFCs.UtilComponent" method="GetTotalNumberOfReports"
    returnvariable="reportCount" />


<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Reports | Ticket Tracking System</title>

    <link rel="shortcut icon" href="../favicon.ico" type="image/x-icon">
    <link rel="stylesheet" href="../css/font-awesome.min.css">

    <link rel="stylesheet" href="../css/global-style.css">
    <link rel="stylesheet" href="../css/navbar-style.css">
    <link rel="stylesheet" href="../css/logged-in-navbar-style.css">
    <link rel="stylesheet" href="../css/footer-style.css">
    <link rel="stylesheet" href="../css/form-styling.css">
    <link rel="stylesheet" href="../css/spinner-style.css">
    <link rel="stylesheet" href="../css/reports-style.css">

    <script src="../js/jquery-3.0.0.min.js"></script>
    <script src="../js/navbar-functionality.js"></script>
    <script src="../js/form-functionality.js"></script>
    <script src="../js/reports-functionality.js"></script>
    <script src="../js/reports-stats.js"></script>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>

</head>

<body>

    <div class="navbar">
        <div class="container-fluid">
            <div class="container">
                <nav>
                    <div class="branding">
                        <img class="brand-icon" src="../img/insect.png">
                        <p class="brand-text">Ticket Tracking System</p>
                        <img src="../img/placeholder-person.png" alt="Profile Imamge" class="profile-img">
                    </div>
                    <ul class="navlist">
                        <li id="profile-img-li"><a href="#" class="navlink"><img class="profile-img"
                                    src="../img/placeholder-person.png" /></a>
                        </li>
                        <li><a href="overview.cfm" class="navlink"><i class="fa fa-dashboard"></i>
                                Overview</a>
                        </li>
                        <cfoutput>
                            <li><a href="reports.cfm" class=" active navlink"><i class="number-badge">#reportCount#</i>
                                    Reports</a></li>
                        </cfoutput>

                        <li><a href="users.cfm" class="navlink"><i class="fa fa-user"></i> Users</a></li>

                        <li><a href="#" id="logOutButton" class="navlink log-out-btn"><i class="fa fa-sign-out"></i> Log out</a>
                        </li>
                    </ul>
                    <div class="nav-toggler">
                        <a href="#" class="fa fa-arrow-up"></a>
                    </div>
                </nav>
            </div>
        </div>
    </div>

    <div class="container-fluid">
        <div class="container" id="pageBody">
            <div class="header-wrapper">
                <div class="header">
                    <h1 class="heading">Reports List</h1>
                    <p class="heading-info">All the list of reports that has been generated since the start.</p>
                </div>
                <div class="search-bar">
                    <input type="text" class="search-control" id="reportSearchInput" placeholder="Search..">
                    <span id="searchBarIcon"><i class="fa fa-search"></i></span>
                </div>
            </div>
            <div class="report-container">
                <div class="spinner-container">
                    <div class="lds-ring">
                        <div></div>
                    </div>
                </div>
                <div class="report-list"> 
                </div>
            </div>
            <div class="" id="chart_div"></div>
        </div>
        <div class="footer">
            <div class="container">
                <div class="footer-wrapper">
                    <div class="branding">
                        <img class="brand-icon" src="../img/insect.png">
                        <p class="brand-text">Ticket Tracking System</p>
                    </div>
                    <ul class="navlist">
                        <li><a href="overview.cfm" class="navlink"></i>Overview</a></li>
                        <li><a href="users.cfm" class="navlink">Users</a></li>
                        <li><a href="reports.cfm" class="navlink"> Reports</a></li>
                        <li><a href="./about_this_project.cfm" class="navlink"> About Project</a></li>
                    </ul>
                </div>
                <hr />
                <div class="footer-wrapper">
                    <p class="copyright-info"><i class="fa fa-copyright"></i> Ticket Tracking System</p>
                    <div class="social-links">
                        <a href="#"><i class="fa fa-facebook-square"></i></a>
                        <a href="#"><i class="fa fa-twitter"></i></a>
                        <a href="#"><i class="fa fa-github"></i></a>
                    </div>
                </div>
            </div>

        </div>

</body>

</html>