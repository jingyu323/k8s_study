



# java 
## java 基础

将一个字符串直接转化为字节数组和将一个字符串转为十六进制字符串再转化为字节数组。字节数组是一样的

jdk 安装

远程调试

```
CATALINA_OPTS="-server -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8788"
```

idea  debug config 中添加  Remote Jvm Debug

## java 安装配置

vi /etc/profile

JAVA_HOME=/usr/local/jdk1.8.0_231
JRE_HOME=$JAVA_HOME/jre
CLASS_PATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
export JAVA_HOME JRE_HOME CLASS_PATH PATH

source /etc/profile 使生效  Java -version 检测安装是否安装成功



## 分布式Session处理方案：



## Springboot：

```yaml
java -jar spring-boot-config.jar --spring.config.location=F:/application.properties
```



jar 中修改参数

```
java -jar aaa.jar --server.port = 8083

java -jar ftpagent-0.0.1.jar --external.devname=eno2
```

##  @Scheduled

1、fixedRate

例：@Scheduled(fixedRate = 5000) //上一次开始执行时间点之后5秒再执行

2、fixedDelay

例：@Scheduled(fixedDelay = 5000) //上一次执行完毕时间点之后5秒再执行

3、cron

例：@Scheduled(cron = "0 0/1 9-21 * * ?")//每天早上9点-晚上21点间执行，每次执行间隔一分钟


## 线程池
核心参数

```java
public ThreadPoolExecutor(int corePoolSize,
                            int maximumPoolSize,
                            long keepAliveTime,
                            TimeUnit unit,
                            BlockingQueue<Runnable> workQueue,	
                            ThreadFactory threadFactory,
                            RejectedExecutionHandler handler);

```
- 3.1 corePoolSize 线程池核心线程大小
线程池中维护的一个最少的线程数量,即使这些线程处于空闲状态,他们也不会被销毁,除非设置了allowCoreThreadTimeOut。

- 3.2 maximumPoolSize 线程池最大线程数量
一个任务被提交到线程池之后，首先会到工作队列中，如果工作队列满了，则会创建一个新的线程，然后从工作队列中取出一个任务交给新线程处理，而将刚提交上来的任务放入到工作队列中。线程池最大的线程数量由maximunPoolSize来指定。

- 3.3 keepAliveTime 空闲线程存活时间
一个线程如果处于空闲状态，并且当前的线程数量大于corePoolSize，那么在指定的时间后，这个空闲的线程将被销毁，这个指定的时间就是keepAliveTime。

- 3.4 unit 空闲线程存活时间单位
keepAliveTime的计量单位，是一个枚举java.util.concurrent.TimeUnit。

- 3.5 workQueue 工作队列
新任务被提交之后，会先进入到此工作队列中，任务调度时再从队列中取出任务。jdk一共提供了四种工作队列。
ArrayBlockingQueue 数组型阻塞队列：数组结构，初始化时传入大小，有界，FIFO（先进先出），使用一个重入锁，默认使用非公平锁，入队和出队共用一个锁，互斥。
LinkedBlockingQueue 链表型阻塞队列：链表结构，默认初始化大小为Integer.MAX_VALUE，有界（近似无解），FIFO，使用两个重入锁分别控制元素的入队和出队，用Condition进行线程间的唤醒和等待。
SynchronousQueue 同步队列：容量为0，添加任务必须等待取出任务，这个队列相当于通道，不存储元素。
PriorityBlockingQueue 优先阻塞队列：无界，默认采用元素自然顺序升序排列。
DelayQueue 延时队列：无界，元素有过期时间，过期的元素才能被取出。
- 3.6 threadFactory 线程工厂
创建新线程的时候使用的工厂，可以用来指定线程名，是否为daemon线程等等。

- 3.7 handler 拒绝策略
当工作队列中的任务已经达到了最大的限制，并且线程池中线程数量达到了最大限制，如果这时候有新任务进来，就会采取拒绝策略，jdk中提供了四种拒绝策略。
AbortPolicy：丢弃任务并抛出RejectedExecutionException异常。
DiscardPolicy：丢弃任务，但是不抛出异常。可能导致无法发现系统的异常状态。
DiscardOldestPolicy：丢弃队列最前面的任务，然后重新提交被拒绝的任务。
CallerRunsPolicy：由调用线程处理该任务。

线程池线程添加策略：
![img](images/%E7%AE%97%E6%B3%95.png) 

- 添加任务的方式
  - execute 方式添加任务
  ```java
  newExecutorService.execute(new Runnable() {
                @Override
                public void run() {
                    System.out.println("threadName;"+Thread.currentThread().getName()+",i"+temp);
                }
            });
  ```

 - threadPool.submit 方式添加任务
  ```java
  Future<Integer> result = threadPool.submit(new Callable<Integer>() {
                @Override
                public Integer call() throws Exception {
                    int num=new Random().nextInt(9);
                    System.out.println("随机数："+num);
                    return num;
                }
            });
  ```
  execute：只能执行不带返回值的任务； 
  submit：它可以执行有返回值的任务或者是没有返回值的任务 。
 - shutdown执行时线程池终止接收新任务，并且会将任务队列中的任务处理完；
 - shutdoNow执行时线程池终止接收新任务，并且会终止执行任务队列中的任务。

可以看到线程池的状态共有5种，分别为：

RUNNING：线程池创建之后的状态，这种状态下可以执行任务；
SHUTDOWN:该状态下线程池不再接受新任务，但是会将工作队列中的任务执行结束；
STOP：该状态下线程池不再接受新任务，并且会中断线程；
TIDYING:该状态下所有任务都已终止，将会执行terminated方法；
TEIMINATED：执行完terminated方法之后。

### 线程池优化
- 如果线程池中的任务执行时间比较长，长时间也就只能创建maxnumber数量的线程，所以根据实际情况选择使用线程池还是线程，线程池比较适合任务时间短且瞬时大量任务
- 核心线程数
  - IO密集型 应该多些线程  
    - 配置方式   CPU核数 * 2
    - CPU核数 / (1 - 阻塞系数)，阻塞系数在0.8~0.9之间
  - CPU 密集
    - CPU核数 + 1


## 1.校验

密码必须包含字母、数字和特殊符号且长度是6-32位：
 ```
 ^(?=.*[0-9])(?=.*[a-zA-Z])(?=.*[`~!@#$%^&*()-=_+;':",./<>?])(?=\S+$).{6,32}$
 ```

密码是8-16位字母和数字的组合

```
^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,16}$
```

^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,16}$
密码必须包含大写、小写、数字和特殊字符，且长度是6位以上

```
 ^(?=.*[0-9])(?=.*[A-Z])(?=.*[a-z])(?=.*[`~!@#$%^&*()-=_+;':",./<>?])(?=\S+$).{6,}$
```

```
public class PwdCheckUtil {
    /**
     * 密码必须包含大写、小写、数字和特殊字符，且长度是6位以上
     */
    private static final String PWD_REGEX = "^(?=.*[0-9])(?=.*[A-Z])(?=.*[a-z])(?=.*[`~!@#$%^&*()-=_+;':\",./<>?])(?=\\S+$).{6,}$";

    /**
     * 密码复杂度校验，判断有效性
     * @param password 密码信息
     * @return 校验密码是否合规有效
     */
    public static boolean isValidPassword(String password) {
        if (StringUtils.isBlank(password)) {
            return false;
        }
        return password.matches(PWD_REGEX);
    }
}
```
## 2.jar 相关



执行jar

nohup java -jar /home/htkj/agent/agent_test-1.0-SNAPSHOT-jar-with-dependencies.jar > /dev/null 2>&1 &

```
[Unit]
Description= ftp_agent
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
User=root
WorkingDirectory=/home/htkj/agent
ExecStart=nohup /usr/local/jdk8/bin/java -jar /home/htkj/agent/agent_test-1.0-SNAPSHOT-jar-with-dependencies.jar > /dev/null 2>&1 &
[Install]
WantedBy=multi-user.target


3.设置权限
  chmod 775  ftp_agent.service
  systemctl daemon-reload
4.设置自启动
  systemctl enable ftp_agent.service
5.启动服务
   systemctl start ftp_agent.service

```



监控查找进程

vim创建并保存 ftp_agent.service

agent_pid=`ps -ef | grep agent_test | grep v | awk '{print $2}'`

if [ -z "$agent_pid" ]; then
  systemctl start ftp_agent.service
  echo "`date +%Y-%m-%d` `date +%H:%M:%S`,start ftp agent" >>   ftp_agent_mornitor.log
else
  echo "`date +%Y-%m-%d` `date +%H:%M:%S`,ftp agent is running" >>   ftp_agent_mornitor.log

fi

定时任务配置，每隔3分钟执行一次

 */3 *  * * *  bash /home/mornitor/ftp_agent_mornitor.sh



直接打成jar包，需要在pom中添加，打出来的jar包以及依赖的jar独立存放

```
<build>
    <plugins>

        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-jar-plugin</artifactId>
            <version>2.6</version>
            <configuration>
                <archive>
                    <manifest>
                        <addClasspath>true</addClasspath>
                        <classpathPrefix>lib/</classpathPrefix>
                        <mainClass>TestMain</mainClass>
                    </manifest>
                </archive>
            </configuration>
        </plugin>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-dependency-plugin</artifactId>
            <version>2.10</version>
            <executions>
                <execution>
                    <id>copy-dependencies</id>
                    <phase>package</phase>
                    <goals>
                        <goal>copy-dependencies</goal>
                    </goals>
                    <configuration>
                        <outputDirectory>${project.build.directory}/lib</outputDirectory>
                    </configuration>
                </execution>
            </executions>
        </plugin>

    </plugins>
</build>

把jar和依赖的jar都打成一个jar，这种方便以jar为执行的方式

<build>
    <plugins>
 
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-assembly-plugin</artifactId>
            <version>2.5.5</version>
            <configuration>
                <archive>
                    <manifest>
                        <mainClass>TestMain</mainClass>
                    </manifest>
                </archive>
                <descriptorRefs>
                    <descriptorRef>jar-with-dependencies</descriptorRef>
                </descriptorRefs>
            </configuration>
        </plugin>
 
    </plugins>

```

```
把jar和依赖的jar都打成一个jar，这种方便以jar为执行的方式

<build>
	<plugins>
 
		<plugin>
			<groupId>org.apache.maven.plugins</groupId>
			<artifactId>maven-assembly-plugin</artifactId>
			<version>2.5.5</version>
			<configuration>
				<archive>
					<manifest>
						<mainClass>TestMain</mainClass>
					</manifest>
				</archive>
				<descriptorRefs>
					<descriptorRef>jar-with-dependencies</descriptorRef>
				</descriptorRefs>
			</configuration>
		</plugin>
 
	</plugins>
</build>
```

## jvm相关

### 1.tomcat 相关

##### 查看tomcat进程启动了多少个线程

1、 获取tomcat进程pid

```linux
ps -ef|grep tomcat
```

例如进程号是29295

2、 统计该tomcat进程内的线程个数

```linux
ps -Lf 29295|wc -l
```

3、查看该进程打开的文件数

```
lsof -p pid | wc -l
查询某个进程打开的文件列表

lsof | grep {pid}
查询某个进程打开的文件数目

lsof | grep {pid} | wc -l
查询进程使用的文件描述符

ls -l /proc/{pid}/fd/

查询进程使用的文件描述符数目

ls -l /proc/{pid}/fd/ | wc -l
1
查看系统文件描述符的最大设置

cat /proc/sys/fs/file-max
1
系统当前被使用的文件描述符数目

cat /proc/sys/fs/file-nr
```

### arthas 监控到JVM的实时运行状态

https://github.com/alibaba/arthas/releases









pstree -p 进程号，这个命令可以列出该进程的所有线程出来。

pstree -p 进程号 | wc -l,直接算出线程的总数过来

命令找不到  yum -y install psmisc

```
Handler dispatch failed; nested exception is java.lang.NoClassDefFoundError: Could not initialize class sun.awt.X11GraphicsEnvironment
org.springframework.web.util.NestedServletException: Handler dispatch failed; nested exception is java.lang.NoClassDefFoundError: Could not initialize class sun.awt.X11GraphicsEnvironment
	at org.springframework.web.servlet.DispatcherServlet.doDispatch(DispatcherServlet.java:978)
	at org.springframework.web.servlet.DispatcherServlet.doService(DispatcherServlet.java:897)
	at org.springframework.web.servlet.FrameworkServlet.processRequest(FrameworkServlet.java:970)
```
解决方案：
JAVA_OPTS="-server -Djava.awt.headless=true  -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -Xloggc:gc-%t.log -XX:+HeapDumpOnOutOfMemoryError  -XX:HeapDumpPath=/home/app/oom"



#### jvm 状态查看

```
https://blog.csdn.net/lufei0920/article/details/115196146
```



### JVM调优

为什么要做JVM调优？

一、防止出现OOM

即在系统部署之前，根据一些关键数据进行预估不同内存区域需要给多少内存合适

二、解决OOM

即线上出现了OOM，应该如何调优以保证程序能正常运行

二、减少full gc出现的频率

这个主要是堆区，如果设置的不合理就会频繁full gc，导致系统运行一阵暂停一阵，导致体验下降







## maven 打包

### maven 中执行 shell 脚本



```
<build>
        <finalName>demo</finalName>
        <plugins>
            <plugin>
                <artifactId>exec-maven-plugin</artifactId>
                <groupId>org.codehaus.mojo</groupId>
                <executions>
                    <execution>
                        <id>uncompress</id>
                        <phase>install</phase>
                        <goals>
                            <goal>exec</goal>
                        </goals>
                    </execution>
                </executions>
                <configuration>
                    <executable>${basedir}/../check-style/test.sh</executable>
                </configuration>
            </plugin>
        </plugins>
    </build>
```





# 多线程
## 线程的状态
- 新建状态： 使用 new Thread 类或其子类建立一个线程对象后，该线程对象就处于新建状态。
- 就绪状态：调用了start()方法之后，该线程就进入就绪状态（就绪队列中），等待JVM里线程调度器的调度
- 运行状态：执行 run()，此时线程便处于运行状态。处于运行状态的线程最为复杂，它可以变为阻塞状态、就绪状态和死亡状态
- 阻塞状态：如果一个线程执行了sleep（睡眠）、suspend（挂起）等方法，失去所占用资源之后，该线程就从运行状态进入阻塞状态
- 死亡状态：一个运行状态的线程完成任务或者其他终止条件发生时，该线程就切换到终止状态


##  锁

### 重入锁
锁重入的意思就是当一个线程得到一个对象锁后，再次请求此对象锁时是可以再次得到该对象的锁的。synchronized关键字拥有锁重入的功能，在一个synchronized方法/块内部调用本对象的其他synchronized方法/块时，是永远可以得到锁的，原因是Java中线程获得对象锁的操作是以线程为单位的，而不是以调用为单位的。同一个线程获得一个对象锁之后，再次访问这个对象的其他同步方法，所需的对象锁没有发生变化。

也就是说，当这个这个线程获取对象锁的时候，可以再次对这个对象加锁，

###  锁粗化
就是将多个连续的加锁、解锁操作连接在一起，扩展成一个范围更大的锁。
扩大加锁解锁的范围

###  锁消除
通过对运行上下文的扫描，去除不可能存在共享资源竞争的锁，通过这种方式消除没有必要的锁，可以节省毫无意义的请求锁时间
###  偏向锁
偏向锁的核心思想是，如果一个线程获得了锁，那么锁就进入偏向模式，此时Mark Word 的结构也变为偏向锁结构，当这个线程再次请求锁时，无需再做任何同步操作，即获取锁的过程，这样就省去了大量有关锁申请的操作，从而也就提供程序的性能。

偏向锁失败后，并不会立即膨胀为重量级锁，而是先升级为轻量级锁。

偏向锁的释放采用了一种只有竞争才会释放锁的机制，线程是不会主动去释放偏向锁，需要等待其他线程来竞争

注意：只要有线程执行同步代码，在没有竞争的情况下就是偏向锁


###  轻量级锁
是两个线程交替执行同步代码块，没有同一时刻执行的场景

### 自旋锁
轻量级获取锁失败后，为了避免线程操作系统层面挂起，耗费时间的问题,因为线程占用锁的时间较短，线程执行几个空循环等待锁释放的过程。

在经过若干次循环后，如果得到锁，就顺利进入临界区。如果还不能获得锁，那就会将线程在操作系统层面挂起，这就是自旋锁的优化方式，这种方式确实也是可以提升效率的。最后没办法也就只能升级为重量级锁了。



###  重量级锁
同一时间访问同一锁的场合，就会导致轻量级锁膨胀为重量级锁。
重量级锁也就是sychronized对象锁。


####  sychronized
实现原理：
JVM可以从方法常量池中的方法表结构(method_info Structure) 中的 ACC_SYNCHRONIZED 访问标志区分一个方法是否同步方法。当方法调用时，调用指令将会 检查方法的 ACC_SYNCHRONIZED 访问标志是否被设置，如果设置了，执行线程将先持有monitor（虚拟机规范中用的是管程一词）， 然后再执行方法，最后再方法完成(无论是正常完成还是非正常完成)时释放monitor。在方法执行期间，执行线程持有了monitor，其他任何线程都无法再获得同一个monitor。

传统的synchronized锁：队列锁

- java内置关键字
- 无法获取锁的状态
- 能自动释放
- 可重入 非公平 不可中断
- 适合少量代码的同步， 有方法和代码块锁
A: synchronized static是某个类的范围，synchronized static cSync{}防止多个线程同时访问这个类中的synchronized static 方法。它可以对类的所有对象实例起作用。

B: synchronized 是某实例的范围，synchronized isSync(){}防止多个线程同时访问这个实例中的synchronized 方法。

synchronized底层实现原理:



####  ReentrantLock

ReentrantLock的时候一定要手动释放锁，并且加锁次数和释放次数要一样,加锁和释放次数不一样导致的死锁
Lock所是一个接口，其所有的实现类为

ReentrantLock(可重入锁)
ReentrantReadWriteLock.ReadLock(可重入读写锁的读锁)
ReentrantReadWriteLock.WriteLock(可重入读写锁的写锁)


####  voilate

### Synchronized和ReentrantLock对比
#### 相同之处
都是加锁方式同步，而且都是阻塞式的同步，也就是说当如果一个线程获得了对象锁，进入了同步块，其他访问该同步块的线程都必须阻塞在同步块外面等待。

synchronized 与Lock都是可重入锁，同一个线程再次进入同步代码的时候.可以使用自己已经获取到的锁。

####  不同之处




#### ThreadLocal
1. ThreadLocal是什么
   ThreadLocal叫做线程变量，意思是ThreadLocal中填充的变量属于当前线程，该变量对其他线程而言是隔离的。ThreadLocal为变量在每个线程中都创建了一个副本，那么每个线程可以访问自己内部的副本变量
   作用：
   1、在进行对象跨层传递的时候，使用ThreadLocal可以避免多次传递，打破层次间的约束。
   2、线程间数据隔离
   3、进行事务操作，用于存储线程事务信息。
   4、数据库连接，Session会话管理。
   threadLocals属性对应在ThreadLocal中定义的ThreadLocalMap对象。 
#####  总结

（1）每个Thread维护着一个ThreadLocalMap的引用

（2）ThreadLocalMap是ThreadLocal的内部类，用Entry来进行存储

（3）ThreadLocal创建的副本是存储在自己的threadLocals中的，也就是自己的ThreadLocalMap。

（4）ThreadLocalMap的键值为ThreadLocal对象，而且可以有多个threadLocal变量，因此保存在map中

（5）在进行get之前，必须先set，否则会报空指针异常，当然也可以初始化一个，但是必须重写initialValue()方法。

（6）ThreadLocal本身并不存储值，它只是作为一个key来让线程从ThreadLocalMap获取value。


threadLocal 如何实现变量副本？
本质上就是一个Map 存放数据的map
注意点：
重点来了，突然我们ThreadLocal是null了，也就是要被垃圾回收器回收了，但是此时我们的ThreadLocalMap生命周期和Thread的一样，它不会回收，这时候就出现了一个现象。那就是ThreadLocalMap的key没了，但是value还在，这就造成了内存泄漏。

解决办法：使用完ThreadLocal后，执行remove操作，避免出现内存溢出情况。


#### synchronized和Lock锁的区别

synchronized:

是java内置的关键字
无法获取锁的状态
会自动释放锁
线程一在获得锁的情况下阻塞了，第二个线程就只能傻傻的等着
是不可中断的、非公平的、可重入锁
适合锁少量的同步代码
有代码块锁和方法锁
Lock:

是java的一个类
可判断是否获取了锁
需手动释放锁，如果不释放会造成死锁
线程一在获得锁的情况下阻塞了，可以使用tryLock()尝试获取锁
非公平的、可判断的、可重入锁
适合锁大量的同步代码
只有代码块锁
使用Lock锁，JVM将花费较少的时间来调度线程，性能更好。并且具有更好的扩展性（拥有更多的子类）


静态方法是依附于类而不是对象的，当synchronized修饰静态方法时，锁是class对象

## 线程池

```
corePoolSize：核心线程数，也是线程池中常驻的线程数，线程池初始化时默认是没有线程的，当任务来临时才开始创建线程去执行任务

maximumPoolSize：最大线程数，在核心线程数的基础上可能会额外增加一些非核心线程，需要注意的是只有当workQueue队列填满时才会创建多于corePoolSize的线程(线程池总线程数不超过maxPoolSize)

keepAliveTime：非核心线程的空闲时间超过keepAliveTime就会被自动终止回收掉，注意当corePoolSize=maxPoolSize时，keepAliveTime参数也就不起作用了(因为不存在非核心线程)；

unit：keepAliveTime的时间单位

workQueue：用于保存任务的队列，可以为无界、有界、同步移交三种队列类型之一，当池子里的工作线程数大于corePoolSize时，这时新进来的任务会被放到队列中

threadFactory：创建线程的工厂类，默认使用Executors.defaultThreadFactory()，也可以使用guava库的ThreadFactoryBuilder来创建

handler：线程池无法继续接收任务(队列已满且线程数达到maximunPoolSize)时的饱和策略，取值有AbortPolicy、CallerRunsPolicy、DiscardOldestPolicy、DiscardPolicy 
```



线程池核心线程在，任务队列满之前不会创建新的线程，当任务队列满了之后有新任务进来之后创建新的线程，当线程数量达到最大线程数任务队列是满的情况下执行拒绝策略。





##### workQueue队列

SynchronousQueue(同步移交队列)：队列不作为任务的缓冲方式，可以简单理解为队列长度为零。 不是一个真正的队列，是一个生产任务的线程，也可以说是一种管理直接在线程间移交信息的机制。
LinkedBlockingQueue(无界队列)：队列长度不受限制，当请求越来越多时(任务处理速度跟不上任务提交速度造成请求堆积)可能导致内存占用过多或OOM LinkedBlockingQueue会默认一个类似无限大小的容量(Integer.MAX_VALUE)，这样的话，如果生产者的速度一旦大于消费者的速度，也许还没有等到队列满阻塞产生，系统内存就有可能已被消耗殆尽了。相对于ArrayBlockingQueue，LinkedBlockingQueue生产者和消费者分别使用两把重入锁来实现同步，所以可以提高系统的并发度。
ArrayBlockintQueue(有界队列)：队列长度受限，当队列满了就需要创建多余的线程来执行任务默认情况下为非公平的，即不保证等待时间最长的队列最优先能够访问队列。查看源码就可以知道ArrayBlockingQueue生产者方放入数据、消费者取出数据都是使用同一把[重入锁](https://so.csdn.net/so/search?q=重入锁&spm=1001.2101.3001.7020)，这就两者无法真正的实现生产者和消费者的并行。



 

#####  handler拒绝策略

AbortPolicy：中断抛出异常
DiscardPolicy：默默丢弃任务，不进行任何通知
DiscardOldestPolicy：丢弃掉在队列中存在时间最久的任务
CallerRunsPolicy：让提交任务的线程去执行任务(对比前三种比较友好一丢丢) 

```java
public ThreadPoolExecutor(int corePoolSize, int maximumPoolSize, long keepAliveTime, TimeUnit unit, BlockingQueue workQueue, ThreadFactory threadFactory, RejectedExecutionHandler handler) {
        if (corePoolSize 0 || maximumPoolSize <= 0 || maximumPoolSize keepAliveTime 0)
        throw new IllegalArgumentException();
        if (workQueue == null || threadFactory == null || handler == null) throw new NullPointerException();
        this.corePoolSize = corePoolSize;
        this.maximumPoolSize = maximumPoolSize;
        this.workQueue = workQueue;
        this.keepAliveTime = unit.toNanos(keepAliveTime);
        this.threadFactory = threadFactory;
        this.handler = handler;
    }
```

#### 线程lamda表达式：

```java
       多行语句
       new Thread(() ->{
           String res= testComan("ssss");

            System.out.println(res);
        } ).start();
        
        单行语句，直接调用方法即可
         new Thread(() -> testComan("ssss")).start();
        
        
```





**线程池五种状态**



##### CyclicBarrier

用于协调多个线程同步执行操作的场合，所有线程等待完成,然后一起做事情( 相互之间都准备好,然后一起做事情 )

CyclicBarrier

可以循环使用
工作线程之间必须等到同一个点才能执行
CountDownLacth

CountDownLacth 不能reset
工作线程之间彼此不关心

## 垃圾回收



1.垃圾回收的对象位于哪里？

主要是堆区，

## springMVC初始化流程（二）



## 分布式：

### 分布式定时任务处理方案：




配置加载顺序为：context-param -> listener -> filter -> servlet

HttpServletBean 调用init 初始化-》  initServletBean()-》initWebApplicationContext()->this.onRefresh()->initStrategies()


## 网关

网关是所有服务的代理出口，鉴权、流量、限流等

### 网关是什么



### 网关实现原理

### 网关具体实现



## 设计模式

### 适配器

1. 类的适配器模式


2. 对象适配器

## 并发

## 高级应用

- 时间轮算法 HashedWheelTimer

  适用场景
  订单超时
  分布式锁中为线程续期的看门狗
  心跳检测

  





## 逃逸分析

## Shiro  分析







## 打包

pom.xml 配置



```

<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.7.5</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>
    <groupId>com.rain.test</groupId>
    <artifactId>testpackage</artifactId>
    <version>0.0.1</version>
    <name>testpackage</name>
    <description>testpackage</description>
    <properties>
        <java.version>1.8</java.version>
        <!-- 配置时间戳格式-->
        <maven.build.timestamp.format>yyyyMMddHHmmss</maven.build.timestamp.format>
    </properties>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <!-- 指定间戳，为后面zip文件名用-->
            <plugin>
                <groupId>org.codehaus.mojo</groupId>
                <artifactId>build-helper-maven-plugin</artifactId>
                <version>3.3.0</version>
                <executions>
                    <execution>
                        <id>timestamp-property</id>
                        <goals>
                            <goal>timestamp-property</goal>
                        </goals>
                    </execution>
                </executions>
                <configuration>
                    <name>build.time</name>
                    <pattern>yyyyMMddHHmmss</pattern>
                    <timeZone>GMT+8</timeZone>
                    <locale>zh_CN</locale>
                    <fileSet/>
                    <regex/>
                    <source/>
                    <value/>
                </configuration>
            </plugin>
            <!-- 指定打包插件 -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-assembly-plugin</artifactId>
                <version>3.4.2</version>
                <configuration>
                    <!-- 打出来的zip是否包含 package.xml 中定义的id -->
                    <appendAssemblyId>false</appendAssemblyId>
                    <descriptors>
                        <descriptor>src/main/resources/deployment/package.xml</descriptor>
                    </descriptors>
                    <finalName>${artifactId}-${version}-${build.time}</finalName>
                </configuration>
                <executions>
                    <execution>
                        <id>make-assembly</id>
                        <phase>package</phase> <!--this is used for inheritance merges  绑定到这个生命周期-->
                        <goals>
                            <goal>single</goal> <!--执行一次-->
                        </goals>
                    </execution>
                </executions>
            </plugin>

        </plugins>
    </build>

</project>

```

package.xml

```
<assembly xmlns="http://maven.apache.org/plugins/maven-assembly-plugin/assembly/1.1.2"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/plugins/maven-assembly-plugin/assembly/1.1.2 http://maven.apache.org/xsd/assembly-1.1.2.xsd">
    <id>packagezip</id>
    <formats>
        <format>zip</format>
    </formats>
    <!--if auto generate a root folder-->
    <includeBaseDirectory>false</includeBaseDirectory>
    <fileSets>
        <!-- 指定打包resource 下的shell 脚本-->
        <fileSet>
            <outputDirectory>/script</outputDirectory>
            <directory>src/main/resources/script</directory>
            <includes>
                <include>**/**.sh</include>  <!--把shell脚本打进去-->
            </includes>
            <fileMode>755</fileMode>
        </fileSet>
        <!-- 指定打包resource  application.properties文件作为外置配置文件-->
        <fileSet>
            <outputDirectory>/</outputDirectory>
            <directory>src/main/resources/</directory>
            <includes>
                <include>application.properties</include>  <!--把shell脚本打进去-->
            </includes>
            <fileMode>644</fileMode>
        </fileSet>
    </fileSets>

    <!--copy the jar into the zip-->
    <files>
        <file>
            <source>${project.build.directory}${file.separator}${artifactId}-${version}.jar</source>
            <outputDirectory>/</outputDirectory>
            <fileMode>755</fileMode>
        </file>
    </files>
    <!--package the jar and figure out if contain artifact, if true there will be many dependency jars-->
    <!--<dependencySets>
        <dependencySet>
            <outputDirectory>/</outputDirectory>
            <useProjectArtifact>false</useProjectArtifact>
        </dependencySet>
    </dependencySets>-->
</assembly>
```

 maven-assembly-plugin 参数详细介绍：

https://www.cnblogs.com/powerwu/articles/16686555.html

# 问题排查 

## 1. tomcat 打开文件太多问题排查
 查看 系统文件限制
ulimit -a 

针对所有用户的设置，在/etc/security/limits.conf文件，其是可以对系统用户、组进行cpu、文件数等限制的，通过它可以针对某个用户或全部进行限制。但不能超越系统的限制；
格式：
#<domain>   <type> <item> <value>
*           soft   noproc        102400


用来查看当前pid 打开多少文件的问题
lsof -p  pid 


lsof -p 1305 | wc -l 

ulimit -n 4096
/proc/sys/fs/file-max

 - 针对所有用户的设置，在/etc/security/limits.conf文件，其是可以对系统用户、组进行cpu、文件数等限制的，通过它可以针对某个用户或全部进行限制。但不能超越系统的限制；

        （*表示所有用户、soft表示可以超出，但只是警告；hard表示绝对不能超出，unlimited用于表示不限制）
     
    - 如果想对所有用户设置，也可以放在/etc/profile文件里面，下面是该文件里面的默认参数：   
    ulimit -S -c 0 > /dev/null 2>&1

    #cat /proc/sys/fs/file-max

    查看系统允许打开的最大文件数

#cat /proc/sys/fs/file-max

查看每个用户允许打开的最大文件数
ulimit -a
发现系统默认的是open files (-n) 1024，问题就出现在这里。
另外方法：
1.使用ps -ef |grep java (java代表你程序，查看你程序进程) 查看你的进程ID，记录ID号，假设进程ID为1305
2.使用：lsof -p 1305 | wc -l 查看当前进程id为1305的 文件操作状况
执行该命令出现文件使用情况为 1192
3.使用命令：ulimit -a 查看每个用户允许打开的最大文件数
发现系统默认的是open files (-n) 1024，问题就出现在这里。
4.然后执行：ulimit -n 4096
将open files (-n) 1024 设置成open files (-n) 4096

## Java OOM优化



 top -H -p pid 



1. Java.lang.OutOfMemoryError: **GC overhead limit exceeded**

   这种问题一般都是 

该*java.lang.OutOfMemoryError：GC开销超过极限*误差信号，你的应用程序花费太多的时间做垃圾收集太少的结果JVM的方式。默认情况下，如果 JVM 花费超过**98% 的总时间进行 GC 并且在 GC 之后仅回收不到 2% 的堆，则**JVM 被配置为抛出此错误。

 

加载了过多的资源，jvm清理不及时导致



2.java.lang.OutOfMemoryError:java heap space   ====JVM Heap(堆)溢出

如果不是代码问题可以手动设置堆大小

OutOfMemoryError： PermGen space

如果使用默认值需要可以根据实际情况，调整永久代大小

老年代溢出 一般都是 创建大对象未及时释放

解决方法：手动设置MaxPermSize大小

OutOfMemoryError： unable to create new native thread

可能原因

1. 系统内存耗尽，无法为新线程分配内存
2. 创建线程数超过了操作系统的限制





3.java.long.StackOverflowError  =======栈溢出

栈溢出了，JVM依然是采用栈时的虚拟机，这个和C和Pascal都是一样的。函数的调用过程都体现在堆栈和退栈上了。

　　　　调用构造函数的 "层" 太多了，以至于把栈区溢出了。

　　　　通常来讲，一般栈区远远小于堆区的，因为函数调用过程往往不会多余上千层，而即使每个函数调用需要1K的空间

　　　　（这个大约相当于C函数内声明了256个int类型的变量，那么栈区也不过需要1MB的空间。通常栈的大小 1-2MB的。

　　　　通常递归也不要递归层次过多，很容易溢出。

　　　　解决方法：修改程序。



java -XX:+PrintFlagsFinal -version | grep ThreadStackSize



查看是否有系统有因为内存溢出杀掉进程

egrep -i -r 'Out Of' /var/log

​	



