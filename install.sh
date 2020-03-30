scratch=$(mktemp -d -t tmp.XXXXXXXXXX) 

cd $scratch

curl -k https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-286.0.0-linux-x86_64.tar.gz -O

tar -xzf google-cloud-sdk-286.0.0-linux-x86_64.tar.gz 

cd google-cloud-sdk

# get list of files which need shebang changed
find $(pwd) -type f -exec awk '
  /^#!.*/{print FILENAME}
  {nextfile}' {} + > ../lines.txt

# create termux-fix-shebang (if not on android)
vi ~/bin/termux-fix-shebang
"
###
###!/data/data/com.termux/files/usr/bin/sh
###PREFIX=/data/data/com.termux/files/usr

if [ $# = 0 -o "$1" = "-h" ]; then
        echo 'usage: termux-fix-shebang <files>'
        echo 'Rewrite shebangs in specified files for running under Termux,'
        echo 'which is done by rewriting #!*/bin/binary to #!$PREFIX/bin/binary.'
        exit 1
fi

for file in $@; do
        # Do realpath to avoid breaking symlinks (modify original file):
        sed -i -E "1 s@^#\!(.*)/bin/(.*)@#\!/data/data/com.termux/files/usr/bin/\2@" $@
done
"

chmod 755 ~/bin/termux-fix-shebang

# apply fix
xargs -0 -n 1 termux-fix-shebang < <(tr \\n \\0 < ../lines.txt)
