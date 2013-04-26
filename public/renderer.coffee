render_buzzwords = (buzzwords) ->
  $('div#buzzword_content').empty()
  $('div#buzzword_content').append buzzwords
  $('div#buzzword_content').fadeIn 600

$( document ).ready () ->
  $.getJSON '/get_content', (response) ->
    render_buzzwords response.html
  $('a#refresh').click () ->
    $('div#buzzword_content').fadeOut 200 
    $.getJSON '/get_content', (response) ->
      render_buzzwords response.html

