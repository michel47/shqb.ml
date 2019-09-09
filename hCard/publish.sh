#

echo "--- # publishing hCard"
dist=../_site/hCard
cat vCard.vcf | qrencode -l L -s 5 -o QRcard.png;
qm=$(ipfs add -Q --hash sha1 -r $dist --cid-base=base58btc)
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
cat <<EOT | ed QRcode.htm
/qm:/c
qm: $qm
.
wq
EOT
qm=$(ipfs add -Q --hash sha1 -r $dist --cid-base=base58btc)
ipfs name publish --key=hcard /ipfs/$qm

