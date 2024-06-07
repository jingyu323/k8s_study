# C++相关

## 1.基础

## 面向对象

### 1.继承

 



## 5.安装

opencv 环境安装编译：



```
编译
minGW32-make -j 4
安装
minGW32-make install 

执行完成之后会生成一个install 目录 

fatal error: opencv2/gapi.hpp: No such file or directory   
->  /samples/cpp/CMakelists.txt文件添加 opencv_gapi
error: '::D3D10CalcSubresource' has not been declared      
->	去掉WITH_DIRECTX,WITH_OPENCL_D3D11_NV选项-代表了windows下directx的使用以及d3d功能，编译会出错，应该是需要windows相关支持

安装参考
https://blog.csdn.net/qq_42817360/article/details/132331835
```







## 6.使用

## 7.常见问题

## 8.参考资料

 

# C相关

malloc 手动分配内存空间  free 手动释放空间



C 中没有字符串，使用字符数组来表示



