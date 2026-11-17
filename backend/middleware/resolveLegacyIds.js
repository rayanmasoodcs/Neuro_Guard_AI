const { resolveUserId } = require('../utils/userId');

/**
 * Keeps the existing Flutter API (numeric user IDs) compatible with MongoDB
 * ObjectId references. New clients may send ObjectIds directly.
 */
async function resolveLegacyIds(req, res, next) {
  try {
    const bodyKeys = ['user_id', 'userId', 'doctor_id', 'doctorId', 'patient_user_id'];
    for (const key of bodyKeys) {
      if (req.body && req.body[key] !== undefined) {
        const resolved = await resolveUserId(req.body[key]);
        if (resolved) req.body[key] = resolved.toString();
      }
    }

    const queryKeys = ['user_id', 'userId', 'doctor_id', 'doctorId', 'patient_user_id'];
    for (const key of queryKeys) {
      if (req.query && req.query[key] !== undefined) {
        const resolved = await resolveUserId(req.query[key]);
        if (resolved) req.query[key] = resolved.toString();
      }
    }

    for (const key of Object.keys(req.params || {})) {
      const value = req.params[key];
      if (/^\d+$/.test(String(value))) {
        const resolved = await resolveUserId(value);
        if (resolved) req.params[key] = resolved.toString();
      }
    }

    next();
  } catch (error) {
    console.error('[LEGACY ID RESOLUTION ERROR]', error);
    next();
  }
}

module.exports = { resolveLegacyIds };
