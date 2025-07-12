# FFMPEG

## 1.基础

码率：叫比特率是一个确定整体视频的参数，码率和视频质量成正比

帧率：肉眼想看到连续移动的图像最少需要15帧/s



I帧：

B帧：前后参考帧

P帧：根据本帧与相邻的前一帧（I帧或者P帧）

## ffmpeg  超快视频编码器



**保持编码格式：**

ffmpeg -i test.mp4 -vcodec copy -acodec copy test_copy.ts

ffmpeg -i test.mp4 -codec copy test_copy2.ts

◼ **改变编码格式：**

ffmpeg -i test.mp4 -vcodec libx265 -acodec libmp3lame out_h265_mp3.mkv

◼ **修改帧率：**

ffmpeg -i test.mp4 -r 15 -codec copy output.mp4 (错误命令)

ffmpeg -i test.mp4 -r 15 output2.mp4

◼ **修改视频码率：**

ffmpeg -i test.mp4 -b 400k output_b.mkv （此时音频也被重新编码）

◼ **修改视频码率：**

ffmpeg -i test.mp4 -b:v 400k output_bv.mkv

ffplay 简单视频播放器

ffprobe 简单流媒体播放器

 

如果音视频格式不统一则**强制**统一为 -vcodec libx264 -acodec aac

**以****MP4****格式进行拼接**

方法2：ffmpeg -f concat -i mp4list.txt -codec copy out_mp42.mp4

◼ **以****TS****格式进行拼接**

方法1：ffmpeg -i "concat:1.ts|2.ts|3.ts" -codec copy out_ts.mp4 

方法2：ffmpeg -f concat -i tslist.txt -codec copy out_ts2.mp4

◼ **以****FLV****格式进行拼接**

方法2：ffmpeg -f concat -i flvlist.txt -codec copy out_flv2.mp4

