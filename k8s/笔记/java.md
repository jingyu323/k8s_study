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
