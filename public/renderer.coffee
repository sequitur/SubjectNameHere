
render_buzzwords = (buzzwords) ->
  console.log buzzwords
  buzzwordContainer = document.getElementById 'buzzword_content'
  buzzwordContainer.innerHTML  = buzzwords

get_content = () ->
  buzzSocket.send 'content request'

window.onload = () ->
  refresher = document.getElementById 'refresh'
  refresher.addEventListener 'click', () ->
    get_content()

buzzSocket.onmessage = (event) ->
  render_buzzwords event.data

buzzSocket.onopen = (event) ->
  buzzSocket.send 'content request'
