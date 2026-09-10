const { randomBytes, scrypt, timingSafeEqual, createHash } = require('node:crypto');
const { promisify } = require('node:util');
const derive = promisify(scrypt);
const options = { N: 32768, r: 8, p: 3, maxmem: 64 * 1024 * 1024 };

async function hashPassword(password, salt = randomBytes(16).toString('hex')) {
  const hash = await derive(password, salt, 64, options);
  return `scrypt-v1$${salt}$${hash.toString('hex')}`;
}

async function verifyPassword(password, encoded) {
  const [version, salt, expected] = String(encoded).split('$');
  if (version !== 'scrypt-v1' || !/^[a-f0-9]{32}$/.test(salt) ||
      !/^[a-f0-9]{128}$/.test(expected)) return false;
  const actual = await derive(password, salt, 64, options);
  return timingSafeEqual(actual, Buffer.from(expected, 'hex'));
}

function tokenHash(token) {
  return createHash('sha256').update(token).digest('hex');
}

module.exports = { hashPassword, verifyPassword, tokenHash };
