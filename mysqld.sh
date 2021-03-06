# Data directory where MySQL database files live. The data subdirectory is here
# because .bashrc and my.cnf both live in /var/lib/mysql/ and we don't want a
# volume to override it.
export MYSQL_DATADIR=/var/lib/mysql

# Configuration settings.
export MYSQL_DEFAULTS_FILE=/etc/my.cnf

# Get prefix rather than hard-code it
export MYSQL_PREFIX=$(which mysqld_safe|sed -e 's|/bin/mysqld_safe$||')

# Be paranoid and stricter than we should be.
# https://dev.mysql.com/doc/refman/5.5/en/identifiers.html
export mysql_identifier_regex='^[a-zA-Z0-9_]+$'
export mysql_password_regex='^[a-zA-Z0-9_~!@#$%^&*()-=<>,.?;:|]+$'


# Poll until MySQL responds to our ping.
function wait_for_mysql() {
	pid=$1 ; shift

	while [ true ]; do
		if [ -d "/proc/$pid" ]; then
			mysqladmin --socket=/tmp/mysql.sock ping &>/dev/null && return 0
		else
			return 1
		fi
		echo "Waiting for MySQL to start"
		sleep 1
	done
}


function initialize_database() {

	# Set common flags.
	mysql_flags="-u root --socket=/tmp/mysql.sock"
	admin_flags="--defaults-file=$MYSQL_DEFAULTS_FILE $mysql_flags"

	echo 'Running mysql_install_db'
	mysql_install_db --datadir=$MYSQL_DATADIR

	# Now start mysqld and add appropriate users.
	echo 'Starting mysqld to create users'
	${MYSQL_PREFIX}/libexec/mysqld \
		--defaults-file=$MYSQL_DEFAULTS_FILE \
		--skip-networking --socket=/tmp/mysql.sock &
	mysql_pid=$!
	wait_for_mysql $mysql_pid

	echo "Reading scripts that may adjust initialization"
        for i in /usr/local/libexec/cont-mysqld-init.d/*.sh; do
            if [ -r "$i" ]; then
		echo "- sourcing $i"
                . "$i"
            fi
        done

	mysqladmin $admin_flags flush-privileges shutdown
}

if [ "$1" = "mysqld" ]; then

	shift

	if [ ! -d "$MYSQL_DATADIR/mysql" ]; then
		initialize_database
	fi

	exec ${MYSQL_PREFIX}/libexec/mysqld \
		--defaults-file=$MYSQL_DEFAULTS_FILE \
		"$@" 2>&1
fi

