const assert = require('node:assert/strict');
const { after, before, test } = require('node:test');
const createApp = require('../src/app');

let server;
let baseUrl;

before(async () => {
  const app = createApp();
  server = app.listen(0);

  await new Promise((resolve) => {
    server.once('listening', resolve);
  });

  const address = server.address();
  baseUrl = `http://127.0.0.1:${address.port}`;
});

after(async () => {
  await new Promise((resolve, reject) => {
    server.close((error) => {
      if (error) {
        reject(error);
      } else {
        resolve();
      }
    });
  });
});

test('health endpoint returns ok', async () => {
  const response = await fetch(`${baseUrl}/api/health`);
  const body = await response.json();

  assert.equal(response.status, 200);
  assert.equal(body.status, 'ok');
});

test('foods endpoint supports keyword search', async () => {
  const response = await fetch(
    `${baseUrl}/api/foods?keyword=${encodeURIComponent('雞')}`,
  );
  const body = await response.json();

  assert.equal(response.status, 200);
  assert.ok(body.total >= 1);
  assert.ok(body.items.some((food) => food.name.includes('雞')));
});

test('favorite endpoints can add and list foods', async () => {
  const addResponse = await fetch(`${baseUrl}/api/me/favorites/food-001`, {
    method: 'POST',
  });
  const addBody = await addResponse.json();

  assert.equal(addResponse.status, 201);
  assert.equal(addBody.isFavorite, true);

  const listResponse = await fetch(`${baseUrl}/api/me/favorites`);
  const listBody = await listResponse.json();

  assert.equal(listResponse.status, 200);
  assert.ok(listBody.items.some((food) => food.id === 'food-001'));
});
