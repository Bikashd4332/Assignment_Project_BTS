<cfinvoke component="Assignment_Project_BTS.CFCs.UtilComponent" method="IsLoggedInPersonAnAdmin"
    returnvariable="isAdmin" />
<cfinvoke component="Assignment_Project_BTS.CFCs.UtilComponent" method="GetTotalNumberOfReports"
    returnvariable="reportCount" />
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Home | Ticket Tracking System</title>
    <meta name="theme-color" content="#87ceeb">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">

    <link rel="icon" href="../img/insect.png">
    <link rel="stylesheet" href="../css/font-awesome.min.css">
    <link rel="stylesheet" href="../css/global-style.css">
    <link rel="stylesheet" href="../css/navbar-style.css">
    <link rel="stylesheet" href="../css/logged-in-navbar-style.css">
    <link rel="stylesheet" href="../css/footer-style.css">
    <link rel="stylesheet" href="../css/about-style.css">

    <script src="../js/jquery-3.0.0.min.js"></script>
    <script src="../js/navbar-functionality.js"></script>
</head>

<body>
    <div class="navbar">
        <div class="container-fluid">
            <div class="container">
                <nav>

                    <cfif session.userEmail EQ ''>
                        <div class="branding">
                            <img class="brand-icon" src="../img/insect.png">
                            <p class="brand-text">Ticket Tracking System</p>
                        </div>
                        <ul class="navlist">
                            <li><a href="../index.cfm" class="navlink"><i class="fa fa-home"></i> Home</a></li>
                            <li><a href="login.cfm" class="navlink"><i class="fa fa-sign-in"></i> Log In</a></li>
                            <li><a href="About_This_Project.cfm" class="active navlink"><i
                                        class="fa fa-info-circle"></i>
                                    About This Project</a></li>
                        </ul>
                        <cfelse>
                            <div class="branding" style="justify-content: center">
                                <img class="brand-icon" src="../img/insect.png">
                                <p class="brand-text">Ticket Tracking System</p>
                                <img class="profile-img" src="../img/placeholder-person.png" alt="Profile Imamge"
                                    class="profile-img">
                            </div>
                            <ul class="navlist">
                                <li id="profile-img-li"><a href="#" class="navlink"><img class="profile-img"
                                            src="../img/placeholder-person.png" /></a></li>
                                <li><a href="overview.cfm" class="navlink active"><i class="fa fa-dashboard"></i>
                                        Overview</a></li>
                                <cfoutput>
                                    <li><a href="reports.cfm" class="navlink"><i class="number-badge">#reportCount#</i>
                                            Reports</a></li>
                                </cfoutput>
                                <cfif isAdmin>
                                    <li><a href="users.cfm" class="navlink"><i class="fa fa-user"></i> Users</a></li>
                                </cfif>
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
        <div class="heading-container">
            <div class="container">
                <h3 class="heading">I believe in being free, being power-full and being open source.</h3>
                <p class="info">An Open-Sourced internship project made for the fullfillment of masters degree.</p>
            </div>
        </div>

        <div class="container">
            <div class="section">
                Lorem ipsum dolor sit amet, consectetur adipisicing elit. Enim quasi quo aperiam nihil, quidem fugit
                modi ex sapiente quod labore nulla aut sunt delectus ipsum! Quia, quos tempore. Voluptate, saepe?Quidem
                libero incidunt reprehenderit excepturi minima. Ipsa iste tempore, odit eius amet quaerat sunt ipsam
                error natus consequuntur. Quo ipsa est ab sit quisquam, reprehenderit impedit laborum molestiae fuga
                cupiditate.
            </div>

            <div class="section">
                Lorem ipsum dolor sit amet, consectetur adipisicing elit. Enim quasi quo aperiam nihil, quidem fugit
                modi ex sapiente quod labore nulla aut sunt delectus ipsum! Quia, quos tempore. Voluptate, saepe?Quidem
                libero incidunt reprehenderit excepturi minima. Ipsa iste tempore, odit eius amet quaerat sunt ipsam
                error natus consequuntur. Quo ipsa est ab sit quisquam, reprehenderit impedit laborum molestiae fuga
                cupiditate.
            </div>
        </div>


        <cfif session.userEmail NEQ ''>
            <div class="footer">
                <div class="container">
                    <div class="footer-wrapper">
                        <div class="branding">
                            <img class="brand-icon" src="../img/insect.png">
                            <p class="brand-text">Ticket Tracking System</p>
                        </div>
                        <ul class="navlist">
                            <li><a href="overview.cfm" class="navlink"></i>Overview</a></li>
                            <cfif isAdmin>
                                <li><a href="users.cfm" class="navlink">Users</a></li>
                            </cfif>
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
                <cfelse>

                    <div class="footer">
                        <div class="container">
                            <div class="footer-wrapper">
                                <div class="branding">
                                    <img class="brand-icon" src="../img/insect.png">
                                    <p class="brand-text">Ticket Tracking System</p>
                                </div>
                                <ul class="navlist">
                                    <li><a href="../index.cfm" class="navlink"></i> Home</a></li>
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

    </div>

</body>

</html>