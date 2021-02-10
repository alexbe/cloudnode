#!/bin/bash

CD=$(cd `dirname $0` && pwd)
CFGDIR=$CD/local
INSTDIR=`realpath ${1:-~/salt-ssh}`

install2()
{
[ -d "$CFGDIR" ] || ( mkdir "$CFGDIR" && echo "Cfg diectory created" )
[ -d "${INSTDIR}" ] || ( mkdir "${INSTDIR}" && echo "Directory '${INSTDIR}' created" )
[ -f "${INSTDIR}/Saltfile" -a -z "$(grep ^${INSTDIR} $CFGDIR/installs)" ] \
  && echo "Found unknown installation '${INSTDIR}'" && exit 1

cat <<THECONTENT > ${CFGDIR}/excl.list && rsync -av --exclude=.git/ --exclude=.gitignore  ${CD}/ ${INSTDIR}/
.git/
.gitignore
local/
roster
Saltfile
master
pillar/
cloud.profiles.d/
cloud.providers.d/
pki/
nodemap
THECONTENT
[ -z "$(grep ^${INSTDIR} $CFGDIR/installs)" ] && echo ${INSTDIR} >> ${CFGDIR}/installs
}


if [ -d "$CFGDIR" -a -d "${INSTDIR}" -a -n "$(grep ^${INSTDIR} $CFGDIR/installs)" ]; then
 while read IPATH
 do
  [ -d "$IPATH" ] && rsync -av --exclude-from="${CFGDIR}/excl.list" $CD/ $IPATH/
 done < ${CFGDIR}/installs
 echo "...syncronized"\!
else
 echo "Perform new install"
 install2
fi
