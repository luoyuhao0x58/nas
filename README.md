# 自建 NAS 的 ALL-in-One 方案

## 简要说明

当前项目给的只是作为 NAS 服务集合的容器化配置。方便使用的前提还是需要先安装好虚拟机，并在虚拟机中安装好 docker。

- 已注册可用的域名，用于获取免费泛域名证书，并且所有服务用同一后缀
- 域名托管在 cloudflare ，并获取了用于ssl证书认证的 DNS 编辑[令牌](https://dash.cloudflare.com/profile/api-tokens)
- 部署 PVE 作为宿主机
  - 在宿主机上配置显卡直通，硬盘直通等
  - 调整防火墙，放通服务相关的端口
  - UPS 等相关软件的安装等（可选）
- 安装最新的 debian 系统作为虚拟机系统
  - 需要一个叫nas的用户和组，用于数据的统一管理
  - 配置 docker，调整仓库镜像
  - 配置直通的显卡加速、挂载直通的硬盘等
  - 执行 docker compose 管理服务
- 配置和数据可以自行灵活备份

## 快速启动

```shell
touch .env  # 创建环境变量文件，环境变量内容见后文
docker compose up -d  # 启动服务，已经支持和包含的服务见后文
```

## 自定义配置

因为 docker compose 自身是支持通过增加 compose.override.yml 文件来覆盖默认文件的。因此可以单独搞一个目录，然后通过软连接管理。

举例：

```shell
mkdir .private
mkdir .private/volumes  # 存放挂载进入容器的数据
touch .private/env  # 存放环境变量
touch .private/compose.override.yml  # 存放自定义容器修改的内容

ln -s .private/env ./.env
ln -s .private/compose.override.yml ./
```

环境变量可以这样配置（举例）
```ini
DOCKER_REPO=nas/service
IMAGE_VERSION=20260101
DOMAIN=nas.xyz
ADMIN_PASSWD=admin
NAS_UID=996
NAS_GID=996
NAS_PASSWD=nas
VOLUME_ROOT_PATH=./.private/volumes
LDAP_URI=ldap://127.0.0.1/
```

在 compose.override.yml 中，就可以用类似
```shell
vol_common_ssl:
    driver: local
    driver_opts:
      o: bind
      type: none
      device: "${VOLUME_ROOT_PATH}/common/ssl"
```
的方式改变挂载点。

通过
```shell
docker compose config
```
可以验证最终生成的配置。


## 环境变量说明

| **变量**      | **说明**                             | **是否必须** | **举例**          |
| ------------- | ------------------------------------ | ------------ | ----------------- |
| DOCKER_REPO   | 用于项目构建和拉取的仓库前缀         | 是           | nas/service       |
| IMAGE_VERSION | 用于项目构建和拉取的镜像版本         | 是           | 20260101          |
| DOMAIN        | 用于解析的域名                       | 是           | nas.xyz           |
| ADMIN_PASSWD  | 服务里跟超管相关的服务共用同一个密码 | 是           | admin             |
| ADMIN_EMAIL   | 服务里跟超管相关的通知邮箱 | 是           | admin@gmail.com            |
| NAS_UID       | nas用户的id                          | 是           | 233               |
| NAS_GID       | nas组的id                            | 是           | 233               |
| NAS_PASSWORD    | nas用户的密码                        | 是           | nas               |
| LDAP_URI      | LDAP用户认证服务的链接               | 是           | ldap://127.0.0.1/ |
| CLOUDFLARE_API_TOKEN      | 用于免费证书生成验证的 cloudflare 的令牌  | 是 | xxx-xxx-xxx |


## 服务说明

| **服务** | **用途**         | **官网**                  | **域名前缀** |
| -------- | ---------------- | ------------------------- | ------------ |
| caddy    | 反响代理         | https://caddyserver.com/  |              |
| openldap | 用户信息存储服务 | https://www.openldap.org/ | ldap         |
| samba    | 文件共享服务     | https://www.samba.org/    | smb          |
| authelia | 单点登录认证服务 | https://www.authelia.com/ | auth         |
| jellyfin | 多媒体服务       | https://jellyfin.org/     | media        |
