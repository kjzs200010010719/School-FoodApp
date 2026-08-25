const cors = require('cors');
const express = require('express');
const routes = require('./routes');

function createApp() {
  const app = express();

  app.use(cors());
  app.use(express.json());
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

    return res.status(err.statusCode || 500).json({
      message: err.message || '伺服器發生錯誤',
    });
  });

  return app;
}

module.exports = createApp;
