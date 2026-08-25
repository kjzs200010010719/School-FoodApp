const express = require('express');
const { demoUser, foods, stores } = require('../data/mockData');

const router = express.Router();
const favorites = new Set();
const history = [];
const searchLogs = [];
const recommendationFeedback = [];

function withStore(food) {
  const store = stores.find((item) => item.id === food.storeId);

  return {
    ...food,
    storeName: store?.name || '',
    storeAddress: store?.address || '',
    businessHours: store?.businessHours || '',
    contactPhone: store?.contactPhone || '',
    isFavorite: favorites.has(food.id),
  };
}

function filterFoods(query) {
  const keyword = String(query.keyword || '').trim().toLowerCase();
  const category = String(query.category || '').trim();
  const tags = String(query.tags || '')
    .split(',')
    .map((tag) => tag.trim())
    .filter(Boolean);
  const maxPrice = query.maxPrice ? Number(query.maxPrice) : null;
  const maxDistanceMeters = query.maxDistanceMeters
    ? Number(query.maxDistanceMeters)
    : null;
  const expiringOnly = query.expiringOnly === 'true';

  return foods.filter((food) => {
    const store = stores.find((item) => item.id === food.storeId);
    const searchableText = [
      food.name,
      food.category,
      store?.name,
      ...food.tags,
      ...food.ingredients,
    ]
      .join(' ')
      .toLowerCase();

    if (keyword && !searchableText.includes(keyword)) {
      return false;
    }

    if (category && food.category !== category) {
      return false;
    }

    if (tags.length > 0 && !tags.some((tag) => food.tags.includes(tag))) {
      return false;
    }

    if (maxPrice !== null && food.price > maxPrice) {
      return false;
    }

    if (maxDistanceMeters !== null && food.distanceMeters > maxDistanceMeters) {
      return false;
    }

    if (expiringOnly && !food.isExpiringSoon) {
      return false;
    }

    return true;
  });
}

function scoreFood(food) {
  const preferenceScore = food.tags.some((tag) =>
    demoUser.preferences.preferredTags.includes(tag),
  )
    ? 0.9
    : 0.45;
  const distanceScore = Math.max(0, 1 - food.distanceMeters / 1200);
  const budgetScore = food.price <= demoUser.preferences.budgetMax ? 1 : 0.35;
  const ecoPriorityScore = demoUser.preferences.wasteReductionEnabled
    ? food.ecoPriorityScore
    : 0;
  const finalScore =
    preferenceScore * 0.35 +
    distanceScore * 0.2 +
    budgetScore * 0.2 +
    ecoPriorityScore * 0.25;

  return {
    preferenceScore: Number(preferenceScore.toFixed(3)),
    distanceScore: Number(distanceScore.toFixed(3)),
    budgetScore: Number(budgetScore.toFixed(3)),
    ecoPriorityScore: Number(ecoPriorityScore.toFixed(3)),
    finalScore: Number(finalScore.toFixed(3)),
  };
}

router.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: '膳解人意 API',
  });
});

router.post('/auth/register', (req, res) => {
  res.status(201).json({
    message: '目前為本機原型，先回傳測試會員資料',
    user: demoUser,
  });
});

router.post('/auth/login', (req, res) => {
  res.json({
    message: '登入成功',
    user: demoUser,
    token: 'local-demo-token',
  });
});

router.post('/auth/logout', (req, res) => {
  res.json({
    message: '登出成功',
  });
});

router.get('/me', (req, res) => {
  res.json(demoUser);
});

router.put('/me', (req, res) => {
  Object.assign(demoUser, {
    name: req.body.name ?? demoUser.name,
    phone: req.body.phone ?? demoUser.phone,
  });

  res.json(demoUser);
});

router.get('/me/preferences', (req, res) => {
  res.json(demoUser.preferences);
});

router.put('/me/preferences', (req, res) => {
  demoUser.preferences = {
    ...demoUser.preferences,
    ...req.body,
  };

  res.json(demoUser.preferences);
});

router.get('/foods', (req, res) => {
  const results = filterFoods(req.query).map(withStore);

  res.json({
    items: results,
    total: results.length,
  });
});

router.get('/foods/:foodId', (req, res) => {
  const food = foods.find((item) => item.id === req.params.foodId);

  if (!food) {
    return res.status(404).json({ message: '找不到餐點' });
  }

  return res.json(withStore(food));
});

router.get('/stores/:storeId', (req, res) => {
  const store = stores.find((item) => item.id === req.params.storeId);

  if (!store) {
    return res.status(404).json({ message: '找不到店家' });
  }

  return res.json(store);
});

router.get('/recommendations', (req, res) => {
  const items = foods
    .map((food) => ({
      ...withStore(food),
      scores: scoreFood(food),
    }))
    .sort((a, b) => b.scores.finalScore - a.scores.finalScore);

  res.json({
    items,
    total: items.length,
  });
});

router.post('/recommendations/:foodId/feedback', (req, res) => {
  const food = foods.find((item) => item.id === req.params.foodId);

  if (!food) {
    return res.status(404).json({ message: '找不到餐點' });
  }

  const feedback = {
    foodId: food.id,
    actionType: req.body.actionType || 'view',
    rating: req.body.rating ?? null,
    createdAt: new Date().toISOString(),
  };
  recommendationFeedback.push(feedback);

  return res.status(201).json(feedback);
});

router.get('/me/favorites', (req, res) => {
  const items = foods.filter((food) => favorites.has(food.id)).map(withStore);

  res.json({
    items,
    total: items.length,
  });
});

router.post('/me/favorites/:foodId', (req, res) => {
  const food = foods.find((item) => item.id === req.params.foodId);

  if (!food) {
    return res.status(404).json({ message: '找不到餐點' });
  }

  favorites.add(food.id);
  return res.status(201).json(withStore(food));
});

router.delete('/me/favorites/:foodId', (req, res) => {
  favorites.delete(req.params.foodId);

  res.json({
    message: '已取消收藏',
    foodId: req.params.foodId,
  });
});

router.get('/me/history', (req, res) => {
  const items = history
    .map((record) => ({
      ...record,
      food: withStore(foods.find((food) => food.id === record.foodId)),
    }))
    .filter((record) => record.food);

  res.json({
    items,
    total: items.length,
  });
});

router.post('/me/history/:foodId', (req, res) => {
  const food = foods.find((item) => item.id === req.params.foodId);

  if (!food) {
    return res.status(404).json({ message: '找不到餐點' });
  }

  const record = {
    foodId: food.id,
    viewedAt: new Date().toISOString(),
  };
  history.unshift(record);

  return res.status(201).json(record);
});

router.post('/search-logs', (req, res) => {
  const record = {
    keyword: req.body.keyword || '',
    category: req.body.category || '',
    tags: req.body.tags || [],
    maxPrice: req.body.maxPrice ?? null,
    maxDistanceMeters: req.body.maxDistanceMeters ?? null,
    expiringOnly: Boolean(req.body.expiringOnly),
    resultCount: Number(req.body.resultCount || 0),
    searchedAt: new Date().toISOString(),
  };
  searchLogs.push(record);

  res.status(201).json(record);
});

module.exports = router;
