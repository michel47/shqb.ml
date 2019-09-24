#

export LC_TIME=en_US.UTF-8
if ! vim --serverlist | grep -q -w POST; then
vim -g --servername POST &
sleep 1
else 
vim -g --servername POST --remote-sent ":remote_foreground()"
fi

set -e
statef='../_data/article.yml'
n=0
eval $(cat $statef 2>/dev/null | eyml )
stamp=$(date +%Y-%m-%d)
echo stamp: $stamp
file="${stamp}-post-$n.md"
echo "file: $file"
date=$(date +"%c")
if [ ! -e $file ]; then
cat <<EOF > $file
---
title: "Article $n ($stamp)"
layout: post
stamp: $stamp
date: 2019-09-24 18:04:23 CEST
created: $date
updated: $date
inode: 2019-09-24 17:51:16.546610500 +0200
access: 2019-09-24 18:03:35.339925900 +0200
description: "This is a description of article $n"
---
body here ...
QmWHT7rY4dGjofJ6XtGHLHEPtGeuVg94v8iUL7WAuZpbkj

EOF
n=$(expr $n + 1);
sed -i "s/^n: .*/n: $n/" $statef
fi
vim --servername POST --remote-wait-tab-silent "$file"
