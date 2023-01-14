

#wlan 技术

华为wifi6 9.6GBPS  

# wlan 解决方案
大型园区Wlan 解决方案

![](images/wlan/园区wlan.png)
# 无线通信

## 频段 
- 2.4G-2.4835G

## 无线通道
调制解调
- 调频
- 调幅
- 调相
## 子载波
载波：是一个特定频率的无线电波单位是hz，是一种频率、振幅、相位被调节成可以传输语言、音乐、图像等其他信号的电磁波
### 信道
什么是信道？
信息传输的通道，无线信道就是空间中无线电波传输信息的通道。
2,4G 有14个重叠的信道 频率宽度分别是20MHZ的信道 现网常用信道是1,5,9，13
5G信道：大量的费重叠信道 共有13个可以使用的非重叠信道

### wlan 如何区分不同的AP

# WLAN 网络架构

## 空间流
无线电在同一时间发送多个信号，每一份信号都是空间流。
空间流使用发射端的天线进行发送，每个空间流经过不同的路径到达接收端。通常情况下一个接收天线和一个发送天线建立一个空间流。80211.ax规定一个射频最大只能建立8个空间流。

## fat AP
- 每个AP独立自治
- 人工成本高
  
## ac+FIT AP 

### 二层组网

## ac可靠性 
![](images/wlan/AC%E5%8F%AF%E9%9D%A0%E6%80%A7.png)
### 双链路双机设备
![](images/wlan/%E5%8F%8C%E9%93%BE%E8%B7%AF%E5%8F%8C%E6%9C%BA%E7%83%AD%E5%A4%87.png)

## capwap隧道
![](images/wlan/CAPWAP.png)

![](images/wlan/capwap_chanel.png)
## capwap隧道

## WLAN漫游概述
⚫ WLAN漫游是指STA在不同AP覆盖范围之间移动且
保持用户业务不中断的行为。
⚫ 实现WLAN漫游的两个AP必须使用相同的SSID和安
全模板（安全模板名称可以不同，但是安全模板下
的配置必须相同），认证模板的认证方式和认证参
数也要配置相同。
⚫ WLAN漫游策略主要解决以下问题：
- 避免漫游过程中的认证时间过长导致丢包甚至业务中
断。
- 保证用户授权信息不变。
- 保证用户IP地址不变。
### 二层三层漫游
• 二层漫游：1个无线客户端在2个AP（或多个AP）之间来回切换连接无线，前提是这
些AP都绑定的是同1个SSID并且业务VLAN都在同1个VLAN内（在同一个IP地址段），
漫游切换的过程中，无线客户端的接入属性（比如无线客户端所属的业务VLAN、获
取的IP地址等属性）不会有任何变化，直接平滑过渡，在漫游的过程中不会有丢包和
断线重连的现象。
• 三层漫游：漫游前后SSID的业务VLAN不同，AP所提供的业务网络为不同的三层网络，
对应不同的网关。此时，为保持漫游用户IP地址不变的特性，需要将用户流量迂回到
初始接入网段的AP，实现跨VLAN漫游。

# wifi6
## wifi6技术介绍
1. 背景介绍
![](images/wlan/wifi6.png)
2. Wi-Fi 6 VS Wi-Fi 5
    | 大带宽 | 高并发| 低时延| 低耗电|
    | :------------- | :----------: | ------------: |------------: |
    |⚫ 速率高达 9.6 Gbps ⚫ 带宽提 升 4 倍| ⚫ 每AP接入 1024 终⚫ 并发用户数提升 4 倍| ⚫ 业务时延低至 20 m s ⚫ 平均时延降低 30%|⚫目标时间唤醒机制⚫ 终端功耗降低 30%|

    wifi6:
    协议最高速率：
    2.4Ghz 1.15Gbps
    5GHz 9.6gbps
    

## Wi-Fi 6技术：OFDMA
⚫ OFDMA是正交频分多址技术，同样是通过不同的频率区分不同的用户。但是与传统FDMA相比，OFDMA的频谱利用率有很大的提
升。 OFDMA实现了多个用户同时进行数据传输，增加了空口效率，大大减少了应用的延迟，同时也降低了用户的冲突退避概念。
⚫ 资源单位RU（核心）：
- 802.11ax 将现有的 20 MHz、40 MHz、80 MHz 以及160 MHz 带宽划分成若干个不同的资源单元（RU）。
- 一共定义了7种RU类型，分别是26-tone RU、52-tone RU、106-tone RU、242-tone RU、484-tone RU、996-tone RU 和 2x 996-tone RU，一个
用户可以同时使用多个RU来传输数据。
## Wi-Fi 6技术：TWT (唤醒时间调度)
### 是什么？
Wi-Fi 6还
支持一项称为“唤醒时间调度（TWT）”的新特性，其允许AP告知客户端何时休眠，并给客户端提供何时唤醒的调度表。每次客户端休眠的时间虽然很短，但多次这样的休眠会明显延长设备的续航时间。
• TWT（Target Wakeup Time）：按需唤醒终端Wi-Fi，终端功耗可降低30%。
• TWT 是由 802.11ah 标准首次提出，初衷是针对 IoT 设备，尤其是低业务量的设备（例如智能电表等）设计的一套节能机制，使得 IoT 设备能够尽可能长时间地处于休眠状态，从而实现极低功耗的目的。建立 TWT 协议后，站点无须接收 Beacon 帧，而是按照一个更长的周期醒来。802.11ax 标准对其进行改进，引入了一些针对站点行为的规则，在满足节能的前提下实现了对信道接入的管控。

# 华为VRP系统概述
VRP 

## 设备管理
### web 网管方式

### 命令行方式
### 用户级别
分为0-15级, 0 最低

![](images/wlan/VRP_user.png)

display lldp


### AC 升级
  -  display startup  查看当前版本
  -  startup system-software 升级包
  -  reboot 重启之后自动版本升级
  -  display ap all 查看所有ap 状态
### AP 升级
display ap ver 

升级步骤：
1.改为AC模式：ap update mode ac-mode
2. 设置更新文件 ap update filename 升级包 aptype 
3. ap reset all  AP  重启
4. dis ap all 查看ap 状态
# 配置FAT AP

1.切换为fat 模式
ap-mode-switch fat

2. wlan 进入wlan 视图
3. country-code CN 

用交换机作为dhcp 分配IP地址
创建vlanif 为 AP分配Ip地址

dhcp enable
interface vlanif 100 
ip address 10.1.100.1 24   设置网关 IP，一般默认使用网段第一个IP做为网关地址
dhcp select interface 

## 创建安全模板
1. security-profile  name test
2. security wap-wapa2 psk pass-phsase 密码 aes   # 设置密码加密方式
## 设置SSID
1.wlan
2. ssid-profile name  test
3. ssid test 

# VAP 模板
创建摸吧
vap-profile  name test

配置wlan 业务
ssid-profile test
security-profile test 
service-vlan vlanid 100

# WLAN 接入安全

# 数据安全
1.主要通过对报文数据进行加密，保证只有特定的设备，可以对数据进行解密
2.wlan 加密方式：
   - TKIP  临时秘钥完整性协议
   -  CCMP 
3.WPA 采用TKIP 加密算法，提供了秘钥重置机制，并增强了秘钥长度，很大程度上弥补了WEP的不足
4. WPA2 CCMP加密协议，该加密机制使用的是AES加密算法，是一种比TYIP 更难破解的对称加密算法。
# WLAN准入 控制
NAC  network admission Control 网络接入控制，通过对接入网络的客户端和用户的认证保证网络的安全，是一种“端到端”的安全技术
NAC与AAA互相配合，共同完成接入认证功能。
• NAC：
- 用于用户和接入设备之间的交互
- NAC负责控制用户的接入方式（802.1X，MAC或Portal认证），接
入过程中的各类参数和定时器
- 确保合法用户和接入设备建立安全稳定的连接。

AAA：
AAA是Authentication（认证）、Authorization（授权）和Accounting（计费）的简称，是网络安全
的一种管理机制，提供了认证、授权、计费三种安全功能
- 用于接入设备与认证服务器之间的交互。
- AAA服务器通过对接入用户进行认证、授权和计费实现对接入用户
访问权限的控制。
 认证：验证用户是否可以获得网络访问权。
 授权：授权用户可以使用哪些服务。
 计费：记录用户使用网络资源的情况。

## 配置开放认证
创建安全模板
- 创建一个安全模板并进入安全模板视图，缺省情况下，系统已经创建名称为default、default-wds和default-mesh的安全模板。
⚫ 配置安全策略为开放认证
-  配置安全策略为开放认证。缺省情况下，安全策略为open。

• 命令：security { wpa | wpa2 | wpa-wpa2 } psk { pass-phrase | hex } key-value
{ aes | tkip | aes-tkip }
▫ wpa：使用WPA（Wi-Fi网络安全存取版本1）认证方式。
▫ wpa2：使用WPA2（Wi-Fi网络安全存取版本2）认证方式。
▫ wpa-wpa2：使用WPA和WPA2混合方式。用户终端使用WPA或WPA2都可以进
行认证。
▫ psk：采用PSK认证方式。
▫ pass-phrase：密钥短语。
▫ Hex：十六进制数。
▫ key-value：用户口令。
▫ aes：使用AES（对称加密算法）方式加密数据。
▫ tkip：使用TKIP（临时密钥完整性协议）方式加密数据。
▫ aes-tkip：使用AES和TKIP混合加密。用户终端支持AES或TKIP，认证通过后，
即可使用支持的算法加密数据。

## 配置WPA/WPA2-PPSK认证
⚫ 创建安全模板
⚫ 配置安全策略为WPA/WPA2-PPSK
⚫ 配置PPSK关键参数
 创建PPSK用户，配置PPSK用户的密码、用户名、所属用户组、绑定的授权VLAN、过期时间、最大接入用户数、
所属分支组、绑定的MAC地址、接入的SSID。
[AC] wlan
[AC-wlan-view] security-profile name profile-name
[AC-wlan-sec-prof-wlan] security { wpa | wpa2 | wpa-wpa2 } ppsk { aes | tkip | aes-tkip }
[AC-wlan-sec-prof-wlan] quit
[AC-wlan-view] ppsk-user psk { pass-phrase | hex } key-value [ user-name user-name | user-group user-group | vlan vlan-id |
expire-date expire-date [ expire-hour expire-hour ] | max-device max-device-number | branch-group branch-group | macaddress mac-address ]* ssid ssid

## WLAN 业务配置

![](images/wlan/wlan%E9%85%8D%E7%BD%AE%E6%B5%81%E7%A8%8B.png)

### vap 模板
1.vap 引入安全模板
安全模板就是创建 密码已经加密方式
ssid 模板就是创建用于链接的标识


SW配置
▫ [SW1] vlan batch 100 101
▫ [SW1] interface gigabitethernet 0/0/1
▫ [SW1-GigabitEthernet0/0/1] port link-type access
▫ [SW1-GigabitEthernet0/0/1] port default vlan 100
▫ [SW1-GigabitEthernet0/0/1] quit
▫ [SW1] interface gigabitethernet 0/0/2
▫ [SW1-GigabitEthernet0/0/2] port link-type trunk
▫ [SW1-GigabitEthernet0/0/2] port trunk allow-pass vlan 100 101
▫ [SW1-GigabitEthernet0/0/2] quit
• AC配置
▫ [AC] vlan batch 100 101
▫ [AC] interface gigabitethernet 0/0/1
▫ [AC-GigabitEthernet0/0/1] port link-type trunk
▫ [AC-GigabitEthernet0/0/1] port trunk allow-pass vlan 100 101
▫ [AC-GigabitEthernet0/0/1] quit

display vap ssid employee查ssid 状态

AC 设置dhcp
dhcp select gloable 

删除capwap 隧道
undo capwap source ip-address 10.10.1.1

配置capwap
capwap source  interface LoopBack 0

创建AP组
ap-group name huawei

设置AP name
ap name AP2

设置mac 认证
ap auth-mode mac-auth
添加认证mac
ap-mac mac地址
添加ap 进组
ap-group  huawei


# tunnel 转发和直接转发 的区别？

# 故障排除
- AP 不上线原因
  - 先查看是否有IP
  - AP认证不通过，有可能MAC地址敲错了
  - AP 设备供电不足
  - 检查AP状态 display ap all, AP 状态 
    - normal 正常
    - standby AP 在AC设备链接正常
    - idel AP和AC连接前初始状态
    - download 正在升级
    - fault 上线失败
    - commit-failed AP 上线后WLAN业务配置下发失败
    - config-failed AP 上线过程中WLAN业务配置下发失败
    - name-conflicted AP  名称冲突
    - xxx-mimatch AP和AC的xxx参数不匹配
    - unauth 未认证
  -  管理AP是否超限 display license usage 
  -  查看 CAPWAP 链路信息 display capwap link all 
  -   查看AP掉线 display ap offline-record
  -   检查用户上线失败原因
      -   display station online-failed-record sta-mac  mac地址
  - 查看AP 用户关联数量  display  ssid-profile name ssiid0 
    - 修改最大在线用户数： wlan-》 ssid-profile name ssid0 -> nax-sta-number 70 
  - 检查VAP状态是否正常
    - 确保AP已正常上线，然后使用display vap来检查VAP状态。
    正常创建的VAP，BSSID字段值不为全0；处于工作状态的VAP，Status字段值为ON。
     如果VAP未正常创建，可以通过display vap create-fail-record all查看VAP创建失败的原因，并根据原因进一步处理。
     如果确认配置正常，即射频下绑定了VAP，但BSSID字段值为全0，一般是由于配置下发失败。
     如果BSSID显示正常，但是Status字段值为OFF，一般是由于配置导致，如射频开关未打开，VAP被禁用等。   
- 检查隐藏SSID配置
  - display rrm-profile name default
  - 可以在RRM模板下执行undo uac reach-access-threshold命令关闭射频达到设置的接入用户数时自动
  隐藏SSID功能。
- 检查SSID模板配置
  - display vap-profile name VAP-Profile-Name
- 检查AP发送的Beacon报文
  - display Wi-Fi radio-statistics radio 0
  - Beacon报文丢失数量是相对于发送数量，如果Missed数量比Transmitted数量多，则STA会很
  难搜索到信号。
   Beacon报文丢失是因为空口一直处于繁忙状态，AP竞争不到发送报文的时间。
   可以使用display ap traffic statistics wireless检查当前环境下的信道利用率和信道底噪。
- 排查空口环境干扰
  - 信道利用率是体现空口状态的一个重要因素，如果AP上业务量较小，但信道利用率比较
  高，则说明空口干扰比较严重。
 - 排查周围环境中的其他干扰，一般需要通过扫描软件扫描周围的空口环境，常用的扫描工具有
WirelessMon、inSSIDer、Network Stumbler等，Android手机可以使用Wi-Fi分析仪。
  - display Wi-Fi base-info radio 0
- 查看用户是否认证成功： 
  - display access-user
- 查看用户接入是否正常：
  - display station assoc-info sta 148f-c661-b424
- 
display ip pool interface VLANif12

- 功分器
  - 把AP的功率等分输出到远端
- 耦合器
  - 将输入信号分成两路不等的功率
- 合路器
  - 把多个系统发射的信号互不干扰的合成一路输出

WLAN规划：
• 普通上网/收发Email：512 kbps;
• 标清视频：2 Mbps
• 推荐吸顶
• POE供电网线距离不超过100米
# CSMA/CA
802.11无线局域网协议中，冲突的检测碰撞会浪费宝贵的传输资源，所需代价较大，因此802.11 转而使用冲突避免（CSMA/CA）机
制。
• CS：载波侦听，在发送数据之前进行侦听，以确保线路空闲，减少冲突的机会。
• MA：多址访问，每个站点发送的数据，可以同时被多个站点接收。
• CA：Collision Avoidance，冲突避免，是碰撞避免的意思，或者说，协议的设计是要尽量减少碰撞发生的概率。
# RTS/CTS
RTS/CTS（Request To Send/Clear To Send，请求发送/允许发送）协议是被802.11无线网络协议采用的一种用来减少节点问题所造
成的冲突机制。
 RTS帧的作用：预约链路使用权；其他收到该RTS的STA保持沉默。
 CTS帧作用：用于AP 答复RTS帧；其他收到该CTS的STA保持沉默
# WLAN 施工：
工勘： 应该怎么做？

华为材料：

https://support.huawei.com/enterprise/zh/doc/DOC1000113314?section=j003



https://support.huawei.com/enterprise/zh/doc/EDOC1100154882?section=j00e

现场工勘采集信息表 (1)
| 工勘收集信息  | 信息记录（例） | 备注|
|楼层的层高 |普通室内楼层高度3 m |  获取镂空区域、大厅或者报告厅等区域的层高信息至关重要。|
可借助测距仪测量
建筑材质及衰减 240 mm砖墙（2.4 GHz 15dB衰减，5
GHz 25dB衰减） 获取现场建筑材质的厚度及衰减，如有条件可现场测试衰减。
干扰源 检测到有其他Wi-Fi干扰，已在图纸上
额外标注干扰源信息
检测现场是否有干扰，包括手机热点，其他厂家Wi-Fi，非Wi-Fi干扰
（如蓝牙、微波炉等）。
可借助工具（CloudCampus App）记录干扰源信息
新增障碍物 现场有新增隔断，已在图纸上额外标注 确认现场是否与建筑图纸完全一致，对于不一致的区域需重点标注，尽
量拍摄照片记录
现场照片 拍照记录全局照片 现场尽可能多拍摄照片，尽量全面地拍摄现场的照片，用于记录环境、
传递勘测信息
注：在无线网络环境中，由于障碍物对无线信号有着较强的衰减，从而影响用户的最终体验，因此在工勘过程中，需要特别关注并掌
握对未知障碍物衰减测试的具体方法。

## 容量计算
• 总带宽需求=总用户数*并发率*每用户带宽需求
• AP数量=总带宽需求/每AP带宽

# 网络测试
WLAN Planner在线网规工具。免安装，使用uniportal账号直接登录使用，PDF、JPG、PNG、
BMP等格式图纸的障碍物自动识别，无需下载新版本、申请license。推荐使用
Chrome浏览器。

工具和手册获取方法：https://serviceturbo-cloud-cn.huawei.com/#/toolappmarket
• 工具名称：CloudCampus APP
CloudCampus APP验收。

WLAN Planner
https://serviceturbo-cloud.huawei.com/serviceturbocloud/#/campusContainer?draftId=ae3aafb4-749a-4d5e-918f-bff02cb1edd2&projectId=19b71d0e-0b06-4996-b896-81df766ff638&appId=d59de9ac-e4ef-409e-bbdc-eff3d0346b42&userId=xzg323_1&projectType=0