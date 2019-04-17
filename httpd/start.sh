#!/bin/bash
set -e

# Note: we don't just use "apache2ctl" here because it itself is just a shell-script wrapper around apache2 which provides extra functionality like "apache2ctl start" for launching apache2 in the background.
# (also, when run as "apache2ctl <apache args>", it does not use "exec", which leaves an undesirable resident shell process)

: "${APACHE_CONFDIR:=/etc/apache2}"
: "${APACHE_ENVVARS:=$APACHE_CONFDIR/envvars}"
if test -f "$APACHE_ENVVARS"; then
	. "$APACHE_ENVVARS"
fi

# Apache gets grumpy about PID files pre-existing
: "${APACHE_RUN_DIR:=/var/run/apache2}"
: "${APACHE_PID_FILE:=$APACHE_RUN_DIR/apache2.pid}"
rm -f "$APACHE_PID_FILE"

# create missing directories
# (especially APACHE_RUN_DIR, APACHE_LOCK_DIR, and APACHE_LOG_DIR)
for e in "${!APACHE_@}"; do
	if [[ "$e" == *_DIR ]] && [[ "${!e}" == /* ]]; then
		# handle "/var/lock" being a symlink to "/run/lock", but "/run/lock" not existing beforehand, so "/var/lock/something" fails to mkdir
		#   mkdir: cannot create directory '/var/lock': File exists
		dir="${!e}"
		while [ "$dir" != "$(dirname "$dir")" ]; do
			dir="$(dirname "$dir")"
			if [ -d "$dir" ]; then
				break
			fi
			absDir="$(readlink -f "$dir" 2>/dev/null || :)"
			if [ -n "$absDir" ]; then
				mkdir -p "$absDir"
			fi
		done

		mkdir -p "${!e}"
	fi
done

{
    echo "<IfModule mpm_prefork_module>"
    echo "  StartServers        $BX_STARTSERVERS"
    echo "  MinSpareServers     $BX_MINSPARESERVERS"
    echo "  MaxSpareServers     $BX_MAXSPARESERVERS"
    echo "  MaxRequestWorkers   $BX_MAXREQUESTWORKERS"
    echo "  MaxRequestsPerChild $BX_MAXREQUESTSPERCHILD"
    echo "</IfModule>"
} > $APACHE_CONFDIR/mods-available/mpm_prefork.conf

if [ -n "$BX_KEEPALIVETIMEOUT" ]; then
    sed -ri \
        -e 's!^(\s*KeepAlive)\s+\S+!\1 On!g' \
        -e "s!^(\s*KeepAliveTimeout)\s+\S+!\1 $BX_KEEPALIVETIMEOUT!g" \
        $APACHE_CONFDIR/apache2.conf
fi

if [ -n "$BX_REMOTEIP" ]; then        
    {
        echo "RemoteIPHeader X-Real-IP" 
        echo "RemoteIPInternalProxy $BX_REMOTEIP" 
    } > $APACHE_CONFDIR/mods-available/remoteip.conf
    a2enmod remoteip
fi

if [ "$BX_USE_SSL" == "yes" ]; then
    a2enmod ssl
fi

for HOST in $BX_HOSTS; do
    mkdir -p /tmp/php_sessions/$HOST /tmp/php_upload/$HOST
    chown www-data:www-data /tmp/php_sessions/$HOST /tmp/php_upload/$HOST
    chmod 770 /tmp/php_sessions/$HOST /tmp/php_upload/$HOST

    CONF="$APACHE_CONFDIR/sites-available/$HOST.conf"
    cp $APACHE_CONFDIR/virtual_host.tmpl.conf $CONF
    sed -i "s/#SERVER_NAME#/$HOST/g" $CONF
    sed -i "s/#SERVER_DIR#/$HOST/g" $CONF
    a2ensite $HOST

    if [ "$BX_USE_SSL" == "yes" ]; then
        CONF_SSL="$APACHE_CONFDIR/sites-available/$HOST-ssl.conf"
        cp $APACHE_CONFDIR/virtual_host-ssl.tmpl.conf $CONF_SSL
        sed -i "s/#SERVER_NAME#/$HOST/g" $CONF_SSL
        sed -i "s/#SERVER_DIR#/$HOST/g" $CONF_SSL
        a2ensite $HOST-ssl
    fi
done

exec apache2 -DFOREGROUND "$@"