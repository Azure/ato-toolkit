echo "Installing scap-security-guide..."
yum -y install scap-security-guide

#Check if the script to apply stig exists
STIG_FILE=/usr/share/scap-security-guide/bash/$1
if [ ! -f "$STIG_FILE" ]; then
    echo "$STIG_FILE does not exist."
    exit 1
fi

echo "Modifying rhel7-script-stig.sh to exlude WALinuxAgent from updates..."
sed 's/yum -y update/yum -y update --exclude=WALinuxAgent/g' $STIG_FILE > script-stig-updated.sh
echo "Running script-stig-updated.sh to deploy STIGs..."
bash script-stig-updated.sh
echo "Deployment completed successfully."