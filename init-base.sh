function usage() {
	if [ $# == 2 ]; then
		echo "error: $1"
	fi
	echo "You may optionally specify following environment variables:"
	echo "  \$MYSQL_ROOT_PASSWORD (regex: '$mysql_password_regex')"
	exit 1
}

function initdb_base() {

        echo "Initializing datadir for root"

	if [ -v MYSQL_ROOT_PASSWORD ]; then
		[[ "$MYSQL_ROOT_PASSWORD" =~ $mysql_password_regex ]] || usage "Invalid root password"
	fi

	mysqladmin $admin_flags -f drop test

	if [ -v MYSQL_ROOT_PASSWORD ]; then
		mysql $mysql_flags <<-EOSQL
			GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
		EOSQL
	fi
}

initdb_base
unset MYSQL_ROOT_PASSWORD
