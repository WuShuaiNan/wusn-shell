# 定义颜色变量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查是否以root权限运行
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}错误: 此脚本需要root权限运行!${NC}" >&2
        return 1
    fi
    return 0
}

# 安装 vsftpd
install_vsftpd() {
    echo -e "${BLUE}安装vsftpd...${NC}"

    # 使用本地rpm包安装
    SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
    RPM_FILE="$SCRIPT_DIR/vsftpd-3.0.2-25.el7.x86_64.rpm"

    if [ -f "$RPM_FILE" ]; then
        rpm -ivh "$RPM_FILE"
    else
        echo -e "${RED}未找到本地rpm包，尝试使用yum安装vsftpd${NC}"
        yum install -y vsftpd
    fi

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}vsftpd安装成功${NC}"
    else
        echo -e "${RED}vsftpd安装失败${NC}"
        return 1
    fi
}

# 配置 vsftpd
configure_vsftpd() {
    echo -e "${BLUE}创建FTP用户...${NC}"

    read -p "请输入FTP用户名 (默认: ftp): " ftp_username
    if [ -z "$ftp_username" ]; then
        ftp_username="ftp"
    fi

    read -p "请输入FTP用户组 (默认: ftp): " ftp_group
    if [ -z "$ftp_group" ]; then
        ftp_group="ftp"
    fi

    # 创建用户组
    if ! getent group $ftp_group > /dev/null 2>&1; then
        groupadd $ftp_group
        echo -e "${GREEN}创建用户组 $ftp_group${NC}"
    fi

    # 创建用户
    if id "$ftp_username" &>/dev/null; then
        echo -e "${YELLOW}用户 $ftp_username 已存在${NC}"
    else
        useradd -g $ftp_group -d /home/$ftp_username -s /sbin/nologin $ftp_username
        echo -e "${GREEN}创建用户 $ftp_username${NC}"
    fi

    # 设置用户密码
    while true; do
        read -p "请选择密码设置方式 [1]手动输入 [2]自动生成 (默认: 1): " password_choice
        if [ -z "$password_choice" ]; then
            password_choice="1"
        fi

        case $password_choice in
            1)
                # 手动输入密码
                read -s -p "请输入用户 $ftp_username 的密码: " user_password
                echo
                if [ -z "$user_password" ]; then
                    echo -e "${RED}密码不能为空，请重新输入${NC}"
                    continue
                fi
                echo "$ftp_username:$user_password" | chpasswd
                echo -e "${GREEN}用户 $ftp_username 密码设置成功${NC}"
                break
                ;;
            2)
                # 自动生成密码
                generated_password=$(openssl rand -base64 12)
                echo "$ftp_username:$generated_password" | chpasswd
                echo -e "${GREEN}用户 $ftp_username 密码已自动生成${NC}"
                echo -e "${BLUE}生成的密码是: $generated_password${NC}"
                echo -e "${YELLOW}请妥善保存此密码${NC}"
                break
                ;;
            *)
                echo -e "${RED}无效选择，请输入 1 或 2${NC}"
                ;;
        esac
    done

    echo -e "${BLUE}配置FTP数据目录和vsftpd...${NC}"

    # 获取FTP数据目录路径
    read -p "请输入FTP数据目录路径 (默认: /data/ftp): " ftp_data_dir
    if [ -z "$ftp_data_dir" ]; then
        ftp_data_dir="/data/ftp"
    fi

    # 创建数据目录
    mkdir -p "$ftp_data_dir"

    # 设置目录权限
    chmod 755 "$ftp_data_dir"

    # 设置目录所有者
    if id "$ftp_username" &>/dev/null; then
        chown $ftp_username:$ftp_group "$ftp_data_dir"
        echo -e "${GREEN}数据目录 $ftp_data_dir 配置完成${NC}"
    else
        chown ftp:$ftp_group "$ftp_data_dir"
        echo -e "${YELLOW}用户 $ftp_username 不存在，使用默认用户 ftp${NC}"
    fi

    # 备份原始配置文件
    if [ -f /etc/vsftpd/vsftpd.conf ]; then
        cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak
        echo -e "${GREEN}已备份原始配置文件到 /etc/vsftpd/vsftpd.conf.bak${NC}"
    fi

    # 询问配置选项
    read -p "请输入FTP监听端口 (默认: 21): " ftp_port
    if [ -z "$ftp_port" ]; then
        ftp_port=21
    fi

    read -p "是否启用被动模式? (y/n, 默认: n): " passive_mode
    if [ -z "$passive_mode" ]; then
        passive_mode="n"
    fi

    # 询问匿名访问配置
    read -p "是否启用匿名访问? (y/n, 默认: n): " anonymous_access
    if [ -z "$anonymous_access" ]; then
        anonymous_access="n"
    fi

    # 如果启用匿名访问，询问是否允许匿名用户写入
    anonymous_write_access="n"
    if [ "$anonymous_access" = "y" ]; then
        read -p "是否允许匿名用户写入? (y/n, 默认: n): " anonymous_write_access
        if [ -z "$anonymous_write_access" ]; then
            anonymous_write_access="n"
        fi

        # 创建匿名访问目录
        anon_root="/var/ftp/pub"
        mkdir -p "$anon_root"
        chmod 755 /var/ftp
        chmod 755 "$anon_root"
        chown ftp:ftp "$anon_root"
        echo -e "${GREEN}匿名访问目录 $anon_root 创建完成${NC}"
    fi

    # 创建新的配置文件
    cat > /etc/vsftpd/vsftpd.conf << EOF
# 服务器配置
listen=YES
listen_ipv6=NO
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
ftpd_banner=Welcome to FTP service.

# 端口配置
listen_port=$ftp_port

# 用户配置
local_enable=YES
write_enable=YES
local_umask=022

# 安全配置
anonymous_enable=$([ "$anonymous_access" = "y" ] && echo "YES" || echo "NO")
ascii_upload_enable=YES
ascii_download_enable=YES
chroot_local_user=YES
chroot_list_enable=NO

# 数据目录配置
local_root=$ftp_data_dir

# 匿名用户配置
anon_world_readable_only=$([ "$anonymous_access" = "y" ] && echo "NO" || echo "YES")
anon_upload_enable=$([ "$anonymous_write_access" = "y" ] && echo "YES" || echo "NO")
anon_mkdir_write_enable=$([ "$anonymous_write_access" = "y" ] && echo "YES" || echo "NO")
anon_other_write_enable=$([ "$anonymous_write_access" = "y" ] && echo "YES" || echo "NO")
anon_root=$([ "$anonymous_access" = "y" ] && echo "/var/ftp/pub" || echo "")

# 被动模式配置
pasv_enable=$([ "$passive_mode" = "y" ] && echo "YES" || echo "NO")
pasv_min_port=30000
pasv_max_port=31000
pasv_address=$([ "$external_access" = "y" ] && echo "$external_ip" || echo "")

# 日志配置
log_ftp_protocol=YES
vsftpd_log_file=/var/log/vsftpd.log

# 其他配置
pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES
EOF
    echo -e "${GREEN}vsftpd配置完成${NC}"
}

# 启动并启用vsftpd服务
start_vsftpd() {
    echo -e "${BLUE}启动vsftpd服务...${NC}"

    # 启动服务
    systemctl start vsftpd

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}vsftpd服务启动成功${NC}"
    else
        echo -e "${RED}vsftpd服务启动失败${NC}"
        return 1
    fi

    # 设置开机自启
    systemctl enable vsftpd

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}vsftpd服务已设置为开机自启${NC}"
    else
        echo -e "${RED}设置vsftpd开机自启失败${NC}"
    fi
}

# 主函数
main() {
    echo -e "${YELLOW}======================================${NC}"
    echo -e "${YELLOW}    VSFTPD 安装和配置脚本    ${NC}"
    echo -e "${YELLOW}======================================${NC}"

    # 检查root权限
    check_root || return 1

    # 安装 vsftpd
    install_vsftpd || return 1

    # 配置 vsftpd
    configure_vsftpd

    # 启动服务
    start_vsftpd || return 1

    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}    VSFTPD 安装和配置完成!    ${NC}"
    echo -e "${GREEN}======================================${NC}"
    echo -e "${BLUE}数据目录: $ftp_data_dir${NC}"
    echo -e "${BLUE}监听端口: $ftp_port${NC}"
    echo -e "${BLUE}被动模式端口范围: 30000-31000${NC}"
    if [ "$external_access" = "y" ]; then
        echo -e "${BLUE}外网访问IP: $external_ip${NC}"
    fi
    if [ "$anonymous_access" = "y" ]; then
        echo -e "${BLUE}已启用匿名访问${NC}"
        if [ "$anonymous_write_access" = "y" ]; then
            echo -e "${BLUE}匿名用户可写入${NC}"
        else
            echo -e "${BLUE}匿名用户只读${NC}"
        fi
        echo -e "${BLUE}匿名访问目录: /var/ftp/pub${NC}"
    fi
}

# 执行主函数
main
