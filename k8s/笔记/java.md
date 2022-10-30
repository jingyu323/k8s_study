



# java

jdk 安装





export JAVA_HOME=/usr/java/jdk1.8.0_231

export JRE_HOME=${JAVA_HOME}/jre

export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib

export PATH=${JAVA_HOME}/bin:$PATH



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
JVM检测到不可能存在共享数据竞争，这是JVM会对这些同步锁进行锁消除
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



##### workQueue队列

SynchronousQueue(同步移交队列)：队列不作为任务的缓冲方式，可以简单理解为队列长度为零
LinkedBlockingQueue(无界队列)：队列长度不受限制，当请求越来越多时(任务处理速度跟不上任务提交速度造成请求堆积)可能导致内存占用过多或OOM LinkedBlockingQueue会默认一个类似无限大小的容量(Integer.MAX_VALUE)，这样的话，如果生产者的速度一旦大于消费者的速度，也许还没有等到队列满阻塞产生，系统内存就有可能已被消耗殆尽了。
ArrayBlockintQueue(有界队列)：队列长度受限，当队列满了就需要创建多余的线程来执行任务



 

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

**线程池五种状态**



##### CyclicBarrier



## 垃圾回收



1.垃圾回收的对象位于哪里？

主要是堆区，


## springMVC初始化流程（二）


配置加载顺序为：context-param -> listener -> filter -> servlet


## 网关

网关是所有服务的代理出口，鉴权、流量、限流等

### 网关是什么



### 网关实现原理

### 网关具体实现
 


## 设计模式

### 适配器
