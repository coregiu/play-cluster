# !/bin/sh
hostname=$(hostname)
echo "Start config sshd ${hostname}..."
sudo sed -i '13i PermitRootLogin yes\nPasswordAuthentication yes' /etc/ssh/sshd_config
sudo systemctl restart sshd
echo "Finish config sshd."
echo "Start to config network ${1}..."
sudo sed -i "5i IPADDR=\"${1}\"\nNETMASK=\"255.255.255.240\"" /etc/sysconfig/network-scripts/ifcfg-eth0
sudo sed -i 's/BOOTPROTO=\"dhcp\"/BOOTPROTO=\"static\"/g' /etc/sysconfig/network-scripts/ifcfg-eth0
sudo systemctl restart network
echo "Finish config the ${hostname}'s sshd and ip:${1}"