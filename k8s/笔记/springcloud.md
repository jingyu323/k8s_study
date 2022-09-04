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

## 7.常见问题

## 8.参考资料