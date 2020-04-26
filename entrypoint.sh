#!/bin/bash

set -eu

##
# Global Variables
##

SRC_DIR=/opt/src
TEMP_DIR=/opt/temp
DEST_DIR=/opt/dest

export SRC_DIR TEMP_DIR DEST_DIR

##
# Display Version
##

version=$(cat VERSION)
echo "Version: $version"

##
# Define user and group credentials used by worker processes
##

group=$(grep ":$PGID:" /etc/group | cut -d: -f1)

if [[ -z "$group" ]]; then
	group='worker'
	echo "Adding group $group($PGID)"
	addgroup --system --gid $PGID $group
fi

user=$(getent passwd $PUID | cut -d: -f1)

if [[ -z "$user" ]]; then
	user='worker'
	echo "Adding user $user($PUID)"
	adduser --system --disabled-login --gid $PGID --no-create-home --home /nonexistent --shell /bin/bash --uid $PUID $user
fi

echo "Credentials used by worker processes: user $user($PUID), group $group($PGID)."

##
# Setting Up Directories
##

test -f /tmp/healthcheck && chown $user:$group /tmp/healthcheck
chown $user:$group "$SRC_DIR"
chown $user:$group "$TEMP_DIR"
chown $user:$group "$DEST_DIR"

##
# Timezone
##

echo "Current timezone: $TZ"

##
# Start Main Loop
##

#exec gosu "${PUID}:${PUID}" env HOME="/opt/home" "/usr/local/bin/photius.sh"
exec gosu $user:$group "/usr/local/bin/photius.sh"
