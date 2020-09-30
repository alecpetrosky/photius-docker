#!/bin/bash
set -eu

##
# Global Variables
##

SRC_DIR=/opt/src
TEMP_DIR=/opt/temp
FAIL_DIR=/opt/fail
DEST_DIR=/opt/dest

export SRC_DIR TEMP_DIR FAIL_DIR DEST_DIR

##
# Define user and group credentials used by worker processes
##

group=$(grep ":$PGID:" /etc/group | cut -d: -f1)

if [[ -z "$group" ]]; then
	group='photius'
	echo "Adding group $group($PGID)"
	addgroup --system --gid $PGID $group
fi

user=$(getent passwd $PUID | cut -d: -f1)

if [[ -z "$user" ]]; then
	user='photius'
	echo "Adding user $user($PUID)"
	adduser --system --disabled-login --gid $PGID --no-create-home --home /nonexistent --shell /bin/bash --uid $PUID $user
fi

echo "Credentials used by worker processes: user $user($PUID), group $group($PGID)."

##
# Setting Up Directories
##

test -d "$SRC_DIR"  || mkdir "$SRC_DIR"
test -d "$TEMP_DIR" || mkdir "$TEMP_DIR"
test -d "$FAIL_DIR" || mkdir "$FAIL_DIR"
test -d "$DEST_DIR" || mkdir "$DEST_DIR"

chown $user:$group "$SRC_DIR"
chown $user:$group "$TEMP_DIR"
chown $user:$group "$FAIL_DIR"
chown $user:$group "$DEST_DIR"

##
# Start Main Loop
##

#exec gosu "${PUID}:${PUID}" env HOME="/opt/home" "/photius.sh"
test -f /tmp/healthcheck && rm /tmp/healthcheck
exec gosu $user:$group "/photius.sh"
