# IDEA.md — CodexBar

> Tài liệu ý tưởng gốc từ Product Owner (dịch và chuẩn hóa cấu trúc từ VISION.md và README.md).

## Bài toán cần giải quyết

Khi sử dụng các công cụ AI lập trình (như Claude, OpenAI, Cursor, Copilot, v.v.), nhà phát triển thường xuyên gặp khó khăn trong việc:
* Theo dõi giới hạn sử dụng token/credits (hết hạn mức lúc nào, khi nào reset).
* Dự đoán thời gian đặt lại hạn mức (reset countdowns) để lên kế hoạch làm việc.
* Quản lý nhiều tài khoản và nhiều nhà cung cấp AI cùng lúc.
* Bảo mật và riêng tư đối với các API key và session cookies.

## Đối tượng khách hàng

* **Lập trình viên / Kỹ sư phần mềm**: Những người sử dụng nhiều công cụ AI hàng ngày để viết code và cần quản lý chi phí/hạn ngạch sử dụng.
* **Đội nhóm công nghệ**: Theo dõi tổng hạn mức và ngân sách sử dụng AI dùng chung.

## Vision sản phẩm

CodexBar là một ứng dụng thanh menu (menu bar) siêu nhẹ trên macOS 14+ giúp giám sát thời gian thực các giới hạn sử dụng, số dư tín dụng (credits), chi phí tiêu dùng (spend), trạng thái hoạt động (status) và chu kỳ đặt lại (reset windows) của hơn 60 nhà cung cấp dịch vụ AI. 

Ứng dụng hướng tới:
* Tốc độ làm mới nhanh (fast refreshes).
* Đảm bảo an toàn riêng tư (privacy-first, xử lý dữ liệu hoàn toàn cục bộ).
* Giao diện UI hợp nhất, nhất quán.
* Hỗ trợ CLI đa nền tảng và WidgetKit.

## Giá trị cốt lõi

1. **Lập kế hoạch xung quanh chu kỳ đặt lại (Plan around resets)**: Đếm ngược thời gian đến lúc reset hạn ngạch theo phiên, tuần hoặc tháng để quyết định thời điểm thực hiện tác vụ lớn.
2. **Theo dõi chi phí và tín dụng (Credits & Spend)**: Biểu thị số dư, biểu đồ chi tiêu Admin API và quét chi phí cục bộ.
3. **Trạng thái trực quan (Live Status)**: Hiển thị trạng thái hoạt động của nhà cung cấp AI ngay trên menu bar.
4. **Riêng tư là trên hết (Privacy-first)**: Sử dụng lại phiên đăng nhập hiện có (OAuth, API keys, browser cookies, local files) và không lưu trữ mật khẩu của Sếp.

## Hệ sinh thái / Liên kết

* **Phần mềm macOS**: Ứng dụng gốc chạy trên macOS 14+ và các Widgets đi kèm.
* **CLI tool (`codexbar`)**: CLI chạy trên macOS và Linux hỗ trợ tự động hóa, CI/CD, tích hợp với thanh trạng thái khác (như SketchyBar, tmux, GNOME extensions, KDE widgets...).
* **Hệ sinh thái tích hợp**: Tự động nhận diện session từ các ứng dụng/CLI của chính nhà cung cấp AI (như Claude CLI, Codex CLI, Cursor config, JetBrains IDE...).

## Ghi chú thêm

* Thiết kế theo nguyên lý tối giản, không chiếm dụng Dock icon, tài nguyên tiêu thụ thấp.
* Quy tắc đóng góp mã nguồn (Merge by Default vs Needs Sign-Off) được quy định rõ để đảm bảo tính ổn định và an toàn riêng tư.

---

**Người viết:** Chau Le (Product Owner)
**Ngày:** 2026-08-05
**Trạng thái:** Confirmed
