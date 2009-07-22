$(document).ready(function() {
  $(".pagination").hide();
  
  $(".date").relatizeDate();
  
  function retrieveCommit() {
    $('.commit:last').after('<img src="/images/loading.gif" class="loading"/>')
    
    $.get($('.commit:last').attr('id'), function(page) {
      $(page).find('div.commit').each(function(index, commit) {
        if (index == 0) {
          return;
        }
        
        $('.commit:last').after(commit);
      });
      
      $(".date").relatizeDate();
      $('img.loading').remove();
    });
  }
  
  $(window).scroll(function(){
    if ($(window).scrollTop() == $(document).height() - $(window).height()){
       retrieveCommit();
    }
  });
});