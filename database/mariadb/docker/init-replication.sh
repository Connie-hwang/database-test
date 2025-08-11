#!/bin/bash

echo "Waiting for master to be ready..."
until docker exec mariadb-master mysql -u root -prootpassword -e "SELECT 1" > /dev/null 2>&1; do
    sleep 2
done

echo "Creating replication user on master..."
docker exec mariadb-master mysql -u root -prootpassword -e "
CREATE USER IF NOT EXISTS 'replica'@'%' IDENTIFIED BY 'replica_password';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'%';
FLUSH PRIVILEGES;
"

echo "Getting master status..."
MASTER_STATUS=$(docker exec mariadb-master mysql -u root -prootpassword -e "SHOW MASTER STATUS;" | tail -n 1)
MASTER_FILE=$(echo $MASTER_STATUS | awk '{print $1}')
MASTER_POS=$(echo $MASTER_STATUS | awk '{print $2}')

echo "Master file: $MASTER_FILE, Position: $MASTER_POS"

echo "Waiting for slave to be ready..."
until docker exec mariadb-slave mysql -u root -prootpassword -e "SELECT 1" > /dev/null 2>&1; do
    sleep 2
done

echo "Configuring slave..."
docker exec mariadb-slave mysql -u root -prootpassword -e "
STOP SLAVE;
CHANGE MASTER TO 
    MASTER_HOST='mariadb-master',
    MASTER_USER='replica',
    MASTER_PASSWORD='replica_password',
    MASTER_LOG_FILE='$MASTER_FILE',
    MASTER_LOG_POS=$MASTER_POS;
START SLAVE;
"

echo "Checking slave status..."
docker exec mariadb-slave mysql -u root -prootpassword -e "SHOW SLAVE STATUS\G" | grep -E "(Slave_IO_Running|Slave_SQL_Running)"

echo "Replication setup completed!"