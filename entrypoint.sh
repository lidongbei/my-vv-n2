#!/bin/sh
# 用 socat 监听 8082 端口，对任何请求返回 HTTP 204
socat TCP-LISTEN:8080,fork,reuseaddr SYSTEM:'echo -e "HTTP/1.1 204 No Content\r\n\r\n"' &
# 启动 sing-box
exec ./sing-box run -c config.json