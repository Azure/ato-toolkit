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
echo "Backup files that will be modified by Azure STIG Automation"
###############################################################################
mkdir ./azureStigBackup
cp --force /etc/fstab ./azureStigBackup/backup.fstab
cp --force /etc/pam.d/system-auth ./azureStigBackup/backup.system-auth
cp --force /etc/pam.d/password-auth ./azureStigBackup/backup.password-auth
cp --force /etc/ssh/sshd_config ./azureStigBackup/backup.sshd_config
cp --force /etc/login.defs ./azureStigBackup/backup.login.defs
cp --force /etc/audit/rules.d/audit.rules ./azureStigBackup/backup.audit.rules
cp --force /etc/security/pwquality.conf ./azureStigBackup/backup.pwquality.conf
cp --force /etc/chrony.conf ./azureStigBackup/backup.chrony.conf
cp --force /etc/dnf/dnf.conf ./azureStigBackup/backup.dnf.conf
cp --force /usr/lib/sysctl.d/50-coredump.conf ./azureStigBackup/backup.50-coredump.conf
cp --force /etc/aliases ./azureStigBackup/backup.aliases
chmod 0600 -R ./azureStigBackup
chgrp root -R ./azureStigBackup
chown root -R ./azureStigBackup
# END Backup

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
echo "Automating Rule Id V-230225"
###############################################################################
echo "You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use only." > /etc/issue
echo "" >> /etc/issue
echo "By using this IS (which includes any device attached to this IS), you consent to the following conditions:" >> /etc/issue
echo "" >> /etc/issue
echo "-The USG routinely intercepts and monitors communications on this IS for purposes including, but not limited to, penetration testing, COMSEC monitoring, network operations and defense, personnel misconduct (PM), law enforcement (LE), and counterintelligence (CI) investigations." >> /etc/issue
echo "" >> /etc/issue
echo "-At any time, the USG may inspect and seize data stored on this IS." >> /etc/issue
echo "" >> /etc/issue
echo "-Communications using, or data stored on, this IS are not private, are subject to routine monitoring, interception, and search, and may be disclosed or used for any USG-authorized purpose." >> /etc/issue
echo "" >> /etc/issue
echo "-This IS includes security measures (e.g., authentication and access controls) to protect USG interests--not for your personal benefit or privacy." >> /etc/issue
echo "" >> /etc/issue
echo "-Notwithstanding the above, using this IS does not constitute consent to PM, LE or CI investigative searching or monitoring of the content of privileged communications, or work product, related to personal representation or services by attorneys, psychotherapists, or clergy, and their assistants. Such communications and work product are private and confidential. See User Agreement for details." >> /etc/issue
echo "" >> /etc/issue
sed -i "s/^#Banner.*/Banner \/etc\/issue/g" /etc/ssh/sshd_config
# END V-230225

###############################################################################
echo "Automating Rule Id V-230228/V-230477"
###############################################################################
if ! rpm -q --quiet rsyslog; then
    yum -y -q install rsyslog
fi
sed -i "s/.*\/var\/log\/secure/auth.*;authpriv.*;daemon.* \/var\/log\/secure/g" /etc/rsyslog.conf
# END V-230228

###############################################################################
echo "Automating Rule Id V-230231"
###############################################################################
sed -i "s/ENCRYPT_METHOD.*/ENCRYPT_METHOD SHA512/g" /etc/login.defs
# END V-230231

###############################################################################
echo "Automating Rule Id V-230233"
###############################################################################
sed -i "s/\(password\s*sufficient.*\)/\1 rounds=5000/g" /etc/pam.d/password-auth /etc/pam.d/system-auth
# END V-230233

###############################################################################
echo "Automating Rule Id V-230236"
###############################################################################
sed -i "s/ExecStart=.*/ExecStart=-\/usr\/lib\/systemd\/systemd-sulogin-shell rescue/g" /usr/lib/systemd/system/rescue.service
# END V-230236

###############################################################################
echo "Automating Rule Id V-230237"
###############################################################################
if ! grep -q -E 'password.*pam_unix\.so.*sha512.*' /etc/pam.d/system-auth; then
    sed -i "s/\(password.*pam_unix\.so.*\)/\1 sha512/g" /etc/pam.d/system-auth
fi
if ! grep -q -E 'password.*pam_unix\.so.*sha512.*' /etc/pam.d/password-auth; then
    sed -i "s/\(password.*pam_unix\.so.*\)/\1 sha512/g" /etc/pam.d/password-auth
fi
# END V-230237

###############################################################################
echo "Automating Rule Id V-230239"
###############################################################################
if rpm -q --quiet krb5-workstation; then
    yum -y -q remove krb5-workstation
fi
# END V-230239

###############################################################################
echo "Automating Rule Id V-230240"
###############################################################################
if [ ! $(getenforce) = 'Enforcing' ]; then
    sed -i "s/^SELINUX=.*/SELINUX=enforcing/g" /etc/selinux/config
fi
# END V-230240

###############################################################################
echo "Automating Rule Id V-230241"
###############################################################################
if ! rpm -q --quiet policycoreutils; then
    yum -y -q install policycoreutils
fi
# END V-230241

###############################################################################
echo "Automating Rule Id V-230242"
###############################################################################
find / -type d -perm -0002 -exec chown root {} \;
# END V-230242

###############################################################################
echo "Automating Rule Id V-230243"
###############################################################################
find / -type d \( -perm -0002 -a ! -perm -1000 \) -exec chmod 1777 {} \;
# END V-230243

###############################################################################
echo "Automating Rule Id V-230244"
###############################################################################
sed -i "s/.*ClientAliveInterval.*/ClientAliveInterval 600/g" /etc/ssh/sshd_config
sed -i "s/.*ClientAliveCountMax.*/ClientAliveCountMax 0/g" /etc/ssh/sshd_config
# END V-230244

###############################################################################
echo "Automating Rule Id V-230245"
# default in RHEL 8 is 0600, STIG states 0640 or less permissive; keep default
###############################################################################
chmod 0600 /var/log/messages
# END V-230245

###############################################################################
echo "Automating Rule Id V-230246"
###############################################################################
chown root /var/log/messages
# END V-230246

###############################################################################
echo "Automating Rule Id V-230247"
###############################################################################
chgrp root /var/log/messages
# END V-230247

###############################################################################
echo "Automating Rule Id V-230248"
###############################################################################
chmod 0755 /var/log
# END V-230248

###############################################################################
echo "Automating Rule Id V-230249"
###############################################################################
chown root /var/log
# END V-230249

###############################################################################
echo "Automating Rule Id V-230250"
###############################################################################
chgrp root /var/log
# END V-230250

###############################################################################
echo "Automating Rule Id V-230251"
###############################################################################
if [ ! $(update-crypto-policies --show) = 'FIPS' ]; then
    fips-mode-setup --enable
fi
# END V-230251

###############################################################################
echo "Automating Rule Id V-230253"
###############################################################################
sed -i "s/^SSH_USE_STRONG_RNG=.*/SSH_USE_STRONG_RNG=32/g" /etc/sysconfig/sshd
# END V-230253

###############################################################################
echo "Automating Rule Id V-230255"
###############################################################################
sed -i "s/.*MinProtocol.*/MinProtocol = TLSv1.2/g" /etc/crypto-policies/back-ends/opensslcnf.config
# END V-230255

###############################################################################
echo "Automating Rule Id V-230257"
###############################################################################
find -L /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin -perm /0022 -type f -exec chmod 0755 {} \;
# END V-230257

###############################################################################
echo "Automating Rule Id V-230258"
###############################################################################
find -L /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin ! -user root -type f -exec chown root {} \;
# END V-230258

###############################################################################
echo "Automating Rule Id V-230259"
###############################################################################
find -L /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin ! -group root -type f -exec chgrp root {} \;
# END V-230259

###############################################################################
echo "Automating Rule Id V-230260"
###############################################################################
find -L /lib /lib64 /usr/lib /usr/lib64 -perm /0022 -type f -exec chmod 0755 {} \;
# END V-230260

###############################################################################
echo "Automating Rule Id V-230261"
###############################################################################
find -L /lib /lib64 /usr/lib /usr/lib64 ! -user root -type f -exec chown root {} \;
# END V-230261

###############################################################################
echo "Automating Rule Id V-230262"
###############################################################################
find -L /lib /lib64 /usr/lib /usr/lib64 ! -group root -type f -exec chgrp root {} \;
# END V-230262

###############################################################################
echo "Automating Rule Id V-230263"
###############################################################################
if ! rpm -q --quiet aide; then
    yum -y -q install aide
fi
echo "  Executing /usr/sbin/aide --init..."
/usr/sbin/aide --init > aideresults.log
echo "  Moving /var/lib/aide/aide.db.new.gz to /var/lib/aide/aide.db.gz..."
mv --verbose --force /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
echo "  Adding aide daily check cron job..."
echo '0 5 * * * root /usr/sbin/aide --check | /bin/mail -s "$(hostname) - AIDE Integrity Check" root@localhost' > /etc/cron.daily/aide
# END V-230263

###############################################################################
echo "Automating Rule Id V-230264"
###############################################################################
grep -r -l -i gpgcheck /etc/yum.repos.d/*.repo | xargs sed -i "s/.*gpgcheck=.*/gpgcheck=1/g"
# END V-230264

###############################################################################
echo "Automating Rule Id V-230265"
###############################################################################
if grep -q -i localpkg_gpgcheck /etc/dnf/dnf.conf; then
    sed -i "s/.*localpkg_gpgcheck.*/localpkg_gpgcheck=True/g" /etc/dnf/dnf.conf
else
    echo "localpkg_gpgcheck=True" >> /etc/dnf/dnf.conf
fi
# END V-230265

###############################################################################
echo "Automating Rule Id V-230266"
###############################################################################
echo "kernel.kexec_load_disabled = 1" > /etc/sysctl.d/90-azurestig-v230266.conf
# END V-230266

###############################################################################
echo "Automating Rule Id V-230267"
###############################################################################
echo "fs.protected_symlinks = 1" > /etc/sysctl.d/90-azurestig-v230267.conf
# END V-230267

###############################################################################
echo "Automating Rule Id V-230268"
###############################################################################
echo "fs.protected_hardlinks = 1" > /etc/sysctl.d/90-azurestig-v230268.conf
# END V-230268

###############################################################################
echo "Automating Rule Id V-230269"
###############################################################################
echo "kernel.dmesg_restrict = 1" > /etc/sysctl.d/90-azurestig-v230269.conf
# END V-230269

###############################################################################
echo "Automating Rule Id V-230270"
###############################################################################
echo "kernel.perf_event_paranoid = 2" > /etc/sysctl.d/90-azurestig-v230270.conf
# END V-230270

###############################################################################
echo "Automating Rule Id V-230271"
###############################################################################
grep -r -l -i nopasswd /etc/sudoers.d/* /etc/sudoers | xargs sed -i 's/\s*NOPASSWD://g' 2>&1
# END V-230271

###############################################################################
echo "Automating Rule Id V-230272"
###############################################################################
grep -r -l -i '!authenticate' /etc/sudoers /etc/sudoers.d/* | xargs sed -i 's/.*!authenticate.*//g' 2>&1
# END V-230272

###############################################################################
echo "Automating Rule Id V-230273"
###############################################################################
if ! rpm -q --quiet esc; then
    yum -y -q install esc
fi
if ! rpm -q --quiet openssl-pkcs11; then
    yum -y -q install openssl-pkcs11
fi
# END V-230273

###############################################################################
echo "Automating Rule Id V-230275"
###############################################################################
if ! rpm -q --quiet opensc; then
    yum -y -q install opensc
fi
# END V-230275

###############################################################################
echo "Automating Rule Id V-230277"
###############################################################################
grubby --update-kernel=ALL --args="page_poison=1"
# END V-230277

###############################################################################
echo "Automating Rule Id V-230278"
###############################################################################
grubby --update-kernel=ALL --args="vsyscall=none"
# END V-230278

###############################################################################
echo "Automating Rule Id V-230279"
###############################################################################
grubby --update-kernel=ALL --args="slub_debug=P"
# END V-230279

###############################################################################
echo "Automating Rule Id V-230280"
###############################################################################
echo "kernel.randomize_va_space = 2" > /etc/sysctl.d/90-azurestig-v230280.conf
# END V-230280

###############################################################################
echo "Automating Rule Id V-230281"
###############################################################################
sed -i "s/.*clean_requirements_on_remove.*/clean_requirements_on_remove=True/g" /etc/dnf/dnf.conf
# END V-230281

###############################################################################
echo "Automating Rule Id V-230282"
###############################################################################
if ! sestatus | grep -q -i "Loaded policy name:\s*targeted"; then
    sed -i "s/^SELINUXTYPE=.*/SELINUXTYPE=targeted/g" /etc/selinux/config
fi
# END V-230282

###############################################################################
echo "Automating Rule Id V-230283"
###############################################################################
find / -name shosts.equiv -type f -exec rm {} \;
# END V-230283

###############################################################################
echo "Automating Rule Id V-230284"
###############################################################################
find / -name '*.shosts' -type f -exec rm {} \;
# END V-230284

###############################################################################
echo "Automating Rule Id V-230285"
###############################################################################
systemctl start rngd.service
systemctl enable rngd.service
# END V-230285

###############################################################################
echo "Automating Rule Id V-230286"
###############################################################################
chmod 0644 /etc/ssh/*key.pub
# END V-230286

###############################################################################
echo "Automating Rule Id V-230287"
# SCAP fails if 0640 is used, group read; 600 is less permissive; still valid
###############################################################################
chmod 0600 /etc/ssh/ssh_host*key
# END V-230287

###############################################################################
echo "Automating Rule Id V-230288"
###############################################################################
sed -i "s/.*StrictModes.*/StrictModes yes/g" /etc/ssh/sshd_config
# END V-230288

###############################################################################
echo "Automating Rule Id V-230289"
###############################################################################
sed -i "s/.*Compression.*/Compression no/g" /etc/ssh/sshd_config
# END V-230289

###############################################################################
echo "Automating Rule Id V-230290"
###############################################################################
sed -i "s/.*IgnoreUserKnownHosts.*/IgnoreUserKnownHosts yes/g" /etc/ssh/sshd_config
# END V-230290

###############################################################################
echo "Automating Rule Id V-230291"
###############################################################################
sed -i "s/.*KerberosAuthentication.*/KerberosAuthentication no/g" /etc/ssh/sshd_config
sed -i "s/.*GSSAPIAuthentication.*/GSSAPIAuthentication no/g" /etc/ssh/sshd_config
# END V-230291

###############################################################################
echo "Automating Rule Id V-230296"
###############################################################################
sed -i "s/\(^PermitRootLogin\|^#PermitRootLogin\).*/PermitRootLogin no/g" /etc/ssh/sshd_config
# END V-230296

###############################################################################
echo "Automating Rule Id V-230297"
###############################################################################
systemctl start auditd.service
systemctl enable auditd.service
# END V-230297

###############################################################################
echo "Automating Rule Id V-230298"
###############################################################################
systemctl start rsyslog.service
systemctl enable rsyslog.service
# END V-230298

###############################################################################
echo "Automating Rule Id V-230299"
###############################################################################
sed -i "s/\(.*\/home.*defaults\)/\1,nosuid/g" /etc/fstab
# END V-230299

###############################################################################
echo "Automating Rule Id V-230300"
###############################################################################
sed -i "s/\(.*\/boot.*defaults\)/\1,nosuid/g" /etc/fstab
# END V-230300

###############################################################################
echo "Automating Rule Id V-230301"
###############################################################################
sed -i "s/\(.*[[:space:]]\/[[:alpha:]].*defaults\)/\1,nodev/g" /etc/fstab
# END V-230301

###############################################################################
echo "Automating Rule Id V-230302"
###############################################################################
sed -i "s/\(.*\/home.*defaults\)/\1,noexec/g" /etc/fstab
# END V-230302

###############################################################################
echo "Automating Rule Id V-230310"
###############################################################################
systemctl disable kdump.service 2>&1
# END V-230310

###############################################################################
echo "Automating Rule Id V-230311"
###############################################################################
rm -f /usr/lib/sysctl.d/50-coredump.conf
echo "kernel.core_pattern = |/bin/false" > /etc/sysctl.d/90-azurestig-v230311.conf
# END V-230311

###############################################################################
echo "Automating Rule Id V-230312"
###############################################################################
systemctl mask systemd-coredump.socket 2>&1
# END V-230312

###############################################################################
echo "Automating Rule Id V-230313"
###############################################################################
echo "* hard core 0" > /etc/security/limits.d/90-azurestig-v230313.conf
# END V-230313

###############################################################################
echo "Automating Rule Id V-230314"
###############################################################################
sed -i "s/.*Storage\s*=.*/Storage=none/g" /etc/systemd/coredump.conf
# END V-230314

###############################################################################
echo "Automating Rule Id V-230315"
###############################################################################
sed -i "s/.*ProcessSizeMax\s*=.*/ProcessSizeMax=0/g" /etc/systemd/coredump.conf
# END V-230315

###############################################################################
echo "Automating Rule Id V-230321"
###############################################################################
ls -d $(awk -F: '($3>=1000)&&($7 !~ /nologin/){print $6}' /etc/passwd) | xargs chmod 0750
# END V-230321

###############################################################################
echo "Automating Rule Id V-230324"
###############################################################################
sed -i "s/.*CREATE_HOME.*/CREATE_HOME yes/g" /etc/login.defs
# END V-230324

###############################################################################
echo "Automating Rule Id V-230325"
# STIG states 740 or less, default is 600 and 640, setting to 640 to exclude "eXec"
###############################################################################
find /home/*/.[^.]* -type f -exec chmod 0640 {} \;
# END V-230325

###############################################################################
echo "Automating Rule Id V-230326"
###############################################################################
find / -nouser -not -path "/proc/*" -exec chown $1 {} \;
# END V-230326

###############################################################################
echo "Automating Rule Id V-230327"
###############################################################################
find / -nogroup -not -path "/proc/*" -exec chgrp $1 {} \;
# END V-230327

###############################################################################
echo "Automating Rule Id V-230330"
###############################################################################
sed -i "s/.*PermitUserEnvironment.*/PermitUserEnvironment no/g" /etc/ssh/sshd_config
# END V-230330

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
echo "Automating Rule Id V-230339"
###############################################################################
if [ ${version} == '8.0' ] || [ ${version} == '8.1' ]; then
    echo "  Automation intended for 8.2 and newer, '$version' detected, skipping..."
else
    sed -i "s/.*dir\s*=.*/dir = \/var\/log\/faillock/g" /etc/security/faillock.conf
fi
# END V-230339

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
echo "Automating Rule Id V-230346"
###############################################################################
echo "* hard maxlogins 10 " > /etc/security/limits.d/90-azurestig-v230346.conf
# END V-230346

###############################################################################
echo "Automating Rule Id V-230348"
###############################################################################
if ! rpm -q --quiet tmux; then
    yum -y -q install tmux
fi
echo "set -g lock-command vlock" >> /etc/tmux.conf
# END V-230348

###############################################################################
echo "Automating Rule Id V-230349"
###############################################################################
echo '[ -n "$PS1" -a -z "$TMUX" ] && exec tmux' >> /etc/bashrc
# END V-230349

###############################################################################
echo "Automating Rule Id V-230350"
###############################################################################
sed -i 's/.*tmux.*//g' /etc/shells
# END V-230350

###############################################################################
echo "Automating Rule Id V-230353"
###############################################################################
echo 'set -g lock-after-time 900' >> /etc/tmux.conf
# END V-230353

###############################################################################
echo "Automating Rule Id V-230356"
###############################################################################
passwordReqPwQual='password    required      pam_pwquality.so try_first_pass local_users_only retry=3 use_authtok'
sed -i "s/password\s*requisite\s*pam_pwquality.so.*/${passwordReqPwQual}/g" /etc/pam.d/password-auth /etc/pam.d/system-auth
# END V-230356

###############################################################################
echo "Automating Rule Id V-230357"
###############################################################################
sed -i 's/.*ucredit.*/ucredit = -1/g' /etc/security/pwquality.conf
# END V-230357

###############################################################################
echo "Automating Rule Id V-230358"
###############################################################################
sed -i 's/.*lcredit.*/lcredit = -1/g' /etc/security/pwquality.conf
# END V-230358

###############################################################################
echo "Automating Rule Id V-230359"
###############################################################################
sed -i 's/.*dcredit.*/dcredit = -1/g' /etc/security/pwquality.conf
# END V-230359

###############################################################################
echo "Automating Rule Id V-230360"
###############################################################################
sed -i 's/.*maxclassrepeat.*/maxclassrepeat = 4/g' /etc/security/pwquality.conf
# END V-230360

###############################################################################
echo "Automating Rule Id V-230361"
###############################################################################
sed -i 's/.*maxrepeat.*/maxrepeat = 3/g' /etc/security/pwquality.conf
# END V-230361

###############################################################################
echo "Automating Rule Id V-230362"
###############################################################################
sed -i 's/.*minclass.*/minclass = 4/g' /etc/security/pwquality.conf
# END V-230362

###############################################################################
echo "Automating Rule Id V-230363"
###############################################################################
sed -i 's/.*difok.*/difok = 8/g' /etc/security/pwquality.conf
# END V-230363

###############################################################################
echo "Automating Rule Id V-230364"
###############################################################################
chage -m 1 $1
chage -m 1 root
# END V-230364

###############################################################################
echo "Automating Rule Id V-230365"
###############################################################################
sed -i "s/\(^PASS_MIN_DAYS\|^#PASS_MIN_DAYS\).*/PASS_MIN_DAYS 1/g" /etc/login.defs
# END V-230365

###############################################################################
echo "Automating Rule Id V-230366"
###############################################################################
sed -i "s/\(^PASS_MAX_DAYS\|^#PASS_MAX_DAYS\).*/PASS_MAX_DAYS 60/g" /etc/login.defs
# END V-230366

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
echo "Automating Rule Id V-230369"
###############################################################################
sed -i 's/.*minlen.*/minlen = 15/g' /etc/security/pwquality.conf
# END V-230369

###############################################################################
echo "Automating Rule Id V-230370"
###############################################################################
sed -i "s/\(^PASS_MIN_LEN\|^#PASS_MIN_LEN\).*/PASS_MIN_LEN 15/g" /etc/login.defs
# END V-230370

###############################################################################
echo "Automating Rule Id V-230373"
###############################################################################
useradd -D -f 35
# END V-230373

###############################################################################
echo "Automating Rule Id V-230375"
###############################################################################
sed -i 's/.*ocredit.*/ocredit = -1/g' /etc/security/pwquality.conf
# END V-230375

###############################################################################
echo "Automating Rule Id V-230377"
###############################################################################
sed -i 's/.*dictcheck.*/dictcheck = 1/g' /etc/security/pwquality.conf
# END V-230377

###############################################################################
echo "Automating Rule Id V-230378"
###############################################################################
###############################################################################
if grep -q -i FAIL_DELAY /etc/login.defs; then
    sed -i '"s/\(^FAIL_DELAY\|^#FAIL_DELAY\).*/FAIL_DELAY 4/g"' /etc/login.defs
else
    echo "FAIL_DELAY 4" >> /etc/login.defs
fi
# END V-230378

###############################################################################
echo "Automating Rule Id V-230380"
###############################################################################
sed -i 's/\s*nullok\s*/ /g' /etc/pam.d/system-auth /etc/pam.d/password-auth
sed -i "s/.*PermitEmptyPasswords.*/PermitEmptyPasswords no/g" /etc/ssh/sshd_config
# END V-230380

###############################################################################
echo "Automating Rule Id V-230381"
###############################################################################
sessPamLastReq='session required                   pam_lastlog.so showfailed'
sed -i "s/\(session.*default.*pam_lastlog.*\)/${sessPamLastReq}\n\1/g" /etc/pam.d/postlogin
# END V-230381

###############################################################################
echo "Automating Rule Id V-230382"
###############################################################################
sed -i "s/.*PrintLastLog.*/PrintLastLog yes/g" /etc/ssh/sshd_config
# END V-230382

###############################################################################
echo "Automating Rule Id V-230383"
###############################################################################
sed -i "s/\(^UMASK\|^#UMASK\).*/UMASK 077/g" /etc/login.defs
# END V-230383

###############################################################################
echo "Automating Rule Id V-230385"
###############################################################################
sed -i "s/^\s*umask.*/umask 077/g" /etc/bashrc /etc/csh.cshrc
# END V-230385

###############################################################################
echo "Automating Rule Id V-230387"
###############################################################################
echo "cron.* /var/log/cron.log" > /etc/rsyslog.d/90-azurestig-v230387.conf
# END V-230387

###############################################################################
echo "Automating Rule Id V-230388"
###############################################################################
sed -i 's/.*action_mail_acct.*/action_mail_acct = root/g' /etc/audit/auditd.conf
# END V-230388

###############################################################################
echo "Automating Rule Id V-230389"
###############################################################################
if grep -q -i "postmaster:.*" /etc/aliases; then
    sed -i 's/postmaster:.*/postmaster:     root/g' /etc/aliases
else
    echo "postmaster:     root" >> /etc/aliases
fi
# END V-230389

###############################################################################
echo "Automating Rule Id V-230390"
###############################################################################
sed -i 's/.*disk_error_action.*/disk_error_action = HALT/g' /etc/audit/auditd.conf
# END V-230390

###############################################################################
echo "Automating Rule Id V-230391"
###############################################################################
sed -i 's/.*max_log_file_action.*/max_log_file_action = syslog/g' /etc/audit/auditd.conf
# END V-230391

###############################################################################
echo "Automating Rule Id V-230392"
###############################################################################
sed -i 's/.*disk_full_action.*/disk_full_action = HALT/g' /etc/audit/auditd.conf
# END V-230392

###############################################################################
echo "Automating Rule Id V-230393"
###############################################################################
sed -i 's/.*local_events.*/local_events = yes/g' /etc/audit/auditd.conf
# END V-230393

###############################################################################
echo "Automating Rule Id V-230394"
###############################################################################
sed -i 's/.*name_format.*/name_format = hostname/g' /etc/audit/auditd.conf
# END V-230394

###############################################################################
echo "Automating Rule Id V-230395"
###############################################################################
sed -i 's/.*log_format.*/log_format = ENRICHED/g' /etc/audit/auditd.conf
# END V-230395

###############################################################################
echo "Automating Rule Id V-230396"
###############################################################################
grep -iw log_file /etc/audit/auditd.conf | sed 's/log_file\s*=\s*\(.*\)/\1/g' | xargs chmod 600
sed -i 's/.*log_group.*/log_group = root/g' /etc/audit/auditd.conf
# END V-230396

###############################################################################
echo "Automating Rule Id V-230397"
###############################################################################
grep -iw log_file /etc/audit/auditd.conf | sed 's/log_file\s*=\s*\(.*\)/\1/g' | xargs chown root
# END V-230397

###############################################################################
echo "Automating Rule Id V-230398"
###############################################################################
grep -iw log_file /etc/audit/auditd.conf | sed 's/log_file\s*=\s*\(.*\)/\1/g' | xargs chgrp root
# END V-230398

###############################################################################
echo "Automating Rule Id V-230399"
###############################################################################
grep -iw log_file /etc/audit/auditd.conf | sed 's/log_file\s*=\s*\(.*\)\/\w*.log/\1/g' | xargs chown root
# END V-230399

###############################################################################
echo "Automating Rule Id V-230400"
###############################################################################
grep -iw log_file /etc/audit/auditd.conf | sed 's/log_file\s*=\s*\(.*\)\/\w*.log/\1/g' | xargs chgrp root
# END V-230400

###############################################################################
echo "Automating Rule Id V-230401"
###############################################################################
grep -iw log_file /etc/audit/auditd.conf | sed 's/log_file\s*=\s*\(.*\)\/\w*.log/\1/g' | xargs chmod 0700
# END V-230401

###############################################################################
echo "Automating Rule Id V-230411"
###############################################################################
yum -q -y install audit
# END V-230411

###############################################################################
echo  "Automating Rule Ids V-230386,V-230402,V-230403,V-230404,V-230405,V-230406,
V-230407,V-230408,V-230409,V-230410,V-230412,V-230413,V-230414,V-230415,V-230416,
V-230417,V-230418,V-230419,V-230420,V-230421,V-230422,V-230423,V-230424,V-230425,
V-230426,V-230427,V-230428,V-230429,V-230430,V-230431,V-230432,V-230433,V-230434,
V-230435,V-230436,V-230437,V-230438,V-230439,V-230440,V-230441,V-230442,V-230443,
V-230444,V-230445,V-230446,V-230447,V-230448,V-230449,V-230450,V-230451,V-230452,
V-230453,V-230454,V-230455,V-230456,V-230457,V-230458,V-230459,V-230460,V-230461,
V-230462,V-230463,V-230464,V-230465,V-230466,V-230467,V-230471"
###############################################################################
echo '## Entries below were generated via Azure STIG Automation for RHEL 8' >> /etc/audit/rules.d/audit.rules
echo '--loginuid-immutable' >> /etc/audit/rules.d/audit.rules
echo '-e 2' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S chmod -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S chown -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S creat -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S delete_module -F auid>=1000 -F auid!=unset -k module_chng' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S execve -C gid!=egid -F egid=0 -k execpriv' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -k execpriv' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S fchmod -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S fchmodat -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S fchown -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S fchownat -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S finit_module -F auid>=1000 -F auid!=unset -k module_chng' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S fremovexattr -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S fremovexattr -F auid=0 -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S fsetxattr -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S fsetxattr -F auid=0 -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S init_module -F auid>=1000 -F auid!=unset -k module_chng' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S lchown -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S lremovexattr -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S lremovexattr -F auid=0 -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S lsetxattr -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S lsetxattr -F auid=0 -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=unset -k privileged-mount' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S open -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S open -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S openat -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S openat -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S removexattr -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S removexattr -F auid=0 -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S rename -F auid>=1000 -F auid!=unset -k delete' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S renameat -F auid>=1000 -F auid!=unset -k delete' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S rmdir -F auid>=1000 -F auid!=unset -k delete' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S setxattr -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S setxattr -F auid=0 -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S truncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S truncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S unlink -F auid>=1000 -F auid!=unset -k delete' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b32 -S unlinkat -F auid>=1000 -F auid!=unset -k delete' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S chmod -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S chown -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S creat -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S delete_module -F auid>=1000 -F auid!=unset -k module_chng' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S execve -C gid!=egid -F egid=0 -k execpriv' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k execpriv' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S fchmod -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S fchmodat -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S fchown -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S fchownat -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S finit_module -F auid>=1000 -F auid!=unset -k module_chng' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S fremovexattr -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S fremovexattr -F auid=0 -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S fsetxattr -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S fsetxattr -F auid=0 -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S init_module -F auid>=1000 -F auid!=unset -k module_chng' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S lchown -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S lremovexattr -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S lremovexattr -F auid=0 -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S lsetxattr -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S lsetxattr -F auid=0 -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=unset -k privileged-mount' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S open -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S open -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S openat -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S openat -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S removexattr -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S removexattr -F auid=0 -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S rename -F auid>=1000 -F auid!=unset -k delete' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S renameat -F auid>=1000 -F auid!=unset -k delete' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S rmdir -F auid>=1000 -F auid!=unset -k delete' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S setxattr -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S setxattr -F auid=0 -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S truncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S truncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S unlink -F auid>=1000 -F auid!=unset -k delete' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F arch=b64 -S unlinkat -F auid>=1000 -F auid!=unset -k delete' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/bin/chacl -F perm=x -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/bin/chage -F perm=x -F auid>=1000 -F auid!=unset -k privileged-chage' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/bin/chcon -F perm=x -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/bin/chsh -F perm=x -F auid>=1000 -F auid!=unset -k priv_cmd' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/bin/crontab -F perm=x -F auid>=1000 -F auid!=unset -k privileged-crontab' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/bin/gpasswd -F perm=x -F auid>=1000 -F auid!=unset -k privileged-gpasswd' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/bin/kmod -F perm=x -F auid>=1000 -F auid!=unset -k modules' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/bin/mount -F perm=x -F auid>=1000 -F auid!=unset -k privileged-mount' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/bin/newgrp -F perm=x -F auid>=1000 -F auid!=unset -k priv_cmd' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/bin/passwd -F perm=x -F auid>=1000 -F auid!=unset -k privileged-passwd' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/bin/setfacl -F perm=x -F auid>=1000 -F auid!=unset -k perm_mod' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/bin/ssh-agent -F perm=x -F auid>=1000 -F auid!=unset -k privileged-ssh' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/bin/su -F perm=x -F auid>=1000 -F auid!=unset -k privileged-priv_change' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/bin/sudo -F perm=x -F auid>=1000 -F auid!=unset -k priv_cmd' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/bin/umount -F perm=x -F auid>=1000 -F auid!=unset -k privileged-mount' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/libexec/openssh/ssh-keysign -F perm=x -F auid>=1000 -F auid!=unset -k privileged-ssh' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/sbin/pam_timestamp_check -F perm=x -F auid>=1000 -F auid!=unset -k privileged-pam_timestamp_check' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/sbin/postdrop -F perm=x -F auid>=1000 -F auid!=unset -k privileged-unix-update' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/sbin/postqueue -F perm=x -F auid>=1000 -F auid!=unset -k privileged-unix-update' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/sbin/semanage -F perm=x -F auid>=1000 -F auid!=unset -k privileged-unix-update' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/sbin/setfiles -F perm=x -F auid>=1000 -F auid!=unset -k privileged-unix-update' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/sbin/setsebool -F perm=x -F auid>=1000 -F auid!=unset -k privileged-unix-update' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/sbin/unix_chkpwd -F perm=x -F auid>=1000 -F auid!=unset -k privileged-unix-update' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/sbin/unix_update -F perm=x -F auid>=1000 -F auid!=unset -k privileged-unix-update' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/sbin/userhelper -F perm=x -F auid>=1000 -F auid!=unset -k privileged-unix-update' >> /etc/audit/rules.d/audit.rules
echo '-a always,exit -F path=/usr/sbin/usermod -F perm=x -F auid>=1000 -F auid!=unset -k privileged-usermod' >> /etc/audit/rules.d/audit.rules
echo '-w /etc/group -p wa -k identity' >> /etc/audit/rules.d/audit.rules
echo '-w /etc/gshadow -p wa -k identity' >> /etc/audit/rules.d/audit.rules
echo '-w /etc/passwd -p wa -k identity' >> /etc/audit/rules.d/audit.rules
echo '-w /etc/security/opasswd -p wa -k identity' >> /etc/audit/rules.d/audit.rules
echo '-w /etc/shadow -p wa -k identity' >> /etc/audit/rules.d/audit.rules
echo '-w /etc/sudoers -p wa -k identity' >> /etc/audit/rules.d/audit.rules
echo '-w /etc/sudoers.d/ -p wa -k identity' >> /etc/audit/rules.d/audit.rules
echo '-w /var/log/faillock -p wa -k logins' >> /etc/audit/rules.d/audit.rules
echo '-w /var/log/lastlog -p wa -k logins' >> /etc/audit/rules.d/audit.rules
# END Multiple Audit Rule STIG Vuln Ids

###############################################################################
echo "Automating Rule Id V-230468"
###############################################################################
grubby --update-kernel=ALL --args="audit=1"
# END V-230468

###############################################################################
echo "Automating Rule Id V-230469"
###############################################################################
grubby --update-kernel=ALL --args="audit_backlog_limit=8192"
# END V-230469

###############################################################################
echo "Automating Rule Id V-230524"
###############################################################################
if ! rpm -q --quiet usbguard.x86_64; then
    yum -y -q install usbguard.x86_64
fi
usbguard generate-policy > /etc/usbguard/rules.conf
systemctl enable usbguard.service 2>&1
systemctl start usbguard.service 2>&1
# END V-230524

###############################################################################
echo "Automating Rule Id V-230470"
###############################################################################
sed -i 's/.*AuditBackend.*/AuditBackend=LinuxAudit/g' /etc/usbguard/usbguard-daemon.conf
# END V-230470

###############################################################################
echo "Automating Rule Id V-230471"
###############################################################################
find /etc/audit/rules.d/*.rules /etc/audit/auditd.conf -type f -exec chmod 0640 {} \;
# END V-230471

###############################################################################
echo "Automating Rule Id V-230472"
###############################################################################
find /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/rsyslogd /sbin/augenrules -exec chmod 0755 {} \;
# END V-230472

###############################################################################
echo "Automating Rule Id V-230473"
###############################################################################
find /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/rsyslogd /sbin/augenrules -exec chown root {} \;
# END V-230473

###############################################################################
echo "Automating Rule Id V-230474"
###############################################################################
find /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/rsyslogd /sbin/augenrules -exec chgrp root {} \;
# END V-230474

###############################################################################
echo "Automating Rule Id V-230475"
###############################################################################
echo '/usr/sbin/auditctl p+i+n+u+g+s+b+acl+xattrs+sha512' >> /etc/aide.conf
echo '/usr/sbin/auditd p+i+n+u+g+s+b+acl+xattrs+sha512' >> /etc/aide.conf
echo '/usr/sbin/ausearch p+i+n+u+g+s+b+acl+xattrs+sha512' >> /etc/aide.conf
echo '/usr/sbin/aureport p+i+n+u+g+s+b+acl+xattrs+sha512' >> /etc/aide.conf
echo '/usr/sbin/autrace p+i+n+u+g+s+b+acl+xattrs+sha512' >> /etc/aide.conf
echo '/usr/sbin/rsyslogd p+i+n+u+g+s+b+acl+xattrs+sha512' >> /etc/aide.conf
echo '/usr/sbin/augenrules p+i+n+u+g+s+b+acl+xattrs+sha512' >> /etc/aide.conf
# END V-230475

###############################################################################
echo "Automating Rule Id V-230478"
###############################################################################
if ! rpm -q --quiet gnutls; then
    yum -y -q install gnutls
fi
# END V-230478

###############################################################################
echo "Automating Rule Id V-230480"
###############################################################################
sed -i 's/.*overflow_action.*/overflow_action = SYSLOG/g' /etc/audit/auditd.conf
# END V-230480

###############################################################################
echo "Automating Rule Id V-230481"
###############################################################################
echo '$DefaultNetstreamDriver gtls' >> /etc/rsyslog.d/90-azurestig-v230481.conf
echo '$ActionSendStreamDriverMode 1' >> /etc/rsyslog.d/90-azurestig-v230481.conf
# END V-230481

###############################################################################
echo "Automating Rule Id V-230482"
###############################################################################
echo '$ActionSendStreamDriverAuthMode x509/name' > /etc/rsyslog.d/90-azurestig-v230482.conf
# END V-230482

###############################################################################
echo "Automating Rule Id V-230483"
###############################################################################
sed -i 's/\(^space_left\|^#space_left\)\s*=.*/space_left = 25%/g' /etc/audit/auditd.conf
sed -i 's/\(^space_left_action\|^#space_left_action\)\s*=.*/space_left_action = email/g' /etc/audit/auditd.conf
# END V-230483

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
echo "Automating Rule Id V-230487"
###############################################################################
if rpm -q --quiet telnet-server; then
    yum -y -q remove telnet-server
fi
# END V-230487

###############################################################################
echo "Automating Rule Id V-230488"
###############################################################################
yum -y -q remove abrt*
# END V-230488

###############################################################################
echo "Automating Rule Id V-230489"
###############################################################################
if rpm -q --quiet sendmail; then
    yum -y -q remove sendmail
fi
# END V-230489

###############################################################################
echo "Automating Rule Id V-230491"
###############################################################################
grubby --update-kernel=ALL --args="pti=on"
# END V-230491

###############################################################################
echo "Automating Rule Id V-230492"
###############################################################################
if rpm -q --quiet rsh-server; then
    yum -y -q remove rsh-server
fi
# END V-230492

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
echo "Automating Rule Id V-230505"
###############################################################################
if ! rpm -q --quiet firewalld.noarch; then
    yum -y -q install firewalld.noarch
fi
systemctl enable firewalld
# END V-230505

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
# END V-230512

###############################################################################
echo "Automating Rule Id V-230523"
###############################################################################
if ! rpm -q --quiet fapolicyd.x86_64; then
    yum -y -q install fapolicyd.x86_64
fi
mount | egrep '^tmpfs| ext4| ext3| xfs' | awk '{ printf "%s\n", $3 }' >> /etc/fapolicyd/fapolicyd.mounts
sed -i 's/.*permissive.*/permissive = 1/g' /etc/fapolicyd/fapolicyd.conf
systemctl enable --now fapolicyd 2>&1
echo "Futher configuration is needed for fapolicyd per STIG..."
# END V-230523

###############################################################################
echo "Automating Rule Id V-230525"
###############################################################################
if ! rpm -q --quiet nftables.x86_64; then
    yum -y -q install nftables.x86_64
fi
systemctl enable nftables.service
systemctl start nftables.service
sed -i 's/.*FirewallBackend\s*=.*/FirewallBackend=nftables/g' /etc/firewalld/firewalld.conf
# END V-230525

###############################################################################
echo "Automating Rule Id V-230526"
###############################################################################
if ! rpm -q --quiet openssh-server.x86_64; then
    yum -y -q install openssh-server.x86_64
fi
systemctl enable sshd.service
# END V-230526

###############################################################################
echo "Automating Rule Id V-230527"
###############################################################################
sed -i "s/.*RekeyLimit.*/RekeyLimit 1G 1h/g" /etc/ssh/sshd_config
# END V-230527

###############################################################################
echo "Automating Rule Id V-230528"
###############################################################################
sed -i "s/.*RekeyLimit.*/RekeyLimit 1G 1h/g" /etc/ssh/ssh_config
# END V-230528

###############################################################################
echo "Automating Rule Id V-230529"
###############################################################################
systemctl mask ctrl-alt-del.target 2>&1
# END V-230529

###############################################################################
echo "Automating Rule Id V-230531"
###############################################################################
sed -i 's/.*CtrlAltDelBurstAction.*/CtrlAltDelBurstAction=none/g' /etc/systemd/system.conf
# END V-230531

###############################################################################
echo "Automating Rule Id V-230532"
###############################################################################
systemctl mask debug-shell.service 2>&1
# END V-230532

###############################################################################
echo "Automating Rule Id V-230533"
###############################################################################
if rpm -q --quiet tftp-server; then
    yum -y -q remove tftp-server
fi
# END V-230533

###############################################################################
echo "Automating Rule Id V-230535"
###############################################################################
sysctl -w net.ipv4.conf.default.accept_redirects=0
sysctl -w net.ipv6.conf.default.accept_redirects=0
echo 'net.ipv4.conf.default.accept_redirects = 0' > /etc/sysctl.d/90-azurestig-v230535.conf
echo 'net.ipv6.conf.default.accept_redirects = 0' >> /etc/sysctl.d/90-azurestig-v230535.conf
# END V-230535

###############################################################################
echo "Automating Rule Id V-230536"
###############################################################################
sysctl -w net.ipv4.conf.all.send_redirects=0
echo 'net.ipv4.conf.all.send_redirects = 0' > /etc/sysctl.d/90-azurestig-v230536.conf
# END V-230536

###############################################################################
echo "Automating Rule Id V-230537"
###############################################################################
sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1
echo 'net.ipv4.icmp_echo_ignore_broadcasts = 1' > /etc/sysctl.d/90-azurestig-v230537.conf
# END V-230537

###############################################################################
echo "Automating Rule Id V-230538"
###############################################################################
sysctl -w net.ipv4.conf.all.accept_source_route=0
sysctl -w net.ipv6.conf.all.accept_source_route=0
echo 'net.ipv4.conf.all.accept_source_route = 0' > /etc/sysctl.d/90-azurestig-v230538.conf
echo 'net.ipv6.conf.all.accept_source_route = 0' >> /etc/sysctl.d/90-azurestig-v230538.conf
# END V-230538

###############################################################################
echo "Automating Rule Id V-230539"
###############################################################################
sysctl -w net.ipv4.conf.default.accept_source_route=0
sysctl -w net.ipv6.conf.default.accept_source_route=0
echo 'net.ipv4.conf.default.accept_source_route = 0' > /etc/sysctl.d/90-azurestig-v230539.conf
echo 'net.ipv6.conf.default.accept_source_route = 0' >> /etc/sysctl.d/90-azurestig-v230539.conf
# END V-230539

###############################################################################
echo "Automating Rule Id V-230540"
###############################################################################
sysctl -w net.ipv4.ip_forward=0
sysctl -w net.ipv6.conf.all.forwarding=0
echo 'net.ipv4.ip_forward = 0' > /etc/sysctl.d/90-azurestig-v230540.conf
echo 'net.ipv6.conf.all.forwarding = 0' >> /etc/sysctl.d/90-azurestig-v230540.conf
# END V-230540

###############################################################################
echo "Automating Rule Id V-230541"
###############################################################################
sysctl -w net.ipv6.conf.all.accept_ra=0
echo 'net.ipv6.conf.all.accept_ra = 0' > /etc/sysctl.d/90-azurestig-v230541.conf
# END V-230541

###############################################################################
echo "Automating Rule Id V-230542"
###############################################################################
sysctl -w net.ipv6.conf.default.accept_ra=0
echo 'net.ipv6.conf.default.accept_ra = 0' > /etc/sysctl.d/90-azurestig-v230542.conf
# END V-230542

###############################################################################
echo "Automating Rule Id V-230543"
###############################################################################
sysctl -w net.ipv4.conf.default.send_redirects=0
echo 'net.ipv4.conf.default.send_redirects = 0' > /etc/sysctl.d/90-azurestig-v230543.conf
# END V-230543

###############################################################################
echo "Automating Rule Id V-230544"
###############################################################################
sysctl -w net.ipv4.conf.all.accept_redirects=0
sysctl -w net.ipv6.conf.all.accept_redirects=0
echo 'net.ipv4.conf.all.accept_redirects = 0' > /etc/sysctl.d/90-azurestig-v230544.conf
echo 'net.ipv6.conf.all.accept_redirects = 0' >> /etc/sysctl.d/90-azurestig-v230544.conf
# END V-230544

###############################################################################
echo "Automating Rule Id V-230545"
###############################################################################
sysctl -w kernel.unprivileged_bpf_disabled=1
echo 'kernel.unprivileged_bpf_disabled = 1' > /etc/sysctl.d/90-azurestig-v230545.conf
# END V-230545

###############################################################################
echo "Automating Rule Id V-230546"
###############################################################################
rm -f /usr/lib/sysctl.d/10-default-yama-scope.conf
sysctl -w kernel.yama.ptrace_scope=1
echo "kernel.yama.ptrace_scope = 1" > /etc/sysctl.d/90-azurestig-v230546.conf
# END V-230546

###############################################################################
echo "Automating Rule Id V-230547"
###############################################################################
sysctl -w kernel.kptr_restrict=1
echo 'kernel.kptr_restrict = 1' > /etc/sysctl.d/90-azurestig-v230547.conf
# END V-230547

###############################################################################
echo "Automating Rule Id V-230548"
###############################################################################
sysctl -w user.max_user_namespaces=0
echo 'user.max_user_namespaces = 0' > /etc/sysctl.d/90-azurestig-v230548.conf
# END V-230548

###############################################################################
echo "Automating Rule Id V-230549"
###############################################################################
sysctl -w net.ipv4.conf.all.rp_filter=1
echo 'net.ipv4.conf.all.rp_filter = 1' > /etc/sysctl.d/90-azurestig-v230549.conf
# END V-230549

###############################################################################
echo "Automating Rule Id V-230555"
###############################################################################
sed -i "s/^X11Forwarding.*/X11Forwarding no/g" /etc/ssh/sshd_config
# END V-230555

###############################################################################
echo "Automating Rule Id V-230556"
###############################################################################
sed -i "s/.*X11UseLocalhost.*/X11UseLocalhost yes/g" /etc/ssh/sshd_config
# END V-230556

###############################################################################
echo "Automating Rule Id V-230558"
###############################################################################
if rpm -q --quiet vsftpd; then
    yum -y -q remove vsftpd
fi
# END V-230558

###############################################################################
echo "Automating Rule Id V-230559"
###############################################################################
if rpm -q --quiet gssproxy; then
    yum -y -q remove gssproxy
fi
# END V-230559

###############################################################################
echo "Automating Rule Id V-230560"
###############################################################################
if rpm -q --quiet iprutils; then
    yum -y -q remove iprutils
fi
# END V-230560

###############################################################################
echo "Automating Rule Id V-230561"
###############################################################################
if rpm -q --quiet tuned; then
    yum -y -q remove tuned
fi
# END V-230561

###############################################################################
echo "Automating Rule Id V-237640"
###############################################################################
if rpm -q --quiet tuned; then
    yum -y -q remove krb5-server
fi
# END V-237640

###############################################################################
echo "Automating Rule Id V-237641"
###############################################################################
sed -i 's/^ALL\s*ALL\s*=.*ALL.*ALL//g' /etc/sudoers /etc/sudoers.d/*
# END V-237641

###############################################################################
echo "Automating Rule Id V-237642"
###############################################################################
echo 'Defaults !targetpw' > /etc/sudoers.d/90-azurestig-v237642.conf
echo 'Defaults !rootpw' >> /etc/sudoers.d/90-azurestig-v237642.conf
echo 'Defaults !runaspw' >> /etc/sudoers.d/90-azurestig-v237642.conf
# END V-237642

###############################################################################
echo "Automating Rule Id V-237643"
###############################################################################
echo 'Defaults timestamp_timeout=1' > /etc/sudoers.d/90-azurestig-v237643.conf
# END V-237643

###############################################################################
echo "Restarting system to apply STIG settings..."
###############################################################################
touch ./azAutomationComplete
shutdown -r +1 2>&1
