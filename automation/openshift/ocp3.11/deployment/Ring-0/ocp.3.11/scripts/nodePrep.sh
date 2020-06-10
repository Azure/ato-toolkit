echo $(date) " - Starting Infra / Node Prep Script"

export USERNAME_ORG=${USERNAME_ORG}
export PASSWORD_ACT_KEY=${PASSWORD_ACT_KEY}
export POOL_ID=${POOL_ID}
export REPOSERVER=${REPOSERVER}
export REGISTRYSERVER=${REGISTRYSERVER}
export PRIVATEIP=${PRIVATEIP}
export ROUTERIP=${ROUTERIP}
export PRIVATEDNS=${PRIVATEDNS}
export INFRADNS=${INFRADNS}
export DEPLOYMENTTYPE=${DEPLOYMENTTYPE}

# Remove RHUI

rm -f /etc/yum.repos.d/*.repo
sleep 10

if [[ ${DEPLOYMENTTYPE} == 3 ]]
then
    # connected
    # Register Host with Cloud Access Subscription
    echo $(date) " - Register host with Cloud Access Subscription"

    subscription-manager register --force --username="${USERNAME_ORG}" --password="${PASSWORD_ACT_KEY}" || subscription-manager register --force --activationkey="${PASSWORD_ACT_KEY}" --org="${USERNAME_ORG}"
    RETCODE=$?

    if [ $RETCODE -eq 0 ]
    then
        echo "Subscribed successfully"
    elif [ $RETCODE -eq 64 ]
    then
        echo "This system is already registered."
    else
        sleep 5
        subscription-manager register --force --username="${USERNAME_ORG}" --password="${PASSWORD_ACT_KEY}" || subscription-manager register --force --activationkey="${PASSWORD_ACT_KEY}" --org="${USERNAME_ORG}"
        RETCODE2=$?
        if [ $RETCODE2 -eq 0 ]
        then
            echo "Subscribed successfully"
        elif [ $RETCODE2 -eq 64 ]
        then
            echo "This system is already registered."
        else
            echo "Incorrect Username / Password or Organization ID / Activation Key specified. Unregistering system from RHSM"
            subscription-manager unregister
            exit 3
        fi
    fi

    subscription-manager attach --pool=${POOL_ID} > attach.log
    if [ $? -eq 0 ]
    then
        echo "Pool attached successfully"
    else
        grep attached attach.log
        if [ $? -eq 0 ]
        then
            echo "Pool ${POOL_ID} was already attached and was not attached again."
        else
            echo "Incorrect Pool ID or no entitlements available"
            exit 4
        fi
    fi

    # Disable all repositories and enable only the required ones
    echo $(date) " - Disabling all repositories and enabling only the required repos"

    subscription-manager repos --disable="*"

    subscription-manager repos \
        --enable="rhel-7-server-rpms" \
        --enable="rhel-7-server-extras-rpms" \
        --enable="rhel-7-server-ose-3.11-rpms" \
        --enable="rhel-7-server-ansible-2.6-rpms" \
        --enable="rhel-7-fast-datapath-rpms" \
        --enable="rh-gluster-3-client-for-rhel-7-server-rpms" \
        --enable="rhel-7-server-optional-rpms"
else

cat > /etc/yum.repos.d/ose.repo <<EOF
[rhel-7-repo]
name=rhel-7-repo
baseurl=http://${REPOSERVER}/repos
enabled=1
gpgcheck=0
EOF

fi

# Install base packages and update system to latest packages
echo $(date) " - Install base packages and update system to latest packages"

yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct ansible
yum -y install cloud-utils-growpart.noarch
yum -y update glusterfs-fuse
yum -y update --exclude=WALinuxAgent
echo $(date) " - Base package insallation and updates complete"

# Grow Root File System
echo $(date) " - Grow Root FS"

rootdev=`findmnt --target / -o SOURCE -n`
rootdrivename=`lsblk -no pkname $rootdev`
rootdrive="/dev/"$rootdrivename
name=`lsblk  $rootdev -o NAME | tail -1`
part_number=${name#*${rootdrivename}}

growpart $rootdrive $part_number -u on
xfs_growfs $rootdev

if [ $? -eq 0 ]
then
    echo "Root partition expanded"
else
    echo "Root partition failed to expand"
    exit 6
fi

# Install Docker
echo $(date) " - Installing Docker"
yum -y install docker

# Update docker config for insecure registry
rm -f /etc/docker/daemon.json
cat > /etc/docker/daemon.json <<EOF 
{
  "insecure-registries" : ["${REGISTRYSERVER}","docker-registry-default.${INFRADNS}"]
}
EOF

# Create thin pool logical volume for Docker
echo $(date) " - Creating thin pool logical volume for Docker and staring service"

DOCKERVG=$( parted -m /dev/sda print all 2>/dev/null | grep unknown | grep /dev/sd | cut -d':' -f1 | head -n1 )

echo "
# Adding OpenShift data disk for docker
DEVS=${DOCKERVG}
VG=docker-vg
" >> /etc/sysconfig/docker-storage-setup

# Running setup for docker storage
docker-storage-setup
if [ $? -eq 0 ]
then
    echo "Docker thin pool logical volume created successfully"
else
    echo "Error creating logical volume for Docker"
    exit 5
fi

# Enable and start Docker services
sysctl -w vm.max_map_count=262144

systemctl enable docker
systemctl start docker

# Add DNS host entries for cluster naming
cat >> /etc/hosts <<EOF
${PRIVATEIP} ${PRIVATEDNS}
${ROUTERIP} ${INFRADNS}
EOF

echo $(date) " - Script Complete"

