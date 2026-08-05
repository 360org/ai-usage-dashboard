# CONTEXT.md — Từ điển nghiệp vụ CodexBar

Tài liệu này định nghĩa các thuật ngữ nghiệp vụ và khái niệm kỹ thuật cốt lõi được sử dụng trong dự án CodexBar. Tất cả các Agent phát triển dự án cần tuân thủ cách gọi và hiểu các thuật ngữ này.

| Thuật ngữ kỹ thuật | Định nghĩa tiếng Việt | Mô tả chi tiết |
|---|---|---|
| **Adaptive Refresh** | Làm mới thông minh | Chế độ làm mới dữ liệu hạn ngạch (quota) dựa trên hành động thực tế của người dùng (chạy IDE, ghi logs) để tối ưu tần suất request API, tránh spam hệ thống. |
| **Merge Icons Mode** | Chế độ hợp nhất biểu tượng | Tính năng gom tất cả các biểu tượng trạng thái của nhiều nhà cung cấp AI thành một biểu tượng duy nhất trên menu bar macOS kèm dropdown để chuyển đổi. |
| **Local Cost Scan** | Quét chi phí cục bộ | Chức năng tự động đọc các file log của các AI client khác trên máy tính của người dùng (như log của Claude CLI) để tự động ước lượng chi phí sử dụng. |
| **Safe Storage** | Lưu trữ an toàn của trình duyệt | Tên gọi chung của các Keychain item (như "Chrome Safe Storage") lưu trữ khóa giải mã cookies của các trình duyệt nhân Chromium. |
| **Binary Cookies** | Cookie nhị phân của Safari | Định dạng tệp tin lưu trữ cookies đặc thù của Safari (`.binarycookies`), yêu cầu quyền Full Disk Access trên macOS để đọc trực tiếp. |
| **Appcast** | Tệp tin phát hành cập nhật | Định dạng tệp XML theo chuẩn Sparkle framework dùng để phát hiện, tải và cài đặt tự động các phiên bản cập nhật mới của ứng dụng. |
| **Notarization** | Công chứng ứng dụng của Apple | Quy trình gửi ứng dụng lên máy chủ Apple quét mã độc và ký xác nhận trước khi phân phối file `.app` trực tiếp tới người dùng macOS. |
| **Merge by Default** | Tự động phê duyệt mã nguồn | Các thay đổi nhỏ như sửa lỗi UI, tài liệu hoặc thêm model đi kèm descriptor mẫu có thể được merge thẳng vào main branch mà không cần review phức tạp. |
| **Needs Sign-Off** | Yêu cầu phê duyệt cấp cao | Các thay đổi liên quan đến cấu trúc bảo mật, lưu trữ API key, cookie hoặc nâng cấp thư viện bên ngoài bắt buộc phải được Product Owner kiểm duyệt thủ công. |
