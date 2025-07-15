# FFMPEG

## 1.基础

码率：叫比特率是一个确定整体视频的参数，码率和视频质量成正比

帧率：肉眼想看到连续移动的图像最少需要15帧/s



I帧：

B帧：前后参考帧

P帧：根据本帧与相邻的前一帧（I帧或者P帧）

## ffmpeg  超快视频编码器

ffmpeg -buildconf 

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

ffprobe 简单流媒体分析器
=======
ffprobe 简单流媒体播放器

如果音视频格式不统一则**强制**统一为 -vcodec libx264 -acodec aac

**以****MP4****格式进行拼接**

方法2：ffmpeg -f concat -i mp4list.txt -codec copy out_mp42.mp4

◼ **以****TS****格式进行拼接**

方法1：ffmpeg -i "concat:1.ts|2.ts|3.ts" -codec copy out_ts.mp4 

方法2：ffmpeg -f concat -i tslist.txt -codec copy out_ts2.mp4

◼ **以****FLV****格式进行拼接**

方法2：ffmpeg -f concat -i flvlist.txt -codec copy out_flv2.mp4

◼ **修改****音频编码**

ffmpeg -i 2.mp4 -vcodec copy -acodec ac3 -vbsf h264_mp4toannexb 2.ts

ffmpeg -i "concat:1.ts|2.ts|3.ts" -codec copy out1.mp4 结果第二段没有声音

◼ **修改****音频采样率**

ffmpeg -i 2.mp4 -vcodec copy -acodec aac -ar 96000 -vbsf h264_mp4toannexb 2.ts

ffmpeg -i "concat:1.ts|2.ts|3.ts" -codec copy out2.mp4 第二段播放异常

◼ 修改视频编码格式

ffmpeg -i 1.mp4 -acodec copy -vcodec libx265 1.ts

ffmpeg -i "concat:1.ts|2.ts|3.ts" -codec copy out3.mp4 

◼ 修改视频分辨率

ffmpeg -i 1.mp4 -acodec copy -vcodec libx264 -s 800x472 -vbsf h264_mp4toannexb 1.ts

ffmpeg -i "concat:1.ts|2.ts|3.ts" -codec copy out4.**mp4**

◼ **注意：**

◼ 把每个视频封装格式也统一为**ts**，拼接输出的时候再输出你需要的封装格

式，比如MP4

◼ **视频分辨率可以不同****，但是编码格式需要统一

◼ 音频编码格式需要统一，音频参数(采样率/声道等)也需要统

### 图片转视频

■ 转换视频为图片（每帧一张图):

ffmpeg –i test.mp4 –t 5 –s 640x360 –r 15 frame%03d.jpg 

■ 图片转换为视频

ffmpeg –f image2 –i frame%03d.jpg –r 25 video.mp4



## 录制视频

**录制声音（默认参数）**

**系统声音：**ffmpeg -f dshow -i audio="virtual-audio-capturer" a-out.aac

**系统****+****麦克风声音：**ffmpeg -f dshow -i audio="麦克风 (Realtek Audio)" -f dshow

-i audio="virtual-audio-capturer" -filter_complex

amix=inputs=2:duration=first:dropout_transition=2 a-out2.aac

◼ **同时录制声音和视频（默认参数）**

ffmpeg -f dshow -i audio="麦克风 (Realtek Audio)" -f dshow -i audio="virtual

audio-capturer" -filter_complex amix=inputs=2:duration=first:dropout_transition=2 -f 

dshow -i video="screen-capture-recorder" -y av-out.flv
