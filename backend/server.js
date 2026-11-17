const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const dotenv = require('dotenv');
const { connectDB } = require('./config/db');
const { resolveLegacyIds } = require('./middleware/resolveLegacyIds');

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Security and utility middleware
app.use(helmet());
if (!process.env.CORS_ORIGINS) {
  console.error('[CRITICAL SECURITY ERROR] CORS_ORIGINS environment variable is missing. Refusing to start.');
  process.exit(1);
}
app.use(cors({ origin: process.env.CORS_ORIGINS.split(',') }));
app.use(express.json({ limit: '50mb' }));

// Health check ML Service
const http = require('http');
const mlUrl = new URL(process.env.ML_SERVICE_URL || 'http://127.0.0.1:5005');
const req = http.request({ hostname: mlUrl.hostname, port: mlUrl.port, path: '/', method: 'GET' }, (res) => {
  console.log('[NEUROGUARD SERVER] ML Service is reachable.');
}).on('error', (err) => {
  console.error('[CRITICAL WARNING] ML service is unreachable at boot:', err.message);
});
req.end();
app.use(express.urlencoded({ extended: true, limit: '50mb' }));
app.use(resolveLegacyIds);

// Rate limiting (100 requests per 15 minutes window)
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  message: { status: 'error', message: 'Too many requests from this IP, please try again later.' }
});
app.use('/api/', apiLimiter);

// Root health check endpoint
app.get('/', (req, res) => {
  res.status(200).json({
    status: 'success',
    name: 'NeuroGuard AI Healthcare Backend Service',
    version: '2.0.0',
    timestamp: new Date().toISOString(),
  });
});

// Mount modular routes
const authRoutes = require('./routes/authRoutes');
const patientRoutes = require('./routes/patientRoutes');
const clinicalRoutes = require('./routes/clinicalRoutes');
const seizureRoutes = require('./routes/seizureRoutes');

// Global endpoint mappings (supporting root & /api/seizure aliases)
app.use('/', authRoutes);
app.use('/', patientRoutes);
app.use('/', clinicalRoutes);
app.use('/api/seizure', seizureRoutes);
app.use('/', seizureRoutes);

// Global 404 handler
app.use((req, res) => {
  res.status(404).json({ status: 'error', message: 'Requested endpoint does not exist.' });
});

// Global error handling middleware
app.use((err, req, res, next) => {
  console.error('[SERVER UNHANDLED EXCEPTION]', err);
  res.status(500).json({
    status: 'error',
    message: 'Internal server error occurred.',
  });
});

// Connect to MongoDB and start server if executed directly
if (require.main === module) {
  connectDB().then(() => {
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`[NEUROGUARD SERVER] Running on http://127.0.0.1:${PORT}`);
    });
  });
}

module.exports = app;
