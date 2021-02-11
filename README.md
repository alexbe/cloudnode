# cloudnode
Deploy & control TON nodes infrastructure with SaltStack

Install
-----------------------

git clone https://github.com/alexbe/cloudnode.git

cd cloudnode/

./sync.sh

cd ~/salt-ssh

Edit cloud.providers.d/* files
and probably cloud.profiles.d/* 
according to your cloud account settings

Cloud provisioning 
-----------------------

salt-cloud -m nodemap -P

or

salt-cloud -p ec2_east1 mnode1

salt-cloud -p gce-f1 rnode1


Connect with salt-ssh
-----------------------

Check ip addresses with:

salt-cloud -Q

Edit roster, then connect and setup ssh keys

salt-ssh -i '*' grains.items
