# python

## 1.介绍

## 2.作用

## 3.优点

## 4.实现原理

## 5.安装

## 6.使用

#### 6.1 正则

```
字符串中间尽量使用非贪婪匹配，也就是用.*?叫来代替.* ,如果匹配的结果在字符串结尾，.*?就有可能匹配不到任何内容
```

#### 6.2 闭包

调用和引用的区别
调用：会直接从内存中去取出相应的对象执行，代码会直接执行

引用：设置了一个路标，该路标指向某一个内存地址中的对象。此时相当于加载了代码在一个缓存空间内，代码并没有被执行。

提醒：如果在没有返回值return的情况下调用闭包函数时，只会调用外层函数，不会调用内层函数

#### 6.3 方法参数传递和使用

方法参数不需要指定类型，上一个方法的返回值，直接当作参数传递进去，不像java 需要指定类型。

```
def insert_data( conn):

    cur = conn.cursor()
    SQL = 'create table if not exists info(' \
          'id int primary key,' \
          'title char not null,' \
          'photo_src char not null)'

    try:
        # 开启一个事务
        conn.begin()
        # 设置将执行的SQL语句
        cur.execute(SQL)
        # 提交事务
        conn.commit()
    except Exception:
        print('【初始化失败（表）】')
        # 打印错误信息
        print('  ', traceback.print_exc())
   
使用 
    conn = get_pymysql_conn()
    insert_data(conn)
```

#### 6.4 数据库连接

```
import mysql.connector

mydb = mysql.connector.connect(
 host="localhost",
 user="yourusername",
 password="yourpassword"
)

mycursor = mydb.cursor()

mycursor.execute("CREATE DATABASE mydatabase")

# 检查数据库是否已创建
mycursor.execute("SHOW DATABASES")
for x in mycursor:
  print(x)
```





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



### 8.3 web爬虫类库



#### 8.3.1 Beautiful Soup 

的一个HTML 或XML 的解析库，我们可以用它来方便地从网页中提取数据。

pip install beautifulsoup4

https://beautifulsoup.readthedocs.io/zh_CN/v4.4.0/#id55

#### 8.3.2 pyquery 

同样是一个强大的网页解析工具，它提供了和jQuery 类似的语法来解析HTML 文梢， 支持c ss 选择器，使用非常方便。

#### 8.3.3 tesserocr

安装tesserocr
1、打开链接，https://digi.bib.uni-mannheim.de/tesseract/，见下图。



在爬虫过程中，难免会遇到各种各样的验证码，而大多数验证码还是罔形验证码，这时候我们可以直接用OCR 来识别。

安装插件

conda install -c simonflueckiger tesserocr pillow

tesseract test.png result -l chi_sim 

安装Python的OCR识别库

pip install Pillow
pip install pytesseract

#### 8.3.4 RedisDump 

RedisDump 是一个用于Redis 数据导人／导出的工具，是基于Ruby 实现的，所以要安装RedisDump ,需要先安装Ruby

#### 8.3.5 Tornado 

Tornado 是一个支持异步的Web 框架，通过使用非阻塞I / O 流，它可以支撑成千上万的开放连接，效率非常高，本节就来介绍一下它的安装方式

pip install tornado

gem install redis-dump 



安装成功后，就可以执行如下两个命令：
redis dump
redis-load



#### 8.3.6  pyspider

http://docs.pyspider.org/en/latest/Quickstart/ 

如果要快速实现一个页面的抓取，推荐使用 pyspider，开发更加便捷，如快速抓取某个普通新闻网站的新闻内容。如果要应对反爬程度很强、超大规模的抓取，推荐使用 Scrapy，如抓取封 IP、封账号、高频验证的网站的大规模数据采集。


著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

下载对应的pycurl安装包

https://www.lfd.uci.edu/~gohlke/pythonlibs/

执行安装

pip install D:\下载\ad3-2.2.1-cp39-cp39-win32.whl

在执行安装 pip  install pyspider 即可成功



替换 async 为 async1

tornado_fetcher.py

site-packages\pyspider\run.py

  phantomjs安装步骤

pip install pymysql

pip install pymongo

pip install redis

pip  install mitmproxy    mitmweb 和mitmdump  是 mitmproxy    关键组建



用来爬取App 

 Appium



Scrapy



#### 8.3.7  Selenium 

https://python-selenium-zh.readthedocs.io/zh_CN/latest/1.%E5%AE%89%E8%A3%85/

https://www.selenium.dev/documentation/

#### 8.3.8  jupyter  

安装成功之后

pip install jupyter -i https://pypi.tuna.tsinghua.edu.cn/simple

生成配置

jupyter notebook --generate-config

在 jupyter  中不能定义方法 只能直接运行

jupyter notebook  启动 jupyter 

http://localhost:8888/tree#notebooks



### 8.4 APP 爬虫类库安装

#### 8.4.1  Charles

Charles 是一个网络抓包工具，相比Fiddler ，其功能更为强大， 而且跨平台支持得更好，所以这
里选用它来作为主要的移动端抓包工具





### 抓包工具
- fidder4


## 参考资料

一些数据接口：http://doc.gopup.cn/#/data/info_data

爬虫案例

https://gitcode.net/hihell/python120/-/tree/master/NO50
