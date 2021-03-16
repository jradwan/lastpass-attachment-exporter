#!/bin/bash

USAGE="usage: $0 [-v] (verbose mode) [-x] (export attachments)]"
VERBOSE_MODE=false
EXPORT_MODE=false
itemcount=0
expcount=0

# show usage/help
if [ $# -eq  1 ] && ( [ $1 == "-h" ] || [ $1 == "-?" ] || [ $1 == '--help' ] ) ; then
    echo $USAGE
    exit 1;
fi

# parse options
while getopts "vx" optname
  do
    case "$optname" in
      "v")
        VERBOSE_MODE=true
        ;;
      "x")
        EXPORT_MODE=true
        ;;
      "?")
        echo "unknown option"
        exit 1;
        ;;
      *)
        echo "unknown error while processing options"
        exit 1;
        ;;
    esac
  done

echo -en "\nLastPass attachment "
if $EXPORT_MODE ; then
    echo -n "export"
else
    echo -n "list"
fi

if $VERBOSE_MODE ; then
    echo -e " (verbose mode)\n"
else
    echo -e "\n"
fi

# create directory to hold exported attachments
if $EXPORT_MODE ; then
    mkdir -p lpass-export
    cd lpass-export
fi

# loop through vault items
for id in `lpass ls | sed -n "s/^.*id:\s*\([0-9]*\).*$/\1/p"`; do

  # keep count of items parsed
  ((itemcount++))

  path=`lpass show ${id} 2> /dev/null | sed "1q;d" | awk '{$NF=""; print $0}' | awk '{$NF=""; print $0}' | awk '{$1=$1};1'`
  # if the current item is valid (non-null value returned by above line), then proceed. this prevents a
  # second error from attcount line below
  if [ ! -z "$path"  ] ; then
    if $VERBOSE_MODE ; then
        echo "Checking: "${id} "-" $path
    fi
    attcount=`lpass show ${id} 2> /dev/null | grep att- | wc -l`

    # loop through attachments (if any)
    until [ ${attcount} -lt 1 ]; do
      att=`lpass show ${id} | grep att- | sed "${attcount}q;d" | tr -d :`
      attid=`echo ${att} | awk '{print $1}'`
      attname=`echo ${att} | sed 's/[^ ]* *//'`

      if [[ -z  ${attname}  ]]; then
        attname=${path#*/}
      fi

      path=${path//\\//}
      if $EXPORT_MODE ; then
          mkdir -p "${path}"
      fi
      out=${path}/${attname}

      if [[ -f ${out} ]]; then
          out=${path}/${attcount}_${attname}
      fi

      if $VERBOSE_MODE ; then
          echo -e "\nexporting attachment:" ${id} "-" ${path} ":" ${attid} "-" ${attname} ">" ${out} "\n"
      else
          echo ${out}
      fi

      # export the attachment
      if $EXPORT_MODE ; then
          lpass show --attach=${attid} ${id} --quiet > "${out}"
      fi

      # keep count of attachments found
      ((expcount++))

      let attcount-=1

    done # attachment loop

  fi # valid item/path

done # loop through vault items

# display final stats
echo -en "\n" $itemcount
echo -n " items searched, "
echo -n $expcount
echo -n " attachments "
if $EXPORT_MODE ; then
    echo -e "exported.\n"
else
    echo -e "listed.\n"
fi

