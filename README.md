# wusn-shell
- `达娃里氏`个人 Linux 管理面板。

## 项目简介
- 使用 shell 脚本命令封装的 Linux 管理面板，主要目的是为了提高 CentOS 7 环境下程序部署速度。
- 注意事项：
  - 本项目仅适用于 CentOS 7 系统，其他系统请自行修改脚本。
  - 脚本已测试通过 CentOS 7.9.2009 系统。
  - 本脚本仅专注于离线环境下程序的快速安装，如需特殊配置的，请自行修改程序配置项。

## 项目使用说明
- 手动上传 `wusn-shell` 文件夹到 `/usr/local/wusn-shell` 目录下。
- 运行 `chmod -R 755 /usr/local/wusn-shell`
- 运行 `./usr/local/wusn-shell/panel.sh`
- 愉快地使用吧~

## TODO
- 新增 redis 安装 / 卸载
- 新增 mysql 安装 / 卸载
- 新增 influxdb 安装 / 卸载
- 新增 vsftp 安装 / 卸载
- 新增 zookeeper 安装 / 卸载
- 新增 kafka 安装 / 卸载
- 新增 tomcat 安装 / 卸载
- 新增 R 安装 / 卸载
- 封装热挂载硬盘命令（硬盘扩容用）
- 新增 SELinux 开启 / 关闭功能
- 新增 docker 安装 / 卸载
- 新增 firewall 开启 / 关闭功能

## 关于项目
- 如果你觉得这个项目不错，请给个star，谢谢！
- 本项目使用 GPL 3.0 开源协议，请遵守协议。

## 作者联系方式：
1. **邮箱：** wu_shuainan@qq.com
2. **微信：** wu_shuainan
