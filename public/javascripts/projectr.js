$(document).ready(function() {
  $(".pagination").hide();
  
  $(".date").relatizeDate();
  
  function retrieveCommit() {
    $.getJSON($('.commit:last').attr('id') + '.js', function(commits) {
      $.each(commits, function(index, commit) {
        if (index == 0) {
          return;
        }
        
        $('.commit:last').after("\
        <div class='commit' id='" + commit.id + "'>\
          <h3>" + commit.sha + "</h3>\
          <div class='author'>\
            <h4>Author</h4>\
            <img src='" + commit.author_gravatar + "' />\
            <div class='name'>" + commit.author_name + "</div>\
            <div class='date'>" + commit.authored_date + "</div>\
          </div>\
          <div class='committer" + (commit['by_author?'] ? ' is_author' : '') + "'>\
            <h4>Committer</h4>\
            <img src='" + commit.committer_gravatar + "' />\
            <div class='name'>" + commit.committer_name + "</div>\
            <div class='date'>" + commit.committed_date + "</div>\
          </div>\
          <div class='message'>" + commit.message + "</div>\
          <div class='clear'></div>\
        </div>\
        ");
        $(".date").relatizeDate();
      })
    });
  }
  
  $(window).scroll(function(){
    if  ($(window).scrollTop() == $(document).height() - $(window).height()){
       retrieveCommit();
    }
  });
});