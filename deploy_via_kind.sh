#!/bin/bash

# 安装docker
## 安装软件包
yum install -y yum-utils device-mapper-persistent-data lvm2
## 添加yum国内源
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
## 安装docker
yum -y install docker-ce-19.03.15-3.el7 docker-ce-cli-19.03.15-3.el7 containerd.io
systemctl start docker && systemctl enable docker

## 设置阿里云镜像仓库和cgroupdriver
cat > /etc/docker/daemon.json << EOF
{
	"exec-opts": ["native.cgroupdriver=systemd"],
  	"registry-mirrors": ["https://b9pmyelo.mirror.aliyuncs.com"]
}
EOF

systemctl daemon-reload
systemctl restart docker

# 安装kubectl
## 添加阿里云YUM软件源
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-$(uname -p)
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

## 安装kubectl
yum install -y kubectl-1.18.2
yum install -y bash-completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
kubectl completion bash >/etc/bash_completion.d/kubectl

# 安装k8s
## 安装kind
dist=$(uname -p)
case $dist in
  "x86_64")
  kind_dist="kind-linux-amd64"
  ;;
  "aarch64")
  kind_dist="kind-linux-arm64"
  ;;
  *)
    echo "current platform($dist) is not supported..."
    exit
  ;;
esac

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/$kind_dist
chmod +x ./kind
mv ./kind /usr/bin/kind

## 安装git
yum install -y git
## 下载安装kubeflow脚本
git clone https://github.com/yangchenwen/kubeflow-manifests.git

## 创建k8s
cd kubeflow-manifests || exit
kind create cluster --config=kind/kind-config.yaml --name=kubeflow --image=kindest/node:v1.18.2

# 安装kubeflow
python install.py

