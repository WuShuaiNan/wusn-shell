#!/bin/bash

# 检查当前用户是否为root
if [ "$(id -u)" -ne 0 ]; then
    echo "错误：此脚本需要root权限才能运行，请使用sudo或切换至root用户执行。"
    exit 1
fi

# 获取脚本所在目录
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# 检查脚本所在目录下是否有RPM文件
if ! ls "${SCRIPT_DIR}"/*.rpm >/dev/null 2>&1; then
    echo "错误：脚本目录下未找到任何RPM包文件。"
    exit 1
fi

# 安装所有RPM包
echo "开始安装脚本目录下的所有RPM包..."
for rpm_file in "${SCRIPT_DIR}"/*.rpm; do
    # 获取包名（不含版本号等信息）
    pkg_name=$(rpm -qp --queryformat '%{NAME}' "$rpm_file" 2>/dev/null)

    # 检查该包是否已经安装
    if rpm -q "$pkg_name" >/dev/null 2>&1; then
        echo "提示：$pkg_name 包已经安装，跳过安装。"
        continue
    fi

    echo "正在安装: $(basename "$rpm_file") ..."
    rpm -ivh --nodeps "$rpm_file"
    if [ $? -ne 0 ]; then
        echo "警告：安装 $(basename "$rpm_file") 时出现问题。"
    fi
done

echo "RPM包安装完成。"
