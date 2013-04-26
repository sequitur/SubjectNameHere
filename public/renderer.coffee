
render_buzzwords = (buzzwords) ->
  console.log buzzwords
  buzzwordContainer = document.getElementById 'buzzword_content'
  buzzwordContainer.innerHTML  = buzzwords
  buzzSocket.close

get_content = () ->
  buzzSocket.open
  buzzSocket.send 'content request'

window.onload = () ->
  get_content()

  refresher = document.getElementById 'refresh'
  refresher.addEventListener 'click', () ->
    get_content()

buzzSocket.onmessage = (event) ->
  render_buzzwords event.data

