#!/bin/bash

# 定义颜色变量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 面板标题
PANEL_TITLE="达娃里氏的 Linux 管理面板 v1.0"

# 获取当前脚本所在目录
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# 检查是否是root用户
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}错误: 此操作需要root权限!${NC}" >&2
        return 1
    fi
    return 0
}

# 1.显示系统信息
show_system_info() {
    echo -e "\n${GREEN}=== 系统信息 ===${NC}"
    echo -e "主机名: $(hostname)"
    echo -e "操作系统: $(cat /etc/centos-release)"
    echo -e "内核版本: $(uname -r)"
    echo -e "CPU信息: $(grep 'model name' /proc/cpuinfo | head -n1 | cut -d':' -f2 | sed 's/^[ \t]*//')"
    echo -e "内存使用: $(free -h | grep Mem | awk '{print $3"/"$2}')"
    echo -e "磁盘使用（根目录）: $(df -h / | tail -1 | awk '{print $3"/"$2}')"
}

# 2.服务管理
service_management() {
    check_root || return

    echo -e "\n${GREEN}=== 服务管理 ===${NC}"
    echo "1. 查看服务状态"
    echo "2. 启动服务"
    echo "3. 停止服务"
    echo "4. 重启服务"
    echo "5. 返回主菜单"

    read -p "请选择操作 [1-5]: " service_choice

    case $service_choice in
        1)
            read -p "输入服务名: " service_name
            systemctl status $service_name
            ;;
        2)
            read -p "输入服务名: " service_name
            systemctl start $service_name
            ;;
        3)
            read -p "输入服务名: " service_name
            systemctl stop $service_name
            ;;
        4)
            read -p "输入服务名: " service_name
            systemctl restart $service_name
            ;;
        5)
            return
            ;;
        *)
            echo -e "${RED}无效的选择!${NC}"
            ;;
    esac

    # 递归调用以继续服务管理
    service_management
}

# 3.用户管理
user_management() {
    check_root || return

    echo -e "\n${GREEN}=== 用户管理 ===${NC}"
    echo "1. 列出所有用户"
    echo "2. 添加用户"
    echo "3. 删除用户"
    echo "4. 修改用户密码"
    echo "5. 返回主菜单"

    read -p "请选择操作 [1-5]: " user_choice

    case $user_choice in
        1)
            echo -e "\n${BLUE}系统用户列表:${NC}"
            cut -d: -f1 /etc/passwd | sort
            ;;
        2)
            read -p "输入用户名: " username
            useradd $username
            passwd $username
            ;;
        3)
            read -p "输入要删除的用户名: " username
            userdel -r $username
            ;;
        4)
            read -p "输入用户名: " username
            passwd $username
            ;;
        5)
            return
            ;;
        *)
            echo -e "${RED}无效的选择!${NC}"
            ;;
    esac

    # 递归调用以继续用户管理
    user_management
}

# 4.网络工具
network_tools() {
    echo -e "\n${GREEN}=== 网络工具 ===${NC}"
    echo "1. 查看IP地址"
    echo "2. 测试网络连通性"
    echo "3. 查看路由表"
    echo "4. 返回主菜单"

    read -p "请选择操作 [1-4]: " network_choice

    case $network_choice in
        1)
            echo -e "\n${BLUE}IP地址信息:${NC}"
            ip addr show
            ;;
        2)
            read -p "输入要测试的地址(如8.8.8.8): " test_addr
            ping -c 4 $test_addr
            ;;
        3)
            echo -e "\n${BLUE}路由表信息:${NC}"
            ip route
            ;;
        4)
            return
            ;;
        *)
            echo -e "${RED}无效的选择!${NC}"
            ;;
    esac

    # 递归调用以继续网络工具
    network_tools
}

# 5.程序安装
program_install() {
    echo -e "\n${GREEN}=== 程序安装 ===${NC}"
    echo "1. 安装 OpenJDK [1.8.0.412.b08]"
    echo "2. 安装 Telnet [0.17-66]"
    echo "3. 安装 Wget [1.14-18]"
    echo "4. 返回主菜单"

    read -p "请选择操作 [1-4]: " install_choice

    case $install_choice in
        1)
            echo -e "${BLUE}正在安装 OpenJDK ...${NC}"
            if bash ${SCRIPT_DIR}/package/openjdk/install.sh; then
                echo -e "${GREEN} OpenJDK 安装成功!${NC}"
            else
                echo -e "${RED} OpenJDK 安装失败! 错误代码: $?${NC}"
                read -p "按回车键继续..."
            fi
            ;;
        2)
            echo -e "${BLUE}正在安装 Telnet ...${NC}"
            if bash ${SCRIPT_DIR}/package/telnet/install.sh; then
                echo -e "${GREEN} Telnet 安装成功!${NC}"
            else
                echo -e "${RED} Telnet 安装失败! 错误代码: $?${NC}"
                read -p "按回车键继续..."
            fi
            ;;
        3)
            echo -e "${BLUE}正在安装 Wget ...${NC}"
            if bash ${SCRIPT_DIR}/package/wget/install.sh; then
                echo -e "${GREEN} Wget 安装成功!${NC}"
            else
                echo -e "${RED} Wget 安装失败! 错误代码: $?${NC}"
                read -p "按回车键继续..."
            fi
            ;;
        4)
            return
            ;;
        *)
            echo -e "${RED}无效的选择!${NC}"
            ;;
    esac

    # 递归一下
    program_install
}

# 6.程序卸载
program_uninstall() {
    echo -e "\n${GREEN}=== 程序卸载 ===${NC}"
    echo "1. 卸载 OpenJDK [1.8.0.412.b08]"
    echo "2. 卸载 Telnet [0.17-66]"
    echo "3. 卸载 Wget [1.14-18]"
    echo "4. 返回主菜单"

    read -p "请选择操作 [1-3]: " uninstall_choice

    case $uninstall_choice in
        1)
            echo -e "${BLUE}正在卸载 OpenJDK ...${NC}"
            if bash ${SCRIPT_DIR}/package/openjdk/uninstall.sh; then
                echo -e "${GREEN} OpenJDK 卸载成功!${NC}"
            else
                echo -e "${RED} OpenJDK 卸载失败! 错误代码: $?${NC}"
                read -p "按回车键继续..."
            fi
            ;;
        2)
            echo -e "${BLUE}正在卸载 Telnet ...${NC}"
            if bash ${SCRIPT_DIR}/package/telnet/uninstall.sh; then
                echo -e "${GREEN} Telnet 卸载成功!${NC}"
            else
                echo -e "${RED} Telnet 卸载失败! 错误代码: $?${NC}"
                read -p "按回车键继续..."
            fi
            ;;
        3)
            echo -e "${BLUE}正在卸载 Wget ...${NC}"
            if bash ${SCRIPT_DIR}/package/wget/uninstall.sh; then
                echo -e "${GREEN} Wget 卸载成功!${NC}"
            else
                echo -e "${RED} Wget 卸载失败! 错误代码: $?${NC}"
                read -p "按回车键继续..."
            fi
            ;;
        4)
            return
            ;;
        *)
            echo -e "${RED}无效的选择!${NC}"
            ;;
    esac

    # 递归一下
    program_uninstall
}

# 主菜单
main_menu() {
    clear
    echo -e "${YELLOW}=================================${NC}"
    echo -e "${YELLOW}    ${PANEL_TITLE}    ${NC}"
    echo -e "${YELLOW}=================================${NC}"
    echo "1. 系统信息"
    echo "2. 服务管理"
    echo "3. 用户管理"
    echo "4. 网络工具"
    echo "5. 程序安装"
    echo "6. 程序卸载"
    echo "7. 退出"

    read -p "请选择功能 [1-7]: " main_choice

    case $main_choice in
        1)
            show_system_info
            ;;
        2)
            service_management
            ;;
        3)
            user_management
            ;;
        4)
            network_tools
            ;;
        5)
            program_install
            ;;
        6)
            program_uninstall
            ;;
        7)
            echo -e "${GREEN}感谢使用，再见!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}无效的选择，请重新输入!${NC}"
            ;;
    esac

    # 按任意键返回主菜单
    read -n 1 -s -r -p "按任意键返回主菜单..."
    main_menu
}

# 启动主菜单
main_menu