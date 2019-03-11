$(document).ready(function() {
  $('#profileImage').on('change', function(event) {
    let myReader = new FileReader();
    myReader.onload = function(e) {
        $('.file-preview > img').attr('src', e.target.result);
    }
    if( event.target.files[0].type.includes('image') ) {
      myReader.readAsDataURL(event.target.files[0]);
    } 
  });
});