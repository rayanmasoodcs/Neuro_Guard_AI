const { z } = require('zod');

const validateRequest = (schema) => (req, res, next) => {
  try {
    req.body = schema.parse(req.body);
    next();
  } catch (err) {
    if (err instanceof z.ZodError) {
      return res.status(400).json({ status: 'error', message: 'Validation failed', errors: err.errors });
    }
    next(err);
  }
};

const storeSensorReadingSchema = z.object({
  userId: z.string(),
  deviceId: z.string().optional(),
  deviceName: z.string().optional(),
  heartRate: z.number().optional(),
  bodyTemperature: z.number().optional(),
  accelerometer: z.object({ x: z.number(), y: z.number(), z: z.number() }).optional(),
  gyroscope: z.object({ x: z.number(), y: z.number(), z: z.number() }).optional(),
  fallDetection: z.boolean().optional(),
  eegReading: z.any().optional(),
}).strict();

const predictSeizureRealtimeSchema = z.object({
  userId: z.string(),
  sensor_data: z.object({
    heartRate: z.number().optional(),
    fallDetection: z.boolean().optional(),
  }).optional(),
  feature_vector: z.array(z.number()).length(16).optional(),
}).strict();

const storeAlertSchema = z.object({
  userId: z.string(),
  patientId: z.string().optional(),
  alertType: z.string().optional(),
  seizureType: z.string().optional(),
  severity: z.string().optional(),
  riskLevel: z.string().optional(),
  alertMessage: z.string().optional(),
  confidenceScore: z.number().optional(),
}).strict();

module.exports = {
  validateRequest,
  storeSensorReadingSchema,
  predictSeizureRealtimeSchema,
  storeAlertSchema,
};
