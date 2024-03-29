#! /bin/sh
chown -R $PUID:$PGID /config /opt/ombi

GROUPNAME=$(getent group $PGID | cut -d: -f1)
USERNAME=$(getent passwd $PUID | cut -d: -f1)

if [ ! $GROUPNAME ]
then
        addgroup -g $PGID ombi
        GROUPNAME=ombi
fi

if [ ! $USERNAME ]
then
        adduser -G $GROUPNAME -u $PUID -D ombi
        USERNAME=ombi
fi

su $USERNAME -c 'cd /opt/ombi && ./Ombi --storage "/config"'
