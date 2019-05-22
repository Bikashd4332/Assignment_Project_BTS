<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <cfoutput>
        <title>#local.error# Error | Ticket Tracking System</title>
    </cfoutput>
    <meta name="theme-color" content="#87ceeb">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">

    <link rel="icon" href="/Assignment_Project_BTS/img/insect.png">
    <link rel="stylesheet" href="/Assignment_Project_BTS//css/font-awesome.min.css">
    <link rel="stylesheet" href="/Assignment_Project_BTS//css/global-style.css">
    <link rel="stylesheet" href="/Assignment_Project_BTS//css/navbar-style.css">
    <link rel="stylesheet" href="/Assignment_Project_BTS//css/logged-in-navbar-style.css">
    <link rel="stylesheet" href="/Assignment_Project_BTS//css/footer-style.css">
    <link rel="stylesheet" href="/Assignment_Project_BTS//css/error-styling.css">

    <script src="/Assignment_Project_BTS//js/jquery-3.0.0.min.js"></script>
    <script src="/Assignment_Project_BTS//js/navbar-functionality.js"></script>
    <script src="/Assignment_Project_BTS//js/error-functionality.js"></script>
    <style>
        .branding-wrapper {
            text-decoration: none;
            width: 100%;
            color: black;
        }
    </style>
</head>

<body>
    <div class="navbar">
        <div class="container-fluid">
            <div class="container">
                <nav>

                    <cfif session.userEmail EQ ''>
                        <a href="/Assignment_Project_BTS//index.cfm" class="branding-wrapper">
                            <div class="branding" style="justify-content: center;">
                                <img class="brand-icon" src="/Assignment_Project_BTS//img/insect.png">
                                <p class="brand-text">Ticket Tracking System</p>
                            </div>
                        </a>
                        <ul class="navlist">
                            <li><a href="/Assignment_Project_BTS/index.cfm" class="navlink"><i class="fa fa-home"></i> Home</a></li>
                            <li><a href="/Assignment_Project_BTS/login.cfm" class="navlink"><i class="fa fa-sign-in"></i> Log In</a></li>
                            <li><a href="/Assignment_Project_BTS/About_This_Project.cfm" class="navlink"><i class="fa fa-info-circle"></i>
                                    About This Project</a></li>
                        </ul>
                        <cfelse>
                            <cfinvoke component="Assignment_Project_BTS.CFCs.UtilComponent"
                                method="GetTotalNumberOfReports" returnvariable="reportCount" />

                            <a href="/Assignment_Project_BTS/index.cfm" class="branding-wrapper">
                                <div class="branding">
                                    <img class="brand-icon" src="/Assignment_Project_BTS/img/insect.png">
                                    <p class="brand-text">Ticket Tracking System</p>
                                    <img class="profile-img" src="/Assignment_Project_BTS/img/placeholder-person.png" alt="Profile Imamge"
                                        class="profile-img">
                                </div>
                            </a>
                            <ul class="navlist">
                                <li id="profile-img-li"><a href="#" class="navlink"><img class="profile-img"
                                            src="/Assignment_Project_BTS/img/placeholder-person.png" /></a></li>
                                <li><a href="/Assignment_Project_BTS/cfm/overview.cfm" class="navlink"><i class="fa fa-dashboard"></i>
                                        Overview</a></li>
                                <cfoutput>
                                    <li><a href="/Assignment_Project_BTS/cfm/reports.cfm" class="navlink"><i class="number-badge">#reportCount#</i>
                                            Reports</a></li>
                                </cfoutput>
                                <li><a href="/Assignment_Project_BTS/cfm/users.cfm" class="navlink"><i class="fa fa-user"></i> Users</a></li>
                                <li><a href="#" id="logOutButton" class="navlink"><i class="fa fa-sign-out"></i> Log
                                        out</a></li>
                            </ul>
                    </cfif>
                    <div class="nav-toggler">
                        <a href="#" class="fa fa-arrow-up"></a>
                    </div>
                </nav>
            </div>
        </div>
    </div>

    <div class="container-fluid">
        <div class="container" id="pageBody">
            <div class="error-info">
                <div class="error-code">
                    <cfoutput>#local.error#</cfoutput>
                </div>
                <div class="bug-img"><img src="/Assignment_Project_BTS//img/insect.png" alt=""></div>
            </div>
            <div class="error-text"></div>
            <div class="error-desc">Oops, The page you are finding does not exist.</div>
        </div>
    </div>

    <cfif session.userEmail NEQ ''>
        <div class="footer">
            <div class="container">
                <div class="footer-wrapper">
                    <div class="branding">
                        <img class="brand-icon" src="/Assignment_Project_BTS//img/insect.png">
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
        <cfelse>

            <div class="footer">
                <div class="container">
                    <div class="footer-wrapper">
                        <div class="branding">
                            <img class="brand-icon" src="/Assignment_Project_BTS//img/insect.png">
                            <p class="brand-text">Ticket Tracking System</p>
                        </div>
                        <ul class="navlist">
                            <li><a href="/Assignment_Project_BTS//index.cfm" class="navlink"></i> Home</a></li>
                            <li><a href="login.cfm" class="navlink"></i> Log In</a></li>
                            <li><a href="./about_this_project.cfm" class="navlink">About This Project</a></li>
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

    </cfif>
</body>

</html>