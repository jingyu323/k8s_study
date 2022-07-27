

安装详细步骤

http://blog.itpub.net/70003733/viewspace-2888774/



hostnamectl set-hostname master
hostnamectl set-hostname node1
hostnamectl set-hostname node2


cat  >  /etc/hosts << EOF

127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.99.115 master
192.168.99.153  node1
192.168.99.116 node2

EOF


cat  /etc/hosts





systemctl start chronyd
systemctl enable chronyd

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



# 2 关闭iptables服务
systemctl stop iptables
systemctl disable iptables




cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
net.ipv4.tcp_tw_recycle=0
vm.swappiness=0
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
fs.file-max=52706963
fs.nr_open=52706963
net.ipv6.conf.all.disable_ipv6=1
net.netfilter.nf_conntrack_max=2310720         
EOF






# 设置开机启动
$ systemctl enable docker
# 启动docker
### 替换阿里云`docker`仓库

yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

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
--apiserver-advertise-address=192.168.99.115 \
--image-repository registry.aliyuncs.com/google_containers \
--kubernetes-version v1.24.1  \
--service-cidr=10.1.0.0/16 \
--pod-network-cidr=10.244.0.0/16 \



如果执行失败， 先 kubeadm reset 再次执行    kubeadm init

kubeadm init \
  --apiserver-advertise-address=192.168.99.115 \
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
				
				
				
				
				

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf


​				
kubeadm join 192.168.109.134:6443 --token voyqtd.dn5fr6wm9oomycfk \
​	--discovery-token-ca-cert-hash sha256:1482bd7c078a97b2dd3c4655542a5809821ce474240f5303aa2789fc1da54947 
​	
​	
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



查看Pod，没有找到相关的Pod

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

# k8s删除Terminating状态的命名空间

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



# istio

查看Pod 状态

 kubectl get po,svc -n kubernetes-dashboard

删除服务

kubectl replace --force -f recommended.yaml





# k8s的更换ip



切换到/etc/kubernetes/manifests， 将etcd.yaml kube-apiserver.yaml里的ip地址替换为新的ip

/etc/kubernetes/manifests # vim etcd.yaml
/etc/kubernetes/manifests # vim kube-apiserver.yaml

替换为新的IP

newIP=192.168.93.53

oldIP=192.168.99.176

find . -type f | xargs sed -i "s/$oldIP/$newIP/"

查看修改结果

find . -type f | xargs grep $newIP

二，生成新的config文件

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

/etc/kubernetes# cp -f admin.conf  ~/.kube/config

 



