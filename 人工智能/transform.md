# Transformer

**Transformer：通常Attention会与传统的模型配合起来使用，但Google的一篇论文《Attention Is All You Need》中提出只需要注意力就可以完成传统模型所能完成的任务，从而摆脱传统模型对于长程依赖无能为力的问题并使得模型可以并行化，并基于此提出Transformer模型**



##### Transformer架构

主要由输入部分（输入输出嵌入与位置编码）、多层编码器、多层解码器以及输出部分（输出线性层与Softmax）四大部分组成。



# Attention工作原理

**Attention Mechanism是一种在****深度学习****模型中用于处理序列数据的技术，尤其在处理长序列时表现出色。最初引入注意力机制是为了解决**[**机器翻译**](https://cloud.tencent.com/product/tmt?from_column=20065&from=20065)**中遇到的长句子（超过50字）性能下降问题。**



##### 核心逻辑：从关注全部到关注重点

- Attention机制处理长文本时，**能从中抓住重点，不丢失重要信息。**
- Attention机制像人类看图片的逻辑，当我们看一张图片的时候，我们并没有看清图片的全部内容，而是将注意力集中在了图片的焦点上。
- 我们的视觉系统就是一种Attention机制，**将有限的注意力集中在重点信息上，从而节省资源，快速获得最有效的信息。**

##### 工作原理

**通过计算Decoder的隐藏状态与Encoder输出的每个词的隐藏状态的相似度（Score），进而得到每个词的Attention Weight，再将这些Weight与Encoder的隐藏状态加权求和，生成一个Context Vector。**

##### Encoder（编码器）

- **输入处理：**原始输入是语料分词后的 token_id 被分批次传入 Embedding 层，将离散的 token_id 转换为连续的词向量
- 特征提取：将得到的词向量作为输入，传入Encoder的特征提取器。特征提取器使用RNN系列的模型（RNN，LSTM，GRU），这里代称为RNNS，**为了更好地捕捉一个句子前后的语义特征，使用双向的RNNs。双向RNNs由前向RNN和后向RNN组成，分别处理输入序列的前半部分和后半部分。**

- **状态输出：**两个方向的RNNs（前向和后向）各自产生一部分隐藏状态。将这两个方向的隐藏层状态拼接（concatenate）成一个完整的隐藏状态 hs。**这个状态 hs 包含了输入序列中各个词的语义信息，是后续Attention机制所需的重要状态值。**

##### Decoder（解码器）

- **输入与隐藏状态传递：**在Decoder的 t-1 时刻，RNNs（如LSTM或GRU）输出一个隐藏状态 h(t-1)。
- **计算Score：**在 t 时刻，Decoder的隐藏状态 h(t-1) 与编码部分产生的每个时间步的隐藏状态 h(s) （来自双向RNNs的拼接状态）进行计算，以得到一个Score。
- **计算Attention Weight：**将所有计算得到的Score进行softmax归一化，得到每个输入词对应的Attention Weight。

- **计算Context Vector：**使用得到的Attention Weight与对应的 h(s) 进行加权求和（reduce_sum），得到Context Vector。这个Context Vector是输入序列中各个词根据当前Decoder隐藏状态重新加权得到的表示。这个Vector包含了输入序列中重要信息的加权表示，用于指导Decoder生成当前时刻的输出。
