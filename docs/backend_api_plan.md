# 膳解人意後端與 API 規劃

## 目前階段

目前我們先完成 Flutter 前端原型，包含首頁推薦、搜尋、轉盤、收藏紀錄與會員中心。因為學校雲端伺服器還沒有正式串接，所以現階段先用 mock data 測試功能流程，確認畫面與資料欄位是否符合初審文件需求。

接下來我們會先在本機建立後端 API 與 MySQL 資料庫，等本機測試穩定後，再把 API 和資料庫部署到學校雲端伺服器。

這份文件主要用來整理後端之後要提供哪些資料給 App。前端目前已經先做出可操作的流程，但資料仍是寫在本機端，因此下一步需要把餐點、會員、收藏、瀏覽紀錄與推薦結果整理成 API，讓系統架構逐漸接近初審文件中規劃的完整版本。

## 本階段目的

- 先確認 Flutter App 需要哪些資料欄位，避免後端資料表設計後才發現前端不夠用。
- 先在本機完成 API 與 MySQL 測試，降低一開始就部署到伺服器造成的除錯成本。
- 讓推薦、搜尋、收藏、瀏覽紀錄這些功能未來可以從 mock data 平順改成資料庫資料。
- 保留學校雲端伺服器作為展示與正式測試環境，而不是目前開發初期就直接依賴它。

## 開發順序

1. 前端先固定資料模型
   - `FoodItem`
   - `UserProfile`
   - `UserPreference`
   - 收藏與瀏覽紀錄

2. 本機後端 API
   - 先使用本機 MySQL
   - API 回傳格式對齊 Flutter model
   - App 逐步從 mock repository 改成 API repository

3. 學校雲端伺服器
   - 部署 API
   - 部署 MySQL 或連接學校提供的資料庫
   - App 改用正式伺服器網址

## API 清單

### Auth / Member

| Method | Path | 用途 |
| --- | --- | --- |
| POST | `/api/auth/register` | 會員註冊 |
| POST | `/api/auth/login` | 會員登入 |
| POST | `/api/auth/logout` | 登出 |
| GET | `/api/me` | 取得目前會員資料 |
| PUT | `/api/me` | 更新會員基本資料 |
| GET | `/api/me/preferences` | 取得飲食偏好 |
| PUT | `/api/me/preferences` | 更新飲食偏好、預算、距離 |

### Foods / Stores

| Method | Path | 用途 |
| --- | --- | --- |
| GET | `/api/foods` | 取得餐點列表，可支援搜尋與篩選 |
| GET | `/api/foods/{foodId}` | 取得餐點詳情 |
| GET | `/api/stores/{storeId}` | 取得店家資訊 |

`GET /api/foods` query 參數建議：

| 參數 | 說明 |
| --- | --- |
| `keyword` | 搜尋餐點、店家、食材、標籤 |
| `category` | 餐點類型 |
| `tags` | 偏好標籤，可用逗號分隔 |
| `maxPrice` | 預算上限 |
| `maxDistanceMeters` | 距離上限 |
| `expiringOnly` | 是否只看即期優惠 |

### Recommendation

| Method | Path | 用途 |
| --- | --- | --- |
| GET | `/api/recommendations` | 根據會員偏好取得推薦餐點 |
| POST | `/api/recommendations/{foodId}/feedback` | 紀錄點擊、收藏、評分、購買等回饋 |

推薦排序欄位需保留：

- `preferenceScore`
- `distanceScore`
- `budgetScore`
- `ecoPriorityScore`
- `finalScore`
- `recommendationReason`

### Favorites / History

| Method | Path | 用途 |
| --- | --- | --- |
| GET | `/api/me/favorites` | 取得收藏清單 |
| POST | `/api/me/favorites/{foodId}` | 加入收藏 |
| DELETE | `/api/me/favorites/{foodId}` | 取消收藏 |
| GET | `/api/me/history` | 取得瀏覽紀錄 |
| POST | `/api/me/history/{foodId}` | 新增瀏覽紀錄 |

### Search Logs

| Method | Path | 用途 |
| --- | --- | --- |
| POST | `/api/search-logs` | 紀錄搜尋關鍵字與篩選條件 |

## Food Response 範例

```json
{
  "id": "food-001",
  "name": "舒肥雞胸餐盒",
  "storeId": "store-001",
  "storeName": "健康餐盒店",
  "storeAddress": "台北市中山區健康路 12 號",
  "businessHours": "10:30-20:30",
  "contactPhone": "02-2500-1200",
  "price": 120,
  "originalPrice": null,
  "discountLabel": null,
  "category": "便當",
  "tags": ["高蛋白", "低脂"],
  "ingredients": ["雞胸肉", "糙米", "花椰菜"],
  "nutritionTags": ["高蛋白"],
  "distanceMeters": 450,
  "stockCount": 8,
  "expiresAt": null,
  "isExpiringSoon": false,
  "ecoPriorityScore": 0.42,
  "recommendationReason": "符合你的高蛋白需求",
  "isFavorite": false
}
```

## Flutter 串接調整方向

目前：

- `MockFoodRepository`
- `UserActivityService`
- `UserProfileService`

下一階段可新增：

- `ApiClient`
- `FoodRepository`
- `AuthRepository`
- `UserRepository`
- `RecommendationRepository`

串接時會先保留目前的 mock repository，再另外建立 API repository。這樣做的原因是，如果後端還在調整，前端畫面仍然可以用 mock data 繼續測試；等 API 穩定後，再逐步把資料來源換成後端回傳資料。

畫面層原則上不直接處理 HTTP 請求，而是交給 repository 或 service 統一管理。這樣未來如果要切換本機後端、學校伺服器，或調整 API 格式，會比較不需要大幅修改每個畫面。

## 目前本機 API 原型

目前已先建立 `backend/` 資料夾，使用 Node.js 與 Express 製作本機 API 原型。這個階段還沒有正式連接 MySQL，主要用途是先讓 API 路徑、回傳格式與 Flutter App 需要的資料欄位對齊。

已建立的內容：

- `GET /api/health`
- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/logout`
- `GET /api/me`
- `PUT /api/me`
- `GET /api/me/preferences`
- `PUT /api/me/preferences`
- `GET /api/foods`
- `GET /api/foods/{foodId}`
- `GET /api/stores/{storeId}`
- `GET /api/recommendations`
- `POST /api/recommendations/{foodId}/feedback`
- `GET /api/me/favorites`
- `POST /api/me/favorites/{foodId}`
- `DELETE /api/me/favorites/{foodId}`
- `GET /api/me/history`
- `POST /api/me/history/{foodId}`
- `POST /api/search-logs`

下一步會把目前 mock data 的資料來源逐步改成 MySQL 查詢，並補上正式會員驗證。
