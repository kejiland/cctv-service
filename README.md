# CCTV Service Bash 一键脚本

使用 `cctv-service.sh` 通过数字菜单一键部署和管理 `wjecee/tv-go:latest` Docker 服务。

## 一键运行

无需手动下载脚本，直接执行：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/kejiland/cctv-service/main/cctv-service.sh)
```

如果系统不支持进程替换，也可以执行：

```bash
curl -fsSL https://raw.githubusercontent.com/kejiland/cctv-service/main/cctv-service.sh -o cctv-service.sh
chmod +x cctv-service.sh
./cctv-service.sh
```

## 数字菜单

```text
1. 安装 / 更新并启动
2. 启动容器
3. 停止容器
4. 重启容器
5. 查看容器状态
6. 查看最近日志
7. 删除容器
0. 退出
```

## 默认配置

| 配置项 | 默认值 |
|---|---|
| Docker 镜像 | `wjecee/tv-go:latest` |
| 容器名称 | `cctv-service` |
| 服务端口 | `3000` |
| 时区 | `Asia/Shanghai` |
| 重启策略 | `unless-stopped` |
| V2Ray SOCKS5 代理 | `127.0.0.1:10808` |

选择 **1. 安装 / 更新并启动** 后，脚本会自动删除旧容器、通过 V2Ray 代理拉取最新镜像，并重新启动服务。

## 访问地址

部署成功后访问：

```text
http://服务器IP:3000
```

请确保服务器防火墙和云服务商安全组已放行 `3000` 端口。

## 系统要求

- Linux 系统
- 已安装并运行 Docker
- 已运行 V2Ray，并监听 `127.0.0.1:10808`
- 当前用户具备 Docker 操作权限

查看日志时按 `Ctrl+C` 返回菜单。
