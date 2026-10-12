# Bài 2: Đóng Gói Ứng Dụng Web Backend Bằng Single-Stage Dockerfile

## 🎯 1. Mục Tiêu
- Xây dựng một ứng dụng REST API bằng Node.js / Express.
- Đóng gói ứng dụng thành Docker Image chuẩn hóa với tệp `Dockerfile` Single-stage chứa đầy đủ các chỉ thị tiêu chuẩn: `FROM`, `WORKDIR`, `ENV`, `COPY`, `RUN`, `EXPOSE`, `CMD`.
- Khởi chạy container `app-single-stage`, ánh xạ cổng `8080:3000` và kiểm tra phản hồi API bằng `curl`.

---

## 📁 2. Cấu Trúc Thư Mục
```text
bai2/
├── .dockerignore      # Loại bỏ file không cần thiết khi build context
├── Dockerfile         # Chỉ thị đóng gói Single-stage
├── package.json       # Khai báo metadata và dependencies (Express)
├── server.js          # Mã nguồn REST API Node.js
└── README.md          # Tài liệu hướng dẫn & báo cáo kết quả
```

---

## 🛠️ 3. Mã Nguồn Ứng Dụng & Cấu Hình Docker

### 3.1. Mã nguồn `package.json`
```json
{
  "name": "ex2-backend",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

### 3.2. Mã nguồn `server.js`
```javascript
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    status: 'success',
    message: 'Hello from Docker Single-stage!'
  });
});

app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
```

### 3.3. Tệp `.dockerignore`
Giúp giảm dung lượng Build Context gửi lên Docker daemon và ngăn ghi đè `node_modules` từ máy host:
```text
node_modules
npm-debug.log
.git
.gitignore
README.md
```

### 3.4. Tệp `Dockerfile` Single-Stage
```dockerfile
# Sử dụng base image node:18-alpine
FROM node:18-alpine

# Thiết lập thư mục làm việc
WORKDIR /app

# Thiết lập biến môi trường
ENV PORT=3000

# Sao chép file cấu hình dependencies
COPY package*.json ./

# Cài đặt dependencies
RUN npm install

# Sao chép mã nguồn ứng dụng
COPY . .

# Khai báo cổng ứng dụng
EXPOSE 3000

# Lệnh khởi chạy container (exec form)
CMD ["node", "server.js"]
```

**Phân tích các chỉ thị:**
- `FROM node:18-alpine`: Base image Alpine Linux siêu nhẹ (~170MB khi cài Node.js).
- `WORKDIR /app`: Đặt thư mục làm việc mặc định, mọi câu lệnh tiếp theo sẽ chạy tại đây.
- `ENV PORT=3000`: Khai báo biến môi trường khả dụng trong container.
- `COPY package*.json ./`: Sao chép file cấu hình trước để tận dụng Docker Build Cache. Nếu mã nguồn thay đổi mà `package.json` không đổi, layer `RUN npm install` sẽ được cache lại.
- `RUN npm install`: Cài đặt thư viện phụ thuộc Express.
- `COPY . .`: Sao chép mã nguồn ứng dụng vào container.
- `EXPOSE 3000`: Tài liệu hóa cổng ứng dụng lắng nghe bên trong container.
- `CMD ["node", "server.js"]`: Exec form (dạng mảng JSON) giúp tiến trình nhận trực tiếp tín hiệu `SIGTERM` / `SIGINT` từ Docker daemon để dừng an toàn (graceful shutdown).

---

## 🚀 4. Quy Trình Build & Kiểm Thử

### Bước 1: Build Docker Image
```bash
docker build -t hw-backend:v1 .
```

### Bước 2: Khởi chạy Container
Khởi chạy container ở chế độ chạy ngầm (`-d`), ánh xạ cổng host `8080` vào cổng container `3000`:
```bash
docker run -d --name app-single-stage -p 8080:3000 hw-backend:v1
```

### Bước 3: Kiểm tra trạng thái và log container
```bash
docker ps --filter "name=app-single-stage"
docker logs app-single-stage
```

**Kết quả:**
```text
CONTAINER ID   IMAGE           COMMAND                  CREATED         STATUS         PORTS                                         NAMES
0de3a336207e   hw-backend:v1   "docker-entrypoint.s…"   7 seconds ago   Up 6 seconds   0.0.0.0:8080->3000/tcp, [::]:8080->3000/tcp   app-single-stage
Server listening on port 3000
```

---

### Bước 4: Kiểm tra phản hồi API bằng `curl`
```bash
curl -i http://localhost:8080/
```

**Kết quả phản hồi thực tế:**
```http
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: application/json; charset=utf-8
Content-Length: 64
ETag: W/"40-upZb7Fps+hszzRU9BoKtiCsmGCQ"
Date: Mon, 12 Oct 2026 06:04:49 GMT
Connection: keep-alive
Keep-Alive: timeout=5

{"status":"success","message":"Hello from Docker Single-stage!"}
```
> ✅ **Xác nhận**: Trả về đúng mã HTTP `200 OK` cùng chuỗi JSON `{"status":"success","message":"Hello from Docker Single-stage!"}`.

---

### Bước 5: Dọn dẹp tài nguyên
```bash
docker stop app-single-stage && docker rm app-single-stage
```
