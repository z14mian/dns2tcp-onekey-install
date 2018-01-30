#!/usr/bin/env bash
#=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
#export PATH

#config_file="/etc/dns2tcpd.conf"

check_root(){
	[[ $EUID != 0 ]] && echo -e "${Error} 当前账号非ROOT(或没有ROOT权限)，无法继续操作，请使用${Green_background_prefix} sudo su ${Font_color_suffix}来获取临时ROOT权限（执行后会提示输入当前账号的密码）。" && exit 1
}
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
	bit=`uname -m`
}

Write_configuration(){
read -p "请输入服务器ip地址（默认为0.0.0.0）：" ip
[[ -z "$ip" ]] && ip="0.0.0.0"
while true
do
	read -p "请输入NS域名：" url
	if [[ ${url} != "" ]]; then
		break
	fi
done






	cat > "/etc/dns2tcpd.conf"<<-EOF
	listen = ${ip}
	port = 53
	user = nobody
	chroot = /tmp
	domain = ${url}
	resources = ssh:127.0.0.1:22,socks:127.0.0.1:1082,http:127.0.0.1:3128
EOF
}

install(){
echo -e "${Info} 安装开发包"
yum -y groupinstall "Development Tools"

echo -e "${Info} 下载"
if ! wget --no-check-certificate https://github.com/alex-sector/dns2tcp/archive/v0.5.2.tar.gz; then
	echo -e "${Error} 服务端源码下载失败 !" && exit 1
else
	echo -e "${Info} 服务端源码下载完成 !"
fi


tar zxf v0.5.2.tar.gz
cd v0.5.2.tar.gz
./configure  
make & make install
#read -p "安装完成，按任意键继续"
Write_configuration
#echo "安装完成"
echo -e "\033[33m 安装完成 \033[0m"
#dns2tcpd -f /etc/dns2tcpd.conf -d 2
#echo "运行"
}


check_root
check_sys
if [[ ${release} == "centos" ]]; then
	install
fi
