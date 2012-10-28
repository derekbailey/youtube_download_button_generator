getTitle = ->
  document.querySelector('h1').textContent.replace(/^\s*|\s*$/g, '')

getMp3Url = ->
  'http://www.video2mp3.net/?url=' + location.href + '&hq=1'

getVideoUrls = ->
  reg = new RegExp('(\\s+)?yt\.playerConfig\\s=\\s(.*?)\n')
  data = document.querySelector('html').textContent.match(reg)[2].replace(/;$/, '')
  json = JSON.parse(data)
  param = json.args.url_encoded_fmt_stream_map
  itagOrder =
    38: 0,
    37: 1,
    22: 2,
    35: 3,
    34: 4
  param.split(',').map (val) ->
    itag: parseInt(val.match(/&?itag=([0-9]+)&?/)[1]),
    url: unescape(val.split(/&?url=(.*)&?/)[1]).replace('sig', 'signature'),
    type: unescape(val).split(/&?type=/)[1].split(/&/)[0].replace(/video\/|x-/g, '').split(/;/)[0],
    quality: val.match(/&quality=(.*)&?/)[1]
  .sort (a, b) ->
    if itagOrder[a.itag] == undefined
      a.itag = 5
    if itagOrder[b.itag] == undefined
      b.itag = 5
    itagOrder[a.itag] - itagOrder[b.itag]

###
createButton = (text, link, target) ->
  a = document.createElement('a')
  a.href = link
  a.className = 'yt-uix-button-content'
  a.textContent = text
  if target
    a.setAttribute('target', '_blank')

  bt = document.createElement('button')
  bt.className = 'yt-uix-tooltip-reverse yt-uix-button yt-uix-button-default yt-uix-tooltip yt-uix-button-empty'
  bt.appendChild(a)

  elm = document.querySelector('#watch-actions')
  elm.appendChild(bt)
###

createSelectButton = (vals) ->
  select = document.createElement('select')
  select.style.verticalAlign = 'top'
  select.onchange = ->
    location.href = this.value

  option = document.createElement('option')
  option.value = vals[0].link
  option.textContent = 'Download'
  select.appendChild(option)

  for val in vals
    option = document.createElement('option')
    option.value = val.link
    option.textContent = val.text
    select.appendChild(option)

  elm = document.querySelector('#watch-actions')
  elm.appendChild(select)

main = ->
  vals = getVideoUrls().map (val) ->
    text: 'Download(' + val.type + ')',
    link: val.url + '&title=' + encodeURIComponent getTitle()

  createSelectButton(vals)

main()
