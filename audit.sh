#### This is the audit script for MYSQL provisioning 
#!/bin/bash
#
#### $1 - username
#### $2 - password
#### $3 - server list with \n separators 'server01\nserver01\nserver03'
#### $4 - 1 to truncate the present tables 
####  (should be done on first run, if audit 
####   runs are partial, always on otherwise)

#### Uncomment below for debug
set -o xtrace

#### Possible known mysql locations
# /usr/bin/mysql
# /opt/mysql/bin/mysql
# /usr/local/mysql/bin/mysql
if [[ -e /usr/bin/mysql ]]
then
MYSQL_PATH=/usr/bin
else
if [[ -e /opt/mysql/bin/mysql ]]
then
MYSQL_PATH=/opt/mysql/bin
else 
if [[ -e /usr/local/mysql/bin/mysql ]]
then
MYSQL_PATH=/usr/local/mysql/bin
else
#### default to local directory otherwise
#### and assume someone has intelligence
#### besides the script itself
MYSQL_PATH=.
fi
fi
fi

if [[ $4 == 1  ]]
then
$MYSQL_PATH/mysql -u $1 --password=$2 --host=PROVISIONING_BOX.local --port=3306 --protocol=tcp -A provisioning -e "truncate provisioning.db;truncate provisioning.db_audit;truncate provisioning.user;truncate provisioning.user_audit;";
fi

port=3306

while read v_table
do
previous=''

while read v_server
do
if  [[ $previous ==  $v_server ]]
then
port=`expr $port + 1`
else
port=3306
fi	
previous="$v_server"
echo "$v_server $v_table $port"


$MYSQL_PATH/mysqldump -u $1 --password=$2 --single-transaction mysql $v_table --host=$v_server.SERVER_SUFFIX.local --port=$port --protocol=tcp | $MYSQL_PATH/mysql -u $1 --password=$2 --host=PROVISIONING_BOX.local --port=3306 --protocol=tcp -A provisioning


$MYSQL_PATH/mysql -u $1 --password=$2 --host=PROVISIONING_BOX.local --port=3306 --protocol=tcp -A provisioning -e "alter table ${v_table} add column Server char(50) COLLATE utf8_bin NOT NULL DEFAULT '';insert into ${v_table}_audit select * from ${v_table};update ${v_table}_audit set Server='${v_server}_${port}' where Server='';alter table ${v_table} drop column Server;"

done < <(echo -e "$3")
done < <(echo -e "db\nuser")
