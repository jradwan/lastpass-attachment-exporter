# LastPass Attachment Exporter

Exports all attachments from LastPass vault items. 

Make sure you run this from a secure location (for example, an encrypted hard drive) as all of your exported attachments will be decrypted and hence, "clear text" readable.

## Pre-requisites

* [lastpass-cli](https://github.com/lastpass/lastpass-cli) (be sure you are already logged in, see Usage below)
* bash
* sed
* awk
* grep
* tr

## Usage

1) log into your LastPass vault via `lpass login <account>`
2) run ./lpass-att-export.sh -x
3) check the `lpass-export` subdirectory for your attachments
4) log out of your vault (`lpass logout`)

To just get a list of your attachments and their locations, leave off the `-x` parameter. Use `-v` for verbose logging mode.

## Known Issues

Both of these items are from the lastpass-cli and not this exporter script:

* Attachments with spaces in their filename are exported with an incomplete name (ends at first space)
* "Corrupted" (un-decryptable) attachments may return a "Error: Unable to decrypt attachment `<id>-<attid>`" message.
  * Use `lpass show <id>` to list which vault item contains the corrupted attachment. 
