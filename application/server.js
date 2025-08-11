const express = require('express');
const mysql = require('mysql2/promise');

const app = express();
const PORT = 3000;

// MariaDB Slave connection pool configuration
const poolConfig = {
  host: 'localhost',
  port: 3307,
  user: 'root',
  password: 'rootpassword',
  database: 'testdb',
  connectionLimit: 10,
  acquireTimeout: 60000,
  timeout: 60000,
  reconnect: true
};

// Create connection pool
const pool = mysql.createPool(poolConfig);

// Middleware
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Server is running' });
});

// Get all TAB_AD_BANNER records
app.get('/api/banners', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM TAB_AD_BANNER');
    
    res.json({
      success: true,
      data: rows,
      count: rows.length
    });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({
      success: false,
      error: 'Database connection failed',
      message: error.message
    });
  }
});

// Get TAB_AD_BANNER by ID
app.get('/api/banners/:id', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM TAB_AD_BANNER WHERE id = ?', [req.params.id]);
    
    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Banner not found'
      });
    }
    
    res.json({
      success: true,
      data: rows[0]
    });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({
      success: false,
      error: 'Database connection failed',
      message: error.message
    });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
  console.log(`Connected to MariaDB Slave on port 3307`);
  console.log(`Connection pool configured with limit: ${poolConfig.connectionLimit}`);
});

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('Server shutting down...');
  await pool.end();
  console.log('Connection pool closed');
  process.exit(0);
});

process.on('SIGTERM', async () => {
  console.log('Server shutting down...');
  await pool.end();
  console.log('Connection pool closed');
  process.exit(0);
});