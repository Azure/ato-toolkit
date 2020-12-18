echo "Installing scap-security-guide..."
yum -y install scap-security-guide
echo "Modifying rhel7-script-stig.sh to exlude WALinuxAgent from updates..."
sed 's/yum -y update/yum -y update --exclude=WALinuxAgent/g' /usr/share/scap-security-guide/bash/rhel7-script-stig.sh > rhel7-script-stig-updated.sh
echo "Running hel7-script-stig-updated.sh to deploy STIGs..."
bash rhel7-script-stig-updated.sh
echo "Deployment completed successfully."