// Generated by CoffeeScript 1.3.3

/*
// ==UserScript==
// @name        Youtube Download Button Generator
// @description Youtube Download Button Generator
// @namespace   http://github.com/derekbailey
// @include     http://www.youtube.com/watch*
// @version     0.1
// ==/UserScript==
*/


(function() {
  var createSelectButton, getMp3Url, getTitle, getVideoUrls, main;

  getTitle = function() {
    return document.querySelector('h1').textContent.replace(/^\s*|\s*$/g, '');
  };

  getMp3Url = function() {
    return 'http://www.video2mp3.net/?url=' + location.href + '&hq=1';
  };

  getVideoUrls = function() {
    var data, i, itagOrder, itags, json, param, reg, val, _i, _len;
    reg = new RegExp('(\\s+)?yt\.playerConfig\\s=\\s(.*?)\n');
    data = document.querySelector('html').textContent.match(reg)[2].replace(/;$/, '');
    json = JSON.parse(data);
    param = json.args.url_encoded_fmt_stream_map;
    itags = '38 46 37 84 22 45 10 85 35 44 18 34 10 10 82 43 6 36 83 5 17 13'.split(/\s/);
    itagOrder = {};
    for (i = _i = 0, _len = itags.length; _i < _len; i = ++_i) {
      val = itags[i];
      itagOrder[val] = i;
    }
    return param.split(',').map(function(val) {
      return {
        itag: parseInt(val.match(/&?itag=([0-9]+)&?/)[1]),
        url: unescape(val.split(/&?url=(.*)&?/)[1]).replace('sig', 'signature'),
        type: unescape(val).split(/&?type=/)[1].split(/&/)[0].replace(/video\/|x-/g, '').split(/;/)[0],
        quality: val.match(/&quality=(.*)&?/)[1]
      };
    }).sort(function(a, b) {
      if (itagOrder[a.itag] === void 0) {
        a.itag = itags.length;
      }
      if (itagOrder[b.itag] === void 0) {
        b.itag = itags.length;
      }
      return itagOrder[a.itag] - itagOrder[b.itag];
    });
  };

  /*
  console.log(getVideoUrls());
  */


  /*
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
  */


  createSelectButton = function(vals) {
    var elm, option, select, val, _i, _len;
    select = document.createElement('select');
    select.style.verticalAlign = 'top';
    select.onchange = function() {
      return location.href = this.value;
    };
    option = document.createElement('option');
    option.value = vals[0].link;
    option.textContent = 'Download';
    select.appendChild(option);
    for (_i = 0, _len = vals.length; _i < _len; _i++) {
      val = vals[_i];
      option = document.createElement('option');
      option.value = val.link;
      option.textContent = val.text;
      select.appendChild(option);
    }
    elm = document.querySelector('#watch-actions');
    return elm.appendChild(select);
  };

  main = function() {
    var vals;
    vals = getVideoUrls().map(function(val) {
      return {
        text: val.type + '(' + val.quality + ')',
        link: val.url + '&title=' + encodeURIComponent(getTitle())
      };
    });
    return createSelectButton(vals);
  };

  main();

}).call(this);
