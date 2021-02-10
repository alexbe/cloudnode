#!/bin/bash

CD=$(cd `dirname $0` && pwd)
CFGDIR=$CD/local
INSTDIR=`realpath ${1:-~/salt-ssh}`

install2()
{

[ -d "${INSTDIR}" || mkdir "${INSTDIR}"
[ -f "${INSTDIR}/Saltfile" ] && [ -z "$(grep '^${INSTDIR}' $CFGDIR/installs)" ] \
  && echo "Found unknown installation '${INSTDIR}'" && exit 1

cat <<THECONTENT > ${CFGDIR}/excl.list
roster
Saltfile
master
pillar/
cloud.profiles.d/
cloud.providers.d/
pki/
nodemap
THECONTENT

echo ${INSTDIR} >> ${CFGDIR}/installs

}



if [ -d "$CFGDIR" -a -f "${CFGDIR}/excl.list" ]; then
 while read IPATH
 do
  [ -d "$IPATH" ] && rsync -av --exclude-from="${CFGDIR}/excl.list" $CD/ $IPATH/
 done < ${CFGDIR}/excl.list
else
 install2
fi
