---
layout: post
title:  "Generate your one time passwords with the command-line"
date:   2017-11-07 13:45:00 +0100
---

Multi-factor authentication has become a good practice to add a security layer
for online accounts, and is so popular that many companies are enforcing it for
their employee accounts.

Mobile applications like Google Authenticator have become popular. The problems
with some of these applications is that they store secrets in plain, without
adding encryption (for example Google Authenticator is storing the secrets as
entries in the application sqlite database).

Personally I started using [andOTP](https://github.com/flocke/andOTP), an open
source Android application to generate one time passwords. The benefit of using
this is that encrypts the secret keys used to generate the codes.

But passing most of the time working on a laptop, I decided to find a solution
for getting the codes without actually have to use my mobile device.

The solution consists in the following steps:

1) export the codes from andOTP as a plain json file, that will look like this:

```json
[
  {
    "secret": "secret_key_1",
    "label": "My secret account 1",
    "period": 30,
    "digits": 6,
    "type": "TOTP",
    "algorithm": "SHA1"
  },
  {
    "secret": "secret_key_2",
    "label": "My secret account 2",
    "period": 30,
    "digits": 6,
    "type": "TOTP",
    "algorithm": "SHA1"
  }
]
```

2) copy the json file to your machine

3) encrypt the json file with a passphrase using [GnuPG](gnupg.org):

```
$ gpg -c otp.json
```

4) create a pipe to extract the codes from the files and copy into the clipboard:

```
# generate the code for the 2nd account in the JSON file
gpg --decrypt otp.json.gpg | jq -r '.[1].secret' | xargs oathtool --totp -b | cin
```

The `gpg` command is used to decrypt the json file,
[jq](https://stedolan.github.io/jq/) is used to extract the secret (`-r` is for
formatting the output in the proper way) from the json text, `oathtool` (from
[oath-toolkit](https://gitlab.com/oath-toolkit/oath-toolkit)) is used to
generate the code, and `cin` is an alias to something that can read from
standard input and write on the clipboard (for e.g. `xclip` for Xorg or
`pbcopy` for OS X). The tools can be easily installed using a package manager.

After running the above command you can paste the code into the browser and enjoy your login!

Edit: I've forgotten to mention that is approach can be personalized to your
needs, for example by using a different format for the input file or a
different tool to extract encrypt/decrypt the data. The only important thing is
that the `oathtool` command needs the secret key as argument in order to
generate the correct one time password.
