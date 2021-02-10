echo "Move (OS Specific) .mof to configuration store as Pending.mof..."
mv ./*.mof /etc/opt/omi/conf/dsc/configuration/Pending.mof
echo "Execute Register.py --RefreshMode Push --ConfigurationMode ApplyOnly..."
/opt/microsoft/dsc/Scripts/Register.py --RefreshMode Push --ConfigurationMode ApplyOnly
echo "Execute PerformRequiredConfigurationChecks.py to apply the Pending.mof configuration..."
/opt/microsoft/dsc/Scripts/PerformRequiredConfigurationChecks.py
echo "Backing up password-auth, postlogin and system-auth files..."
cp --force /etc/pam.d/system-auth /etc/pam.d/backup.system-auth
cp --force /etc/pam.d/password-auth /etc/pam.d/backup.password-auth
cp --force /etc/pam.d/postlogin /etc/pam.d/backup.postlogin
echo "Removing 'nullok' from both password-auth and system-auth files..."
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
echo "Removing 'NOPASSWD' tag from all files in /etc/sudors.d/"
grep -r -l -i nopasswd /etc/sudoers.d/* | xargs sed -i 's/\s*NOPASSWD://g'
echo "Rebooting to apply STIG settings..."
shutdown -r +1 2>&1
