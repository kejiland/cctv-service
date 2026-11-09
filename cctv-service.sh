#!/usr/bin/env bash

set -u

CONTAINER_NAME="cctv-service"
IMAGE="wjecee/tv-go:latest"
PORT="3000"
TIMEZONE="Asia/Shanghai"

pause() {
  read -r -p $'\n按回车键返回主菜单...' _
}

is_docker_available() {
  command -v docker >/dev/null 2>&1
}

show_status() {
  echo "正在检查容器状态..."
  if ! is_docker_available; then
    echo "错误：未找到 Docker，请先安装 Docker。"
    return 1
  fi
  if docker ps -a --format '{{.Names}}' | grep -Fxq "$CONTAINER_NAME"; then
    docker ps -a --filter "name=^/${CONTAINER_NAME}$" --format '容器：{{.Names}}\n状态：{{.Status}}\n端口：{{.Ports}}'
  else
    echo "容器 $CONTAINER_NAME 不存在。"
  fi
}

install_or_update() {
  if ! is_docker_available; then
    echo "错误：未找到 Docker，请先安装 Docker。"
    return 1
  fi

  echo "[1/4] 删除旧容器..."
  docker rm "$CONTAINER_NAME" -f 2>/dev/null || true

  echo "[2/4] 删除旧镜像..."
  docker rmi "$IMAGE" 2>/dev/null || true

  echo "[3/4] 配置 V2Ray 代理并拉取最新镜像..."
  export ALL_PROXY="socks5://127.0.0.1:10808"
  export all_proxy="$ALL_PROXY"
  export HTTP_PROXY="$ALL_PROXY"
  export HTTPS_PROXY="$ALL_PROXY"
  docker pull "$IMAGE" || return 1
  echo "[4/4] 启动容器..."
  docker run -d \
    --name "$CONTAINER_NAME" \
    --restart=unless-stopped \
    -e "TZ=$TIMEZONE" \
    -p "$PORT:$PORT" \
    "$IMAGE" || return 1

  echo
  echo "部署完成！"
  echo "访问地址：http://服务器IP:$PORT"
  docker ps --filter "name=^/${CONTAINER_NAME}$"
}

start_container() {
  docker start "$CONTAINER_NAME" 2>/dev/null && echo "容器已启动。" || echo "启动失败：容器不存在或已在运行。"
}

stop_container() {
  docker stop "$CONTAINER_NAME" 2>/dev/null && echo "容器已停止。" || echo "停止失败：容器不存在或已停止。"
}

restart_container() {
  docker restart "$CONTAINER_NAME" 2>/dev/null && echo "容器已重启。" || echo "重启失败：容器不存在。"
}

remove_container() {
  read -r -p "确定删除容器 $CONTAINER_NAME？输入 yes 确认：" confirm
  if [[ "$confirm" == "yes" ]]; then
    docker rm -f "$CONTAINER_NAME" 2>/dev/null && echo "容器已删除。" || echo "容器不存在。"
  else
    echo "已取消。"
  fi
}

view_logs() {
  if docker ps -a --format '{{.Names}}' | grep -Fxq "$CONTAINER_NAME"; then
    docker logs --tail 100 -f "$CONTAINER_NAME"
  else
    echo "容器不存在。"
  fi
}

while true; do
  clear
  echo "========================================"
  echo "       CCTV TV-Go Docker 管理脚本"
  echo "========================================"
  echo "1. 安装 / 更新并启动"
  echo "2. 启动容器"
  echo "3. 停止容器"
  echo "4. 重启容器"
  echo "5. 查看容器状态"
  echo "6. 查看最近日志"
  echo "7. 删除容器"
  echo "0. 退出"
  echo "========================================"
  read -r -p "请输入选项 [0-7]：" choice
  echo

  case "$choice" in
    1) install_or_update; pause ;;
    2) start_container; pause ;;
    3) stop_container; pause ;;
    4) restart_container; pause ;;
    5) show_status; pause ;;
    6) view_logs ;;
    7) remove_container; pause ;;
    0) echo "已退出。"; exit 0 ;;
    *) echo "无效选项，请重新输入。"; pause ;;
  esac
done


