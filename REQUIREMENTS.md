# REQUIREMENTS.md — CodexBar

> Sinh từ [IDEA.md](IDEA.md). Mỗi section truy nguồn về IDEA tương ứng.

## 1. Tổng quan dự án

### 1.1 Mục tiêu kinh doanh
* Trở thành công cụ trực quan hóa hạn mức sử dụng AI lập trình hàng đầu trên macOS, có hiệu năng cực cao, gọn nhẹ và bảo mật.
* Hỗ trợ đầy đủ hơn 60 nhà cung cấp AI phổ biến để nhà phát triển có thể theo dõi tập trung mọi giới hạn sử dụng trong một giao diện duy nhất.
* Đảm bảo tính riêng tư tuyệt đối (xử lý local 100%, không gửi token/cookie lên máy chủ trung gian).

### 1.2 Đối tượng người dùng (Personas)
* **Kỹ sư AI/Lập trình viên độc lập (Developer)**: Sử dụng các dịch vụ API/Chat của OpenAI, Claude, Cursor... liên tục. Cần biết chính xác khi nào hạn mức reset để tối ưu hóa công việc.
* **Đội ngũ Phát triển Phần mềm (Teams)**: Sử dụng tài khoản nhóm, cần kiểm soát ngân sách chi tiêu và tránh việc hết hạn ngạch đột ngột trong quá trình làm việc.

### 1.3 Phạm vi (Scope)
* **Trong phạm vi:**
  * Ứng dụng macOS gốc chạy trên menu bar.
  * Widget hiển thị ngoài màn hình macOS.
  * Bộ công cụ dòng lệnh CLI (`codexbar`) đa nền tảng (macOS và Linux) để lấy dữ liệu dạng JSON, phục vụ tích hợp thanh trạng thái hoặc script tự động.
  * Khả năng tự động đọc và phân tích local config/cookie/keychain của các AI client khác.
* **Ngoài phạm vi:**
  * Ứng dụng GUI trên Windows hoặc Linux.
  * Lưu trữ dữ liệu trên đám mây (cloud sync) dùng chung tài khoản riêng.

## 2. Yêu cầu chức năng (Functional Requirements)

### 2.1 Hiển thị giới hạn và bộ đếm ngược (Meters & Countdowns)
* **Mô tả:** Hiển thị trực quan thanh sử dụng (usage bar) theo phần trăm và đếm ngược thời gian (countdown) cho đến khi reset hạn ngạch (theo giờ, ngày, tuần, tháng).
* **Tiêu chí nghiệm thu:**
  * Tính toán chính xác thời gian reset theo múi giờ địa phương.
  * Thanh tiến trình thay đổi màu sắc dựa trên mức độ sử dụng (ví dụ: xanh lá -> vàng -> đỏ).
* **Nguồn:** IDEA §Giá trị cốt lõi (1)

### 2.2 Quản lý Đa Nhà cung cấp (Multi-provider Support)
* **Mô tả:** Cho phép bật/tắt hiển thị riêng lẻ từng nhà cung cấp AI (hơn 60 nhà cung cấp gồm Codex, OpenAI, Claude, Gemini, Cursor...).
* **Tiêu chí nghiệm thu:** 
  * Cấu hình dễ dàng qua Settings -> Providers.
  * Hỗ trợ Merge Icons mode để gom tất cả icon nhà cung cấp thành 1 icon duy nhất trên menu bar kèm dropdown switcher.
* **Nguồn:** IDEA §Vision sản phẩm & Giá trị cốt lõi (1, 2)

### 2.3 Quét chi phí và số dư tín dụng (Credits & Spend Scan)
* **Mô tả:** Đọc và biểu diễn thông tin số dư tài khoản (credit balance), biểu đồ chi tiêu (spend charts) từ API của các nhà cung cấp hỗ trợ (OpenAI, Anthropic Admin, OpenRouter, v.v.).
* **Tiêu chí nghiệm thu:**
  * Vẽ biểu đồ chi tiêu cục bộ trong popover menu của ứng dụng.
  * Hỗ trợ quét lịch sử chi phí cục bộ dựa trên file logs của các IDE/CLI.
* **Nguồn:** IDEA §Giá trị cốt lõi (2)

### 2.4 Hỗ trợ CLI (`codexbar` command-line)
* **Mô tả:** Cung cấp CLI để thao tác cấu hình, truy vấn số dư và chi phí sử dụng qua terminal.
* **Tiêu chí nghiệm thu:**
  * Cú pháp CLI nhất quán: `codexbar config`, `codexbar cost`, `codexbar serve`.
  * Có khả năng trả về định dạng JSON (`--json`) để tích hợp với các công cụ hiển thị bên thứ ba.
* **Nguồn:** IDEA §Hệ sinh thái / Liên kết

### 2.5 Hỗ trợ Đa ngôn ngữ (i18n)
* **Mô tả:** Hỗ trợ giao diện ứng dụng và trang web bằng 21 ngôn ngữ khác nhau, bao gồm hỗ trợ bố cục từ phải qua trái (RTL) và tự động nhận diện ngôn ngữ hệ thống.
* **Tiêu chí nghiệm thu:**
  * Dịch thuật chuẩn xác các thuật ngữ kỹ thuật.
  * Không vỡ layout khi chuyển đổi ngôn ngữ.
* **Nguồn:** README.md §Features

## 3. Yêu cầu phi chức năng (Non-Functional Requirements)

### 3.1 Hiệu năng
* Thời gian phản hồi và làm mới dữ liệu nhanh, tối ưu hóa qua thuật toán Adaptive Refresh (làm mới thông minh dựa trên hành động sử dụng của Sếp, tránh spam API).
* Mức độ tiêu thụ CPU và năng lượng ở mức tối thiểu để không làm chậm hệ thống macOS (khắc phục triệt để các lỗi rò rỉ bộ nhớ/năng lượng).

### 3.2 Bảo mật & Quyền riêng tư
* Tuyệt đối không gửi hoặc lưu trữ thông tin nhạy cảm (API keys, cookies) lên bất kỳ máy chủ nào ngoài API gốc của nhà cung cấp AI.
* Mã hóa hoặc lưu trữ an toàn các credential bằng macOS Keychain hoặc phân quyền tệp tin chặt chẽ (`chmod 600` cho file config).

### 3.3 Khả năng mở rộng
* Thiết kế hệ thống provider có cấu trúc module rõ ràng (mỗi provider là một descriptor riêng biệt) để dễ dàng thêm nhà cung cấp mới mà không ảnh hưởng đến phần lõi của app.

## 4. Thiết kế & Trải nghiệm (UX/UI)

### 4.1 Phong cách thiết kế
* Đơn giản, tích hợp mượt mà vào ngôn ngữ thiết kế macOS Sonoma trở lên.
* Hỗ trợ cả Light Mode và Dark Mode.
* Kích thước popover nhỏ gọn, căn chỉnh hoàn hảo với biểu tượng trạng thái trên menu bar.

### 4.2 Brand guidelines
* Sử dụng bảng màu trung tính, tinh tế cho các biểu đồ và thanh sử dụng (tuân thủ nguyên lý thiết kế `dataviz` của dự án).

## 5. Tích hợp & Phụ thuộc

### 5.1 Hệ thống bên ngoài
* API của hơn 60 nhà cung cấp AI (Anthropic, OpenAI, Cursor, Google Gemini, OpenRouter...).
* macOS Keychain API để lưu trữ an toàn thông tin xác thực.

### 5.2 Hệ sinh thái địa phương
* Trích xuất cookie từ các trình duyệt phổ biến (Safari, Chrome, Brave, Edge...) khi được cấp quyền Full Disk Access.
* Đọc file log/config cục bộ của Claude Code (`~/.claude`), Codex CLI (`~/.codex`), Cursor (`~/.config/Cursor`), v.v.

## 6. Ràng buộc (Constraints)

### 6.1 Công nghệ
* macOS 14+ (Sonoma) làm môi trường chạy chính cho ứng dụng GUI.
* Ngôn ngữ Swift (Swift 6.2+ và Xcode tương ứng) để phát triển phần core và GUI.
* CLI hỗ trợ macOS và Linux (glibc hoặc static musl).

## 7. Tiêu chí nghiệm thu (Acceptance Criteria)

| # | Tiêu chí | Phương pháp kiểm tra |
|---|----------|---------------------|
| 1 | Mọi API Key lưu bằng CLI đều được lưu đúng phân quyền file config. | Kiểm tra `ls -l ~/.config/codexbar/config.json` có quyền read/write chỉ cho user sở hữu. |
| 2 | Khi chạy CLI `codexbar usage --json`, dữ liệu JSON trả về phải đúng cấu trúc schema. | Thực thi CLI trên terminal macOS/Linux và parse kết quả JSON. |
| 3 | Tốc độ làm mới Adaptive không spam API. | Kiểm tra nhật ký hoạt động hoặc chạy log giám sát số lượng request. |

## 8. Rủi ro & Giảm thiểu

| # | Rủi ro | Xác suất | Tác động | Giảm thiểu |
|---|--------|----------|----------|------------|
| 1 | Nhà cung cấp AI thay đổi cấu trúc trang web hoặc cơ chế lưu cookie/session. | Cao | Cao | Thiết kế cơ chế phân tích (parser) dạng động, dễ dàng cập nhật qua bản vá nhỏ mà không cần thay đổi core app. |
| 2 | Người dùng không cấp quyền Full Disk Access hoặc Keychain Access khiến app không đọc được cookies. | Trung bình | Trung bình | Cung cấp tài liệu hướng dẫn chi tiết tại Settings và README; cung cấp cơ chế nhập token/cookie thủ công (Manual cookies). |

---

**Nguồn:** [IDEA.md](IDEA.md)
**Người duyệt:** Chau Le (Product Owner)
**Trạng thái:** Approved
**Ngày duyệt:** 2026-08-05
