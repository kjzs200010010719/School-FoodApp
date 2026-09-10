const express = require('express');
const run = (handler) => (req, res, next) => Promise.resolve(handler(req, res)).catch(next);
const invalid = () => Object.assign(new Error('商品查詢條件格式不正確'), { statusCode: 400 });
function id(value, zero = false) {
  if (typeof value !== 'string' || !(zero ? /^(0|[1-9][0-9]{0,19})$/ : /^[1-9][0-9]{0,19}$/).test(value) ||
    BigInt(value) > 18446744073709551615n) throw invalid();
  return value;
}
function filters(query) {
  const result = { after: id(query.after ?? '0', true), tags: [] };
  for (const [key, length] of [['keyword', 120], ['category', 40], ['brand', 60]]) {
    if (query[key] !== undefined) {
      if (typeof query[key] !== 'string' || query[key].length > length) throw invalid();
      result[key] = query[key].trim();
    }
  }
  if (query.storeId !== undefined) result.storeId = id(query.storeId);
  for (const key of ['maxPrice', 'maxDistanceMeters']) {
    if (query[key] !== undefined) {
      if (typeof query[key] !== 'string' || !/^\d{1,7}$/.test(query[key]) || Number(query[key]) > 1000000) throw invalid();
      result[key] = Number(query[key]);
    }
  }
  for (const key of ['expiringOnly', 'openToday']) {
    if (query[key] !== undefined && !['true', 'false'].includes(query[key])) throw invalid();
    result[key] = query[key] === 'true';
  }
  if (query.tags !== undefined) {
    if (typeof query.tags !== 'string' || query.tags.length > 819) throw invalid();
    result.tags = [...new Set(query.tags.split(',').map((tag) => tag.trim()).filter(Boolean))];
    if (result.tags.length > 20 || result.tags.some((tag) => tag.length > 40)) throw invalid();
  }
  return result;
}
function catalogRoutes(repository) {
  const router = express.Router();
  router.get('/foods', run(async (req, res) => res.json(await repository.list(filters(req.query)))));
  for (const [path, method] of [['foods', 'food'], ['stores', 'store']]) {
    router.get(`/${path}/:id`, run(async (req, res) => {
      const item = await repository[method](id(req.params.id));
      if (!item) return res.status(404).json({ message: '找不到已上架的餐點或店家' });
      res.json(item);
    }));
  }
  // Do not mix mock food IDs into the real catalogue; App ranking uses the same loaded foods.
  router.get('/recommendations', (req, res) => res.status(501).json({ message: '雲端推薦排序尚未開放' }));
  return router;
}
module.exports = catalogRoutes;
