# set up variables needed
workingFolder="/var/tmp/zta-files"
archive="offline-zta.tar.gz"
offlineRepoName="offline-zta-repo"
stigFile="rhel7.sh"

# create the working folder
echo "..creating the working folder: $workingFolder"
mkdir $workingFolder

# uncompress the archive
echo "..uncompressing archive to: $workingFolder"
tar -xzvf "$archive" -C "$workingFolder"

# create an entry for the repo
echo "..creating repo file: /etc/yum.repos.d/$offlineRepoName.repo"
cat > /etc/yum.repos.d/$offlineRepoName.repo<< EOF
[offline-zta-repo]
name=$offlineRepoName
baseurl=file:///$workingFolder/$offlineRepoName
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF

# run the stig script
echo "..executing stig script: $stigFile"
bash "$stigFile"

# remove the repo file and working folder
echo "..stig script done. Time for cleanup"
echo "..removing repo file: /etc/yum.repos.d/$offlineRepoName.repo"
rm -f /etc/yum.repos.d/$offlineRepoName.repo
echo "..removing working folder: $workingFolder"
rm -r $workingFolder

