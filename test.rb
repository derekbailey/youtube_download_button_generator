# encoding: utf-8
require 'open-uri'
require 'json'
require 'uri'
require 'pp'

VIDEO = 'http://www.youtube.com/watch?v=79vtRZSLvfw'

def html
  open(VIDEO).read
end

def json
  reg = /(\s+)?yt\.playerConfig\s=\s(.*?)\n/
  data = html.match(reg)[2].gsub(/;$/, '')
  JSON.parse data
end

def param
  param = json['args']['url_encoded_fmt_stream_map']
  param.split(',').map{|val|
    {
      itag: val.match(/&?itag=([0-9]+)&?/)[1].to_i,
      url: URI.decode(val.split(/&?url=(.*)&?/)[1]).gsub('sig', 'signature'),
      type: URI.decode(val).split(/&?type=/)[1].split(/&/)[0].gsub(/video\/|x-/, '').split(/;/)[0],
      quality: val.match(/&quality=(.*)&?/)[1]
    }
  }
end

pp param

