---
layout: post
title:  "NIST SP800-185* Perl Module"
date:   2019-08-20 09:53:03 +0200
categories: perl code
keywords: perl module kmac sha3 code
---

In order to secure the documents in the blockring we use the SHAKE-224 sponge function.
and we wrote a few perl routines to computes the different hash values.

The perl module [KMAC.pm] implements the NIST SP800-185*
bytepad, left_encode, right_encode function.
for the message authentication code KMAC (MAC-SHA3)
using cSHAKE hash function (Secure  Hash  Algorithm  [KECCAK])

note:
  * for L < 160 I use KMAC128 and KMAC256 otherwise
  * cSHAKE is slightly different than NIST because of the 2 bits: 00
    in message for the [sponge] function.

     ```
     # KMAC128(K, X, L, S): Validity Conditions: len(K) < 2^2040 and 0 ≤ L < 2^2040 and len(S) < 2^2040
     # newX = bytepad(encode_string(K), 168) || X || right_encode(L).
     # return cSHAKE128(newX, L, “KMAC”, S).
     
     # KMAC256(K, X, L, S): Validity Conditions: len(K) < 2^2040 and 0 ≤ L < 2^2040 and len(S) < 2^2040
     # newX = bytepad(encode_string(K), 136) || X || right_encode(L).
     # return cSHAKE256(newX, L, “KMAC”, S).
     
     
     # example for using S (Customization String)
     # *  cSHAKE128(public_key, 256, "", "key fingerprint")
     # *  cSHAKE128(email_contents, 256, "", "email signature")
     ```

<!-- more -->
## Perl sub for KMAC:

```
sub KMAC {
  my ($K,$X,$L,$S) = @_;
  my $rate = ($L >= 160) ? 136 : 168;
  my $newX = &bytepad($K,$rate) . $X . &right_encode($L);
  printf qq(newX:%s\n),unpack'H*',$newX if $dbug;
  return &cSHAKE($newX,$L,"KMAC",$S);
}


sub cSHAKE {
  my ($X,$L,$N,$S) = @_;
  if ($N eq '' && $S eq '') {
    return &shake($L,$X); # L before X
  } else {
    # KECCAK[256/512](bytepad(encode_string(N) || encode_string(S), 168/136) || X ||  00, L).
    my $rate = ($L >= 160) ? 136 : 168;
    my $M = &bytepad($N.$S,$rate) . $X . "\x00"; # /!\ bug alert here != NIST document : "00" as 2 bits !!
    printf qq(M:%s\n),enc($M) if $dbug;
    my $kh = &shake($L,$M); # L before M
    return $kh;
  }
}
```

where shake is 
```
sub shake { # use shake 128 for L < 160
  # see also [*][sponge]
  use Crypt::Digest::SHAKE;
  my $len = shift;
  my $x = ($len >= 160) ? 256 : 128; # selection of the sponge !
  my $msg = Crypt::Digest::SHAKE->new($x);
  $msg->add(join'',@_);
  my $digest = $msg->done(($len+7)/8);
  return $digest;
}
```
again here we use the 160 threshold for choosing between KECCAK[256] and KECCAK[512]

[KMAC.pm]: https://cloudflare-ipfs.com/ipfs/QmWEZ1ZKbmcgxu2chr68opV6DDwmQFewoVjhLJcDuzGk1c
[KECCAK]: http://keccak.noekeon.org/Keccak-reference-3.0.pdf
[sponge]: http://sponge.noekeon.org/CSF-0.1.pdf


#### other miscellaneous functions
```
sub bytepad {
  my ($X,$w) = @_;
  my $z = &left_encode($w) . $X;
  while (length($z)/8 % $w != 0) {
    $z = $z . "\x00"
  }
  return $z;
}
```

```
sub left_encode { # for now limited to 32bit... (int32)
   my $i = shift;
   my $x = &encode_base256($i);
   my $n = length($x);
   my $s = pack('C',$n) . $x;
   return $s;

}
```

```
sub right_encode { # for now limited to 32bit... (int32)
   my $i = shift;
   my $x = &encode_base256($i);
   my $n = length($x);
   my $s = $x.pack('C',$n);
   return $s;
}
```

```
sub encode_base256 { # limited to integer for now, will need to extend to bigint later
 use integer;
  my ($n) = @_;
  my $e = '';
  return("\x00") if $n == 0;
  while ( $n ) {
    my $c = $n % 256;
    $e .=  pack'C',$c;
    $n = int $n / 256;
  }
  return scalar reverse $e;
}
```

