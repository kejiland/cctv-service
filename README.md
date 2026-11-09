# CCTV Service 一键部署脚本

使用 `cctv-service.sh` 通过数字菜单管理 `wjecee/tv-go:latest` Docker 服务。

## 快速开始

下载并运行脚本：

```bash
curl -fsSL https://raw.githubusercontent.com/kejiland/cctv-service/main/cctv-service.sh -o cctv-service.sh
chmod +x cctv-service.sh
./cctv-service.sh
```

也可以直接运行本地脚本：

```bash
bash cctv-service.sh
```

## 管理菜单

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

## 部署配置

| 配置项 | 默认值 |
|---|---|
| Docker 镜像 | `wjecee/tv-go:latest` |
| 容器名称 | `cctv-service` |
| 服务端口 | `3000` |
| 时区 | `Asia/Shanghai` |
| 重启策略 | `unless-stopped` |
| V2Ray SOCKS5 代理 | `127.0.0.1:10808` |

选择“安装 / 更新并启动”后，脚本会自动：

1. 删除旧的 `cctv-service` 容器；
2. 删除旧镜像并拉取最新镜像；
3. 使用 `127.0.0.1:10808` 作为 V2Ray SOCKS5 代理；
4. 创建并启动容器；
5. 设置容器异常退出后自动重启。

## 访问服务

部署成功后访问：

```text
http://服务器IP:3000
```

请确保服务器防火墙和云服务商安全组已放行 `3000` 端口。

## 系统要求

- Linux 系统
- 已安装 Docker
- 已运行 V2Ray，并监听 `127.0.0.1:10808`（仅拉取镜像时使用代理）
- 具备 Docker 操作权限

## 注意事项

- 脚本仅负责部署和管理 `cctv-service` 容器。
- 删除容器不会删除 Docker 镜像之外的其他数据。
- 查看日志时按 `Ctrl+C` 返回菜单。
