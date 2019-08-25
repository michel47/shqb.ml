#

find . -name "*.org" -type f -delete
jekyll build
qm=$(ipfs add -Q -r _site --cidbase=base58btc)
ww32=$(ipfs cid base32 $qm)
echo http://$ww32.cf-ipfs.com/
