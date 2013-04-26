
render_buzzwords = (buzzwords) ->
  console.log buzzwords
  buzzwordContainer = document.getElementById 'buzzword_content'
  buzzwordContainer.innerHTML  = buzzwords

get_content = () ->
  buzzSocket.send 'content request'

window.onload = () ->
  buzzSocket.open
  get_content()

  refresher = document.getElementById 'refresh'
  refresher.addEventListener 'click', () ->
    get_content()

buzzSocket.onmessage = (event) ->
  render_buzzwords event.data

