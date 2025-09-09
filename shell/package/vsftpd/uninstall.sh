#!/bin/bash

# 检查当前用户是否为root
if [ "$(id -u)" -ne 0 ]; then
    echo "错误：此脚本需要root权限才能执行RPM卸载操作。"
    exit 1
fi

# 获取当前目录
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 检查目录中是否有RPM文件
rpm_files=$(ls "$DIR"/*.rpm 2>/dev/null | wc -l)
if [ "$rpm_files" -eq 0 ]; then
    echo "当前目录 ($DIR) 中没有找到RPM包。"
    exit 0
fi

echo "找到以下RPM包："
ls "$DIR"/*.rpm

# 确认操作
read -p "确定要卸载这些RPM包吗？(y/n) " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "操作已取消。"
    exit 0
fi

# 卸载所有RPM包
for rpm_pkg in "$DIR"/*.rpm; do
    echo "正在卸载: $(basename "$rpm_pkg")..."
    rpm -e --nodeps "$(rpm -qp --nosignature "$rpm_pkg")"
    if [ $? -eq 0 ]; then
        echo "卸载成功: $(basename "$rpm_pkg")"
    else
        echo "卸载失败: $(basename "$rpm_pkg")"
    fi
done

echo "所有RPM包卸载完成。"