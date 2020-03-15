# !bin/sh


setted=$(grep -rn "#{docker.registry.mirror}#" /etc/docker/daemon.json | wc -l)
if [ $setted -eq 0 ];then 
   yum install -y docker-ce
   mkdir -p /etc/docker
   tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["#{docker.registry.mirror}#"],
  "exec-opts":["native.cgroupdriver=systemd"]
}
EOF
   systemctl daemon-reload
   systemctl restart docker
   systemctl enable docker
fi
