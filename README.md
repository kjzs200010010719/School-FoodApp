# 膳解人意 Flutter App

「膳解人意」是以個人化餐飲推薦與即期食品減廢為目標的 Flutter App。專案目前以前端原型與本機資料為主，後續會再串接本機後端、MySQL，最後部署到學校雲端伺服器。

## 目前已完成

- 首頁推薦與即期優惠
- 餐點詳情頁
- 搜尋與篩選
- 食物轉盤
- 收藏與瀏覽紀錄
- 會員中心與測試登入
- 未登入功能導向登入頁
- 推薦、搜尋、轉盤、會員服務測試

## 開發方式

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d emulator-5554
```

## 本機後端

```powershell
cd backend
npm install
npm start
```

目前後端先提供 mock API，端點規劃會對齊 Flutter App 與後續 MySQL schema。

注意：`npm start` 才會讓 `http://localhost:3000` 持續可連線；`npm test` 只是執行測試，測完就會關閉。

## 後端規劃

- API 規劃：[docs/backend_api_plan.md](docs/backend_api_plan.md)
- MySQL schema：[database/schema.sql](database/schema.sql)
- 本機 API 原型：[backend/README.md](backend/README.md)

目前不直接使用學校雲端伺服器。先以本機後端與 MySQL 完成串接測試，再部署到學校伺服器。
