echo "Move (OS Specific) .mof to configuration store as Pending.mof..."
mv ./*.mof /etc/opt/omi/conf/dsc/configuration/Pending.mof
echo "Execute Register.py --RefreshMode Push --ConfigurationMode ApplyOnly..."
/opt/microsoft/dsc/Scripts/Register.py --RefreshMode Push --ConfigurationMode ApplyOnly
echo "Execute PerformRequiredConfigurationChecks.py to apply the Pending.mof configuration..."
/opt/microsoft/dsc/Scripts/PerformRequiredConfigurationChecks.py
echo "Deployment Complete..."
