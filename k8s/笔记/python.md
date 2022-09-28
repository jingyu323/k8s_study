# python

## 1.介绍

## 2.作用

## 3.优点

## 4.实现原理

## 5.安装

## 6.使用

## 7.常见问题
## 8.爬虫
爬虫到底是个什么呢? 

　　爬虫就是通过编写程序，浏览模拟器上网，然后让其去互联网上爬取数据的过程.

爬虫分类

通用爬虫：将一整张爬虫进行爬取，搜索引擎用的比较多。
聚焦爬虫：将一张爬下来，在获取指定元素。
增量式：只爬取最新或者没有爬过的数据。
反爬机制

门户网站，设计逻辑机制阻止爬虫程序。
反反爬策略

破解防反爬策略。
rebots.txt协议

它是一个反爬机制，指定的协议。
遵从或者不遵从


### Python requests 模块
requests 模块是我们使用的 python爬虫 模块 可以完成市场进80%的爬虫需求。

安装

pip install requests
使用

requests模块代码编写的流程：

- 指定url
- 发起请求
- 获取响应对象中的数据
- 持久化存储

```python
import requests
# 指定url
url="https://www.sogou.com/"
# 发起请求
response = requests.get(url)
# 获取响应对象中的数据
page_text = response.text
# 持久化存储
with open('./sogou.html','w',encoding='utf-8') as fp:
    fp.write()
```

参数

```python
# post 数据
response = requests.post(url=url,data=data,headers=headers)

# get 数据
response = requests.get(url=url,data=data,headers=headers)

# 返回二进制数据
response.content  

# 返回字符串数据    
response.text    

# 返回json对象     
response.json()     
```  

其他了解

1、该模块实现爬取数据前需要查找需要爬取数据的指定URL，可通过浏览器自带抓包功能。

### 浏览器抓取 Ajax 请求
F12 --> Network --> XHR --> Name --> Response
2、上面的headers参数是进行UA伪装为了反反爬

反爬机制：UA检测 --> UA伪装
3、下面是http我们爬包是常用的请求头参数

复制代码
　　- accept: 浏览器通过这个头告诉服务器，他所支持的数据类型

　　- Accept-Charset：浏览器通过这个头告诉服务器，它支持那种字符集

　　- Accept-Encoding：浏览器通过这个头告诉服务器，支持的压缩格式

　　- Accept-Language：浏览器通过这个头告诉服务器，他的语言环境

　　- Host：浏览器同过这个头告诉服务器，想访问哪台主机

　　- If-ModifiedSince：浏览器通过这个头告诉服务器，缓存数据的时间

　　- Heferer：浏览器通过这个头告诉服务器，客户及时那个页面来的，防盗链

　　- Connection：浏览器通过这个头告诉服务器，请求完后是断开链接还是保持链接

　　- X-Requested-With：XMLHttpRequest 代表通过ajax方式进行访问

　　- User-Agent：请求载体的身份标识

### 抓包工具
- fidder4


## 参考资料

