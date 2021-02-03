echo "Executing apt-get update..."
apt-get update -q
echo "Move ubuntu1804.mof to configuration store as Pending.mof..."
mv ./*.mof /etc/opt/omi/conf/dsc/configuration/Pending.mof
echo "Executing Register.py with RefreshMode = Push and ConfigurationMode = ApplyOnly..."
/opt/microsoft/dsc/Scripts/Register.py --RefreshMode Push --ConfigurationMode ApplyOnly
echo "Executing PerformRequiredConfigurationChecks.py to apply the Pending.mof configuration..."
/opt/microsoft/dsc/Scripts/PerformRequiredConfigurationChecks.py
echo "Deployment Complete..."
