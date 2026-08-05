# DEPLOY_GUIDE.md — Hướng dẫn triển khai CodexBar

> Sinh từ [ARCH.md](ARCH.md).

Tài liệu này hướng dẫn cách build, đóng gói ứng dụng macOS (CodexBar App) và biên dịch công cụ dòng lệnh CLI (`codexbar`) từ mã nguồn.

---

## 1. Yêu cầu môi trường (Prerequisites)

* **Hệ điều hành**: macOS 14+ (Sonoma) trở lên.
* **Công cụ lập trình**: Xcode 15+ (chứa Swift SDK 6.2+).
* **Công cụ bổ sung**:
  * SwiftFormat & SwiftLint (dùng cho việc định dạng và kiểm tra chuẩn code).
  * `make` (chạy các task tự động hóa).

---

## 2. Các lệnh phát triển nhanh (Dev Commands)

Tại thư mục gốc của dự án, sử dụng các công cụ script đi kèm để build và test nhanh:

### 2.1 Biên dịch và chạy thử ngay lập tức:
```bash
./Scripts/compile_and_run.sh
```

### 2.2 Biên dịch kèm chạy bộ test của hệ thống:
```bash
./Scripts/compile_and_run.sh --test
```

### 2.3 Format code và kiểm tra lỗi cú pháp (Linter):
```bash
make check
```

---

## 3. Đóng gói ứng dụng macOS (Packaging CodexBar.app)

Để tạo ra file ứng dụng `.app` chạy độc lập trên máy macOS của Sếp với chữ ký ad-hoc (ad-hoc signing):

### 3.1 Chạy script đóng gói:
```bash
./Scripts/package_app.sh
```
Sau khi chạy xong, file `CodexBar.app` sẽ được tạo ra ngay tại thư mục gốc của dự án.

### 3.2 Khởi chạy ứng dụng:
```bash
open CodexBar.app
```
Sếp có thể kéo file `CodexBar.app` này vào thư mục `/Applications` trên máy để sử dụng lâu dài.

---

## 4. Biên dịch và cài đặt CLI (`codexbar`)

Công cụ CLI (`codexbar`) có thể cài đặt trực tiếp vào hệ thống sau khi ứng dụng GUI đã được đặt vào thư mục `/Applications`.

### 4.1 Chạy script cài đặt CLI:
```bash
./bin/install-codexbar-cli.sh
```
Script này sẽ liên kết hoặc copy binary `codexbar` vào thư mục thực thi của hệ thống (ví dụ: `/usr/local/bin` hoặc `~/.local/bin`), giúp Sếp có thể gọi lệnh `codexbar` từ bất kỳ terminal nào.

### 4.2 Kiểm tra cài đặt CLI thành công:
```bash
codexbar --version
```

---

## 5. Quy trình phát hành bản release (Release Workflow)

Dành cho nhà phát triển muốn đóng gói bản release chính thức để phân phối ra ngoài (cần Apple Developer Account):

1. **Ký chứng thư và Notarize ứng dụng (Apple Notarization)**:
   Sử dụng script ký chính thức để Apple phê duyệt bảo mật:
   ```bash
   ./Scripts/sign-and-notarize.sh
   ```
2. **Cập nhật Appcast cho tính năng Sparkle Update**:
   Tạo tệp XML appcast mới để cập nhật OTA cho người dùng:
   ```bash
   ./Scripts/make_appcast.sh
   ```
3. **Xác thực cấu hình appcast**:
   ```bash
   ./Scripts/verify_appcast.sh
   ```

---

**Nguồn:** [ARCH.md](ARCH.md)
**Người duyệt:** Chau Le (Product Owner)
**Trạng thái:** Approved
**Ngày duyệt:** 2026-08-05
