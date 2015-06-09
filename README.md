# OpenEars2SaveWaveSample
OpenEars语音识别并获取音频

openears是CMU Pocketsphinx的ios移植，非常方便使用

我需要将检测的声音输出或者保存为音频，官方只有一个收费的插件

既然是开源的，看了一下源代码自己实现一个

只要写个category对源码修改一下 发送一下通知，接收到之后添加上wav头就可以播放了

这是使用的openears 2.x版本，1.x更好实现，当然1.x也不推荐使用了，
