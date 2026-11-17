const mongoose = require('mongoose');

/**
 * Connect to MongoDB database via Mongoose.
 * Validates MONGODB_URI environment variable, handles connection errors,
 * sets connection event listeners, and provides graceful disconnection logic.
 */
const connectDB = async () => {
  const mongoURI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/neuroguard_ai';

  if (!mongoURI) {
    console.error('[DATABASE CRITICAL] MONGODB_URI environment variable is not defined.');
    process.exit(1);
  }

  // Configure Mongoose options
  mongoose.set('strictQuery', true);

  // Connection event listeners
  mongoose.connection.on('connected', () => {
    console.log(`[MONGODB] Connected successfully to database: ${mongoose.connection.name}`);
  });

  mongoose.connection.on('error', (err) => {
    console.error('[MONGODB ERROR] Database connection error:', err);
  });

  mongoose.connection.on('disconnected', () => {
    console.warn('[MONGODB WARNING] Disconnected from database');
  });

  try {
    const conn = await mongoose.connect(mongoURI, {
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
    });
    return conn;
  } catch (error) {
    console.error(`[DATABASE ERROR] Failed to connect to MongoDB: ${error.message}`);
    // If running in production or strict mode, throw or handle gracefully
    if (process.env.NODE_ENV === 'test') {
      throw error;
    }
    console.warn('[DATABASE WARNING] Server continuing in degraded mode. Reconnect will be attempted on query.');
  }
};

/**
 * Disconnect cleanly from MongoDB
 */
const disconnectDB = async () => {
  try {
    await mongoose.disconnect();
    console.log('[MONGODB] Connection closed cleanly');
  } catch (error) {
    console.error('[MONGODB ERROR] Error during disconnection:', error);
  }
};

module.exports = { connectDB, disconnectDB };
