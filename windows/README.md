# HumanTyper cho Windows

Hướng dẫn này dành cho người **clone nhánh `windows`** rồi chạy từ mã nguồn trên Windows 10/11 có giao diện desktop. Cần Internet để tải code và .NET 8 SDK trong lần cài đầu.

Nếu muốn cài tự động bằng một lệnh mà không clone thủ công, xem [CAI-DAT-MAY-MOI.md](CAI-DAT-MAY-MOI.md). Các yêu cầu về máy cloud, quyền và Google Docs nằm trong [REQUIREMENTS.md](REQUIREMENTS.md).

## Từ máy mới đến lúc chạy

Mở **PowerShell**. Các lệnh dưới đây dùng `D:\Tool\tool-go-docs-windows`; có thể đổi `D:\Tool` sang thư mục khác.

### 1. Cài Git và .NET 8 SDK nếu máy chưa có

Kiểm tra:

```powershell
git --version
dotnet --list-sdks
```

Nếu thiếu Git hoặc danh sách SDK không có dòng bắt đầu bằng `8.`, cài phần tương ứng bằng WinGet:

```powershell
winget install --id Git.Git -e --source winget
winget install --id Microsoft.DotNet.SDK.8 -e --source winget
```

Chỉ cần chạy lệnh của phần còn thiếu. Sau khi cài, **đóng và mở lại PowerShell** để nhận PATH mới. Nếu máy không có `winget`, tải [Git for Windows](https://git-scm.com/install/windows) và [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0) từ trang chính thức. SDK đã gồm runtime cần thiết; không cần cài `npm`, `pip` hay gói NuGet riêng.

### 2. Clone đúng nhánh Windows

```powershell
New-Item -ItemType Directory -Force D:\Tool | Out-Null
git clone --branch windows --single-branch https://github.com/NemCua/tool-go-docs-windows.git D:\Tool\tool-go-docs-windows
cd D:\Tool\tool-go-docs-windows
```

Nếu đã clone rồi, chỉ cần `cd` vào thư mục đó. Kiểm tra đang ở nhánh `windows` bằng `git branch --show-current`.

### 3. Chạy thử, chưa gửi phím vào Google Docs

```powershell
.\run.cmd testText --dry-run
```

Lần chạy đầu, `run.cmd` tự restore và build dự án. Nếu lệnh thành công, bạn sẽ thấy số ký tự và thời gian ước tính. File mẫu là `input\testText.txt`.

### 4. Chạy thật

Mở tài liệu Google Docs trong Chrome, Edge hoặc Brave. Tại PowerShell đang ở thư mục gốc dự án, chạy:

```powershell
.\run.cmd testText
```

Trong thời gian đếm ngược, chuyển sang Google Docs và đặt con trỏ tại vị trí muốn gõ. Không gõ tay trong lúc chương trình đang chạy.

Để dùng nội dung riêng, lưu file UTF-8 tại `input\bai-viet.txt`, rồi chạy `.\run.cmd bai-viet`. Có thể thêm `--dry-run` để kiểm tra trước. File `run.cmd` nằm ở thư mục gốc, cạnh `settings.json`, `input` và `windows`.

### 5. Dừng khi đang chạy

Nhấn **phím backtick (\` dưới Escape)** một lần. Bản Windows bắt phím vật lý này kể cả khi Google Docs đang có focus. Nếu bàn phím không có phím đó, dùng `Pause/Break`, `Ctrl + Alt + Shift + Escape`, hoặc đưa chuột vào góc trên-trái màn hình chính. Chương trình sẽ dừng và in số ký tự đã gõ. Khi gõ xong file, chương trình tự kết thúc; gõ `exit` nếu muốn đóng PowerShell.

## Cập nhật code sau khi đã clone

Mở PowerShell tại thư mục đã clone:

```powershell
cd D:\Tool\tool-go-docs-windows
git status --short
```

Nếu `git status --short` báo bạn đã sửa `settings.json`, tạm cất thay đổi trước:

```powershell
git stash push -m "settings local" -- settings.json
```

Sau đó tải bản mới và chạy thử:

```powershell
git pull --ff-only origin windows
.\run.cmd testText --dry-run
```

Nếu đã tạm cất `settings.json`, khôi phục cấu hình riêng:

```powershell
git stash pop
```

Nếu Git báo xung đột khi `stash pop`, cần chọn lại các giá trị trong `settings.json` trước khi chạy thật. Các thay đổi khác trong file Git đang theo dõi cũng cần được lưu hoặc xử lý trước khi pull. File `.txt` mới do bạn thêm trong `input` vẫn nằm tại chỗ. Sau khi cập nhật, chạy `.\run.cmd ten-file` như trên; script sẽ build lại mã mới.

## Chức năng

Bản Windows dùng chung cú pháp và `settings.json` với macOS:

- Gõ Unicode, tiếng Việt, emoji, Enter và Tab bằng `SendInput`.
- Lỗi ngẫu nhiên theo cụm, xóa và gõ lại đúng.
- `{save}` và `[sai, đúng]`.
- Chuyển LaTeX đơn giản sang Unicode.
- Tạo và nhập bảng `[[TABLE ...]]`.
- Lưu lịch sử Google Docs bằng `Ctrl + Alt + Shift + H`.
- Nhịp gõ tự nhiên và các khoảng chờ trong settings.
- Dry-run và các tùy chọn `--wpm`, `--error-rate`, `--countdown`, `--seed`, `--no-errors`, `--no-history`.

Panel không lấy focus, luôn nổi ở góc trên bên phải. Panel hiện countdown, thời gian ước tính, thời gian thực, ký tự còn lại và tiến độ; khi hoàn tất hiện tổng thời gian 4 giây rồi tự đóng.

## Khác biệt hệ điều hành

- Windows dùng `Ctrl`/`Alt`/`Shift`; macOS dùng `Command`/`Option`/`Control`.
- Tool Finder của Google Docs trên Windows mở bằng `Alt + /`.
- Chương trình hiện gửi tên lệnh bảng bằng tiếng Việt (`Chèn bảng`, `Chèn cột bên phải`, `Chèn hàng bên dưới`, `Xóa cột`, `Xóa hàng`), nên giao diện Google Docs phải dùng tiếng Việt để tạo bảng tự động.
- `SendInput` không điều khiển được ứng dụng chạy quyền Administrator nếu HumanTyper chạy quyền thường. Nên chạy trình duyệt và HumanTyper cùng mức quyền.
- Panel dùng WinForms và `user32.dll`, không chạy trên macOS/Linux.

## Đóng gói

Tạo file chạy độc lập, không yêu cầu người dùng cài .NET:

```powershell
powershell -ExecutionPolicy Bypass -File windows\publish.ps1 -Runtime win-x64
```

Máy Windows ARM dùng:

```powershell
powershell -ExecutionPolicy Bypass -File windows\publish.ps1 -Runtime win-arm64
```

Kết quả nằm trong `windows\publish\win-x64` hoặc `windows\publish\win-arm64`. Khi chuyển sang máy khác, đặt `settings.json` và thư mục `input` cạnh file chạy hoặc chạy file từ thư mục dự án.

## Kiểm tra trước khi phát hành

1. Chạy `--dry-run` với `input/testText.txt`.
2. Kiểm tra tiếng Việt, emoji, xuống dòng, directive và bảng trong Preview.
3. Mở Google Docs tiếng Việt, đặt con trỏ rồi chạy thử một file ngắn.
4. Xác nhận panel không lấy focus khỏi trình duyệt.
5. Thử phím dừng khẩn cấp.
6. Thử đúng gói `win-x64` hoặc `win-arm64` trên máy đích.
