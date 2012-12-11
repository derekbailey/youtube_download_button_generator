
###
// ==UserScript==
// @name        Youtube Download Button Generator
// @description Youtube Download Button Generator
// @namespace   http://github.com/derekbailey
// @include     http://www.youtube.com/watch*
// @version     0.2
// ==/UserScript==
###

getTitle = ->
  document.querySelector('h1').textContent.replace(/^\s*|\s*$/g, '')

getMp3Url = ->
  'http://www.video2mp3.net/?url=' + location.href + '&hq=1'

getVideoUrls = ->
  reg = new RegExp('(\\s+)?yt\.playerConfig\\s=\\s(.*?)\n')
  data = document.querySelector('html').textContent.match(reg)[2].replace(/;$/, '')
  json = JSON.parse(data)
  param = json.args.url_encoded_fmt_stream_map
  itags = '38 46 37 84 22 45 10 85 35 44 18 34 10 10 82 43 6 36 83 5 17 13'.split(/\s/)
  itagOrder = {}
  for val, i in itags
    itagOrder[val] = i
  param.split(',').map (val) ->
    itag: parseInt(val.match(/&?itag=([0-9]+)&?/)[1]),
    url: unescape(val.split(/&?url=(.*)&?/)[1]).replace('sig', 'signature'),
    type: unescape(val).split(/&?type=/)[1].split(/&/)[0].replace(/video\/|x-/g, '').split(/;/)[0],
    quality: val.match(/&quality=(.*)&?/)[1]
  .sort (a, b) ->
    if itagOrder[a.itag] is undefined
      a.itag = itags.length
    if itagOrder[b.itag] is undefined
      b.itag = itags.length
    itagOrder[a.itag] - itagOrder[b.itag]

###
console.log(getVideoUrls());
###


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
  select.className = 'yt-uix-button'
  select.onchange = ->
    this.options[this.selectedIndex].textContent = "Download..."
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

  elm = document.querySelector('#watch7-secondary-actions')
  elm.appendChild(select)

main = ->
  vals = getVideoUrls().map (val) ->
    text: val.type + '(' + val.quality + ')',
    link: val.url + '&title=' + encodeURIComponent getTitle()

  createSelectButton(vals)

main()

