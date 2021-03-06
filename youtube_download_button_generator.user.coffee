
###
// ==UserScript==
// @name        Youtube Download Button Generator
// @description Youtube Download Button Generator
// @namespace   http://github.com/derekbailey
// @include     http://www.youtube.com/watch*
// @include     https://www.youtube.com/watch*
// @version     0.7
// ==/UserScript==
###

getTitle = ->
  getJson().args.title

getJson = ->
  reg = /.*ytplayer\.config\s=\s(.*)/
  data = document.querySelector('html').textContent.match(reg)[1].split(";</script>")[0].replace(/;\s+?$/, "")
  JSON.parse(data)

getVideoUrls = ->
  return getJson().args.url_encoded_fmt_stream_map.split(',').map (param) ->
    video = {}
    param.split("&").map (val) ->
      data = val.split "="
      key = data[0]
      val = data[1]
      switch key
        when "itag"
          video.itag    = parseInt val
        when "url"
          video.url     = unescape val
        when "sig"
          video.sig     = val
        when "type"
          video.type    = unescape(val).split("video/")[1].split(";")[0].replace "x-", ""
        when "quality"
          video.quality = val
    video

sortByItag = (videos)->
  itags = '38 46 37 84 22 45 10 85 35 44 18 34 10 10 82 43 6 36 83 5 17 13'.split /\s/
  itagOrder = {}
  for val, i in itags
    itagOrder[val] = i
  return videos.sort (a, b) ->
    if itagOrder[a.itag] is undefined
      a.itag = itags.length
    if itagOrder[b.itag] is undefined
      b.itag = itags.length
    itagOrder[a.itag] - itagOrder[b.itag]

###
console.log(getVideoUrls());
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
  vals = sortByItag(getVideoUrls()).map (val) ->
    text: val.type + '(' + val.quality + ')',
    link: val.url + "&signature=" + val.sig+ '&title=' + encodeURIComponent getTitle()

  createSelectButton(vals)

main()

