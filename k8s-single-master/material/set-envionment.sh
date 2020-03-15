# !bin/sh

BASE_REPO=/etc/yum.repos.d/CentOS-Base.repo
if [ -f ${BASE_REPO}  ];then
   rm -rf ${BASE_REPO} 
fi

DOCKER_REPO=/etc/yum.repos.d/docker-ce.repo
if [ ! -f ${DOCKER_REPO} ];then
   curl -o ${DOCKER_REPO} #{yum.repos.docker}#
fi

NEW_BASE_REPO=/etc/yum.repos.d/CentOS-7-NEW.repo
if [ ! -f ${NEW_BASE_REPO} ];then
   curl -o ${NEW_BASE_REPO}  #{yum.repos.base}#
   yum clean all
   yum makecache
   yum -y upgrade
fi
  
ntp_setted=$(grep -rn "#mssh-k8s-ntp-setting" /etc/ntp.conf | wc -l)
if [ $ntp_setted -eq 0 ];then  
    yum –y remove ntpdate*
    yum –y install ntpdate
	cat >> /etc/ntp.conf <<EOF
#mssh-k8s-ntp-setting
server #{system.ntp.server}#
EOF
    crontab -l > conf 
	echo "*/15 * * * * /usr/sbin/ntpdate -u #{system.ntp.server}# >/dev/null 2>&1" >> conf 
	crontab conf 
	rm -f conf
fi


swap_setted=$(grep -rn "#mssh-k8s-swap-setting" /etc/sysctl.conf | wc -l)
if [ $swap_setted -eq 0 ];then  
   	cat >> /etc/sysctl.conf <<EOF
#mssh-k8s-swap-setting
vm.swappiness = 0
EOF
   swapoff -a
   swapon -a
   sysctl -p
   sed -i 's/.*swap.*/#&/' /etc/fstab
   swapoff -a
   sed -i  's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
   setenforce 0
fi


security_setted=$(grep -rn "#mssh-k8s-security-setting" /etc/security/limits.conf | wc -l)
if [ $security_setted -eq 0 ];then 
   cat >> /etc/security/limits.conf <<EOF
#mssh-k8s-security-setting
# End of file
* soft nproc 65536
* hard nproc 65536
* soft nofile 65536
* hard nofile 65536
* soft  memlock  unlimited
* hard memlock  unlimited
EOF
fi

if [ ! -f /etc/sysctl.d/k8s.conf ];then
   cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
vm.swappiness=0
EOF
   modprobe br_netfilter
   sysctl -p /etc/sysctl.d/k8s.conf
fi 

if [ ! -f /etc/sysconfig/modules/ipvs.modules ];then
   cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
   chmod 755 /etc/sysconfig/modules/ipvs.modules
   bash /etc/sysconfig/modules/ipvs.modules
   lsmod | grep -e ip_vs -e nf_conntrack_ipv4
fi