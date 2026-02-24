const axios = require('axios');

const BASE_URL = 'http://localhost:8787/api/auth';
const TEST_USER = {
      username: 'testuser',
      email: `test${Date.now()}@example.com`,
      password: 'password123'
};

const verifyAuth = async () => {
      try {
            console.log('--- Starting Authentication Verification ---');

            // 1. Register
            console.log(`\n1. Registering user: ${TEST_USER.email}`);
            const registerRes = await axios.post(`${BASE_URL}/register`, TEST_USER);
            console.log('✅ Register Success:', registerRes.data);

            // 2. Login
            console.log(`\n2. Logging in user: ${TEST_USER.email}`);
            const loginRes = await axios.post(`${BASE_URL}/login`, {
                  email: TEST_USER.email,
                  password: TEST_USER.password
            });
            console.log('✅ Login Success. Token received.');
            const token = loginRes.data.token;

            // 3. Access Protected Route (Valid Token)
            console.log('\n3. Accessing Protected Route (with token)');
            const profileRes = await axios.get(`${BASE_URL}/profile`, {
                  headers: { Authorization: `Bearer ${token}` }
            });
            console.log('✅ Protected Route Success:', profileRes.data);

            // 4. Access Protected Route (No Token)
            console.log('\n4. Accessing Protected Route (without token)');
            try {
                  await axios.get(`${BASE_URL}/profile`);
            } catch (error) {
                  if (error.response && error.response.status === 401) {
                        console.log('✅ Expected 401 Unauthorized received.');
                  } else {
                        console.error('❌ Unexpected error:', error.message);
                  }
            }

            // 5. Access Protected Route (Invalid Token)
            console.log('\n5. Accessing Protected Route (invalid token)');
            try {
                  await axios.get(`${BASE_URL}/profile`, {
                        headers: { Authorization: `Bearer invalidtoken` }
                  });
            } catch (error) {
                  if (error.response && error.response.status === 403) {
                        console.log('✅ Expected 403 Forbidden received.');
                  } else {
                        console.error('❌ Unexpected error:', error.message);
                        if (error.response) console.error('Status:', error.response.status);
                  }
            }

            console.log('\n--- Verification Complete ---');

      } catch (error) {
            console.error('❌ Verification Failed:', error.message);
            if (error.response) {
                  console.error('Response Data:', error.response.data);
                  console.error('Response Status:', error.response.status);
            }
      }
};

verifyAuth();
