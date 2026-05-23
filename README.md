# cygnus-rs

跨平台的JLU Drcom实现

## 使用

```shell
# 创建用户数据
cygnus user create -u <username> -p <password> -m <mac_addr> -f cygnus.usr
# 使用用户数据登录
cygnus auth -f cygnus.usr
```

> MAC地址以`:`分隔

## OpenWrt 部署

如果日志显示 UTC 时间而非本地时间，需要设置时区：

```bash
# 安装 zoneinfo-asia 包（如已安装可跳过）
apk update && apk add zoneinfo-asia

# 修复时区符号链接（重启后会丢失，建议加入启动脚本）
ln -sf /usr/share/zoneinfo/Asia/Shanghai /tmp/localtime
ln -sf /tmp/localtime /etc/localtime
```
