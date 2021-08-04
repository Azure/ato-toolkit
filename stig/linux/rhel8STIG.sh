# only run once during deployment
if [ -f ./azAutomationComplete ]; then
    echo "STIG Automation completed, exiting..."
    exit 0
fi

###############################################################################
echo "Setting script variables"
###############################################################################
version=$(. /etc/os-release && echo $VERSION_ID)

###############################################################################
echo "Automating Rule Id V-230233"
###############################################################################
sed -i "s/\(password\s*sufficient.*\)/\1 rounds=5000/g" /etc/pam.d/password-auth /etc/pam.d/system-auth
# END V-230233

###############################################################################
echo "Automating Rule Id V-230234"
# SCAP fails if /boot/efi/EFI/redhat/grub.cfg exists on Gen 1 Azure VM
###############################################################################
firmwarecheck=$([ -d /sys/firmware/efi ] && echo UEFI || echo BIOS)
if [ $firmwarecheck = 'BIOS' ]; then
    mv /boot/efi/EFI/redhat/grub.cfg /boot/efi/EFI/redhat/grub.bak
fi
# END V-230234

###############################################################################
echo "Automating Rule Id V-230253"
###############################################################################
sed -i "s/^SSH_USE_STRONG_RNG=.*/SSH_USE_STRONG_RNG=32/g" /etc/sysconfig/sshd
# END V-230253

###############################################################################
echo "Automating Rule Id V-230257"
###############################################################################
find -L /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin -perm /0022 -type f -exec chmod 0755 {} \;
# END V-230257

###############################################################################
echo "Automating Rule Id V-230271"
###############################################################################
grep -r -l -i nopasswd /etc/sudoers.d/* /etc/sudoers | xargs sed -i 's/\s*NOPASSWD://g' 2>&1
# END V-230271

###############################################################################
echo "Automating Rule Id V-230301"
###############################################################################
sed -i "s/\(.*[[:space:]]\/[[:alpha:]].*defaults\)/\1,nodev/g" /etc/fstab
# END V-230301

###############################################################################
echo "Automating Rule Id V-230311"
###############################################################################
rm -f /usr/lib/sysctl.d/50-coredump.conf
echo "kernel.core_pattern = |/bin/false" > /etc/sysctl.d/90-azurestig-v230311.conf
# END V-230311

###############################################################################
echo "Automating Rule Ids V-230332, V-230334, V-230336, V-230338, V-230340, V-230342, V-230344"
###############################################################################
if [ ${version} == '8.0' ] || [ ${version} == '8.1' ]; then
    authRequired='auth        required'
    acctRequired='account     required'
    spacing='                                     '
    authFaillockPreAuth='pam_faillock.so preauth dir=\/var\/log\/faillock silent audit deny=3 even_deny_root fail_interval=900 unlock_time=0'
    authFaillockAuthFail='pam_faillock.so authfail dir=\/var\/log\/faillock unlock_time=0'
    sed -i "s/\(auth.*pam_unix.so.*\)/${authRequired}${spacing}${authFaillockPreAuth}\n\1/g" /etc/pam.d/password-auth /etc/pam.d/system-auth
    sed -i "s/\(auth.*pam_unix.so.*\)/\1\n${authRequired}${spacing}${authFaillockAuthFail}/g" /etc/pam.d/password-auth /etc/pam.d/system-auth
    sed -i "s/\(account.*pam_unix.so\)/${acctRequired}${spacing}pam_faillock.so\n\1/g" /etc/pam.d/password-auth /etc/pam.d/system-auth
else
    echo "  Automation intended for 8.0 and 8.1; '$version' detected, skipping..."
fi
# END V-230332, V-230334, V-230336, V-230338, V-230340, V-230342, V-230344

###############################################################################
echo "Automating Rule Id V-230333"
###############################################################################
if [ ${version} == '8.0' ] || [ ${version} == '8.1' ]; then
    echo "  Automation intended for 8.2 and newer, '$version' detected, skipping..."
else
    authRequiredFaillock='auth        required      pam_faillock.so'
    acctRequiredFaillock='account     required      pam_faillock.so'
    sed -i "s/\(auth.*required.*pam_env.so\)/\1\n${authRequiredFaillock} preauth/g" /etc/pam.d/password-auth /etc/pam.d/system-auth
    sed -i "s/\(auth.*required.*pam_deny.so\)/${authRequiredFaillock} authfail\n\1/g" /etc/pam.d/password-auth /etc/pam.d/system-auth
    sed -i "s/\(account.*required.*pam_unix.so\)/${acctRequiredFaillock}\n\1/g" /etc/pam.d/password-auth /etc/pam.d/system-auth
    sed -i "s/.*deny\s*=.*/deny = 3/g" /etc/security/faillock.conf
fi
# END V-230333

###############################################################################
echo "Automating Rule Id V-230335"
###############################################################################
if [ ${version} == '8.0' ] || [ ${version} == '8.1' ]; then
    echo "  Automation intended for 8.2 and newer, '$version' detected, skipping..."
else
    sed -i "s/.*fail_interval\s*=.*/fail_interval = 900/g" /etc/security/faillock.conf
fi
# END V-230335

###############################################################################
echo "Automating Rule Id V-230337"
###############################################################################
if [ ${version} == '8.0' ] || [ ${version} == '8.1' ]; then
    echo "  Automation intended for 8.2 and newer, '$version' detected, skipping..."
else
    sed -i "s/^\(#\|\)[[:space:]]*unlock_time\s*=.*/unlock_time = 0/g" /etc/security/faillock.conf
fi
# END V-230337

###############################################################################
echo "Automating Rule Id V-230341"
###############################################################################
if [ ${version} == '8.0' ] || [ ${version} == '8.1' ]; then
    echo "  Automation intended for 8.2 and newer, '$version' detected, skipping..."
else
    if grep -q -i silent /etc/security/faillock.conf; then
        sed -i "s/.*silent.*/silent/g" /etc/security/faillock.conf
    else
        echo "silent" >> /etc/security/faillock.conf
    fi
fi
# END V-230341

###############################################################################
echo "Automating Rule Id V-230343"
###############################################################################
if [ ${version} == '8.0' ] || [ ${version} == '8.1' ]; then
    echo "  Automation intended for 8.2 and newer, '$version' detected, skipping..."
else
    if grep -q -i audit /etc/security/faillock.conf; then
        sed -i "s/.*audit.*/audit/g" /etc/security/faillock.conf
    else
        echo "audit" >> /etc/security/faillock.conf
    fi
fi
# END V-230343

###############################################################################
echo "Automating Rule Id V-230345"
###############################################################################
if [ ${version} == '8.0' ] || [ ${version} == '8.1' ]; then
    echo "  Automation intended for 8.2 and newer, '$version' detected, skipping..."
else
    sed -i "s/^\(#\|\)[[:space:]]*even_deny_root.*/even_deny_root/g" /etc/security/faillock.conf
fi
# END V-230345

###############################################################################
echo "Automating Rule Id V-230350"
###############################################################################
sed -i 's/.*tmux.*//g' /etc/shells
# END V-230350

###############################################################################
echo "Automating Rule Id V-230367"
###############################################################################
chage -M 60 $1
chage -M 60 root
# END V-230367

###############################################################################
echo "Automating Rule Id V-230368"
###############################################################################
passwordRequired='password    required'
spacing='      '
passwordReqPwHist='pam_pwhistory.so use_authtok remember=5 retry=3'
sed -i "s/\(password.*pam_unix.so.*\)/${passwordRequired}${spacing}${passwordReqPwHist}\n\1/g" /etc/pam.d/password-auth /etc/pam.d/system-auth
# END V-230368

###############################################################################
echo "Automating Rule Id V-230373"
###############################################################################
useradd -D -f 35
# END V-230373

###############################################################################
echo "Automating Rule Id V-230380"
###############################################################################
sed -i 's/\s*nullok\s*/ /g' /etc/pam.d/system-auth /etc/pam.d/password-auth
sed -i "s/.*PermitEmptyPasswords.*/PermitEmptyPasswords no/g" /etc/ssh/sshd_config
# END V-230380

###############################################################################
echo "Automating Rule Id V-230485"
###############################################################################
if ! grep -q -w 'port' /etc/chrony.conf; then
    echo 'port 0' >> /etc/chrony.conf
else
    sed -i 's/\(^port\|^#port\).*/port 0/g' /etc/chrony.conf
fi
# END V-230485

###############################################################################
echo "Automating Rule Id V-230486"
###############################################################################
if ! grep -q -w 'cmdport' /etc/chrony.conf; then
    echo 'cmdport 0' >> /etc/chrony.conf
else
    sed -i 's/\(^cmdport\|^#cmdport\).*/cmdport 0/g' /etc/chrony.conf
fi
# END V-230486

###############################################################################
echo "Automating Rule Id V-230494"
###############################################################################
echo 'install ATM /bin/true' > /etc/modprobe.d/ATM.conf
echo 'blacklist ATM' >> /etc/modprobe.d/blacklist.conf
# END V-230494

###############################################################################
echo "Automating Rule Id V-230495"
###############################################################################
echo 'install CAN /bin/true' > /etc/modprobe.d/CAN.conf
echo 'blacklist CAN' >> /etc/modprobe.d/blacklist.conf
# END V-230495

###############################################################################
echo "Automating Rule Id V-230496"
###############################################################################
echo 'install SCTP /bin/true' > /etc/modprobe.d/SCTP.conf
echo 'blacklist SCTP' >> /etc/modprobe.d/blacklist.conf
# END V-230496

###############################################################################
echo "Automating Rule Id V-230497"
###############################################################################
echo 'install TIPC /bin/true' > /etc/modprobe.d/TIPC.conf
echo 'blacklist TIPC' >> /etc/modprobe.d/blacklist.conf
# END V-230497

###############################################################################
echo "Automating Rule Id V-230498"
###############################################################################
echo 'install cramfs /bin/true' > /etc/modprobe.d/cramfs.conf
echo 'blacklist cramfs' >> /etc/modprobe.d/blacklist.conf
# END V-230498

###############################################################################
echo "Automating Rule Id V-230499"
###############################################################################
echo 'install firewire-core /bin/true' > /etc/modprobe.d/firewire-core.conf
echo 'blacklist firewire-core' >> /etc/modprobe.d/blacklist.conf
# END V-230499

###############################################################################
echo "Automating Rule Id V-230503"
###############################################################################
echo 'install usb-storage /bin/true' > /etc/modprobe.d/usb-storage.conf
echo 'blacklist usb-storage' >> /etc/modprobe.d/blacklist.conf
# END V-230503

###############################################################################
echo "Automating Rule Id V-230507"
###############################################################################
echo 'install bluetooth /bin/true' > /etc/modprobe.d/bluetooth.conf
# END V-230507

###############################################################################
echo "Automating Rule Ids V-230508, V-230509, V-230510"
###############################################################################
echo 'tmpfs /dev/shm tmpfs defaults,nodev,nosuid,noexec 0 0' >> /etc/fstab
# END V-230508, V-230509, V-230510

###############################################################################
echo "Automating Rule Id V-230511, V-230512, V-230513"
###############################################################################
sed -i 's/\(\/tmp.*\)defaults.*/\1defaults,nodev,nosuid,noexec 0 0/g' /etc/fstab
# END V-230511, V-230512, V-230513

###############################################################################
echo "Automating Rule Id V-230546"
###############################################################################
rm -f /usr/lib/sysctl.d/10-default-yama-scope.conf
sysctl -w kernel.yama.ptrace_scope=1
echo "kernel.yama.ptrace_scope = 1" > /etc/sysctl.d/90-azurestig-v230546.conf
# END V-230546

###############################################################################
echo "Installing Ansible for STIG automation..."
###############################################################################
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
# replacing releasever in epel repo files; issue in 8.1/8.2 where the $releasever returns "8.1" / "8.2" instead of "8"
sed -i 's/$releasever/8/g' /etc/yum.repos.d/epel*.repo
yum -y install ansible

###############################################################################
echo "Unzipping rhel8STIG-ansible.zip to ./rhel8STIG"
###############################################################################
unzip rhel8STIG-ansible.zip -d ./rhel8STIG
chmod +x ./rhel8STIG/enforce.sh
# due to enforce.sh content pathing, changing to expanded directory for script execution
cd ./rhel8STIG
sh ./enforce.sh

###############################################################################
# "Automating Rule Id V-230483" 8.0 auditd.conf does not recogn. percent sign
###############################################################################
if [ ${version} == '8.0' ]; then
    echo "Automating Rule Id V-230483"
    sed -i 's/25%/2048/g' /etc/audit/auditd.conf
fi
# END V-230483

###############################################################################
echo "Restarting system to apply STIG settings..."
###############################################################################
touch ./../azAutomationComplete
shutdown -r +1 2>&1
