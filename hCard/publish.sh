#

set -e

if uname -r | grep -q Microsoft; then
  rootfs='C:\Users\mcomb\AppData\Local\Packages\CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc\LocalState\rootfs'
  dist=${rootfs}/home/michelc/repo/shqb.ml/_site/hCard
  echo $dist
  option=''
else
  dist=../_site/hCard
  option=" --cid-base=base58btc"
fi
#exit
echo "--- # publishing hCard"
cat vCard.vcf | qrencode -l L -s 5 -o QRcard.png;
qm=$(ipfs add -Q --hash sha1 -r $dist $option)
chart=https://chart.googleapis.com/chart?cht=qr&choe=UTF-8&chld=H&chs=210&chl=
echo " - $qm" >> qm.yml
echo qm: $qm
echo url: ${chart}http://0.0.0.0:8080/ipfs/$qm
cat <<EOT | ed hCard.htm
/qm:/c
qm: $qm
.
wq
EOT
cat <<EOT | ed QRcode.md
/qm:/c
qm: $qm
.
wq
EOT
qm=$(ipfs add -Q --hash sha1 -r $dist $option)
ipfs files rm -r /my/profile/hcard
ipfs files cp /ipfs/$qm /my/profile/hcard
ipfs name publish --key=hCard /ipfs/$qm

