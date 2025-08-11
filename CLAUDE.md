# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a database testing repository featuring a MariaDB master-slave replication setup with a Node.js REST API application. The project demonstrates database replication patterns and provides a simple API interface for querying advertising banner data.

## Architecture

### Database Layer
- **MariaDB 10.6.21** master-slave replication setup using Docker
- **Master**: Port 3308, handles writes and replication source
- **Slave**: Port 3307, read-only replica for API queries
- **Replication**: Automated setup with binary logging and relay logs
- **Data**: TAB_AD_BANNER table for advertising banner management

### Application Layer  
- **Node.js 18+** Express REST API in `/application/`
- **Connection Pool**: mysql2 with connection pooling (limit: 10)
- **Database Strategy**: Reads exclusively from slave (port 3307) for load distribution
- **API Endpoints**: Health check, banner listing, and individual banner retrieval

## Common Commands

### Database Operations
```bash
# Start MariaDB master-slave containers
cd database/mariadb/docker && docker-compose up -d

# Stop database containers
cd database/mariadb/docker && docker-compose down

# Check replication status
docker exec mariadb-slave mysql -u root -prootpassword -e "SHOW SLAVE STATUS\G"

# Access master database
docker exec -it mariadb-master mysql -u root -prootpassword testdb

# Access slave database  
docker exec -it mariadb-slave mysql -u root -prootpassword testdb
```

### Application Operations
```bash
# Start API server (from application directory)
cd application && ./start.sh

# Stop API server
cd application && ./stop.sh

# Install dependencies manually
cd application && nvm use 18 && npm install

# Test API endpoints
curl http://localhost:3030/health
curl http://localhost:3030/api/banners
curl http://localhost:3030/api/banners/1
```

## Key Configuration Details

### Database Connection
- Application connects to **slave only** (port 3307) for read operations
- Connection pool configured with 10 concurrent connections
- Database: `testdb`, Table: `TAB_AD_BANNER`
- Credentials: root/rootpassword (development only)

### Replication Setup
- Master server-id: 1, Slave server-id: 2
- Binary logging enabled on master with `binlog-do-db=testdb`
- Slave configured with relay logs and read-only mode
- Replication user: replica/replica_password
- Auto-increment configured to avoid conflicts (master: odd, slave: even)

### File Structure Notes
- `database/mariadb/docker/`: Contains all Docker configuration
- `init-replication.sh`: Automated replication setup script
- `master.cnf`/`slave.cnf`: MariaDB configuration files
- Shell scripts use `nvm use 18` - Node.js 18 is required
- `node_modules/` is gitignored, will be installed automatically

## Development Notes

When making changes to the database schema, always apply changes to the master database - they will automatically replicate to the slave. The API application should never write to the database; it's designed as a read-only service querying the slave for optimal performance.

The replication setup includes an automated initialization container that configures master-slave replication on first startup. If replication breaks, restart the containers to re-initialize.