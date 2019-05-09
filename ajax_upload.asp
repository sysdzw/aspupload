<!--#include file="clsUpload.asp"-->
<%
dim upload,file,formName,SavePath,filename
dim strMsg

SavePath = "uploadfiles/"   '存放上传文件的目录，注意最后要加/

set upload=new upload_file    '建立上传对象

if upload.fileCount>3 then'限制单次上传的文件个数，如果不限制就把这段if注释掉
	response.write "上传文件不能超过2个！"
	response.end
end if

for each formName in upload.file '列出所有上传了的文件
	set file=upload.file(formName)  '生成一个文件对象
	if file.ErrCode>0 then
		strMsg=strMsg & "上传失败！原因：" & file.ErrMsg & vbcrlf
	else
		randomize
		sTime=now
		filename=SavePath & year(sTime)&right("0" & month(sTime),2)&right("0" & day(sTime),2)&right("0" & hour(sTime),2)&right("0" & minute(sTime),2)&right("0" & second(sTime),2) & cstr(int(900*rnd)+100) & "."&file.FileExt
		file.SaveToFile Server.mappath(filename) '保存文件到服务器
		strMsg=strMsg & filename & vbcrlf
	end if
next
if strMsg<>"" then strMsg=left(strMsg,len(strMsg)-2)
set file=nothing
set upload=nothing

response.write strMsg
%>
