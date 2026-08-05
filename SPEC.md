# SPEC.md — CodexBar

> Sinh từ [REQUIREMENTS.md](REQUIREMENTS.md).

## 1. Cấu trúc cấu hình (`config.json`)

Mặc định tệp cấu hình được lưu trữ tại `~/.config/codexbar/config.json` (hoặc tương thích ngược với `~/.codexbar/config.json`). Phân quyền tệp bắt buộc là `600` (chỉ chủ sở hữu được đọc/ghi).

### Cấu trúc JSON Schema
```json
{
  "version": 1,
  "refreshInterval": "adaptive", 
  "mergeIcons": false,
  "displayStyle": {
    "showLabels": true,
    "showBars": true,
    "resetStyle": "countdown"
  },
  "providers": {
    "openai": {
      "enabled": true,
      "apiKey": "sk-...",
      "customSettings": {}
    },
    "claude": {
      "enabled": true,
      "authMode": "oauth",
      "sessionCookies": {}
    }
  }
}
```

---

## 2. Mô hình dữ liệu (Data Models)

### 2.1 Provider Usage (Dữ liệu sử dụng)
Mỗi nhà cung cấp AI khi được phân tích sẽ trả về một cấu trúc dữ liệu chung:
```swift
struct ProviderUsage: Codable {
    let providerId: String
    let displayName: String
    let quotaLimit: Double // Tổng hạn mức hoặc số dư tối đa
    let quotaUsed: Double  // Dung lượng đã sử dụng
    let currency: String?   // Loại tiền tệ (nếu có: USD, CNY, EUR...)
    let resetTime: Date?   // Thời gian đặt lại hạn mức tiếp theo
    let status: ProviderStatus
}

enum ProviderStatus: String, Codable {
    case active      // Hoạt động bình thường
    case warning     // Gần hết hạn mức
    case exhausted   // Hết hạn mức
    case error       // Lỗi kết nối / xác thực
    case incident    // Nhà cung cấp gặp sự cố hệ thống
}
```

### 2.2 Cost Scan (Quét chi phí cục bộ)
Cấu trúc quét chi phí từ logs của IDE/CLI:
```swift
struct CostUsageRecord: Codable {
    let timestamp: Date
    let provider: String
    let model: String
    let inputTokens: Int
    let outputTokens: Int
    let estimatedCost: Double
}
```

---

## 3. Đặc tả CLI (`codexbar` CLI Specification)

CLI hỗ trợ cấu hình và truy vấn dữ liệu nhanh mà không cần giao diện đồ họa.

### 3.1 Các lệnh cấu hình (`config`)
* **Liệt kê danh sách provider:**
  `codexbar config providers`
* **Bật/Tắt provider:**
  `codexbar config enable --provider <id>`
  `codexbar config disable --provider <id>`
* **Cài đặt API key:**
  `codexbar config set-api-key --provider <id> --api-key <key>`
  * *Tùy chọn `--stdin` để truyền key bảo mật hơn qua đường dẫn pipe.*

### 3.2 Các lệnh thống kê chi phí & hạn ngạch
* **Truy vấn hạn ngạch hiện tại:**
  `codexbar usage --provider <id> [--json]`
* **Tính toán chi phí sử dụng cục bộ:**
  `codexbar cost --provider <id> [--days <count>] [--json]`

#### Dữ liệu JSON Output mẫu của `codexbar usage --json`:
```json
[
  {
    "provider": "claude",
    "name": "Claude",
    "limit": 1000000,
    "used": 450000,
    "percent": 45.0,
    "resetSeconds": 14200,
    "status": "active"
  }
]
```

---

## 4. Cơ chế làm mới Adaptive (Adaptive Refresh Policy)

Thuật toán làm mới thông minh (Adaptive) nhằm cân bằng giữa việc giữ dữ liệu mới và giảm thiểu số lượng request API/cookie đọc từ ổ đĩa.

### Nguyên lý hoạt động:
1. **Trạng thái nhàn rỗi (Idle state):** Khi không phát hiện hoạt động lập trình từ các IDE hoặc CLI trong 30 phút qua, tần suất làm mới giảm xuống còn **15 phút/lần**.
2. **Trạng thái hoạt động (Active state):** Khi phát hiện các tiến trình IDE (VS Code, Cursor, Xcode) đang chạy hoặc tệp nhật ký logs thay đổi kích thước, tần suất tăng lên tương ứng:
   * Có chỉnh sửa file: làm mới sau **1-2 phút**.
   * Chạy CLI AI: làm mới ngay lập tức (Trigger-based).
3. **Cận kề giới hạn (Near-limit state):** Nếu hạn ngạch sử dụng đã đạt trên 90%, tần suất tăng lên để cập nhật chính xác thời điểm hết hạn ngạch.

---

## 5. Tích hợp Keychain & Cookies

### 5.1 Safari Cookie Reader
* Đường dẫn lưu trữ: `~/Library/Containers/com.apple.Safari/Data/Library/Cookies/Cookies.binarycookies`
* **Ràng buộc:** Cần quyền Full Disk Access trên macOS.

### 5.2 Chromium Browser Cookie Decryptor (Chrome, Brave, Edge)
1. Đọc tệp SQLite cookies của trình duyệt tương ứng (ví dụ: `~/Library/Application Support/Google/Chrome/Default/Cookies`).
2. Truy vấn Keychain để lấy khóa giải mã **Safe Storage** của trình duyệt tương ứng (ví dụ: "Chrome Safe Storage").
3. Giải mã trường `encrypted_value` bằng khóa AES CBC.

---

**Nguồn:** [REQUIREMENTS.md](REQUIREMENTS.md)
**Người duyệt:** Chau Le (Product Owner)
**Trạng thái:** Approved
**Ngày duyệt:** 2026-08-05
