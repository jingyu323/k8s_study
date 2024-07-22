# keras

 

## 一 基础介绍：

### 1.核心层

#### 1.1 全连接层：

神经网络中最常用到的，实现对神经网络里的神经元激活。

```
Dense（units, activation=’relu’, use_bias=True）

参数说明：
units: 全连接层输出的维度，即下一层神经元的个数。
activation：激活函数，默认使用Relu。
use_bias：是否使用bias偏置项。
```

#### 1.2  激活层： 

对上一层的输出应用激活函数。

```
Activation(activation)

参数说明：
Activation：想要使用的激活函数，如：’relu’、’tanh’、‘sigmoid’等。
```

#### 1.3  Dropout层：

对上一层的神经元随机选取一定比例的失活，不更新，但是权重仍然保留，防止过拟合

```
Dropout(rate)

参数说明:
rate：失活的比例，0-1的浮点数。
```

#### 1.4   Flatten层：

 将一个维度大于或等于3的高维矩阵，“压扁”为一个二维矩阵。即保留第一个维度（如：batch的个数），然后将剩下维度的值相乘作为“压扁”矩阵的第二个维度。

Flatten()

#### 1.5  Reshape层：

该层的作用和reshape一样，就是将输入的维度重构成特定的shape。

```
Reshape(target_shape)

参数说明：
target_shape：目标矩阵的维度，不包含batch样本数。
如我们想要一个9个元素的输入向量重构成一个(None, 3, 3)的二维矩阵：
Reshape((3,3), input_length=(16, ))
```

#### 1.6   卷积层：

卷积操作分为一维、二维、三维，分别为Conv1D、Conv2D、Conv3D。一维卷积主要应用于以时间序列数据或文本数据，二维卷积通常应用于图像数据。由于这三种的使用和参数都基本相同，所以主要以处理图像数据的Conv2D进行说明。



```
# CNN在Keras上的API
tf.keras.layers.Conv2D(
    filters, # 卷积核的个数
    kernel_size, # 卷积核的大小，常用的是（3，3）
    strides=(1, 1), # 核移动步幅
    padding='valid', # 是否需要边界填充
    data_format=None,
    dilation_rate=(1, 1), 
    activation=None, # 激活函数
    use_bias=True,
    kernel_initializer='glorot_uniform',
    bias_initializer='zeros',
    kernel_regularizer=None, 
    bias_regularizer=None, 
    activity_regularizer=None,
    kernel_constraint=None, 
    bias_constraint=None, 
    **kwargs
)


参数说明：
filters：卷积核的个数。
kernel_size：卷积核的大小。
strdes：步长，二维中默认为(1, 1)，一维默认为1。
Padding：补“0”策略，’valid‘指卷积后的大小与原来的大小可以不同，’same‘则卷积后大小与原来大小一致。
```

#### 1.7 池化层：

与卷积层一样，最大统计量池化和平均统计量池化也有三种，分别为MaxPooling1D、MaxPooling2D、MaxPooling3D和AveragePooling1D、AveragePooling2D、AveragePooling3D，由于使用和参数基本相同，所以主要以MaxPooling2D进行说明。

```
MaxPooling(pool_size=(2,2), strides=None, padding=’valid’)

参数说明：

pool_size：长度为2的整数tuple，表示在横向和纵向的下采样样子，一维则为纵向的下采样因子。

padding：和卷积层的padding一样
```



最大池化层MaxPooling
最大池化层通常使用2*2的窗口，步幅为2进行特征下采样
作用有二：
1、减少需要处理的特征图的元素个数
2、增加卷积层的观察窗口（即窗口覆盖原始输入的比例越来越大）
一个张量输入(28, 28, 32)，经过(2, 2)的MaxPooling处理，输出张量(14, 14, 32)，其过程直观的可以理解为取相邻(2, 2)矩阵里面的最大值。当然也有其他的处理方法，比如取平均值。 



#### 1.8 循环层：

循环神经网络中的RNN、LSTM和GRU都继承本层，所以该父类的参数同样使用于对应的子类SimpleRNN、LSTM和GRU。

```
Recurrent(return_sequences=False)

return_sequences：控制返回的类型，“False”返回输出序列的最后一个输出，“True”则返回整个序列。当我们要搭建多层神经网络（如深层LSTM）时，若不是最后一层，则需要将该参数设为True。
```

#### 1.9 嵌入层：

该层只能用在模型的第一层，是将所有索引标号的稀疏矩阵映射到致密的低维矩阵。如我们对文本数据进行处理时，我们对每个词编号后，我们希望将词编号变成词向量就可以使用嵌入层。

```
Embedding(input_dim, output_dim, input_length)

参数说明：

Input_dim：大于或等于0的整数，字典的长度即输入数据的个数。

output_dim：输出的维度，如词向量的维度。

input_length：当输入序列的长度为固定时为该长度，然后要在该层后加上Flatten层，然后再加上Dense层，则必须指定该参数，否则Dense层无法自动推断输出的维度
```

该层可能有点费解，举个例子，当我们有一个文本，该文本有100句话，我们已经通过一系列操作，使得文本变成一个(100,32)矩阵，每行代表一句话，每个元素代表一个词，我们希望将该词变为64维的词向量：

Embedding(100, 64, input_length=32)

则输出的矩阵的shape变为(100, 32, 64)：即每个词已经变成一个64维的词向量



## 二 模型搭建 

假设我们有一个两层神经网络，其中输入层为784个神经元，隐藏层为32个神经元，输出层为10个神经元，隐藏层使用relu激活函数，输出层使用softmax激活函数。分别使用序列模型和通用模型实现如下：

### 1  序列模型（Sequential类）

```
    model = Sequential()
    model.add(Dense(units=10, activation='relu', input_dim=784))
    model.add(Dense(units=10, activation='softmax'))
```



### 2 通用模型（Model类）

```
    x_input = keras.layers.Input(shape=(784,))
    dense_1 = Dense(units=32, activation='relu')(x_input)
    output = Dense(units=10, activation='softmax')(dense_1)
    model = keras.models.Model(inputs=x_input, outputs=output)
```





## 三   训练

 

模型编译

```
compile(optimizer, loss, metrics=None)

参数说明：

optimizer：优化器，如：’SGD‘，’Adam‘等。

loss：定义模型的损失函数，如：’mse’，’mae‘等。

metric：模型的评价指标，如：’accuracy‘等。
```



 训练

```
fit(x=None, y=None, batch_size=None, epochs=1, verbose=1, validation_split=0.0)

x：输入数据。

y：标签。

batch_size：梯度下降时每个batch包含的样本数。

epochs：整数，所有样本的训练次数。

verbose：日志显示，0为不显示，1为显示进度条记录，2为每个epochs输出一行记录。

validation_split：0-1的浮点数，切割输入数据的一定比例作为验证集。
```







## 四   优化 



欠拟合



过拟合





## 五 评估 预测







## 六   案例



## RNN和双向RNN



recurrent模块中的RNN模型包括RNN、LSTM、GRU等模型(后两个模型将在后面Keras系列文章讲解)：

1.RNN：全连接RNN模型

SimpleRNN(units,activation=’tanh’,dropout=0.0,recurrent_dropout=0.0, return_sequences=False)

2.LSTM：长短记忆模型

LSTM(units,activation=’tanh’,dropout=0.0,recurrent_dropout=0.0,return_sequences=False)

3.GRU：门限循环单元

GRU(units,activation=’tanh’,dropout=0.0,recurrent_dropout=0.0,return_sequences=False)

4.参数说明：

units: RNN输出的维度

activation: 激活函数，默认为tanh

dropout: 0~1之间的浮点数，控制输入线性变换的神经元失活的比例

recurrent_dropout：0~1之间的浮点数，控制循环状态的线性变换的神经元失活比例

return_sequences: True返回整个序列,用于stack两个层，False返回输出序列的最后一个输出，若模型为深层模型时设为True

input_dim: 当使用该层为模型首层时，应指定该值

input_length: 当输入序列的长度固定时，该参数为输入序列的长度。当需要在该层后连接Flatten层，然后又要连接Dense层时，需要指定该参数

 

## 七 一些网站

opencv 中文

https://woshicver.com/

