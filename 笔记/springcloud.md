# SpringCloud相关

## 1.介绍

## 2.作用

## 3.优点


## 4.实现原理

### 4.1 Spring Boot 原理和启动流程

SpringBoot是一个快速开发框架，目的是解放java程序猿的生产力，提高开发效率。主要特点：
1、整合依赖：通过Maven，快速的将一些常用的第三方依赖整合。
2、简化配置：简化XML配置，全部采用注解形式。
3、集成web容器：内置Http服务器（Jetty和Tomcat），最终以java应用程序进行执行。
简化Spring应用的创建、运行、调试、部署的工作，使用它可以做到专注于Spring应用的开发，而无需过多关注XML的配置

SpringBoot核心通过Maven继承依赖关系快速整合第三方框架

### 4.2. 注解 SpringBootApplication启动

@SpringBootApplication注解只是一个组合注解，包含@Configuration配置类，@ComponentScan包扫描类，@EnableAutoConfiguration。根据需求自动加载相关的bean这三个注解。



## 5.安装

## 6.使用

### 1.静态工具类的属性注入方式

方式一：

使用 @Value() 注解
通过set方法来赋值。属性是static修饰的，get方法也是static修饰的，但是set方法不能是static修饰，使用@Value()注解来修饰set方法。类头需要添加@Configuration 或者@Component 标记为spring管理否则读取不到值

方式二：

只要把set方法设置为非静态，那么这个配置类的静态属性就能成功注入了

```java
@Configuration
@ConfigurationProperties(prefix = "system")
public class SystemApiConfig {

    /**账号*/
    private static String account;

    /**密码*/
    private static String password;

    /**平台三方系统分配的id*/
    private static String appid;

    public static String getAccount() {
        return account;
    }

    public void setAccount(String account) {
        SystemApiConfig.account = account;
    }

    public static String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        SystemApiConfig.password = password;
    }

 
}
```

### 2.Springboot 配置文件加载顺序

**Springboot的application.properties配置文件的加载路径优先级（从高到低）：**

- 工程根目录:./config/
- 工程根目录：./
- classpath:/config/
- classpath:/

当Springboot打成JAR包（不包含配置文件），读取外部配置文件application.properties时，可以选择：

1. 把application.properties放在在项目名.jar的同级目录下。 



## 7.常见问题

## 1.RequestBody  RequestParam 

**@RequestBody注解后** ，只能解析json类型的数据，

## 8.Springcloud Alibaba

### 8.1 熔断与服务降级

Sentinel 

#### @SentinelResource

@SentinelResource是sentinel中非常重要的注解，提供了简单易用的功能。其中blockHandler注解是限流的处理方法，fallback是服务降级的处理方法。

```
@SentinelResource(value="edit", blockHandler="editBlock", fallback = "editFallback")
@RequestMapping("/edit")
public Object edit(@RequestParam(required = false) String id,
                   @RequestParam(required = false) Integer age) throws Exception {
    Thread.sleep(20);
    return this.studentService.commons();
}

// 限流的处理
public Object editBlock(String id, Integer age, BlockException ex) {
    Map<String, Object> map = new HashMap<>();
    map.put("msg", "限流了.");
    return map;
}

//服务降级的处理方法
public Object editFallback(String id, Integer age) {
    Map<String, Object> map = new HashMap<>();
    map.put("msg", "fallback 服务降级了.");
    return map;
}
```



### Feign与Sentinel的整合







### 8.2 负载均衡 

1. ​	feign是基于Ribbon的另外一个负载均衡的客户端框架，只需要在接口上定义要调用的服务名即可，使用起来非常的简单。

**pom.xml依赖**

```
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>
```

**启动类配置**

需要在启动类上加上@EnableFeignClients这个注解

```
@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
public class ConsumerApplication {
    public static void main(String[] args) {
        SpringApplication.run(ConsumerApplication.class, args);
    }
}
```

**服务接口配置**

```
@FeignClient(name="alibaba-provider")
public interface UserService {

    @RequestMapping("/user")
    public List<String> getUsers();
}
```







## 参考资料