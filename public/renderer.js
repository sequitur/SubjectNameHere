// Generated by CoffeeScript 1.6.1
(function() {
  var render_buzzwords;

  render_buzzwords = function(buzzwords) {
    $('div#buzzword_content').empty();
    $('div#buzzword_content').append(buzzwords);
    return $('div#buzzword_content').fadeIn(600);
  };

  $(document).ready(function() {
    $.getJSON('/get_content', function(response) {
      return render_buzzwords(response.html);
    });
    return $('a#refresh').click(function() {
      $('div#buzzword_content').fadeOut(200);
      return $.getJSON('/get_content', function(response) {
        return render_buzzwords(response.html);
      });
    });
  });

}).call(this);
