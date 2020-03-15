# !/bin/sh
hostname=$(hostname)
echo "Start config sshd ${hostname}"
sudo sed -i '13i PermitRootLogin yes\nPasswordAuthentication yes' /etc/ssh/sshd_config
sudo systemctl restart sshd