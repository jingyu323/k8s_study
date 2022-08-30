# java

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

workQueue队列

SynchronousQueue(同步移交队列)：队列不作为任务的缓冲方式，可以简单理解为队列长度为零
LinkedBlockingQueue(无界队列)：队列长度不受限制，当请求越来越多时(任务处理速度跟不上任务提交速度造成请求堆积)可能导致内存占用过多或OOM
ArrayBlockintQueue(有界队列)：队列长度受限，当队列满了就需要创建多余的线程来执行任务

 handler拒绝策略

AbortPolicy：中断抛出异常
DiscardPolicy：默默丢弃任务，不进行任何通知
DiscardOldestPolicy：丢弃掉在队列中存在时间最久的任务
CallerRunsPolicy：让提交任务的线程去执行任务(对比前三种比较友好一丢丢) 
