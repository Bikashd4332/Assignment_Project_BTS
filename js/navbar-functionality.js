$(document).ready( function() {
  // On Click nav-toggler toggle navlist
  $('.navbar .nav-toggler').on('click', function() {
    // If navlist is not shown then show by fading in.
    if ($('nav .navlist').css('display') === 'none') {
      $('nav .navlist').fadeIn('fast', function() {
        // Also changing the nav-toggler's icon to up
        $('nav .nav-toggler > a')
            .addClass('fa-arrow-up')
            .removeClass('fa-arrow-down');
      });
      // Else hide navlist by fading out.
    } else {
      $('nav .navlist').fadeOut('fast', function() {
        // Also changing the nav-toggler's icon to down
        $('nav .nav-toggler > a')
            .addClass('fa-arrow-down')
            .removeClass('fa-arrow-up');
      });
    }
  });

  $(window).resize(function() {
    if ($(window).width() > 780 && $('.navlist').css('display') === 'none') {
      $('.navlist').css('display', 'flex');
    }
  });

});
