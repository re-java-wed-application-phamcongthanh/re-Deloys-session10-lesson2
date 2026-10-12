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
