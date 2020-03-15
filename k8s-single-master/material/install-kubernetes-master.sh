# !bin/sh 

if ! [ -f /#{user}#/.kube/config ]; then
    yum install -y mlocate bash-completion; 
	updatedb;
	locate bash_completion;
	source /usr/share/bash-completion/bash_completion; 
	source <(kubectl completion bash); 
	kubeadm init --kubernetes-version=#{k8s.version}# \
             --image-repository #{k8s.images.source}# \
			 --pod-network-cidr=10.244.0.0/16 \
			 --service-cidr=10.96.0.0/12 \
			 --ignore-preflight-errors=Swap;
    export KUBECONFIG=/etc/kubernetes/admin.conf;
	mkdir -p /#{user}#/.kube;
	cp -i /etc/kubernetes/admin.conf /#{user}#/.kube/config;
	if [ $(docker images -q "quay.io/coreos/flannel:#{flannel.version}#-amd64"| wc -l) -eq 0 ];then
       docker pull #{flannel.image.source}#/coreos/flannel:#{flannel.version}#-amd64
       docker tag  #{flannel.image.source}#/coreos/flannel:#{flannel.version}#-amd64 quay.io/coreos/flannel:#{flannel.version}#-amd64
       docker rmi #{flannel.image.source}#/coreos/flannel:#{flannel.version}#-amd64
	   kubectl apply -f /tmp/kube-flannel.yml;
	   kubectl get pods -n kube-system;
    fi
fi  