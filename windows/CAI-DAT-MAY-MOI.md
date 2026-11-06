# Cài và chạy HumanTyper trên Windows

Mở PowerShell và dán **một lệnh** sau:

```powershell
& ([scriptblock]::Create((Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/NemCua/tool-go-docs-windows/windows/windows/install.ps1').Content)) -Run
```

Script tải bản source mới vào `%LOCALAPPDATA%\HumanTyper\releases`, không dùng lại file `.csproj` cũ trên máy. Nó tự cài .NET 8 SDK cho tài khoản hiện tại nếu thiếu, build, chạy thử `testText --dry-run`, rồi chờ bạn nhấn Enter để chạy thật. Sau khi nhấn Enter, chuyển sang Google Docs và đặt con trỏ trong tài liệu trong 5 giây đếm ngược.

Máy cần Windows 10/11 có desktop và kết nối HTTPS đến GitHub, `dot.net` và nguồn gói NuGet. Mặc định script dùng `input/testText.txt`; để dùng file khác, đặt file vào thư mục `input` của bản vừa tải và chạy lệnh được in ra sau khi script hoàn tất.
