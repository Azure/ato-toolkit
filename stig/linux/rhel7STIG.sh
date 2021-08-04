set -e

# only run once during deployment
if [ -f ./azAutomationComplete ]; then
    echo "STIG Automation completed, exiting..."
    exit 0
fi

# https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/redhat/redhat-rhui
id=$(. /etc/os-release && echo $ID)
if [ ${id} == 'rhel' ]; then
    echo "Executing yum update to disable all repos and enable all microsoft repos..."
    yum update -y --disablerepo='*' --enablerepo='*microsoft*' > ./yumupdateresults.log
fi

# dsc deployment automation
echo "Move (OS Specific) .mof to configuration store as Pending.mof..."
mv ./*.mof /etc/opt/omi/conf/dsc/configuration/Pending.mof
echo "Execute Register.py --RefreshMode Push --ConfigurationMode ApplyOnly..."
/opt/microsoft/dsc/Scripts/Register.py --RefreshMode Push --ConfigurationMode ApplyOnly > ./dscresults.log
echo "Execute PerformRequiredConfigurationChecks.py to apply the Pending.mof configuration..."
/opt/microsoft/dsc/Scripts/PerformRequiredConfigurationChecks.py >> ./dscresults.log
if grep -q "MI_RESULT_FAILED" ./dscresults.log; then
    echo "Failed to apply Desired State Configuration successfully, check dscresults.log for more details..."
    exit 1
else
    echo "Applied Desired State Configuration successfully..."
fi

# authentication/password/session automation
echo "Backing up password-auth, postlogin and system-auth files..."
cp --force /etc/pam.d/system-auth /etc/pam.d/backup.system-auth
cp --force /etc/pam.d/password-auth /etc/pam.d/backup.password-auth
cp --force /etc/pam.d/postlogin /etc/pam.d/backup.postlogin
echo "Removing 'nullok' from password-auth and system-auth files..."
sed -i 's/nullok //g' /etc/pam.d/system-auth /etc/pam.d/password-auth
echo "Updating auth pam_faillock.so module in password-auth and system-auth files..."
authRequiredFailDelay='auth        required      pam_faildelay.so delay=2000000'
authRequiredFaillock='auth        required      pam_faillock.so preauth silent audit deny=3 even_deny_root fail_interval=900 unlock_time=900'
authDefaultFaillock='auth        [default=die] pam_faillock.so authfail audit deny=3 even_deny_root fail_interval=900 unlock_time=900'
sed -i "s/\(auth.*sufficient.*pam_fprintd.so\)/${authRequiredFailDelay}/g" /etc/pam.d/system-auth
sed -i "s/\(auth.*delay.*2000000\)/\1\n${authRequiredFaillock}/g" /etc/pam.d/password-auth /etc/pam.d/system-auth
sed -i "s/\(auth.*pam_unix.so.*\)/\1\n${authDefaultFaillock}/g" /etc/pam.d/password-auth /etc/pam.d/system-auth
echo "Updating account pam_faillock.so module in password-auth and system-auth files..."
acctReqPamFaillock='account     required      pam_faillock.so'
sed -i "s/\(account.*pam_unix\.so\)/${acctReqPamFaillock}\n\1/g" /etc/pam.d/password-auth /etc/pam.d/system-auth
echo "Updating password pam_pwhistory.so module in password-auth and system-auth files..."
passReqPamPwHistory='password    requisite     pam_pwhistory.so use_authtok remember=5 retry=3'
sed -i "s/\(password.*requisite.*pam_pwquality\.so.*\)/\1\n${passReqPamPwHistory}/g" /etc/pam.d/password-auth /etc/pam.d/system-auth
echo "Updating session pam_lastlog.so module in /etc/pam.d/postlogin"
sessReqPamLastlog='session     required      pam_lastlog.so showfailed'
sed -i "s/\(session.*quiet\)/${sessReqPamLastlog}\n\1/g" /etc/pam.d/postlogin
echo "Removing 'NOPASSWD' tag from all files in /etc/sudoers.d/* /etc/sudoers"
grep -r -l -i nopasswd /etc/sudoers.d/* /etc/sudoers | xargs sed -i 's/\s*NOPASSWD://g'
echo "Setting minimum number of days before password change for user specified admin account to 1"
chage -m 1 $1
echo "Setting maximum number of days before password change for user specified admin account to 60"
chage -M 60 $1

# file system automation
echo "Setting /home mount to use nosuid in /etc/fstab..."
sed -i "s/\(.*\/home.*defaults\)/\1,nosuid/g" /etc/fstab
echo "Setting tmpfs /dev/shm to mount using nodev, nosuid and noexec in /etc/fstab"
echo 'tmpfs /dev/shm tmpfs defaults,nodev,nosuid,noexec 0 0' >> /etc/fstab

# fips automation
if rpm -q --quiet "dracut-fips"; then
    echo "Recreating initramfs with dracut to support FIPS..."
    dracut --force --verbose 2> ./fipsresults.log
    echo "Modifying grub to support FIPS..."
    BOOT_UUID=$(findmnt --noheadings --output uuid --target /boot)
    sed -i "s/\(GRUB_CMDLINE_LINUX=\".*[^\"]\+\)/\1 fips=1 boot=UUID=${BOOT_UUID}/g" /etc/default/grub
    if [ -f /boot/grub2/grub.cfg ]; then
        echo "Regenerating /boot/grub2/grub.cfg (BIOS)..."
        grub2-mkconfig -o /boot/grub2/grub.cfg 2>> ./fipsresults.log
    fi
    if [ -f /boot/efi/EFI/centos/grub.cfg ]; then
        echo "Regenerating /boot/efi/EFI/centos/grub.cfg (UEFI)..."
        grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg 2>> ./fipsresults.log
    elif [ -f /boot/efi/EFI/redhat/grub.cfg ]; then
        echo "Regenerating /boot/efi/EFI/redhat/grub.cfg (UEFI)..."
        grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg 2>> ./fipsresults.log
    else
        echo "Skipping grub2-mkconfig for UEFI, no EFI grub.cfg file found..."
    fi
else
    echo "Skipping fips automation due to dracut-fips package installation absence..."
fi

# aide configuration automation
if rpm -q --quiet "aide"; then
    echo "Modifying /etc/aide.conf to use sha512..."
    sed -i 's/CONTENT_EX = sha256/CONTENT_EX = sha512/g' /etc/aide.conf
    echo "Executing /usr/sbin/aide --init..."
    /usr/sbin/aide --init > aideresults.log
    echo "Moving /var/lib/aide/aide.db.new.gz to /var/lib/aide/aide.db.gz..."
    mv --verbose --force /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
    echo "Adding aide daily check cron job..."
    echo '0 5 * * * root /usr/sbin/aide --check | /bin/mail -s "$(hostname) - AIDE Integrity Check" root@localhost' > /etc/cron.daily/aide
else
    echo "Skipping aide automation due to aide package installation absence..."
fi

# system reboot
echo "Rebooting to apply STIG settings..."
touch ./azAutomationComplete
shutdown -r +1 2>&1
