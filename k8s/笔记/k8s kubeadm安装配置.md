



http://blog.itpub.net/70003733/viewspace-2888774/

# 二进制安装Kubernetes（k8s） v1.24.0 IPv4/IPv6双栈 （三主俩从）

https://blog.csdn.net/qq_33921750/article/details/124958403

# 3台Master+3台Node

https://blog.csdn.net/jasonhe2018/article/details/112749146

# 安装集群的方式：



安装单master集群

1.设置hostname

hostnamectl set-hostname master
hostnamectl set-hostname node1
hostnamectl set-hostname node2

2.配置 /etc/hosts


cat  >  /etc/hosts << EOF

127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.99.110  master
192.168.99.178  node1
192.168.99.142 node2

EOF


cat  /etc/hosts



yum -y install  chrony 

systemctl start chronyd
systemctl enable chronyd

4.关闭防火墙

systemctl stop firewalld
systemctl disable firewalld

yum makecache      //更新yum软件包索引

yum -y install yum-utils



安装containerd

浏览器打开链接https://download.docker.com/linux/centos/7/x86_64/stable/Packages/
查看containerd.io最新版本（一般是最后一个）

wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.6.6-3.1.el7.x86_64.rpm

yum install  containerd.io-1.6.6-3.1.el7.x86_64.rpm



## 配置containerd

cat > /etc/yum.repos.d/k8s.repo <<EOF
[k8s]
 name=k8s
 baseurl=https://mirrors.tuna.tsinghua.edu.cn/kubernetes/yum/repos/kubernetes-el7-x86_64/
 gpgcheck=0
 enabled=1

[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/ yum/doc/yum-key.gpg
       https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg

EOF



产生config.toml

containerd config default > /etc/containerd/config.toml

替换镜像，不然镜像下载不下来

grep sandbox_image  /etc/containerd/config.toml
sed -i "s#k8s.gcr.io/pause#registry.aliyuncs.com/google_containers/pause#g"       /etc/containerd/config.toml
grep sandbox_image  /etc/containerd/config.toml



#### 配置containerd cgroup 驱动程序systemd

kubernets自ｖ1.24.0后，就不再使用docker.shim，替换采用containerd作为容器运行时端点。因此需要安装containerd（在docker的基础下安装），上面安装docker的时候就自动安装了containerd了。这里的docker只是作为客户端而已。容器引擎还是containerd。 

```
sed -i 's#SystemdCgroup = false#SystemdCgroup = true#g' /etc/containerd/config.toml
# 应用所有更改后,重新启动containerd
systemctl restart containerd
```





### 替换阿里云`docker`仓库

yum-config-manager  --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

### 安装`docker`引擎

yum install --allowerasing docker-ce -y

$ systemctl start docker



cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

查看版本，最新版
yum list kubeadm --showduplicates

yum list | grep kube	
指定版本安装

yum install -y  kubelet-1.24.1-0 kubeadm-1.24.1-0 kubectl-1.24.1-0

安装最新版本
yum install kubelet kubeadm kubectl -y



/etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}

cat > /etc/docker/daemon.json << EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

重启docker
 systemctl restart docker

systemctl enable docker.service 

systemctl enable kubelet.service 

安装 kubelet kubeadm kubectl 之后再配置crictl ， 安装的同时会安装依赖cri-tools等这样才能配置

crictl config runtime-endpoint unix:///run/containerd/containerd.sock

 原因：未配置endpoints

 crictl config runtime-endpoint unix:///run/containerd/containerd.sock
crictl config image-endpoint unix:///run/containerd/containerd.sock

mkdir -p /etc/docker
echo -e "{
   "registry-mirrors": ["https://r61ch9pn.mirror.aliyuncs.com"]
}" > /etc/docker/daemon.json
cat /etc/docker/daemon.json


cd /etc/yum.repos.d/ && wget -c https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/docker-ce.repo --no-check-certificate



kubeadm init \
--apiserver-advertise-address=192.168.99.110 \
--image-repository registry.aliyuncs.com/google_containers \
--kubernetes-version v1.24.1  \
--service-cidr=10.1.0.0/16 \
--pod-network-cidr=10.244.0.0/16 \



如果执行失败， 先 kubeadm reset 再次执行    kubeadm init

kubeadm init \
  --apiserver-advertise-address=192.168.99.110 \
  --image-repository registry.aliyuncs.com/google_containers \
  --kubernetes-version v1.24.1 \
  --service-cidr=10.1.0.0/16 \
  --pod-network-cidr=10.244.0.0/16 \
  --ignore-preflight-errors=all \
  --v=5 





[ERROR CRI]: container runtime is not running: output: E0712 01:49:47.179156   
 3917 remote_runtime.go:925] "Status from runtime service failed" err="rpc error: code = Unimplemented desc = unknown service runtime.v1alpha2.RuntimeService"

 解决办法
[root@master:~] rm -rf /etc/containerd/config.toml
[root@master:~] systemctl restart containerd



systemctl enable kubelet && systemctl start kubelet 

 systemctl status kubelet

kubeadm join 192.168.99.115:6443 --token 7wv2z1.h70wgh710h1woobs \
> config.toml --discovery-token-ca-cert-hash sha256:44bb791d1f393a96db0d224f247b8b2c4fb18f2db59346c6658b9f19f80aea0a
> accepts at most 1 arg(s), received 2
> To see the stack trace of this error execute with --v=5 or higher

解决办法：重新建立一个空目录，切换到空目录，再执行join命令

netstat -antpl  |grep kubelet

将桥接的 IPv4 的流量传递到 iptables的链
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF


kubectl -n kube-system get cm kubeadm-config -o yaml


/usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf


关闭交换
swapoff -a



cd /etc/sysconfig/network-scripts
ONBOOT=yes
重启网卡
 nmcli c reload

 



拉镜像
ctr -n k8s.io images import <your tar file>

查看镜像：
crictl img

 


journalctl -f -u kubelet.service



kubectl get pod --all-namespaces

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "registry-mirrors": ["https://registry.cn-hangzhou.aliyuncs.com"],
  "storage-driver": "overlay2"
}
EOF






docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.6 k8s.gcr.io/pause:3.6



Unknown desc = failed to get sandbox image "k8s.gcr.io/pause:3.6": failed to pull image "k8s.gcr.io/piled to pull and unpack image "k8s.gcr.io/pause:3.6": failed to resolve reference "k8s.gcr.io/pause:3request: Head "https://k8s.gcr.io/v2/pause/manifests/3.6": dial tcp 74.125.203.82:443: connect: conne
  Warning  FailedCreatePodSandBox  4m51s (x12 over 18m)  kubelet            Failed to create pod sandde = Unknown desc = failed to get sandbox image "k8s.gcr.io/pause:3.6": failed to pull image "k8s.gcriled to pull and unpack image "k8s.gcr.io/pause:3.6": failed to resolve reference "k8s.gcr.io/pause:3request: Head "https://k8s.gcr.io/v2/pause/manifests/3.6": dial tcp 142.250.157.82:443: connect: conn
  Warning  FailedCreatePodSandBox  3m7s (x8 over 16m)    kubelet            Failed to create pod sandde = Unknown desc = failed to get sandbox image "k8s.gcr.io/pause:3.6": failed to pull image "k8s.gcriled to pull and unpack image "k8s.gcr.io/pause:3.6": failed to resolve reference "k8s.gcr.io/pause:3request: Head "https://k8s.gcr.io/v2/pause/manifests/3.6": dial tcp 64.233.189.82:443: 

[root@localhost ~]#mkdir -p /etc/containerd
[root@localhost ~]#containerd config default > /etc/containerd/config.toml
[root@localhost ~]#systemctl daemon-reload
[root@localhost ~]#systemctl start containerd.service
[root@localhost ~]#systemctl enable containerd.service
[root@localhost ~]#runc -v 

sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.7"
执行
systemctl restart containerd



[plugins."io.containerd.grpc.v1.cri".registry]
   [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
       [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
          		endpoint = ["https://registry-1.docker.io"] //到此为配置文件默认生成，之后为需要添加的内容
       [plugins."io.containerd.grpc.v1.cri".registry.mirrors."192.168.66.4"]
         		endpoint = ["https://192.168.66.4:443"]
   [plugins."io.containerd.grpc.v1.cri".registry.configs]
   		 [plugins."io.containerd.grpc.v1.cri".registry.configs."192.168.66.4".tls]
          		insecure_skip_verify = true
       	 [plugins."io.containerd.grpc.v1.cri".registry.configs."192.168.66.4".auth]
          		username = "admin"
          		password = "Harbor12345" 
				
				
				
				
节点init完成	

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

### 添加worknode

kubeadm join 192.168.109.134:6443 --token voyqtd.dn5fr6wm9oomycfk \
​	--discovery-token-ca-cert-hash sha256:1482bd7c078a97b2dd3c4655542a5809821ce474240f5303aa2789fc1da54947 
​

### 添加master

kubeadm join 192.168.109.134:6443 --token voyqtd.dn5fr6wm9oomycfk \
	--discovery-token-ca-cert-hash sha256:1482bd7c078a97b2dd3c4655542a5809821ce474240f5303aa2789fc1da54947  \

--control-plane

 


#如果超过2小时忘记了令牌，可以这样做

$ kubeadm token create --print-join-command #新令牌
	kubeadm token create --print-join-command  

$ kubeadm token create --ttl 0 --print-join-command #永不过期的令牌

kubeadm join 192.168.43.23:6443 --token w2hiyq.429yixajmuvfvcnk --discovery-token-ca-cert-hash sha256:dae5c056947982c4e5463a4e450786ab248e88e91ee45b2a7bf8dba44dad22e2


– 命令解析：第二行：指定apiserver的地址，即master节点的地址
– 第三行：由于master初始化需要下载很多镜像，默认是从k8s.gcr.io拉取镜像，k8s.gcr.io镜像地址国内无法访问，这里指定阿里云镜像仓库地址。
– 第四行：kubernetes版本
– 第五行：service网络
– 第六行：pod网络
– cidr
科普:无类别域间路由(Classless Inter-Domain Routing、CIDR）是一个用于给用户分配IP地址以及在互联网上有效地路由IP数据包的对IP地址进行归类的方法。
第五行建议使用：–service-cidr=10.96.0.0/16
第六行建议使用：–pod-network-cidr=10.244.0.0/16
因为后续安装flannel默认的网段是10.244.0.0
为了导致不必要的麻烦所以建议使用 



删除pod 自动重建
kubectl delete pod  kube-proxy-p6q6w -n kube-system



# 部署网络插件

$ wget https://docs.projectcalico.org/manifests/calico.yaml --no-check-certificate

# 先下载下来，然后修改IPV4的网段，修改这两行：

- name: CALICO_IPV4POOL_CIDR

value: "10.244.0.0/16"

​	搜索Always ，再附近添加


- name: IP_AUTODETECTION_METHOD
  value: "interface=ens.*"  # ens 根据实际网卡开头配置

修改配置之后重新部署

kubectl apply -f calico.yaml

$ kubectl apply -f calico.yaml # 然后部署插件
# 如果calicio状态不是running，则尝试手动拉取镜像

$ cat calico.yaml | grep image

$ grep image calico.yaml

$ docker pull calico/cni:v3.15.1





kubeadm join失败：
1.先初始化
kubeadm reset -f
2.再执行jion


4分支就可以搞定node2 安装
node2    Ready    <none>          4m4s   v1.24.3


ContainerD：

查看镜像
crictl image


kubectl get pods -n kube-system 

#查看集群信息
kubectl cluster-info

#查看集群版本
kubectl version

#查看集群api版本
kubectl api-versions

#查看主机资源使用信息
kubectl top nodes

查看k8s-node1 节点信息
kubectl describe node k8s-node1

#创建namespace 
kubectl create namespace mysapce

#查看namespace信息
kube]# kubectl get namespaces
NAME          STATUS    AGE
default       Active    2d
kube-public   Active    2d
kube-system   Active    2d
mysapce       Active    6s

#删除namespace空间
kubectl delete namespaces mysapce
namespace "mysapce" deleted


查看不同namespace下的Pod

kubectl get pods --all-namespace

kubectl get pod --all-namespaces -o wide
如下，查看所有Pod信息，加上-o wide参数，能看到每个Pod的ip和k8s节点等信息，看的多了

# 配置其他节点能使用kubectl

1. 把主节点/etc/kubernetes/admin.conf 复制到其他节点对应的目录
2. export KUBECONFIG=/etc/kubernetes/admin.conf 目的是设置环境变量
3. kubectl  get node

第二种方法：

1、先进入master节点

cd 到/root.kube文件
cd /root/.kube
复制./kube文件下的config文件
2、到工作节点下

cd 到/root/目录下
mkdir .kube 创建.kube文件
cd .kube

# 添加worknode



# 安装配置**calicoctl** 

官方路径，使用命令下载比较慢

https://projectcalico.docs.tigera.io/maintenance/clis/calicoctl/install#install-calicoctl-as-a-binary-on-a-single-host



# 安装配置Dashboard

https://github.com/kubernetes/dashboard







curl -o kubernetes-dashboard.yaml  https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml



kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.0/aio/deploy/recommended.yaml

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.0/aio/deploy/recommended.yaml
```

查看服务：

```
kubectl get po,svc -n kubernetes-dashboard
NAME                                TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)         AGE
service/dashboard-metrics-scraper   ClusterIP   10.1.26.91    <none>        8000/TCP        99s
service/kubernetes-dashboard        NodePort    10.1.240.79   <none>        443:30001/TCP   99s
部署成功


```

kubernetes-dashbaord 安装完成后，kubernetes-dashbaord 默认 service 的类型为 ClusterIP，为了能从外部访问控制面板，需要修改为 NodePort 类型

```
kubectl edit services -n kubernetes-dashboard kubernetes-dashboard
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: v1
kind: Service
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"labels":{"k8s-app":"kubernetes-dashboard"},"name":"kubernetes-dashboard","namespace":"kubernetes-dashboard"},"spec":{"ports":[{"port":443,"targetPort":8443}],"selector":{"k8s-app":"kubernetes-dashboard"}}}
  creationTimestamp: "2021-04-11T10:18:54Z"
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
  resourceVersion: "33097"
  selfLink: /api/v1/namespaces/kubernetes-dashboard/services/kubernetes-dashboard
  uid: 38jsd1sd-4045-448b-b70f-mia218mda8s
spec:
  clusterIP: 10.102.198.114
  ports:
  - port: 443
    protocol: TCP
    targetPort: 8443
    # 添加固定端口
    nodePort: 30000
  selector:
    k8s-app: kubernetes-dashboard
  sessionAffinity: None
  # 修改
  type: NodePort
status:
  loadBalancer: {}
```

想要访问dashboard服务，就要有访问权限，创建kubernetes-dashboard管理员角色，以下两种方式创建用户都是可以的

```
vim dashboard-svc-account.yaml
 
# 结果
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dashboard-admin
  namespace: kubernetes-dashboard
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: dashboard-admin
subjects:
  - kind: ServiceAccount
    name: dashboard-admin
    namespace: kubernetes-dashboard
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io


 
# 执行
kubectl apply -f dashboard-svc-account.yaml
```



 kubectl -n kubernetes-dashboard create token admin-user
error: failed to create token: serviceaccounts "admin-user" not found



```
vim create-admin.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
  
  
 kubectl apply -f  create-admin.yaml
```



 



查看Pod，没有找到相关的Pod，是因为节点之间通信有问题导致

```
kubectl  get pod -A -o wide
NAMESPACE     NAME                                       READY   STATUS    RESTARTS       AGE   IP               NODE     NOMINATED NODE   READINESS GATES
kube-system   calico-kube-controllers-555bc4b957-9q49b   1/1     Running   0              30h   10.244.166.131   node1    <none>           <none>
kube-system   calico-node-cxzq5                          1/1     Running   1 (30h ago)    31h   192.168.99.116   node2    <none>           <none>
kube-system   calico-node-kzbn9                          1/1     Running   0              31h   192.168.99.115   master   <none>           <none>
kube-system   calico-node-tkgmn                          1/1     Running   1 (31h ago)    31h   192.168.99.153   node1    <none>           <none>
kube-system   coredns-74586cf9b6-8n8qx                   1/1     Running   0              30h   10.244.219.65    master   <none>           <none>
kube-system   coredns-74586cf9b6-mbhpz                   1/1     Running   0              30h   10.244.166.130   node1    <none>           <none>
kube-system   etcd-master                                1/1     Running   1              31h   192.168.99.115   master   <none>           <none>
kube-system   kube-apiserver-master                      1/1     Running   1              31h   192.168.99.115   master   <none>           <none>
kube-system   kube-controller-manager-master             1/1     Running   13 (26h ago)   31h   192.168.99.115   master   <none>           <none>
kube-system   kube-proxy-4pq9b                           1/1     Running   1 (30h ago)    31h   192.168.99.116   node2    <none>           <none>
kube-system   kube-proxy-8lcjq                           1/1     Running   0              31h   192.168.99.115   master   <none>           <none>
kube-system   kube-proxy-j6sch                           1/1     Running   1 (31h ago)    31h   192.168.99.153   node1    <none>           <none>
kube-system   kube-scheduler-master                      1/1     Running   12 (26h ago)   31h   192.168.99.115   master   <none>           <none>

```

获取token

```
kubectl -n kubernetes-dashboard create token admin-user

eyJhbGciOiJSUzI1NiIsImtpZCI6IktaMm9Gd1h5azJReGNnbWt3dGhHZUNTaXBqM2VmVW1IcEExaUVKMG5MQ28ifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNjU4OTM2MTU1LCJpYXQiOjE2NTg5MzI1NTUsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJhZG1pbi11c2VyIiwidWlkIjoiMGJiODc2MzAtYWRiZS00YzU0LTkwN2YtZjYxM2E4ZjhiODBhIn19LCJuYmYiOjE2NTg5MzI1NTUsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlcm5ldGVzLWRhc2hib2FyZDphZG1pbi11c2VyIn0.ncrjzGsZhPZhqg7zJ4IEH4CkTOhqDcUebzmRl7URLn05t7c_tXDreaBzczeGqYO8pQfUJ3oCsl_7WUdzlBDNNBmZBKI1JU356DNVBG8o7_thqfY-RtUf6BC76vuN3LV_l6-tzk-haxblOd5YnPqdwF_83ky62A3YGFN6eVLgyUQFFFQKWtde5wXXsxatLPeJdICF5U28n6Uu82_aW2tnjwQ3TsWjfunlFxSXJ4uxx2lotfzAGhvU4rSzUCwakFbeqDiLOTkmw374iCdN7d5MVcYWiAd_jcpMcxBLdkzUxlWGSUZv9oHI3IOSK-OdK2fIF1KBXfUQWyCMh4G0GMzgqw
```

删除用户

```
kubectl -n kubernetes-dashboard delete serviceaccount admin-user
kubectl -n kubernetes-dashboard delete clusterrolebinding admin-user
```

kubectl get secret -n kubernetes-dashboard



## 端口映射

可以通过service的nodePort模式，kubectl proxy,kubectl-port，ingress等各种方式进行访问。

本例通过port-forwad将service映射到主机上

```shell
nohup kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8080:443 --address='172.20.58.83' &
```

# k8s删除Terminating状态的命名空间

# 部署Service

#### 创建namespace.[yaml](https://so.csdn.net/so/search?q=yaml&spm=1001.2101.3001.7020)文件

```
 cat  >  /home/rain/namespase.yaml << EOF
apiVersion: v1 #类型为Namespace
kind: Namespace  #类型为Namespace
metadata:
  name: ssx-nginx-ns  #命名空间名称
  labels:
    name: lb-ssx-nginx-ns
EOF
```

然后应用到k8s中  kubectl create -f namespace.yaml

####  创建deployment.yaml文件

```
 
cat  >  /home/rain/deployment.yaml  << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx #为该Deployment设置key为app，value为nginx的标签
  name: ssx-nginx-dm
  namespace: ssx-nginx-ns
spec:
  replicas: 2 #副本数量
  selector: #标签选择器，与上面的标签共同作用
    matchLabels: #选择包含标签app:nginx的资源
      app: nginx
  template: #这是选择或创建的Pod的模板
    metadata: #Pod的元数据
      labels: #Pod的标签，上面的selector即选择包含标签app:nginx的Pod
        app: nginx
    spec: #期望Pod实现的功能（即在pod中部署）
      containers: #生成container，与docker中的container是同一种
      - name: ssx-nginx-c
        image: nginx:latest #使用镜像nginx: 创建container，该container默认80端口可访问
        ports:
        - containerPort: 80  # 开启本容器的80端口可访问
        volumeMounts:  #挂载持久存储卷
        - name: volume #挂载设备的名字，与volumes[*].name 需要对应 
          mountPath: /usr/share/nginx/html #挂载到容器的某个路径下  
      volumes:
      - name: volume #和上面保持一致 这是本地的文件路径，上面是容器内部的路径
        hostPath:
          path: /opt/web/dist #此路径需要实现创建
 EOF
```

然后应用到k8s中 kubectl create -f deployment.yaml

#### 创建service.yaml文件

```
cat  >  /home/rain/service.yaml  << EOF
apiVersion: v1
kind: Service
metadata:
  labels:
   app: nginx
  name: ssx-nginx-sv
  namespace: ssx-nginx-ns
spec:
  ports:
  - port: 80 #写nginx本身端口
    name: ssx-nginx-last
    protocol: TCP
    targetPort: 80 # 容器nginx对外开放的端口 上面的dm已经指定了
    nodePort: 31090 #外网访问的端口
  selector:
    app: nginx    #选择包含标签app:nginx的资源
  type: NodePort
 EOF
```

然后应用到k8s中

```bash
kubectl create -f ./service.yaml
```



查看创建的service

```
kubectl  get svc -A
NAMESPACE              NAME                        TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                  AGE   SELECTOR
default                kubernetes                  ClusterIP   10.1.0.1       <none>        443/TCP                  42m   <none>
kube-system            kube-dns                    ClusterIP   10.1.0.10      <none>        53/UDP,53/TCP,9153/TCP   42m   k8s-app=kube-dns
kubernetes-dashboard   dashboard-metrics-scraper   ClusterIP   10.1.24.143    <none>        8000/TCP                 39m   k8s-app=dashboard-metrics-scraper
kubernetes-dashboard   kubernetes-dashboard        NodePort    10.1.124.236   <none>        443:30001/TCP            39m   k8s-app=kubernetes-dashboard
ssx-nginx-ns           ssx-nginx-sv                NodePort    10.1.90.83     <none>        80:31090/TCP             22m   app=nginx

```

分别在node1 和node2下创建/opt/web/dist/index.html 

访问：

在master 节点访问 10.1.90.83  因为端口是80 所以可以直接访问返回：node1 或者node2

外网访问：master IP:31090  访问返回node1 或者node2 ，主节点应该是有负载均衡的

node1  IP:31090 只能返回node1

node2  IP:31090 只能返回node2





# 

查看[命名空间](https://so.csdn.net/so/search?q=命名空间&spm=1001.2101.3001.7020)

```
# kubectl  get ns 
NAME                   STATUS        AGE
default                Active        31h
kube-node-lease        Active        31h
kube-public            Active        31h
kube-system            Active        31h
kubernetes-dashboard   Terminating   3h16m
```

**解决方法**
查看kubesphere-system的namespace描述

```
kubectl get ns  kubernetes-dashboard   -o json > kubernetes-dashboard.json
```

编辑json文件，删除spec字段的内存，因为k8s集群时需要认证的。

vi kubernetes-dashboard.json
将

"spec": {
        "finalizers": [
            "kubernetes"
        ]
    },
更改为：

"spec": {
    
  },



新开一个窗口运行kubectl proxy跑一个API代理在本地的8081端口

```
# kubectl proxy --port=8081
Starting to serve on 127.0.0.1:8081
```

```
curl -k -H "Content-Type:application/json" -X PUT --data-binary @kubernetes-dashboard.json http://127.0.0.1:8081/api/v1/namespaces/kubernetes-dashboard/finalize 
注意：命令中的kubernetes-dashboard就是命名空间。

再次查看命名空间

# kubectl get ns
	NAME              STATUS   AGE
default           Active   31h
kube-node-lease   Active   31h
kube-public       Active   31h
kube-system       Active   31h
```

查看Pod 状态

 kubectl get po,svc -n kubernetes-dashboard

删除服务

kubectl replace --force -f recommended.yaml



查看所有命名空间的Pod

*kubectl get pods -A -o wide*

# istio

https://blog.csdn.net/aa18855953229/article/details/109281007



# Harbor创建私有镜像

https://github.com/goharbor/harbor

**On a Linux host:** docker 17.06.0-ce+ and docker-compose 1.18.0+ .



# 制作镜像



# k8s的更换ip



切换到/etc/kubernetes/manifests， 将etcd.yaml kube-apiserver.yaml里的ip地址替换为新的ip

/etc/kubernetes/manifests # vim etcd.yaml
/etc/kubernetes/manifests # vim kube-apiserver.yaml

替换为新的IP



newIP=192.168.99.110

oldIP=192.168.93.63	



find . -type f | xargs sed -i "s/$oldIP/$newIP/"

查看修改结果

find . -type f | xargs grep $newIP

二，生成新的config文件

cd /etc/kubernetes

/etc/kubernetes# mv admin.conf admin.conf.bak
/etc/kubernetes# kubeadm init phase kubeconfig admin --apiserver-advertise-address $newIP
三，删除老证书，生成新证书

/etc/kubernetes# cd pki
 /etc/kubernetes/pki# mv apiserver.key apiserver.key.bak
/etc/kubernetes/pki# mv apiserver.crt apiserver.crt.bak
 /etc/kubernetes/pki# kubeadm init phase certs apiserver  --apiserver-advertise-address  $newIP
四，重启docker

/etc/kubernetes# cd ..
/etc/kubernetes# service docker restart
/etc/kubernetes# service kubelet restart

五，将配置文件config输出
/etc/kubernetes#kubectl get nodes --kubeconfig=admin.conf # 此时已经是通信成功了

六，将kubeconfig默认配置文件替换为admin.conf，这样就可以直接使用kubectl get nodes

/etc/kubernetes# cp  -f admin.conf  ~/.kube/config

此时kubectl的是能使用了原来创建的Pod IP都还未变。



# docker  使用命令

1. docker network inspect bridge 可以查看网桥的子网网络范围和网关

   docker network inspect bridge

 



# 问题定位：

1. ##### 查看一下kubelet启动日志  *journalctl -f -u kubelet*

2. ##### *systemctl status  kubelet*  查看状态

3. ##### Failed to create pod sandbox: rpc error: code = Unknown desc = [failed to set up sandbox container...

   - 表现状态

   ```
   [root@linux03 ~]# kubectl get pods -n kube-system
   NAME                              READY   STATUS              RESTARTS   AGE
   coredns-7f89b7bc75-jzs26          0/1     ContainerCreating   0          63s
   coredns-7f89b7bc75-qg924          0/1     ContainerCreating   0          63s
   ```

 

- 更改calico.yaml

```
# Cluster type to identify the deployment type
  - name: CLUSTER_TYPE
  value: "k8s,bgp"
# 下方熙增新增
  - name: IP_AUTODETECTION_METHOD
    value: "interface=ens192"
    # ens192为本地网卡名字
```

- kubectl apply -f calico.yaml

  查看正常

4.之前创建kubernetes-dashboard,只有service但是没有pod

 这个问题是因为修改过IP，修改IP之后节点之间不能正常通信，导致任务下发失败，所以就没看到创建的pod，重置节点之后，各个节点通信正常pod也创建正常

```
[root@master rain]# kubectl  get pod -A -o wide
NAMESPACE              NAME                                        READY   STATUS    RESTARTS   AGE    IP               NODE     NOMINATED NODE   READINESS GATES
kube-system            calico-kube-controllers-555bc4b957-7qxs4    1/1     Running   0          90m    10.244.166.129   node1    <none>           <none>
kube-system            calico-node-f6zvj                           1/1     Running   0          90m    192.168.93.63    master   <none>           <none>
kube-system            calico-node-w7skz                           1/1     Running   0          90m    192.168.93.64    node1    <none>           <none>
kube-system            calico-node-xlk4n                           1/1     Running   0          90m    192.168.93.65    node2    <none>           <none>
kube-system            coredns-74586cf9b6-pkx5r                    1/1     Running   0          102m   10.244.219.65    master   <none>           <none>
kube-system            coredns-74586cf9b6-r2j9v                    1/1     Running   0          102m   10.244.219.66    master   <none>           <none>
kube-system            etcd-master                                 1/1     Running   1          102m   192.168.93.63    master   <none>           <none>
kube-system            kube-apiserver-master                       1/1     Running   1          102m   192.168.93.63    master   <none>           <none>
kube-system            kube-controller-manager-master              1/1     Running   30         102m   192.168.93.63    master   <none>           <none>
kube-system            kube-proxy-ktnnt                            1/1     Running   0          102m   192.168.93.63    master   <none>           <none>
kube-system            kube-proxy-l5rgb                            1/1     Running   0          101m   192.168.93.64    node1    <none>           <none>
kube-system            kube-proxy-ldqqj                            1/1     Running   0          101m   192.168.93.65    node2    <none>           <none>
kube-system            kube-scheduler-master                       1/1     Running   29         102m   192.168.93.63    master   <none>           <none>
kubernetes-dashboard   dashboard-metrics-scraper-8c47d4b5d-n8bdf   1/1     Running   0          85m    10.244.104.1     node2    <none>           <none>
kubernetes-dashboard   kubernetes-dashboard-75d8f74d66-ck4sz       1/1     Running   0          86s    10.244.104.3     node2    <none>           <none>
```



## keepalive配置

vim /etc/keepalived/keepalived.conf

```
global_defs { 
 notification_email { 
 acassen@firewall.loc 
 failover@firewall.loc 
 sysadmin@firewall.loc 
 } 
 notification_email_from Alexandre.Cassen@firewall.loc 
 smtp_server 127.0.0.1 
 smtp_connect_timeout 30 
 router_id NGINX_MASTER 
} 
 
vrrp_script check_nginx { 
 script "/etc/keepalived/check_nginx.sh" 
}

vrrp_instance VI_1 { 
 state MASTER 
 interface ens33 # 修改为实际网卡名 
 virtual_router_id 51 # VRRP 路由 ID 实例，每个实例是唯一的 
 priority 100 # 优先级，备服务器设置 90 
 advert_int 1 # 指定 VRRP 心跳包通告间隔时间，默认 1 秒 
 authentication { 
 auth_type PASS 
 auth_pass 1111 
 } 
 # 虚拟 IP 
 virtual_ipaddress { 
 192.168.48.199/24 
 } 
 track_script { 
 check_nginx 
 } 
}
#vrrp_script：指定检查 nginx 工作状态脚本（根据 nginx 状态判断是否故障转移） 
#virtual_ipaddress：虚拟 IP（VIP） 
```



编写脚本/etc/keepalived/check_nginx.

```shell
#!/bin/bash 
count=$(ps -ef |grep nginx | grep sbin | egrep -cv "grep|$$") 
if [ "$count" -eq 0 ];then 
 systemctl stop keepalived 
fi 
```

启动nginx
systemctl daemon-reload && yum install nginx-mod-stream -y && systemctl start nginx
启动keepalived
systemctl start keepalived && systemctl enable nginx keepalived && systemctl status keepalived
注意:keepalived无法启动的时候，查看keepalived.conf配置权限
chmod 644 keepalived.conf

## 常用命令：

删除pod并重新创建

kubectl get pod -n kube-system | grep kube-proxy |awk '{system("kubectl delete pod "$1" -n kube-system")}'



kubectl get pod -n kube-system | grep kube-proxy

查看集群情况：kubectl get pod -n kube-system
查看kubelet情况:

```
systemctl status kubelet -l
```

查看kubelet系统日志：journalctl -xefu kubelet
docker ps 查看容器启动情况

systemctl restart networking

##### 强制删除pod(1.5以后)

kubectl  delete pod kubernetes-dashboard-75d8f74d66-bkxt7    -n kubernetes-dashboard  **--force --grace-period=0**

如果在这些命令后 Pod 仍处于 `Unknown` 状态，请使用以下命令从集群中删除 Pod:

```shell
kubectl patch pod <pod> -p '{"metadata":{"finalizers":null}}'
```



## doccker 镜像

ctr ns ls

指定命名空间引入镜像

ctr -n k8s.io  image import kubernetesui.tar



ctr 命令使用
Container命令ctr,crictl的用法
版本：ctr containerd.io 1.4.3
containerd 相比于docker , 多了namespace概念, 每个image和container 都会在各自的namespace下可见, 目前k8s会使用k8s.io 作为命名空间~~

1.1、查看ctr image可用操作
ctr image list, ctr i list , ctr i ls
COPY
1.2、镜像标记tag
ctr -n k8s.io i tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2 k8s.gcr.io/pause:3.2
注意: 若新镜像reference 已存在, 需要先删除新reference, 或者如下方式强制替换
ctr -n k8s.io i tag --force registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2 k8s.gcr.io/pause:3.2
COPY
1.3、删除镜像
ctr -n k8s.io i rm k8s.gcr.io/pause:3.2
COPY
1.4、拉取镜像
ctr -n k8s.io i pull -k k8s.gcr.io/pause:3.2
COPY
1.5、推送镜像
ctr -n k8s.io i push -k k8s.gcr.io/pause:3.2
COPY
1.6、导出镜像
ctr -n k8s.io i export pause.tar k8s.gcr.io/pause:3.2
COPY
1.7、导入镜像

ctr -n k8s.io i import pause.tar

# 不支持 build,commit 镜像
COPY
1.8、查看容器相关操作
ctr c
COPY
1.9、运行容器

创建容器

 ctr c create docker.io/library/nginx:alpine nginx

创建并运行容器：

ctr run -d docker.io/library/nginx:alpine nginx

–null-io: 将容器内标准输出重定向到/dev/null
–net-host: 主机网络
-d: 当task执行后就进行下一步shell命令,如没有选项,则会等待用户输入,并定向到容器内
–mount 挂载本地目录或文件到容器
–env 环境变量
ctr -n k8s.io run --null-io --net-host -d \
–env PASSWORD="123456"
–mount type=bind,src=/etc,dst=/host-etc,options=rbind:rw
COPY
1.10、容器日志
注意: 容器默认使用fifo创建日志文件, 如果不读取日志文件,会因为fifo容量导致业务运行阻塞

如要创建日志文件,建议如下方式创建:
ctr -n k8s.io run --log-uri file:///var/log/xx.log
COPY

#####  docker inspect 

  ctr c info nginx 

进入容器： ctr task exec --exec-id 0 -t nginx sh

暂停容器： ctr task pause nginx

杀死容器ctr task kill nginx

ctr -n  <命名空间>  import 镜像名称，就可以指定镜像到固定命名空间



二、ctr和docker命令比较
Containerd命令    Docker命令    描述
ctr task ls    docker ps    查看运行容器
ctr image ls      docker images    获取image信息

  ctr i ls 

ctr image pull pause    docker pull pause    pull 应该pause镜像
ctr image push pause-test    docker push pause-test    改名
ctr image import pause.tar    docker load 镜像    导入本地镜像
ctr run -d pause-test pause    docker run -d --name=pause pause-test    运行容器
ctr image tag pause pause-test    docker tag pause pause-test    tag应该pause镜像
三、crictl 命令
3.1、crictl 配置



# 通过在配置文件中设置端点 --config=/etc/crictl.yaml
root@k8s-node-0001:~$ cat /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
COPY
3.2、列出业务容器状态
crictl inspect ee20ec2346fc5
COPY
3.3、查看运行中容器
root@k8s-node-0001:~$ crictl pods
POD ID              CREATED             STATE               NAME                                                     NAMESPACE           ATTEMPT             RUNTIME
b39a7883a433d       10 minutes ago      Ready               canal-server-quark-b477b5d79-ql5l5                       mbz-alpha           0                   (default)
COPY
3.4、打印某个固定pod
root@k8s-node-0001:~$ crictl pods --name canal-server-quark-b477b5d79-ql5l5
POD ID              CREATED             STATE               NAME                                 NAMESPACE           ATTEMPT             RUNTIME
b39a7883a433d       12 minutes ago      Ready               canal-server-quark-b477b5d79-ql5l5   mbz-alpha           0                   (default)
COPY
3.5、打印镜像
root@k8s-node-0001:~$ crictl images
IMAGE                                                          TAG                             IMAGE ID            SIZE
ccr.ccs.tencentyun.com/koderover-public/library-docker         stable-dind                     a6e51fd179fb8       74.6MB
ccr.ccs.tencentyun.com/koderover-public/library-nginx          stable                          588bb5d559c28       51MB
ccr.ccs.tencentyun.com/koderover-public/nsqio-nsq              v1.0.0-compat                   2714222e1b39d       22MB
COPY
3.6、只打印镜像 ID
root@k8s-node-0001:~$ crictl images -q
sha256:a6e51fd179fb849f4ec6faee318101d32830103f5615215716bd686c56afaea1
sha256:588bb5d559c2813834104ecfca000c9192e795ff3af473431497176b9cb5f2c3
sha256:2714222e1b39d8bd6300da72b0805061cabeca3b24def12ffddf47abd47e2263
sha256:be0f9cfd2d7266fdd710744ffd40e4ba6259359fc3bc855341a8c2adad5f5015
COPY
3.7、打印容器清单
root@k8s-node-0001:~$ crictl ps -a
CONTAINER           IMAGE               CREATED             STATE               NAME                     ATTEMPT             POD ID
ee20ec2346fc5       c769a1937d035       13 minutes ago      Running             canal-server             0                   b39a7883a433d
76226ddb736be       cc0c524d64c18       34 minutes ago      Running             mbz-rescue-manager       0                   2f9d48c49e891
e2a19ff0591b4       eb40a52eb437d       About an hour ago   Running             export                   0                   9844b5ea5fdbc
COPY
3.8、打印正在运行的容器清单
root@k8s-node-0001:~$ crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                   ATTEMPT             POD ID
ee20ec2346fc5       c769a1937d035       13 minutes ago      Running             canal-server           0                   b39a7883a433d
COPY
3.9、容器上执行命令
root@k8s-node-0001:~$ crictl exec -i -t ee20ec2346fc5 ls
app.sh  bin  canal-server  health.sh  node_exporter  node_exporter-0.18.1.linux-arm64
COPY
3.10、获取容器的所有日志
root@k8s-node-0001:~$ crictl logs ee20ec2346fc5
DOCKER_DEPLOY_TYPE=VM
==> INIT /alidata/init/02init-sshd.sh
==> EXIT CODE: 0
==> INIT /alidata/init/fix-hosts.py
COPY
3.11、获取最近的 N 行日志
root@k8s-node-0001:~$ crictl logs --tail=2 ee20ec2346fc5
start canal successful
==> START SUCCESSFUL ...
COPY
3.12、拉取镜像
crictl pull busybox

crictl pods



# 启动一个pod：给个名字mynginx，启动一个镜像nginx
kubectl run mynginx --image=nginx

# 查看default名称空间的Pod
kubectl get pod  # 所有集群范围内，其他node的也可以看到

# 描述
kubectl describe pod 你自己的Pod名字  # 查看默认名称空间pod
kubectl describe  -n [ns] pod 你自己的Pod名字  # 

# 删除
kubectl delete pod Pod名字

# 查看Pod的运行日志
kubectl logs Pod名字

#查找指定的运行中的容器
docker ps|grep mynginx

#删除镜像
kubectl delete -f pytest.yaml

# 每个Pod - k8s都会分配一个ip
kubectl get pod -owide  # 可以查看pod运行的node和ip地址，打印详细信息	

# 使用Pod的ip+pod里面运行容器的端口
curl xxx.xxx.xxx.xxx # 不写端口默认就是80端口

# 进入pod
kubectl exec -it myngix  -- /bin/bash

# 集群中的任意一个机器以及任意的应用都能通过Pod分配的ip来访问这个Pod

kubectl get namespace  # 获取名称空间
kubectl get pods  # 获取默认名称空间pods
kubectl get pods -A  # 获取全部名称空间pods
kubectl get pods -n [namespace]  # 查看指定名称空间pod
kubectl creat ns hello  # 创建名称空间

也可以通过yaml文件创建ns：
apiVersion: v1
kind: Namespace
metadata:
  name: hello

vi hello.yaml
kubectl apply -f hello.yaml

# 描述
kubectl describe pod 你自己的Pod名字

# 删除
kubectl delete pod Pod名字  # 会删除该名称空间的所有资源
kubectl delete -f hello.yaml  # 用配置文件创建的ns用这种方式删，删的干净

# 查看Pod的运行日志
kubectl logs Pod名字

\# 每个Pod - k8s都会分配一个ip kubectl get pod -owide # 使用Pod的ip+pod里面运行容器的端口 curl 192.168.169.136 # 集群中的任意一个机器以及任意的应用都能通过Pod分配的ip来访问这个Pod