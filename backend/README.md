# 膳解人意 Backend

這個資料夾是本機後端 API 原型，先用 mock data 對齊 Flutter App 目前需要的資料格式。之後可依照 `database/schema.sql` 把資料來源改成 MySQL。

## 執行方式

```powershell
cd backend
npm install
npm start
```

`npm start` 會持續啟動 API 伺服器，終端機需要保持開著。`npm test` 只會跑測試，測試完成後程式會結束，因此瀏覽器不會連到 `localhost:3000`。

啟動後可測試：

```text
GET http://localhost:3000/api/health
GET http://localhost:3000/api/foods
GET http://localhost:3000/api/recommendations
```

## 環境變數

複製 `.env.example` 成 `.env`，再填入本機 MySQL 設定。`.env` 不會提交到 Git。

## 目前狀態

- 已建立 API 路由骨架。
- 已提供餐點、推薦、收藏、瀏覽紀錄、搜尋紀錄等 mock 回應。
- 尚未正式連接 MySQL。
- 尚未加入正式會員密碼加密與 JWT 驗證。
