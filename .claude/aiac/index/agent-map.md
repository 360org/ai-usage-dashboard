### 360 Agent Map

- Nguồn: 26 tệp; 155 symbol; 0 tín hiệu domain.
- Mục tiêu: chọn đúng file/symbol trước khi đọc sâu; chống viết trùng/viết thừa.
- Quy tắc: đọc map trước; nếu cần flow/impact/caller/callee hoặc bug fail lần 3 thì dùng 360-codegraph.

#### Domain signals
- Chưa có tín hiệu domain chuyên biệt.

#### Hotspots
- `docs/site.js` — 39 tín hiệu
- `Sources/CodexBarCore/Resources/Plugins/sucrase-3.35.1.min.js` — 29 tín hiệu
- `Scripts/ci_swift_test_by_suite.py` — 16 tín hiệu
- `Sources/CodexBarCore/Resources/Plugins/synthetic.js` — 15 tín hiệu
- `Sources/CodexBarCore/Resources/Plugins/openai.js` — 9 tín hiệu
- `Sources/CodexBarCore/Resources/Plugins/zai.js` — 8 tín hiệu
- `Scripts/mimo-usage.py` — 7 tín hiệu
- `Sources/CodexBarCore/Resources/Plugins/deepgram.js` — 5 tín hiệu
- `Sources/CodexBarCore/Resources/Plugins/poe.js` — 5 tín hiệu
- `Sources/CodexBarCore/Resources/Plugins/sub2api.js` — 5 tín hiệu
- `Sources/CodexBarCore/Resources/Plugins/openrouter.js` — 4 tín hiệu
- `Sources/CodexBarCore/Resources/Plugins/provider-plugin-prelude.js` — 4 tín hiệu

#### Symbol mẫu
- `TestSelection` (class) — `Scripts/ci_swift_test_by_suite.py:18`
- `RunStats` (class) — `Scripts/ci_swift_test_by_suite.py:25`
- `parse_args` (function) — `Scripts/ci_swift_test_by_suite.py:64`
- `run_command` (function) — `Scripts/ci_swift_test_by_suite.py:83`
- `swift_test_list` (function) — `Scripts/ci_swift_test_by_suite.py:99`
- `append_github_summary` (function) — `Scripts/ci_swift_test_by_suite.py:147`
- `print_timing_summary` (function) — `Scripts/ci_swift_test_by_suite.py:162`
- `chunks` (function) — `Scripts/ci_swift_test_by_suite.py:168`
- `shard_groups` (function) — `Scripts/ci_swift_test_by_suite.py:173`
- `prioritized_suites` (function) — `Scripts/ci_swift_test_by_suite.py:185`
- `filtered_suites_for_environment` (function) — `Scripts/ci_swift_test_by_suite.py:192`
- `filter_for` (function) — `Scripts/ci_swift_test_by_suite.py:205`
- `run_group` (function) — `Scripts/ci_swift_test_by_suite.py:209`
- `retry_selections_individually` (function) — `Scripts/ci_swift_test_by_suite.py:216`
- `main` (function) — `Scripts/ci_swift_test_by_suite.py:232`
- `summary_rows` (function) — `Scripts/ci_swift_test_by_suite.py:42`
- `parse_session_usage` (function) — `Scripts/mimo-usage.py:29`
- `aggregate_usage` (function) — `Scripts/mimo-usage.py:72`
- `write_cache` (function) — `Scripts/mimo-usage.py:147`
- `fmt_tokens` (function) — `Scripts/mimo-usage.py:163`
- `short_status` (function) — `Scripts/mimo-usage.py:171`
- `human_summary` (function) — `Scripts/mimo-usage.py:178`
- `main` (function) — `Scripts/mimo-usage.py:218`
- `integer` (function) — `Sources/CodexBarCore/Resources/Plugins/clawrouter.js:48`
- `micros` (function) — `Sources/CodexBarCore/Resources/Plugins/clawrouter.js:54`
- `monthlyReset` (function) — `Sources/CodexBarCore/Resources/Plugins/clawrouter.js:58`
- `_optionalChain` (function) — `Sources/CodexBarCore/Resources/Plugins/clinepass.js:1`
- `defineProvider` (function) — `Sources/CodexBarCore/Resources/Plugins/codexbar-plugin.d.ts:179`
- `optionalNumber` (function) — `Sources/CodexBarCore/Resources/Plugins/crof.js:26`
- `optionalNumber` (function) — `Sources/CodexBarCore/Resources/Plugins/crof.ts:32`
