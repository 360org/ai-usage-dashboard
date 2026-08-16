### Codegraph cục bộ

- Nguồn: 33 tệp mã; 2 liên kết import cục bộ.
- Hiển thị: 2/2 liên kết theo thứ tự ổn định.
- Phạm vi: chỉ import resolve được trong project; package ngoài không được đưa vào context.

```mermaid
graph TD
  n_646f63732f736974652e6a73["docs/site.js"] --> n_646f63732f736974652d6c6f63616c65732e6d6a73["docs/site-locales.mjs"]
  n_536372697074732f636865636b2d736974652d6c6f63616c65732e6d6a73["Scripts/check-site-locales.mjs"] --> n_646f63732f736974652d6c6f63616c65732e6d6a73["docs/site-locales.mjs"]
```
