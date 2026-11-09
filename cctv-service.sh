#!/usr/bin/env bash

# CCTV Service 一键部署与管理脚本
# 用法：bash <(curl -fsSL https://raw.githubusercontent.com/kejiland/cctv-service/main/cctv-service.sh)

set -u

CONTAINER_NAME="cctv-service"
IMAGE="wjecee/tv-go:latest"
PORT="3000"
TIMEZONE="Asia/Shanghai"
PROXY="socks5://127.0.0.1:10808"

command_exists() { command -v "$1" >/dev/null 2>&1; }

pause() {
  read -r -p $'\n按回车键返回主菜单...' _
}

require_docker() {
  if ! command_exists docker; then
    echo "错误：未检测到 Docker，请先安装 Docker。"
    return 1
  fi
  if ! docker info >/dev/null 2>&1; then
    echo "错误：Docker 服务未运行，或当前用户没有 Docker 权限。"
    return 1
  fi
}

container_exists() {
  docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1
}

install_or_update() {
  require_docker || return 1

  echo "[1/3] 删除旧容器..."
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

  echo "[2/3] 使用 V2Ray 代理拉取最新镜像..."
  ALL_PROXY="$PROXY" all_proxy="$PROXY" HTTP_PROXY="$PROXY" HTTPS_PROXY="$PROXY" \
    docker pull "$IMAGE" || return 1

  echo "[3/3] 启动容器..."
  docker run -d \
    --name "$CONTAINER_NAME" \
    --restart=unless-stopped \
    -e "TZ=$TIMEZONE" \
    -p "$PORT:$PORT" \
    "$IMAGE" || return 1

  echo
  echo "部署完成！"
  echo "访问地址：http://服务器IP:$PORT"
}

start_container() {
  require_docker || return 1
  if ! container_exists; then
    echo "容器不存在，请先选择 1 安装 / 更新并启动。"
    return 1
  fi
  docker start "$CONTAINER_NAME" >/dev/null && echo "容器已启动。"
}

stop_container() {
  require_docker || return 1
  if ! container_exists; then
    echo "容器不存在。"
    return 1
  fi
  docker stop "$CONTAINER_NAME" >/dev/null && echo "容器已停止。"
}

restart_container() {
  require_docker || return 1
  if ! container_exists; then
    echo "容器不存在，请先选择 1 安装 / 更新并启动。"
    return 1
  fi
  docker restart "$CONTAINER_NAME" >/dev/null && echo "容器已重启。"
}

show_status() {
  require_docker || return 1
  if container_exists; then
    docker ps -a --filter "name=^/${CONTAINER_NAME}$" \
      --format '容器：{{.Names}}\n状态：{{.Status}}\n端口：{{.Ports}}'
  else
    echo "容器 $CONTAINER_NAME 不存在。"
  fi
}

view_logs() {
  require_docker || return 1
  if container_exists; then
    docker logs --tail 100 -f "$CONTAINER_NAME"
  else
    echo "容器不存在。"
  fi
}

remove_container() {
  require_docker || return 1
  if ! container_exists; then
    echo "容器不存在。"
    return 1
  fi
  read -r -p "确定删除容器 $CONTAINER_NAME？输入 yes 确认：" confirm
  if [[ "$confirm" == "yes" ]]; then
    docker rm -f "$CONTAINER_NAME" >/dev/null && echo "容器已删除。"
  else
    echo "已取消。"
  fi
}

main_menu() {
  while true; do
    clear 2>/dev/null || true
    echo "========================================"
    echo "       CCTV TV-Go 一键管理脚本"
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
}

main_menu

