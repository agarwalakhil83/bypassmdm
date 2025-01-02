#!/bin/bash

# Define colors for output
RED='\033[0;31m'
GRN='\033[0;32m'
BLU='\033[0;34m'
NC='\033[0m'

echo -e "${GRN}Starting Bypass on Recovery${NC}"

# Check and rename the data volume if needed
if [ -d "/Volumes/Macintosh HD - Data" ]; then
    diskutil rename "Macintosh HD - Data" "Data"
    echo -e "${GRN}Renamed 'Macintosh HD - Data' to 'Data'${NC}"
else
    echo -e "${RED}'Macintosh HD - Data' volume not found.${NC}"
fi

# Create a new user
echo -e "${GRN}Creating a new user${NC}"
echo -e "${BLU}Press Enter to use the default values for each prompt.${NC}"

# Get real name
echo -e "Enter real name (default: MAC):"
read realName
realName="${realName:=MAC}"

# Get username
echo -e "Enter username (no spaces or special characters, default: MAC):"
read username
username="${username:=MAC}"

# Get password
echo -e "Enter password (default: 1234):"
read passw
passw="${passw:=1234}"

dscl_path='/Volumes/Data/private/var/db/dslocal/nodes/Default'

# Create the user with the specified details
echo -e "${GRN}Creating user account...${NC}"
dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username"
dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UserShell "/bin/zsh"
dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" RealName "$realName"
dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UniqueID "501"
dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" PrimaryGroupID "20"
mkdir "/Volumes/Data/Users/$username"
dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" NFSHomeDirectory "/Users/$username"
dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/$username" "$passw"
dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership $username

# Block specific Apple MDM endpoints
echo -e "${GRN}Blocking Apple MDM endpoints...${NC}"
echo "0.0.0.0 deviceenrollment.apple.com" >>/Volumes/Macintosh\ HD/etc/hosts
echo "0.0.0.0 mdmenrollment.apple.com" >>/Volumes/Macintosh\ HD/etc/hosts
echo "0.0.0.0 iprofiles.apple.com" >>/Volumes/Macintosh\ HD/etc/hosts

# Modify configuration profiles
echo -e "${GRN}Modifying configuration profiles...${NC}"
touch /Volumes/Data/private/var/db/.AppleSetupDone
rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound

echo -e "${GRN}Bypass on Recovery completed successfully.${NC}"
