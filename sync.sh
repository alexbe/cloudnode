#!/bin/bash

rsync --version 2>&1 1>/dev/null || { 
	echo "rsync is not found, install it properly please" && exit 1 
}

CD=$(cd `dirname $0` && pwd)
CFGDIR=$CD/local
INSTDIR=`realpath ${1:-~/salt-ssh}`

pubkey_subst()
{
 [ -f "${1}" ] && sed -E 's/^([a-z-]+)\s([^ ]+)\s.+$/\1 \2/' ${1}.pub
}




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
sync.sh
roster
Saltfile
master
pillar/default.sls
cloud
cloud.profiles.d/
cloud.providers.d/
pki/
nodemap
THECONTENT

SSHKEY=$(ls -1 $HOME/.ssh/id_{rsa,ed25519} 2>/dev/null|tail -n1)
VMUSER=$USER

cat <<THECONTENT > ${INSTDIR}/cloud.profiles.d/gce.conf

gce-f1:
  #image: ubuntu-minimal-2004-focal-v20210119a 
  image: debian-10-buster-v20210122
  size: f1-micro
  #South Carolina
  location: us-east1-b
  network: default
  subnetwork: default
  tags: '["salt-created", "free-tier", "us-east1-b"]'
  metadata: '{"size": "f1-micro",
   "sshKeys": "$VMUSER:$(sed -E 's/^([a-z-]+)\s([^ ]+)\s.+$/\1 \2/' ${SSHKEY}.pub) $VMUSER@somewhere"}'
  use_persistent_disk: True
  delete_boot_pd: False
  deploy: True
  make_master: False
  provider: gce   
  ssh_username: $VMUSER
  ssh_keyfile: ${SSHKEY}

gce-2vCPU4G:
  #image: ubuntu-minimal-2004-focal-v20210119a 
  image: debian-10-buster-v20210122
  size: e2-medium
  #South Carolina
  location: us-east1-b
  network: default
  subnetwork: default
  tags: '["salt-created", "free-tier", "us-east1-b"]'
  metadata: '{"size": "e2-medium", "sshKeys": "$VMUSER:$(sed -E 's/^([a-z-]+)\s([^ ]+)\s.+$/\1 \2/' ${SSHKEY}.pub) $VMUSER@somewhere"}'
  use_persistent_disk: True
  delete_boot_pd: False
  deploy: True
  make_master: False
  provider: gce    
  ssh_username: $VMUSER
  ssh_keyfile: ${SSHKEY}
  
THECONTENT



for D in profiles providers
do
 sed -i "s/\/home\/yourname/${HOME//\//\\/}/" ${INSTDIR}/cloud.${D}.d/*.conf
done
for F in Saltfile master cloud
do
 sed -i "s/\/home\/yourname/${HOME//\//\\/}/" ${INSTDIR}/$F
done


#sed -En '/./{H;$!d;};x;/ssh_keyfile:/!d;{s|yourname:ssh-rsa[^"]+|'"$(sed -E 's/^([a-z-]+)\s([^ ]+)\s.+$/\1 \2/' $HOME/.ssh/id_rsa.pub)"'|;p}' cloud.profiles.d/gce.conf

[ -z "$(grep ^${INSTDIR} $CFGDIR/installs 2>/dev/null)" ] && echo ${INSTDIR} >> ${CFGDIR}/installs
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
