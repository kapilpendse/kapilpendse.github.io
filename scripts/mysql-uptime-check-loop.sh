#!/bin/sh

# Script that repeatedly connects to and queries a MySQL database, and prints out the results to STDOUT

DB_HOST=$1
DB_USER=$2
DB_PASSWORD=$3

# Keep checking MySQL server status (uptime) once every second
while true; do
	date
	mysql -u $DB_USER -p$DB_PASSWORD -h $DB_HOST --connect-timeout=2 --reconnect -e 'SHOW STATUS LIKE "Uptime";'
	sleep 1
done
