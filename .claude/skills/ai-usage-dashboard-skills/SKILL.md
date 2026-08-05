# AI Usage Dashboard Development Skill (ai-usage-dashboard-skills)

Bộ kỹ năng chuyên biệt cho việc phát triển và bảo trì dự án **AI Usage Dashboard (CodexBar)**.
Tất cả các Agent khi tiếp nhận dự án bắt buộc phải load và tuân thủ các chỉ dẫn trong skill này.

---

## 🚨 Nguyên tắc Đồng bộ hóa GitLab bắt buộc
Mọi yêu cầu xử lý vấn đề, tính năng mới hoặc fix lỗi từ Sếp bắt buộc phải đi kèm với quy trình đồng bộ hóa khép kín trên GitLab Private (`git@gitlab.com:360_public/ai-usage-dashboard.git`):

1. **Tạo Issue**: Khi nhận task, tự động tạo Issue trên GitLab bằng GitLab CLI:
   `glab issue create --title "[T<ID>] <Tiêu đề>" --description "<Mô tả phương án & hướng xử lý>" --yes`
   Đồng thời thêm task vào `task.md` local.
2. **Cập nhật tiến độ**: Viết comment báo cáo hướng xử lý, các file sửa đổi và đính kèm ảnh minh họa (nếu có) lên GitLab Issue vừa tạo.
3. **Đóng và Hoàn tất**: Khi commit code chứa task-id (VD: `T2.1`), Git post-commit hook local (`.devhooks/post-commit` gọi `.devhooks/devtrack.py` local) sẽ:
   * Tự động tick `[x]` vào `task.md` local.
   * Tự động đóng Issue trên GitLab kèm comment báo cáo commit SHA.
   * Tự động commit checklist và push ngầm dưới nền lên GitLab Private (`origin`).
   * *Chỉ khi Issue chuyển sang Closed mới được coi là hoàn thành.*

---

## 📂 Quản lý Tài liệu Bắt buộc (Mandatory Docs)
Dự án phải luôn duy trì và cập nhật 8 tệp tài liệu kỹ thuật ở thư mục gốc:
1. `IDEA.md` — Ý tưởng và giá trị cốt lõi của CodexBar.
2. `REQUIREMENTS.md` — Yêu cầu tính năng chi tiết.
3. `SPEC.md` — Đặc tả kỹ thuật (mô hình dữ liệu, CLI commands, cấu hình config.json).
4. `ARCH.md` — Kiến trúc hệ thống và sơ đồ Mermaid.
5. `README.md` — Hướng dẫn cài đặt và sử dụng cơ bản.
6. `DEPLOY_GUIDE.md` — Hướng dẫn build, đóng gói ứng dụng macOS và cài đặt CLI.
7. `CHANGELOGS.md` — Nhật ký thay đổi (liên kết với `CHANGELOG.md` qua symlink).
8. `CONTEXT.md` — Từ điển nghiệp vụ (Adaptive Refresh, Merge Icons, Safe Storage...).

---

## 🛠️ Các lệnh phát triển nhanh (Dev Commands)

* **Chạy thử app macOS**:
  ```bash
  ./Scripts/compile_and_run.sh
  ```
* **Chạy thử app kèm chạy bộ test**:
  ```bash
  ./Scripts/compile_and_run.sh --test
  ```
* **Format và Lint code**:
  ```bash
  make check
  ```
* **Đóng gói file cài đặt app `.app`**:
  ```bash
  ./Scripts/package_app.sh
  ```
* **Thêm task mới (tự động đẩy lên GitLab)**:
  ```bash
  python3 .devhooks/devtrack.py task-add "Tên task" --body "Phương án..."
  ```
