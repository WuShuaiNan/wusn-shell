#!/bin/bash

# 定义颜色变量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 面板标题
PANEL_TITLE="CentOS 7 管理面板 v1.0"

# 获取当前脚本所在目录
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# 1.显示系统信息
show_system_info() {
    echo -e "\n${GREEN}=== 系统信息 ===${NC}"
    echo -e "主机名: $(hostname)"
    echo -e "操作系统: $(cat /etc/redhat-release)"
    echo -e "内核版本: $(uname -r)"
    echo -e "CPU信息: $(grep 'model name' /proc/cpuinfo | head -n1 | cut -d':' -f2 | sed 's/^[ \t]*//')"
    echo -e "内存使用: $(free -h | grep Mem | awk '{print $3"/"$2}')"
    echo -e "磁盘使用（根目录）: $(df -h / | tail -1 | awk '{print $3"/"$2}')"
}

# 2.服务管理
service_management() {
    check_root || return

    echo -e "\n${GREEN}=== 系统服务 ===${NC}"
    echo "1. 查看系统服务状态"
    echo "2. 查看 SELinux 状态"
    echo "3. 控制 SELinux"
    echo "4. DNF 镜像源切换管理"
    echo "5. 返回主菜单"

    read -p "请选择操作 [1-5]: " service_choice

    case $service_choice in
        1)
            read -p "输入服务名: " service_name
            systemctl status $service_name
            ;;
        2)
            echo -e "\n${BLUE}SELinux 状态:${NC}"
            sestatus
            ;;
        3)
            echo -e "\n${GREEN}=== SELinux 控制 ===${NC}"
            echo "当前 SELinux 状态: $(getenforce)"
            echo "1. 切换 SELinux 为宽容模式 (需永配置 SELinux 永久启用)"
            echo "2. 切换 SELinux 为严格模式 (需永配置 SELinux 永久启用)"
            echo "3. 永久禁用 SELinux (需重启)"
            echo "4. 永久启用 SELinux (需重启)"
            echo "5. 返回上一级"

            read -p "请选择操作 [1-5]: " selinux_choice

            case $selinux_choice in
                1)
                    setenforce 0
                    echo -e "${GREEN}SELinux 临时更改为宽容模式，重启失效${NC}"
                    ;;
                2)
                    setenforce 1
                    echo -e "${GREEN}SELinux 临时更改为严格模式，重启失效${NC}"
                    ;;
                3)
                    sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
                    echo -e "${GREEN}SELinux 已设置为永久禁用，重启生效${NC}"
                    ;;
                4)
                    sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
                    echo -e "${GREEN}SELinux 已设置为永久启用，重启生效${NC}"
                    ;;
                5)
                    ;;
                *)
                    echo -e "${RED}无效的选择!${NC}"
                    ;;
            esac
            ;;
        4)
            mirror_management
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
    echo "4. 防火墙管理"
    echo "5. 返回主菜单"

    read -p "请选择操作 [1-5]: " network_choice

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
            firewall_management
            ;;
        5)
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
    echo "4. 安装 Redis [6.2.19-1.el9_6.x86_64]"
    echo "5. 安装 Tomcat [9.0.60]"
    echo "6. 安装 Vsftpd [3.0.5-6.el9.x86_64]"
    echo "7. 返回主菜单"

    read -p "请选择操作 [1-7]: " install_choice

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
            echo -e "${BLUE}正在安装 Redis ...${NC}"
            if bash ${SCRIPT_DIR}/package/redis/install.sh; then
                echo -e "${GREEN} Redis 安装成功!${NC}"

                # Redis配置选项
                echo -e "\n${YELLOW}是否需要配置 Redis？${NC}"
                read -p "配置端口、密码等选项？(y/n): " configure_redis
                if [[ "$configure_redis" == "y" || "$configure_redis" == "Y" ]]; then
                    configure_redis_options
                fi
            else
                echo -e "${RED} Redis 安装失败! 错误代码: $?${NC}"
                read -p "按回车键继续..."
            fi
            ;;
        5)
            echo -e "${BLUE}正在安装 Tomcat ...${NC}"
            install_tomcat
            ;;
        6)
            echo -e "${BLUE}正在安装 Vsftpd ...${NC}"
            if bash ${SCRIPT_DIR}/package/vsftpd/install.sh; then
                echo -e "${GREEN} Vsftpd 安装成功!${NC}"
            else
                echo -e "${RED} Vsftpd 安装失败! 错误代码: $?${NC}"
                read -p "按回车键继续..."
            fi
            ;;
        7)
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
    echo "4. 卸载 Redis [6.2.19-1.el9_6.x86_64]"
    echo "5. 卸载 Tomcat [9.0.60]"
    echo "6. 卸载 Vsftpd [3.0.5-6.el9.x86_64]"
    echo "7. 返回主菜单"

    read -p "请选择操作 [1-7]: " uninstall_choice

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
            echo -e "${BLUE}正在卸载 Redis ...${NC}"
            if bash ${SCRIPT_DIR}/package/redis/uninstall.sh; then
                echo -e "${GREEN} Redis 卸载成功!${NC}"
            else
                echo -e "${RED} Redis 卸载失败! 错误代码: $?${NC}"
                read -p "按回车键继续..."
            fi
            ;;
        5)
            echo -e "${BLUE}正在卸载 Tomcat ...${NC}"
            uninstall_tomcat
            ;;
        6)
            echo -e "${BLUE}正在卸载 Vsftpd ...${NC}"
            if bash ${SCRIPT_DIR}/package/vsftpd/uninstall.sh; then
                echo -e "${GREEN} Vsftpd 卸载成功!${NC}"
            else
                echo -e "${RED} Vsftpd 卸载失败! 错误代码: $?${NC}"
                read -p "按回车键继续..."
            fi
            ;;
        7)
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
    echo -e "${YELLOW}======================================${NC}"
    echo -e "${YELLOW}    ${PANEL_TITLE}    ${NC}"
    echo -e "${YELLOW}======================================${NC}"
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

# 定义方法
# 检查是否是root用户
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}错误: 此操作需要root权限!${NC}" >&2
        return 1
    fi
    return 0
}

# 防火墙管理
firewall_management() {
    check_root || return

    while true; do
        echo -e "\n${GREEN}=== 防火墙管理 ===${NC}"
        echo "1. 查看防火墙状态"
        echo "2. 启动防火墙"
        echo "3. 停止防火墙"
        echo "4. 重启防火墙"
        echo "5. 查看开放的端口"
        echo "6. 开放端口"
        echo "7. 关闭端口"
        echo "8. 重载防火墙配置"
        echo "9. 查看活动区域"
        echo "10. 设置防火墙开机自启"
        echo "11. 关闭防火墙开机自启"
        echo "12. 返回上一级"

        read -p "请选择操作 [1-12]: " firewall_choice

        case $firewall_choice in
            1)
                echo -e "\n${BLUE}防火墙状态:${NC}"
                if systemctl is-active --quiet firewalld; then
                    echo -e "${GREEN}防火墙正在运行${NC}"
                    firewall-cmd --state
                else
                    echo -e "${RED}防火墙未运行${NC}"
                fi
                ;;
            2)
                systemctl start firewalld
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}防火墙启动成功${NC}"
                else
                    echo -e "${RED}防火墙启动失败${NC}"
                fi
                ;;
            3)
                systemctl stop firewalld
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}防火墙停止成功${NC}"
                else
                    echo -e "${RED}防火墙停止失败${NC}"
                fi
                ;;
            4)
                systemctl restart firewalld
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}防火墙重启成功${NC}"
                else
                    echo -e "${RED}防火墙重启失败${NC}"
                fi
                ;;
            5)
                if systemctl is-active --quiet firewalld; then
                    echo -e "\n${BLUE}当前开放的端口:${NC}"
                    firewall-cmd --list-all
                else
                    echo -e "${RED}防火墙未运行，无法查看端口信息${NC}"
                fi
                ;;
            6)
                read -p "请输入要开放的端口号: " port
                read -p "请输入协议 (tcp/udp): " protocol
                firewall-cmd --add-port=${port}/${protocol} --permanent
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}端口 ${port}/${protocol} 已添加到永久配置${NC}"
                else
                    echo -e "${RED}端口添加失败${NC}"
                fi
                ;;
            7)
                read -p "请输入要关闭的端口号: " port
                read -p "请输入协议 (tcp/udp): " protocol
                firewall-cmd --remove-port=${port}/${protocol} --permanent
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}端口 ${port}/${protocol} 已从永久配置中移除${NC}"
                else
                    echo -e "${RED}端口移除失败${NC}"
                fi
                ;;
            8)
                firewall-cmd --reload
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}防火墙配置重载成功${NC}"
                else
                    echo -e "${RED}防火墙配置重载失败${NC}"
                fi
                ;;
            9)
                echo -e "\n${BLUE}活动区域:${NC}"
                firewall-cmd --get-active-zones
                ;;
            10)
                systemctl enable firewalld
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}防火墙已设置为开机自启${NC}"
                else
                    echo -e "${RED}设置防火墙开机自启失败${NC}"
                fi
                ;;
            11)
                systemctl disable firewalld
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}防火墙已关闭开机自启${NC}"
                else
                    echo -e "${RED}关闭防火墙开机自启失败${NC}"
                fi
                ;;
            12)
                break
                ;;
            *)
                echo -e "${RED}无效的选择!${NC}"
                ;;
        esac
    done
}

# 镜像源管理
mirror_management() {
    check_root || return

    while true; do
        echo -e "\n${GREEN}=== 镜像源切换管理 ===${NC}"
        echo -e "\n${YELLOW}注意：如果您之前已经更改了镜像源，请先恢复默认镜像再进行切换。否则，镜像切换不生效！${NC}"
        echo "1. 查看当前镜像源配置"
        echo "2. 切换为阿里云镜像源"
        echo "3. 切换为清华大学镜像源"
        echo "4. 恢复默认官方镜像源"
        echo "5. 更新软件包缓存"
        echo "6. 返回上一级"

        read -p "请选择操作 [1-9]: " mirror_choice

        case $mirror_choice in
            1)
                echo -e "\n${BLUE}当前镜像源配置:${NC}"
                for file in /etc/yum.repos.d/[Rr]ocky*.repo; do
                    if [[ -f "$file" ]]; then
                        echo -e "\n${YELLOW}文件: $file${NC}"
                        grep -E "baseurl=|mirrorlist=" "$file"
                    fi
                done
                ;;
            2)
                echo -e "${BLUE}正在切换为阿里云镜像源...${NC}"
                backup_mirror_configs
                sed -e 's|^mirrorlist=|#mirrorlist=|g' \
                    -e 's|^#baseurl=http://mirror.centos.org/centos|baseurl=https://mirrors.aliyun.com/centos|g' \
                    -e 's|^baseurl=http://mirror.centos.org/centos|baseurl=https://mirrors.aliyun.com/centos|g' \
                    -i.bak \
                    /etc/yum.repos.d/CentOS-Base.repo 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}已成功切换为阿里云镜像源${NC}"
                else
                    echo -e "${RED}切换镜像源时出错${NC}"
                fi
                ;;
            3)
                echo -e "${BLUE}正在切换为清华大学镜像源...${NC}"
                backup_mirror_configs
                sed -e 's|^mirrorlist=|#mirrorlist=|g' \
                    -e 's|^#baseurl=http://mirror.centos.org/centos|baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos|g' \
                    -e 's|^baseurl=http://mirror.centos.org/centos|baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos|g' \
                    -i.bak \
                    /etc/yum.repos.d/CentOS-Base.repo 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}已成功切换为清华大学镜像源${NC}"
                else
                    echo -e "${RED}切换镜像源时出错${NC}"
                fi
                ;;
            4)
                echo -e "${BLUE}正在恢复默认官方镜像源...${NC}"
                # 恢复被注释掉的mirrorlist并恢复baseurl为默认值
                for file in /etc/yum.repos.d/CentOS-Base.repo; do
                    if [[ -f "$file" ]]; then
                        sed -i 's|^#mirrorlist=|mirrorlist=|g' "$file"
                        sed -i 's|^baseurl=.*centos.*|baseurl=http://mirror.centos.org/centos|g' "$file"
                    fi
                done
                echo -e "${GREEN}已恢复默认官方镜像源${NC}"
                ;;
            5)
                echo -e "${BLUE}正在更新软件包缓存...${NC}"
                yum clean all && yum makecache
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}软件包缓存更新完成${NC}"
                else
                    echo -e "${RED}软件包缓存更新失败${NC}"
                fi
                ;;
            6)
                break
                ;;
            *)
                echo -e "${RED}无效的选择!${NC}"
                ;;
        esac
    done
}

# 备份镜像配置文件
backup_mirror_configs() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_dir="/etc/yum.repos.d/backup_$timestamp"

    if [ ! -d "$backup_dir" ]; then
        mkdir -p "$backup_dir"
    fi

    cp /etc/yum.repos.d/CentOS-Base.repo "$backup_dir/" 2>/dev/null
    echo -e "${GREEN}已备份原始配置文件到 $backup_dir${NC}"
}

# Redis配置函数
configure_redis_options() {
    echo -e "\n${GREEN}=== Redis 配置 ===${NC}"

    # 查找Redis配置文件
    REDIS_CONF=""
    if [ -f "/etc/redis/redis.conf" ]; then
        REDIS_CONF="/etc/redis/redis.conf"
    elif [ -f "/etc/redis.conf" ]; then
        REDIS_CONF="/etc/redis.conf"
    else
        echo -e "${YELLOW}未找到 Redis 配置文件，请手动指定路径${NC}"
        read -p "请输入 Redis 配置文件路径: " REDIS_CONF
        if [ ! -f "$REDIS_CONF" ]; then
            echo -e "${RED}指定的配置文件不存在！${NC}"
            return 1
        fi
    fi

    echo -e "${BLUE}找到 Redis 配置文件: $REDIS_CONF${NC}"

    # 配置端口号
    read -p "请输入端口号 (默认 6379): " redis_port
    if [ -n "$redis_port" ]; then
        sed -i "s/^port .*/port $redis_port/" $REDIS_CONF
        echo -e "${GREEN}端口号已设置为: $redis_port${NC}"
    else
        echo -e "${BLUE}使用默认端口号: 6379${NC}"
    fi

    # 配置外网访问
        echo -e "\n${YELLOW}配置 Redis 外网访问${NC}"
        read -p "是否允许 Redis 外网访问？(y/n): " enable_external_access
        if [[ "$enable_external_access" == "y" || "$enable_external_access" == "Y" ]]; then
            # 设置为监听所有IP地址
            sed -i 's/^bind .*/bind 0.0.0.0/' $REDIS_CONF
            echo -e "${GREEN}已允许 Redis 外网访问${NC}"

            # 提示用户需要配置防火墙
            echo -e "${YELLOW}注意: 请确保防火墙已开放 Redis 端口${NC}"
        else
            # 限制为仅本地访问
            sed -i 's/^bind .*/bind 127.0.0.1/' $REDIS_CONF
            echo -e "${BLUE}已限制 Redis 仅本地访问${NC}"
        fi

    # 配置密码
    read -p "请输入密码 (留空则不设置密码): " redis_password
    if [ -n "$redis_password" ]; then
        # 删除原有的密码配置行
        sed -i '/^requirepass/d' $REDIS_CONF
        # 添加新的密码配置行
        echo "requirepass $redis_password" >> $REDIS_CONF
        echo -e "${GREEN}密码已设置${NC}"
    else
        # 移除密码配置
        sed -i '/^requirepass/d' $REDIS_CONF
        echo -e "${BLUE}未设置密码${NC}"
    fi

    # 配置开机自启
    echo -e "\n${YELLOW}配置 Redis 开机自启${NC}"
    read -p "是否设置 Redis 开机自启？(y/n): " enable_autostart
    if [[ "$enable_autostart" == "y" || "$enable_autostart" == "Y" ]]; then
        # 检查systemctl是否可用
        if command -v systemctl &> /dev/null; then
            systemctl enable redis &> /dev/null
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Redis 开机自启已设置成功！${NC}"
            else
                echo -e "${RED}设置 Redis 开机自启失败！请检查 Redis 服务是否存在。${NC}"
            fi
        else
            echo -e "${RED}系统不支持 systemctl 命令，无法设置开机自启。${NC}"
        fi
    else
        echo -e "${BLUE}跳过设置开机自启。${NC}"
    fi

    echo -e "${GREEN}Redis 配置完成！请重启 Redis 服务使配置生效。${NC}"

    # 询问是否重启Redis服务
    read -p "是否现在重启 Redis 服务？(y/n): " restart_redis
    if [[ "$restart_redis" == "y" || "$restart_redis" == "Y" ]]; then
        systemctl restart redis
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Redis 服务重启成功！${NC}"
        else
            echo -e "${RED}Redis 服务重启失败！请手动重启。${NC}"
        fi
    fi
}

# Tomcat安装
install_tomcat() {
    # 检查Tomcat压缩包是否存在
    TOMCAT_PACKAGE="${SCRIPT_DIR}/package/tomcat/apache-tomcat-9.0.60.tar"

    if [ ! -f "$TOMCAT_PACKAGE" ]; then
        echo -e "${RED}Tomcat压缩包不存在: $TOMCAT_PACKAGE${NC}"
        read -p "按回车键继续..."
        return 1
    fi

    # 获取安装目录
    read -p "请输入Tomcat安装目录 (默认 /usr/local/tomcat): " tomcat_install_dir
    if [ -z "$tomcat_install_dir" ]; then
        tomcat_install_dir="/usr/local/tomcat"
    fi

    echo -e "${BLUE}正在将Tomcat解压到 $tomcat_install_dir ...${NC}"

    # 检查安装目录是否已存在
    if [ -d "$tomcat_install_dir" ]; then
        echo -e "${YELLOW}目录 $tomcat_install_dir 已存在${NC}"
        read -p "是否覆盖该目录? (y/N): " overwrite_choice
        case "$overwrite_choice" in
            y|Y|yes|YES)
                echo -e "${BLUE}正在清空目录 $tomcat_install_dir ...${NC}"
                rm -rf "$tomcat_install_dir"/*
                if [ $? -ne 0 ]; then
                    echo -e "${RED}清空目录 $tomcat_install_dir 失败，请检查权限${NC}"
                    read -p "按回车键继续..."
                    return 1
                fi
                ;;
            *)
                echo -e "${YELLOW}取消安装${NC}"
                read -p "按回车键继续..."
                return 0
                ;;
        esac
    else
        # 创建安装目录（如果不存在）
        mkdir -p "$tomcat_install_dir"
        if [ $? -ne 0 ]; then
            echo -e "${RED}创建目录 $tomcat_install_dir 失败，请检查权限${NC}"
            read -p "按回车键继续..."
            return 1
        fi
    fi

    # 解压Tomcat
    tar -xvf "$TOMCAT_PACKAGE" -C "$tomcat_install_dir" --strip-components=1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Tomcat解压成功!${NC}"

        # 赋予目录下所有文件权限
        echo -e "${BLUE}正在设置文件权限...${NC}"
        chmod -R 755 "$tomcat_install_dir"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Tomcat安装完成，所有文件权限已设置为755!${NC}"
        else
            echo -e "${RED}设置文件权限失败!${NC}"
        fi
    else
        echo -e "${RED}Tomcat解压失败!${NC}"
    fi

    # 询问是否配置为系统服务
    echo -e "\n${YELLOW}是否将Tomcat配置为系统服务（守护进程）？${NC}"
    read -p "配置为系统服务？(y/n): " configure_service
    if [[ "$configure_service" == "y" || "$configure_service" == "Y" ]]; then
        # 检测系统类型并创建相应服务文件
        if [ -f /etc/redhat-release ] && grep -q "release 7" /etc/redhat-release; then
            # CentOS 7 使用 systemd
            cat > "/usr/lib/systemd/system/tomcat.service" <<EOF
[Unit]
Description=Tomcat Service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=${tomcat_install_dir}/bin/catalina.sh start
ExecReload=${tomcat_install_dir}/bin/catalina.sh restart
ExecStop=${tomcat_install_dir}/bin/catalina.sh stop
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
        else
            # 对于较老的系统，创建init.d脚本
            cat > "/etc/init.d/tomcat" <<EOF
#!/bin/bash
# chkconfig: 35 80
# description: Tomcat service

. /etc/rc.d/init.d/functions

TOMCAT_HOME=${tomcat_install_dir}

start() {
    echo -n "Starting Tomcat: "
    daemon \$TOMCAT_HOME/bin/catalina.sh start
    RETVAL=\$?
    echo
    [ \$RETVAL -eq 0 ] && touch /var/lock/subsys/tomcat
    return \$RETVAL
}

stop() {
    echo -n "Shutting down Tomcat: "
    \$TOMCAT_HOME/bin/catalina.sh stop
    RETVAL=\$?
    echo
    [ \$RETVAL -eq 0 ] && rm -f /var/lock/subsys/tomcat
    return \$RETVAL
}

case "\$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    *)
        echo "Usage: \$0 {start|stop|restart}"
        exit 1
esac

exit \$?
EOF
            chmod +x /etc/init.d/tomcat
        fi
    fi

    # 询问是否设置开机自启
    echo -e "\n${YELLOW}是否设置Tomcat开机自启？${NC}"
    read -p "设置开机自启？(y/n): " enable_autostart
    if [[ "$enable_autostart" == "y" || "$enable_autostart" == "Y" ]]; then
        if [ -f /etc/redhat-release ] && grep -q "release 7" /etc/redhat-release; then
            # CentOS 7 使用 systemctl
            systemctl enable tomcat &>/dev/null
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Tomcat已设置为开机自启！${NC}"
            else
                echo -e "${RED}设置Tomcat开机自启失败！${NC}"
            fi
        else
            # 较老的系统使用 chkconfig
            chkconfig --add tomcat
            chkconfig tomcat on
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Tomcat已设置为开机自启！${NC}"
            else
                echo -e "${RED}设置Tomcat开机自启失败！${NC}"
            fi
        fi
    else
        echo -e "${BLUE}已跳过设置Tomcat开机自启。${NC}"
    fi

    # 询问是否启动Tomcat服务
    read -p "是否现在启动 Tomcat 服务？(y/n): " start_tomcat
    if [[ "$start_tomcat" == "y" || "$start_tomcat" == "Y" ]]; then
        if [ -f /etc/redhat-release ] && grep -q "release 7" /etc/redhat-release; then
            # CentOS 7 使用 systemctl
            systemctl start tomcat
        else
            # 较老的系统使用 service
            service tomcat start
        fi
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Tomcat 服务启动成功！${NC}"
        else
            echo -e "${RED}Tomcat 服务启动失败！${NC}"
        fi
    fi

    read -p "按回车键继续..."
}

# Tomcat卸载
uninstall_tomcat() {
    # 获取Tomcat安装目录
    read -p "请输入Tomcat安装目录 (默认 /usr/local/tomcat): " tomcat_install_dir
    if [ -z "$tomcat_install_dir" ]; then
        tomcat_install_dir="/usr/local/tomcat"
    fi

    # 检查目录是否存在
    if [ ! -d "$tomcat_install_dir" ]; then
        echo -e "${RED}指定的Tomcat目录不存在: $tomcat_install_dir${NC}"
        read -p "按回车键继续..."
        return 1
    fi

    echo -e "${BLUE}正在停止Tomcat服务...${NC}"
    # 检测系统类型并停止服务
    if [ -f /etc/redhat-release ] && grep -q "release 7" /etc/redhat-release; then
        # CentOS 7 使用 systemctl
        systemctl stop tomcat &>/dev/null
        systemctl disable tomcat &>/dev/null
    else
        # 较老的系统使用 service 和 chkconfig
        service tomcat stop &>/dev/null
        chkconfig --del tomcat &>/dev/null
    fi

    echo -e "${BLUE}正在删除Tomcat目录...${NC}"
    # 删除Tomcat目录
    rm -rf "$tomcat_install_dir"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Tomcat目录删除成功: $tomcat_install_dir${NC}"
    else
        echo -e "${RED}Tomcat目录删除失败: $tomcat_install_dir${NC}"
        read -p "按回车键继续..."
        return 1
    fi

    echo -e "${BLUE}正在移除Tomcat服务文件...${NC}"
    # 检测系统类型并删除相应服务文件
    if [ -f /etc/redhat-release ] && grep -q "release 7" /etc/redhat-release; then
        # CentOS 7 删除systemd服务文件
        if [ -f "/usr/lib/systemd/system/tomcat.service" ]; then
            rm -f /usr/lib/systemd/system/tomcat.service
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Tomcat systemd服务文件移除成功${NC}"
            else
                echo -e "${RED}Tomcat systemd服务文件移除失败${NC}"
            fi
        else
            echo -e "${YELLOW}未找到Tomcat systemd服务文件${NC}"
        fi
        
        # 重新加载systemd配置
        systemctl daemon-reload
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}systemd配置刷新成功${NC}"
        else
            echo -e "${RED}systemd配置刷新失败${NC}"
        fi
    else
        # 较老的系统删除init.d脚本
        if [ -f "/etc/init.d/tomcat" ]; then
            rm -f /etc/init.d/tomcat
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Tomcat init.d脚本移除成功${NC}"
            else
                echo -e "${RED}Tomcat init.d脚本移除失败${NC}"
            fi
        else
            echo -e "${YELLOW}未找到Tomcat init.d脚本${NC}"
        fi
    fi

    echo -e "${GREEN}Tomcat卸载完成!${NC}"
    read -p "按回车键继续..."
}

# 启动主菜单
main_menu