微标ASP上传类 v1.4（无刷新、无组件、多文件上传，并且可查杀木马,utf-8格式）

请将本程序放到你的虚拟主机上运行，如果本地有iis也可以（注意定要把iis那儿的上传大小限制的200k改大点，参考下面第二点）。注意不要使用一些简易asp服务器，会有莫名其妙的错误。
如果只需要上传单文件可以把index.htm中的multiple="multiple"删除掉，对应的多文件前端显示及处理需要您对upload.asp进行修改调整，然后前端ajax获取数据进行处理。

关于“微标ASP上传类 v1.4”更新摘要：
'=========================================================================================================
'类  名 : 微标ASP上传类 v1.4（无刷新、无组件、多文件上传，并且可查杀木马,utf-8格式）
'作  者 : sysdzw
'联系QQ : 171977759
'网  站 : https://blog.csdn.net/sysdzw
'版  本 : v1.0 以化境ASP无组件上传作为初版v1.0，之后进行了多项修改。
'          v1.1 修正了批量上传时file.add语句的报错问题。原因是键值冲突，本版本对键值做了唯一化处理。		2018-06-04
'          v1.2 修改文件格式为utf-8格式，以提高兼容性												2018-08-13
'               修改代码中部分Charset="gb2312"为Charset="utf-8"，以提高兼容性
'               增加了图片木马检测功能。在上传的时候以gb2312格式读入字符串检测是否包含request等关键字
'          v1.3 改进了图片木马检测功能。加入了更多的关键字判断，让木马无处遁形						2018-10-04
'          v1.4 增加了属性FileCount，这样可对上传数量进行控制，用法请参考ajax_upload.微标ASP上传类	2019-05-09
'=========================================================================================================


相关参数设置：

1.ajax_upload.asp中的参数设置说明：
（1）SavePath 表示上传目录，默认为“uploadfiles”。
（2）FileCountLimited 表示限定用户上传文件的个数，默认为0表示不限制数量，如果限制用户一次只能上传3个文件就显示为3，如果不允许上传就设置为任意一个负数

2.clsUpload.asp中的参数设置说明：
（1）AllowFiles 所允许上传的文件格式，默认为"jpg,jpeg,gif,png"。
（2）MaxDownFileSize 允许上传的文件大小，默认30M，注意iis默认限制就200k，您需要在iis那儿做设置，网站 - asp - 限制属性 - 最大请求实体主体限制，加上两个0，改成20000000，这样就改成20M了。

3.index.htm中的参数说明
在第32和37行，分别是判断类型和大小的，可根据需要修改。这里是前端检测文件类型和大小的，可减轻服务器工作。后端要等文件post完成才能开始检测，假设误选择了个几百兆的exe、rar等文件网页直接卡死。早发现文件早提示。


查杀图片木马原理：一些图片会被不法分子插入些可执行的asp代码，在被include的时候悄悄执行，我们将图片以文本方式进行检查，判断是否包含某些关键字，如果包含就停止上传，总而提高了服务器的安全。
本来想打包个图片木马文件供大家测试，担心上传会不通过，而且下载了后本机的360等软件也会报毒，这样会吓坏一批小白，以为我代码有什么后门。。其实就那么几行代码，大家可以逐行看，没什么机关的。如果一定想试验下代码的效果可以百度下asp图片木马制作方法，然后自己做个图马上传测试看看。


本程序由sysdzw提供。如有需技术支持可联系QQ：171977759
15:52 2019-05-09

