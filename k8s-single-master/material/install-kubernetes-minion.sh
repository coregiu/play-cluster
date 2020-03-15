# !bin/sh 

if ! [ -x "$(command -v kubeadm)" ]; then 
	if [ $(docker images -q "quay.io/coreos/flannel:#{flannel.version}#-amd64"| wc -l) -eq 0 ];then
       docker pull #{flannel.image.source}#/coreos/flannel:#{flannel.version}#-amd64
       docker tag  #{flannel.image.source}#/coreos/flannel:#{flannel.version}#-amd64 quay.io/coreos/flannel:#{flannel.version}#-amd64
       docker rmi #{flannel.image.source}#/coreos/flannel:#{flannel.version}#-amd64
    fi
	if [ $(docker images -q "k8s.gcr.io/kube-proxy-amd64:#{k8s.version}#"| wc -l) -eq 0 ];then
       docker pull #{k8s.images.source}#/kube-proxy-amd64:#{k8s.version}#
       docker tag  #{k8s.images.source}#/kube-proxy-amd64:#{k8s.version}# k8s.gcr.io/kube-proxy-amd64:#{k8s.version}#
       docker rmi #{k8s.images.source}#/kube-proxy-amd64:#{k8s.version}#
    fi	
	if [ $(docker images -q "k8s.gcr.io/pause-amd64:#{k8s.version}#"| wc -l) -eq 0 ];then
       docker pull #{k8s.images.source}#/pause-amd64:#{k8s.version}#
       docker tag  #{k8s.images.source}#/pause-amd64:#{k8s.version}# k8s.gcr.io/kube-proxy-amd64:#{k8s.version}#
       docker rmi #{k8s.images.source}#/pause-amd64:#{k8s.version}#
    fi	
fi 