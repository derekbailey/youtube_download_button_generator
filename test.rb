# encoding: utf-8
require 'open-uri'
require 'json'
require 'uri'
require 'pp'

VIDEO = %!

http://www.youtube.com/watch?v=J-ZiPr1ryQU

!.strip

def get_html
  open(VIDEO).read
end

def get_json
  reg = /.*ytplayer\.config\s=\s(.*)/
  data = get_html.match(reg)[1].split("</script>")[0].sub(/;$/, "")
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

def get_title
  get_json["args"]["title"]
end

#puts get_html
#pp get_json
#pp get_param
#pp get_result
puts get_title

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

# 更新時にやること

・プログラムの修正
・グリモンヘッダーのバージョンを更新
・readme.mdにバージョンを追加

