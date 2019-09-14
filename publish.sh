#

set -e

domain=shqb.ml
find . -name "*.org" -type f -delete
bundle exec jekyll build
echo .
qm=$(ipfs add -Q -r _site --cid-version=0 --cid-base=base58btc)
bafy=$(ipfs cid base32 $qm)
echo url: http://$bafy.ipfs.dweb.link/
echo url: https://$bafy.cf-ipfs.com/
if ipfs files stat /root/www/web/$domain 1>/dev/null; then
ipfs files rm -r /root/www/web/$domain
fi
ipfs files cp /ipfs/$qm /root/www/web/$domain
webroot=$(ipfs files stat /root/www/web --hash)
wr58=$(echo $webroot | mbase -d | xyml b58)
www=$(ipfs files stat /root/www --hash)
echo url: https://cloudflate-ipfs.com/ipfs/$webroot/$domain

date=$(date +%D);
gitid=$(git rev-parse --short HEAD)
eval $($HOME/bin/name $qm | tee _data/name.yml | eyml)
echo "qm: $qm" >> _data/name.yml

eval $($HOME/bin/version _site/index.htm | eyml)
cat <<EOF > _data/ipfs.yml
--- # YAML data for $domain on IPFS
release: $scheduled
date: $date
user: $user
parent: $gitid
qm: $qm
bafy: $bafy
webroot: $webroot
wr58: $wr58
www: $www
pgw: https://gateway.ipfs.io
EOF
ver=$scheduled

bundle exec jekyll build 1>/dev/null # redo jekyll with ipfs files!
git add _data/ipfs.yml links.md
msg="publishing on $date $version"
git config user.name "$fullname"
git config user.email "$user@$domain"
if git commit -m "$ver: $msg"; then
gitid=$(git rev-parse HEAD)
git tag -f -a $ver -m "tagging $gitid on $date"
tic=$(date +%s)
cat <<EOT | ed _data/revs.log
/tic: /c
tic: $tic
.
/ver: /c
ver: $rel
.
/gitid: /c
gitid: $gitid
.
wq
EOT
echo $tic: $gitid >> _data/revs.log
time=$(date +%T)
date=$(date +%D);
cat <<EOF > _data/VERSION.yml
--- # (previous) site VERSION
date: $date
time: $time
version: $version
gitid: $gitid
rel: $ver
EOF
bundle exec jekyll build 1>/dev/null # redo jekyll w/ version files

# test if tag $ver exist ...
if git ls-remote --tags | grep "$ver"; then
git push --delete origin "$ver"
fi
fi
echo "git push : "
git push --follow-tags
echo .
echo url: https://github.com/michel47/$domain/releases/





