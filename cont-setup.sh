#!/bin/bash

# Get prefix rather than hard-code it
export MYSQL_CONFIG_FILE=$(for f in `scl enable mariadb55 -- my_print_defaults --help --verbose | grep --after=1 '^Default options' | tail -n 1 | grep -o '.*opt[^ ]*my.cnf' ` ; do echo "$f" ; done | grep -v mysql/my.cnf)

# We want to offer to use standard paths /etc/my.cnf and /etc/my.cnf.d
rm -rf /etc/my.cnf /etc/my.cnf.d
ln -s ${MYSQL_CONFIG_FILE} /etc/my.cnf
ln -s ${MYSQL_CONFIG_FILE}.d /etc/my.cnf.d

