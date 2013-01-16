# encoding: utf-8
require 'open-uri'
require 'json'
require 'uri'
require 'pp'

VIDEO = %!

http://www.youtube.com/watch?v=InzDjH1-9Ns

!.strip

def get_html
  open(VIDEO).read
end

def get_json
  reg = /(\s+)?yt\.playerConfig\s=\s(.*?)\n/
  data = get_html.match(reg)[2].gsub(/;$/, '')
  JSON.parse data
end

def get_param
  get_json['args']['url_encoded_fmt_stream_map'].split(",")
end

def get_result
  result = []
  get_param.each do |param|
    video = { itag: nil, url: nil, sig: nil, type: nil, quality: nil, dl_url: nil }
    param.split("&").each do |val|
      key, val = val.split("=")
      case key
      when /itag/
        video[:itag]    = val
      when /url/
        video[:url]     = URI.decode val
      when /sig/
        video[:sig]     = val
      when /type/
        video[:type]    = URI.decode(val).split("video/")[1].split(";").first
      when /quality/
        video[:quality] = val
      end
    end
    video[:dl_url] = video[:url] + "&signature=" + video[:sig]
    result << video
  end
  result
end

pp get_result

__END__

# Youtubeの動画を保存するスクリプト

動画ページのhtml内のjsonからurl_encoded_fmt_stream_mapを抽出する。
ビデオのフォーマットごとのデータがカンマ区切りで記述されている。
カンマで分割してビデオごとのクエリ文字列を作る。
クエリ文字列を&で分割すると以下のキーができる。
  url sig type fallback itag
urlの値をURI.decodeする
sigの値をsignatureというキー名にしてurlと結合する。
それが動画のURLなので、ブラウザからアクセスか、プログラムから取得するかで保存できる。



