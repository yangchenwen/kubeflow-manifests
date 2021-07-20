#!/bin/bash

## 准备环境
# 关闭防火墙
systemctl stop firewalld
systemctl disable firewalld

# 关闭selinux
sed -i 's/enforcing/disabled/' /etc/selinux/config  # 永久
setenforce 0  # 临时

# 关闭swap
swapoff -a  # 临时
sed -ri 's/.*swap.*/#&/' /etc/fstab    # 永久

# 将桥接的IPv4流量传递到iptables的链
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system  # 生效

# 时间同步
yum install ntpdate -y
ntpdate ntp1.aliyun.com

# 开启ipvs
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4

## 所有节点安装Docker/kubeadm/kubelet
### 安装Docker
## 安装软件包
yum install -y yum-utils device-mapper-persistent-data lvm2
## 添加yum国内源
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum -y install docker-ce-19.03.15-3.el7 docker-ce-cli-19.03.15-3.el7 containerd.io
systemctl enable docker && systemctl start docker

cat > /etc/docker/daemon.json << EOF
{
	"exec-opts": ["native.cgroupdriver=systemd"],
  	"registry-mirrors": ["https://b9pmyelo.mirror.aliyuncs.com"]
}
EOF
systemctl daemon-reload
systemctl restart docker

### 添加阿里云YUM软件源
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

### 安装kubeadm，kubelet和kubectl
yum install -y kubelet-1.18.2 kubeadm-1.18.2 kubectl-1.18.2
systemctl enable kubelet

yum install -y bash-completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
kubectl completion bash >/etc/bash_completion.d/kubectl







