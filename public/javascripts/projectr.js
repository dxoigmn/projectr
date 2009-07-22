$(document).ready(function() {
  $('.date').relatizeDate();
  
  var retrieving = false;
  
  function retrieveCommit() {
    url = $('li#next a').attr('href');
    
    if (url != undefined) {
      retrieving = true;
      
      $('#pagination').hide();
      $('.commit:last').after('<div id="loading"><img src="/images/loading.gif"/></div>')
      
      $.get($('li#next a').attr('href'), function(page) {
        $('#article').append($(page).find('#article').html());
        $('#pagination').html($(page).find('#pagination').html());
        $('.date').relatizeDate();
        $('div#loading').remove();
        $('#pagination').show();
        retrieving = false;
      });
    }
  }
  
  $(window).scroll(function(){
    if ($(window).scrollTop() == $(document).height() - $(window).height()){
      if (!retrieving) {
        retrieveCommit();
      }
    }
  });
});