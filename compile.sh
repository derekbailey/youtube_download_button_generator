
if test "$1" = "w"; then
  coffee -cw youtube_download_button_generator.user.coffee

else
  coffee -c youtube_download_button_generator.user.coffee
  echo "Compiled: youtube_download_button_generator.user.js"

  ruby -e "File.open('tmp.md', 'wb') {|f| f.write File.read('readme.md').gsub(/[a-zA-z#\n\s]*Greasemonkey/, '').gsub(/^##\s/, '### ') }"
  perl $HOME/Dropbox/Dotfiles/lib/Markdown.pl tmp.md > userscript.org.html;
  rm tmp.md
  echo "Compiled: userscript.org.html"

fi

