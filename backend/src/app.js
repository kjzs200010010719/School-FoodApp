const cors = require('cors');
const express = require('express');
const routes = require('./routes');
const authRoutes = require('./auth/routes');
const UserRepository = require('./auth/user_repository');
const { createDatabasePool } = require('./config/database');

function createApp({ userRepository, enablePrototypeRoutes = false } = {}) {
  const app = express();

  app.use(cors());
  app.use(express.json({ limit: '16kb' }));
  app.use('/api', authRoutes(userRepository || new UserRepository(createDatabasePool())));
  if (!enablePrototypeRoutes) {
    app.use('/api', (req, res, next) => {
      if (req.path.startsWith('/me') || req.path.startsWith('/merchant') ||
          req.path.startsWith('/auth') || req.method !== 'GET') {
        return res.status(501).json({ message: '此功能尚未開放雲端服務' });
      }
      next();
    });
  }
  app.use('/api', routes);

  app.use((req, res) => {
    res.status(404).json({
      message: '找不到此 API 路徑',
      path: req.path,
    });
  });

  app.use((err, req, res, next) => {
    if (res.headersSent) {
      return next(err);
    }

    const status = err.statusCode || err.status || 500;
    return res.status(status).json({
      message: status >= 500 ? '伺服器暫時無法處理，請稍後再試' :
        (err.type === 'entity.parse.failed' ? 'JSON 格式不正確' : err.message),
    });
  });

  return app;
}

module.exports = createApp;
