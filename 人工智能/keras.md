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
Padding：补“0”策略，’valid‘指卷积后的大小与原来的大小可以不同，’same‘则卷积后大小与原来大小一致

generator产生的训练数据不够用，少于所要求的steps_per_epoch * epochs 个batch数。
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

##### RNN

区别于传统的网络结构，增加了一个状态（state），每次处理的时候输入为本次输入+当前状态



SimpleRNN上一层的输出直接作为下一层的状态输入，状态输入+本层输入得到本层输出

```
# demo，表示需要返回每个时间步连续输出的完整序列
from keras.models import Sequential
from keras.layers import Embedding, SimpleRNN

model = Sequential()
model.add(Embedding(10000, 32))
model.add(SimpleRNN(32, return_sequences=True))
model.add(SimpleRNN(32, return_sequences=True))
model.add(SimpleRNN(32))  # This last layer only returns the last outputs.
model.summary()

```



梯度消失： 近距离的权重





**BRNN**

BRNN模型需要使用wrappers包的Bidirecitional模块实现双向RNN模型，并且要将return_sequences参数设置为True，因为如上文所述需要将前、后向的重要信息拼接起来，所以需要将整个序列返回，而不是只返回最后一个预测词。



##### LSTM

随着层数的增加容易出现**梯度消失**，增加网络层数将变得无法训练，继而就有了长短期记忆（LSTM，long short-term memory)
LSTM增加了一种携带信息跨越多个时间步的方法 —— Ct



LSTM单元的作用 —— 允许过去的信息稍后重新进入，从而解决梯度消失问题



```
model = Sequential()
model.add(Embedding(max_features, 32))
model.add(LSTM(32))
model.add(Dense(1, activation='sigmoid'))

model.compile(optimizer='rmsprop',
              loss='binary_crossentropy',
              metrics=['acc'])
history = model.fit(input_train, y_train,
                    epochs=10,
                    batch_size=128,
                    validation_split=0.2) 
```



##### GRU

门控循环单元（GRU，gated recurrent unit）层的工作原理与 LSTM相同，但它做了一些简化，运行的计算代价更低，效果可能不如LSTM

```
model.add(layers.GRU(32, input_shape=(None, float_data.shape[-1])))
```



##### 高级用法：

- #### 循环dropout 

  使用循环dropout(recurrent dropout) 将某一层的输入单元随机设为0，其目的是打破该层训练数据中的偶然相关性，降低网络的过拟合。
  为了对GRU、LSTM等循环层得到的表示做正则化，应该将不随时间变化的dropout掩码应用于层的内部循环激活。
  使用相同的dropout掩码，可以让网络沿着时间正确地传播其学习误差，而随时间随机变化的dropout掩码则会破坏这个误差信号，并且不利于学习过程。

  **recurrent_dropout=0.2**  

```
model = Sequential()
model.add(layers.GRU(32,
                     dropout=0.2,
                     recurrent_dropout=0.2,
                     input_shape=(None, float_data.shape[-1])))
model.add(layers.Dense(1))

model.compile(optimizer=RMSprop(), loss='mae')
model.summary() 
```

- #### 堆叠循环层

  堆叠循环层(stacking recurrent layers) 可以提高网路表达能力。
  增加网络容量的通常做法是 —— 增加每层单元数或增加层数。
  在过拟合不是很严重的时候，可以放心地增大每层的大小、层数，但这么做的计算成本很高。

```
model = Sequential()
model.add(layers.GRU(32,
                     dropout=0.1,
                     recurrent_dropout=0.5,
                     return_sequences=True,
                     input_shape=(None, float_data.shape[-1])))
# 堆叠➕一层
model.add(layers.GRU(64, activation='relu',
                     dropout=0.1, 
                     recurrent_dropout=0.5))
model.add(layers.Dense(1))

model.compile(optimizer=RMSprop(), loss='mae')
model.summary() 
```

- #### 双向循环层

  双向循环层 (directional recurrent layer) 是一种常见的RNN变体，在某些任务上的性能比普通RNN更好，常用**于自然语言处理，可谓深度学习对自然语言处理的瑞士军刀。**
  双向循环层包含两个普通RNN，每个RNN分别沿一个方向对输入序列进行处理（时间正序和时间逆序），然后将它们的表示合并在一起，通过沿这两个方向处理序列，双向RNN能够捕捉到可能被单向RNN忽略的模式 

​	

```
from keras.models import Sequential
from keras import layers
from keras.optimizers import RMSprop

model = Sequential()
model.add(layers.Bidirectional(
    layers.GRU(32), input_shape=(None, float_data.shape[-1])))
model.add(layers.Dense(1))

model.compile(optimizer=RMSprop(), loss='mae')
history = model.fit_generator(train_gen,
                              steps_per_epoch=500,
                              epochs=40,
                              validation_data=val_gen,
                              validation_steps=val_steps)

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







### 3. 手动搭建VGG-16模型

**VGG-16结构说明：**

- 13个卷积层（Convolutional Layer），分别用`blockX_convX`表示;

- 3个全连接层（Fully connected Layer），用`classifier`表示;

- 5个池化层（Pool layer）

  **`VGG-16`包含了16个隐藏层（13个卷积层和3个全连接层），故称为`VGG-16`**

## 

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



#### 基准调优，数据增强

```
将 train_datagen = ImageDataGenerator(rescale=1./255)
修改为 
train_augmented_datagen = ImageDataGenerator(
    rescale=1./255,
    rotation_range=40, # 随机旋转的角度范围
    width_shift_range=0.2, # 在水平方向上平移的范围
    height_shift_range=0.2, # 在垂直方向上平移的范围
    shear_range=0.2, # 随机错切变换的角度
    zoom_range=0.2, # 随机缩放的范围
    horizontal_flip=True,)# 随机将一半图像水平翻转

# Note that the validation data should not be augmented!
train_augmented_generator = train_augmented_datagen.flow_from_directory(
        train_dir,
        target_size=(150, 150),
        batch_size=32,
        class_mode='binary')
```





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



### 7.1 初级

- [Google's Machine Learning Crash Course](https://developers.google.com/machine-learning/crash-course)提供了一个快速入门机器学习的课程，包括视频讲座和实践练习。
- [Scikit-learn Documentation](https://scikit-learn.org/stable/user_guide.html)是Python中最流行的机器学习库之一，其文档提供了很多实用的教程和示例。







## 八  算法

### 8.1学习方式

#### 8.1.1监督式学习

逻辑回归算法核心数学公式是使用 sigmoid 函数将线性组合映射到 (0,1) 区间内，从而得到一个概率值。最终通过设定阈值进行类别预测。其预测公式为 ，损失函数为交叉熵损失函数 。

反向传递神经网络是目前用来训练人工神经网络的最常用且最有效的算法。其主要思想是将训练集数据输入到神经网络的输入层，经过隐藏层，最后达到输出层并输出结果，这是神经网络的前向传播过程；由于神经网络的输出结果与实际结果有误差，则计算估计值与实际值之间的误差，并将该误差从输出层向隐藏层反向传播，直至传播到输入层；在反向传播的过程中，根据误差调整各种参数的值；不断迭代上述过程，直至收敛

#### 8.1.2 非监督式学习

常见的非监督式学习算法有 Apriori 算法和 k-Means 算法。

Apriori 算法主要用于关联规则的挖掘。它通过分析数据集中的频繁项集，找出数据之间的关联关系。

k-Means 算法是一种无监督学习算法中的聚类算法。它从任意选择的数据点开始，作为数据组的提议方法，并迭代地重新计算新的均值，以便收敛到数据点的最终聚类。k-Means 算法非常适合探索性分析，非常适合了解数据并提供几乎所有数据类型的见解。无论是图像、图形还是文本，k-Means 都非常灵活，几乎可以满足所有需求。

k-Means 算法的工作原理如下：首先随机创建 K 个质心，K-means 将数据集中的每个数据点分配到最近的质心（最小化它们之间的欧几里德距离），然后通过获取分配给该质心集群的所有数据点的平均值来重新计算质心，从而减少与前一步骤相关的集群内总方差。该算法在步骤 2 和 3 之间迭代，直到满足一些标准（例如最小化数据点与其对应质心的距离之和，达到最大迭代次数，质心值不变或数据点没有变化集群）。

#### 8.1.3半监督式学习

半监督式学习方式下，输入数据部分被标识，部分没有被标识。这种学习模型可以用来进行预测，但是模型首先需要学习数据的内在结构以便合理的组织数据来进行预测。

半监督式学习的特点是结合了监督学习和非监督学习的优点。它可以利用少量的有标记数据和大量的无标记数据进行学习，提高模型的泛化能力。

常见的半监督式学习算法有**图论推理算法和拉普拉斯支持向量**机等。

图论推理算法通过构建图模型来表示数据之间的关系，然后利用图的结构信息进行学习和预测。

####  8.1.4强化学习

强化学习是让智能体在与环境交互中学习，通过奖励机制来优化决策。

常见的应用场景包括动态系统以及机器人控制等。

强化学习的常见算法有 Q-Learning 和时间差学习。

时间差学习也是一种强化学习算法，它通过**比较当前状态和下一个状态的价值估**计来更新价值函数，以实现最优决策。

#### 8.1.5其他算法分类

1. 回归算法：回归算法是试图采用对误差的衡量来探索变量之间的关系的一类算法。常见的回归算法包括：最小二乘法（Ordinary Least Square），逻辑回归（Logistic Regression），逐步式回归（Stepwise Regression），多元自适应回归样条（Multivariate Adaptive Regression Splines）以及本地散点平滑估计（Locally Estimated Scatterplot Smoothing）。

   

2. 基于实例的算法：基于实例的算法常常用来对决策问题建立模型，这样的模型常常先选取一批样本数据，然后根据某些近似性把新数据与样本数据进行比较。通过这种方式来寻找最佳的匹配。常见的算法包括 k-Nearest Neighbor (KNN), 学习矢量量化（Learning Vector Quantization， LVQ），以及自组织映射算法（Self-Organizing Map ， SOM）。 

3. 正则化方法：正则化方法是其他算法（通常是回归算法）的延伸，根据算法的复杂度对算法进行调整。正则化方法通常对简单模型予以奖励而对复杂算法予以惩罚。常见的算法包括：Ridge Regression，Least Absolute Shrinkage and Selection Operator（LASSO），以及弹性网络（Elastic Net）。

4. 决策树学习：决策树算法根据数据的属性采用树状结构建立决策模型， 决策树模型常常用来解决分类和回归问题。常见的算法包括：分类及回归树（Classification And Regression Tree， CART）， ID3 (Iterative Dichotomiser 3)， C4.5， Chi-squared Automatic Interaction Detection (CHAID), Decision Stump, 随机森林（Random Forest）， 多元自适应回归样条（MARS）以及梯度推进机（Gradient Boosting Machine， GBM）

5. 贝叶斯方法：贝叶斯方法算法是基于贝叶斯定理的一类算法，主要用来解决分类和回归问题。常见算法包括：朴素贝叶斯算法，平均单依赖估计（Averaged One-Dependence Estimators， AODE），以及 Bayesian Belief Network（BBN）

6. 基于核的算法：基于核的算法中最著名的莫过于支持向量机（SVM）了。基于核的算法把输入数据映射到一个高阶的向量空间， 在这些高阶向量空间里， 有些分类或者回归问题能够更容易的解决。常见的基于核的算法包括：支持向量机（Support Vector Machine， SVM）， 径向基函数（Radial Basis Function ，RBF)， 以及线性判别分析（Linear Discriminate Analysis ，LDA) 

7. 聚类算法：聚类是一种广泛用于查找具有相似特征的观察组的技术。常见的聚类算法包括 k-Means 聚类、层次聚类等

## 九  神经网络

GAN 



## 十 **Transformer** 

而 Transformers 库等工具则为快速构建高效的[自然语言处理模型](https://so.csdn.net/so/search?q=自然语言处理模型&spm=1001.2101.3001.7020)提供了便利



多头注意力机制：







