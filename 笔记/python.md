# python

## 1.介绍

## 2.基础操作

#### 2.1 文件操作

读取文件列表：

```
#1
import os

# 当前目录
dir_path = '/path/to/current/directory'

# 获取当前目录下的所有文件
files = [os.path.join(base_dir, file) for file in os.listdir(base_dir)]

# 遍历文件列表，输出文件名
for file in files:
    print(file)


# 2 glob模块中的glob()函数

import os
import glob

# 获取当前目录
directory = os.getcwd()

# 获取所有文件
files = glob.glob(directory + "/*")

# 输出所有文件名
for file in files:
    print(file) 
    
# 3 subprocess 执行命令   
    
import os

dir_path = '当前目录'
files = os.listdir(dir_path)
for file in files:
    output = subprocess.check_output(['ls', '-l', '-a', dir_path, file])
    print(file + ':' + output.decode('utf-8').strip()) 
```

判断文件是否存在：

```
创建文件
file = open("filename.txt", "w")
file.close()

写入文件
file = open("filename.txt", "w")
file.write("Hello, World!")
file.close()

读取文件
file = open("filename.txt", "r")
content = file.read() # 读取整个文件内容
lines = file.readlines() # 逐行读取文件内容 返回一个数组
file.close()


迭代器方式逐行读取
with open('file.txt', 'r') as f:
    for line in f:
        print(line)
换行符的转换

如果在读取文件时需要将换行符进行转换，可以使用strip方法将换行符删除，并使用replace方法将不同操作系统上的换行符转换为统一的"\n"：
with open('file.txt', 'r') as f:
    lines = [line.strip().replace('\r\n', '\n').replace('\r', '\n') for line in f]
strip方法用于删除行末的换行符，replace方法用于将不同的换行符转换为统一的"\n"。最终得到的lines列表中的每一个元素都是一行文件的内容。

追加内容

file = open("filename.txt", "a")

file.write("New content")

file.close()


判断文件是否存在
os.path.exists("file1.txt")

重命名
os.rename("file1.txt", "myfile.txt")

# 移除
os.remove("aa.txt")
os.removedirs() 方法用于递归删除目录

os.rmdir() 方法用于删除指定路径的目录。仅当这文件夹是空的才可以, 否则, 抛出OSError。
os.unlink() 方法用于删除文件,如果文件是一个目录则返回一个错误。

Python清空指定文件夹下所有文件的方法： 
这个需求很简单：需要在执行某些代码前清空指定的文件夹，如果直接用os.remove()，可能出现因文件夹中文件被占用而无法删除，解决方法也很简单，先强制删除文件夹，再重新建同名文件夹即可：

import shutil  
shutil.rmtree('要清空的文件夹名')  
os.mkdir('要清空的文件夹名')  
shutil.rmtree(os.path.join("test_delete", "test_1_delete"))

import shutil
 
# 移动文件
shutil.move(r'C:\example\oldfile.txt', r'C:\example\newfile.txt')
 
 获取当前路径
 os.getcwd()
 
 路径的拼接
 os.path.join('output', 'pretext.xlsx')
 
 显示当前目录下所包含的所有文件
 os.listdir('文件夹名称')
 
 
 复制文件
 shutil.copy(os.path.join('test_dir', 'data.csv'), 'output')
 
 # 压缩包
 创建一个压缩包
 file_lists = list(glob(os.path.join('.', '*.xlsx')))
with zipfile.ZipFile(r"我创建的压缩包.zip", "w") as zipobj:
    for file in file_lists:
        zipobj.write(file)

 读取压缩包当中的文件信息
 with zipfile.ZipFile("我创建的压缩包.zip", "r") as zipobj:
    print(zipobj.namelist())
    
 将压缩包当中的单个文件，解压出来
 dst = "output"
with zipfile.ZipFile("我创建的压缩包.zip", "r") as zipobj:
    zipobj.extract("Book1.xlsx",dst)
    
  将压缩包中的所有文件，都解压出来
 dst = "output
with zipfile.ZipFile("我创建的压缩包.zip", "r") as zipobj:
    zipobj.extractall(dst)
 
 
```

## 3.游戏 

 





### 素材

####  1. 音乐素材    https://www.aigei.com/music/class/



## 4. 面向对象

`__dict__`类变量查看对象的实例变量

```
student = Student('a', 10)
print(student.__dict__)
查看类变量
print(Student.__dict__)
```

#### 4.1 类函数(类方法)

定义类方法, 使用`@classmethod`装饰器

- 类方法关联类变量

- 实例方法关联实例变量
-  调用：实例对象和类对象都可以调用。

#### 4.2 静态方法

静态方法第一个参数不代表类本身, 而是一个参数

#####  使用

-   调用：实例对象和类对象都可以调用。
- 静态方法可以使用类变量

#### 4.3多态







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

pymysql

```
import pymysql

mydb =pymysql.connect(
  host="192.168.90.90",
  user="root",
  password="xxx"
)

mycursor = mydb.cursor()

mycursor.execute("CREATE DATABASE mydatabase")


```

#### 6.5 转换为json 

```
print(json.dumps(brick.__dict__))


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



## 9 python 常用的包的使用方法

### 9.1 Numpy

#### np.reshape()

```
# 使用-1作为占位符来转换数组形状
# 这里-1意味着Numpy会自动计算该维度的大小，保持总元素数不变
arr_2d_with_minus_one = np.reshape(arr_1d, (-1, 2))

np.ravel()和np.flatten()都会返回一维数组，但它们在处理内存时有所不同。np.ravel()返回的是原数组的视图（view），而np.flatten()返回的是原数组的副本（copy）。
np.ndarray.resize()会直接改变原数组的形状和大小，而不是返回一个新数组 
```







np.ravel()和np.flatten()都会返回一维数组，但它们在处理内存时有所不同。np.ravel()返回的是原数组的视图（view），而np.flatten()返回的是原数组的副本（copy）。
np.ndarray.resize()会直接改变原数组的形状和大小，而不是返回一个新数组。



### 抓包工具
- fidder4


## 参考资料

一些数据接口：http://doc.gopup.cn/#/data/info_data

爬虫案例

https://gitcode.net/hihell/python120/-/tree/master/NO50
