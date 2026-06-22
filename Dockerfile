FROM alpine:3.20

RUN apk add --no-cache wget tar socat

WORKDIR /app

COPY NOTICE.txt .

RUN wget https://github.com/SagerNet/sing-box/releases/download/v1.13.13/sing-box-1.13.13-linux-amd64.tar.gz && \
    tar -zxvf sing-box-1.13.13-linux-amd64.tar.gz && \
    mv sing-box-1.13.13-linux-amd64/sing-box ./ && \
    rm -rf sing-box-1.13.13-linux-amd64*

COPY config.json .

# 创建简单的健康响应文件
RUN mkdir -p /www && echo "OK" > /www/index.html

EXPOSE 8080

# 启动 socat，监听 8080，对 HTTP 请求返回 OK，其他流量转发到 8081（VLESS）
# 注意：这里假设 VLESS 监听 8081，且 socat 会将非 HTTP 的连接原样转发。
CMD sh -c 'socat TCP-LISTEN:8080,fork,reuseaddr SYSTEM:"\
  read -r line; \
  if echo \"\$line\" | grep -q \"^GET /health\"; then \
    echo -e \"HTTP/1.1 200 OK\\r\\nContent-Length: 2\\r\\n\\r\\nOK\"; \
  else \
    exec socat - TCP:127.0.0.1:8081; \
  fi" & ./sing-box run -c config.json'
