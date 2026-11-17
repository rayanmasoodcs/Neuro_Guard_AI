const request = require('supertest');
const app = require('../server');

describe('NeuroGuard AI Express & MongoDB API Verification Suite', () => {

  let testToken;
  let testUserId;
  let testPatientId;

  it('GET / - should return 200 health check status', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toEqual(200);
    expect(res.body.status).toEqual('success');
    expect(res.body.name).toContain('NeuroGuard');
  });

  it('POST /signup - should register a new user successfully', async () => {
    const randomEmail = `testuser_${Date.now()}@neuroguard.ai`;
    const res = await request(app).post('/signup').send({
      name: 'Test Patient',
      email: randomEmail,
      password: 'SecurePassword123!',
      role: 'patient',
      age: 28,
      gender: 'Female',
    });

    expect(res.statusCode).toEqual(201);
    expect(res.body.status).toEqual('success');
    expect(res.body).toHaveProperty('token');
    expect(res.body.user).toHaveProperty('id');

    testToken = res.body.token;
    testUserId = res.body.user.id;
  });

  it('POST /login - should authenticate valid user', async () => {
    const email = `doctor_${Date.now()}@neuroguard.ai`;
    await request(app).post('/signup').send({
      name: 'Dr. Smith',
      email,
      password: 'DoctorPassword123!',
      role: 'doctor',
    });

    const res = await request(app).post('/login').send({
      email,
      password: 'DoctorPassword123!',
    });

    expect(res.statusCode).toEqual(200);
    expect(res.body.status).toEqual('success');
    expect(res.body.user.role).toEqual('doctor');
  });

  it('POST /update_or_add_patient - should create a patient chart record', async () => {
    const res = await request(app).post('/update_or_add_patient').send({
      name: 'John Doe',
      age: 34,
      gender: 'Male',
      medical_condition: 'Refractory Epilepsy',
      email: 'johndoe@example.com',
    });

    expect(res.statusCode).toEqual(201);
    expect(res.body.status).toEqual('success');
    expect(res.body).toHaveProperty('patient_id');
    testPatientId = res.body.patient_id;
  });

  it('GET /get_all_patients - should return patient list', async () => {
    const res = await request(app).get('/get_all_patients');
    expect(res.statusCode).toEqual(200);
    expect(res.body.status).toEqual('success');
    expect(Array.isArray(res.body.patients)).toBeTruthy();
  });

  it('POST /add_medication - should add medication to user profile', async () => {
    const res = await request(app).post('/add_medication').send({
      user_id: testUserId,
      medicine_name: 'Levetiracetam',
      dose: '500mg',
      frequency: 'twice daily',
      timing: '08:00 AM, 08:00 PM',
    });

    expect(res.statusCode).toEqual(201);
    expect(res.body.status).toEqual('success');
  });

  it('POST /api/seizure/store_sensor_reading - should log wearable telemetry', async () => {
    const res = await request(app).post('/api/seizure/store_sensor_reading').send({
      user_id: testUserId,
      heart_rate: 85,
      body_temperature: 36.6,
      fall_detection: false,
    });

    expect(res.statusCode).toEqual(201);
    expect(res.body.status).toEqual('success');
    expect(res.body).toHaveProperty('reading_id');
  });

});
