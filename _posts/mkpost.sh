#

set -e

n=0
eval $(cat ../data/article.yml 2>/dev/null | eyml )
stamp=$(date +%Y-%m-%d)
echo stamp: $stamp
#QmWHT7rY4dGjofJ6XtGHLHEPtGeuVg94v8iUL7WAuZpbkj
