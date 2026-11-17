const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET || JWT_SECRET.length < 32) {
  console.error('[CRITICAL SECURITY ERROR] JWT_SECRET is either missing or too short (must be >= 32 characters). Server refusing to start.');
  process.exit(1);
}

/**
 * Verify JWT token from Authorization header or query parameter
 */
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = (authHeader && authHeader.startsWith('Bearer ')) 
    ? authHeader.split(' ')[1] 
    : null;

  if (!token) {
    return res.status(401).json({ status: 'error', message: 'Authentication required. Token missing.' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(403).json({ status: 'error', message: 'Invalid or expired authentication token.' });
  }
};

/**
 * Generate JWT token for user
 */
const generateToken = (user) => {
  return jwt.sign(
    { id: user._id || user.id, email: user.email, role: user.role, name: user.name },
    JWT_SECRET,
    { expiresIn: '24h' }
  );
};

/**
 * Enforce role-based access control (RBAC)
 */
const requireRole = (role) => {
  return (req, res, next) => {
    if (!req.user || req.user.role !== role) {
      return res.status(403).json({ status: 'error', message: `Access denied. Requires ${role} role.` });
    }
    next();
  };
};

module.exports = {
  authenticateToken,
  generateToken,
  requireRole,
  JWT_SECRET,
};
