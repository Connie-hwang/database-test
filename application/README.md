# Ad Banner API

Simple Node.js + Express REST API for TAB_AD_BANNER table

## Setup & Run

### Start Server
```bash
./start.sh
```

### Stop Server
```bash
./stop.sh
```

## API Endpoints

- `GET /health` - Health check
- `GET /api/banners` - Get all banners from slave DB
- `GET /api/banners/:id` - Get banner by ID from slave DB

## Database Connection

- Connects to MariaDB slave on port 3307
- Database: testdb
- Table: TAB_AD_BANNER

## Example Usage

```bash
# Health check
curl http://localhost:3000/health

# Get all banners
curl http://localhost:3000/api/banners

# Get banner by ID
curl http://localhost:3000/api/banners/1
```