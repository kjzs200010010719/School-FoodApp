# Windows API 常駐服務

以下操作只在學校 Windows Server 的遠端桌面內執行，不在開發筆電安裝。
工具不修改防火牆、不開放資料庫，也不取代既有 Apache 或 AppServ MySQL。

## 安裝前

確認 MySQLFoodApp 正在執行、backend/.env 已完成設定，且 db:check 與 test:mysql 通過。
以系統管理員開啟 PowerShell，更新已核對的專案版本；若 git pull 被本機修改阻擋，先保留修改，不要強制覆寫。

```powershell
cd C:\School\my_app
git status --short --branch
git pull --ff-only
cd backend
npm.cmd ci
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\api_service.ps1 -Action Check
```

Check 會驗證資料庫連線與必要檔案，不安裝服務、不修改權限、不下載程式。
若原本有 npm start 視窗，請在該視窗按 Ctrl+C 停止 API，再進行安裝。

## 安裝與驗收

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\api_service.ps1 -Action Install
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\api_service.ps1 -Action Status
```

預期服務 SchoolFoodAppApi 顯示 Running、Auto，帳戶為 LocalService。
健康檢查除了 /api/health 回傳 ok，也會確認監聽程序確實由服務啟動。
API 固定監聽 127.0.0.1:3000；只有伺服器本機能存取，外部 App 仍需完成核准的 HTTPS 存取設定。

安裝成功後可關閉 PowerShell；服務不依賴互動登入，會在 Windows 開機後延遲自動啟動。
請在適當維護時間自行重開伺服器，再執行 Status 驗證開機啟動。工具不會替你重開機。
單純中斷遠端桌面不等同登出；使用服務的目的是讓 API 不依賴使用者工作階段。

## 維護

將下列指令的 Status 換成 Start、Stop、Restart 或 Uninstall：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\api_service.ps1 -Action Status
```

更新程式時先 Stop，再 git pull、npm.cmd ci、db:check、必要的資料庫遷移與測試，最後 Start。
不要在服務執行中更換 node_modules。遷移前應先備份資料庫。
Uninstall 只移除 API 服務，保留程式、.env、MySQL、設定與日誌，以及已授予 LocalService 的檔案權限。

日誌位於 C:\ProgramData\SchoolFoodAppApi\logs。標準輸出與錯誤日誌各以約 10 MB 輪替，保留 5 份歷史檔。
啟動失敗時檢查日誌，請勿貼出 .env 或密碼。服務異常退出後等待 30 秒重啟；首次安裝健康檢查失敗會停止服務，避免持續重試。

## 安全與執行環境

- 使用 LocalService 低權限帳戶；授予 backend 讀取及執行權限、日誌目錄寫入權限。
- .env 保留在 backend，不複製密碼到服務 XML；不改變原資料庫帳號權限。
- 服務執行檔與設定放在 ProgramData，只有系統與管理員可修改。
- 使用官方 WinSW 2.12.0 NET461，需 .NET Framework 4.6.1 以上。安裝時下載並核對腳本內固定的 SHA-256；此為下載內容校驗，不是數位簽章驗證。
- 工具拒絕在一般 Windows 工作站安裝，也拒絕管理同名但路徑不符的服務。
- 本機自動測試只驗證設定與安全檢查；實際服務啟動、重啟及重開機驗收必須在學校伺服器完成。

官方參考：[WinSW 2.12.0](https://github.com/winsw/winsw/releases/tag/v2.12.0)、[服務設定](https://github.com/winsw/winsw/blob/v2.12.0/doc/xmlConfigFile.md)。
