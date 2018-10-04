<%
'=========================================================================================================
'类  名 : 微标ASP上传类 v1.3（无刷新、无组件、多文件上传，并且可查杀木马,utf-8格式）
'作  者 : sysdzw
'联系QQ : 171977759
'网  站 : https://blog.csdn.net/sysdzw
'版  本 : v1.0 以化境ASP无组件上传作为初版v1.0，之后进行了多项修改。
'          v1.1 修正了批量上传时file.add语句的报错问题。原因是键值冲突，本版本对键值做了唯一化处理。		2018-06-04
'          v1.2 修改文件格式为utf-8格式，以提高兼容性												2018-08-13
'               修改代码中部分Charset="gb2312"为Charset="utf-8"，以提高兼容性
'               增加了图片木马检测功能。在上传的时候以gb2312格式读入字符串检测是否包含request等关键字
'          v1.3 改进了图片木马检测功能。加入了更多的关键字判断，让木马无处遁形						2018-10-04
'=========================================================================================================
%>
<%@ CODEPAGE=65001 %>
<% Response.CodePage=65001 %>
<% Response.Charset="UTF-8" %>
<%
dim oUpFileStream

Class upload_file
	dim Form,File,Version
	public AllowFiles,MaxDownFileSize

	Private Sub Class_Initialize 
		dim RequestBinDate,sStart,bCrLf,sInfo,iInfoStart,iInfoEnd,tStream,iStart,oFileInfo,testStream,savePosition,strContent
		dim iFileSize,sFilePath,sFileType,sFormvalue,sFileName
		dim iFindStart,iFindEnd
		dim iFormStart,iFormEnd,sFormName
		dim intItemCount
		dim vMumaKeyWord,intMKW,isHasMuma

		intItemCount=0
		AllowFiles="jpg,jpeg,gif,png" '所允许的文件格式
		MaxDownFileSize = 30000	'限制30M
		vMumaKeyWord = split("request|execute|wscript.shell|activexobject|include|function|.encode|.getfolder|.createfolder|.deletefolder|.createdirectory|.deletedirectory|.saveas|.createobject","|") '要检测的木马关键字
		set Form = Server.CreateObject("Scripting.Dictionary")
		set File = Server.CreateObject("Scripting.Dictionary")
		if Request.TotalBytes <= 0 then Exit Sub
		set tStream = Server.CreateObject("adodb.stream")
		set oUpFileStream = Server.CreateObject("adodb.stream")
		oUpFileStream.Type = 1
		oUpFileStream.Mode = 3
		oUpFileStream.Open
		oUpFileStream.Write Request.BinaryRead(Request.TotalBytes)
		oUpFileStream.Position=0
		RequestBinDate = oUpFileStream.Read 
		iFormEnd = oUpFileStream.Size
		bCrLf = chrB(13) & chrB(10)
		'取得每个项目之间的分隔符
		sStart = MidB(RequestBinDate,1, InStrB(1,RequestBinDate,bCrLf)-1)
		iStart = LenB (sStart)
		iFormStart = iStart+2
		'分解项目
		Do
			iInfoEnd = InStrB(iFormStart,RequestBinDate,bCrLf & bCrLf)+3
			tStream.Type = 1
			tStream.Mode = 3
			tStream.Open
			oUpFileStream.Position = iFormStart
			oUpFileStream.CopyTo tStream,iInfoEnd-iFormStart
			tStream.Position = 0
			tStream.Type = 2
			tStream.Charset ="utf-8"
			sInfo = tStream.ReadText
			'取得表单项目名称
			iFormStart = InStrB(iInfoEnd,RequestBinDate,sStart)-1
			iFindStart = InStr(22,sInfo,"name=""",1)+6
			iFindEnd = InStr(iFindStart,sInfo,"""",1)
			sFormName = Mid (sinfo,iFindStart,iFindEnd-iFindStart)
			'如果是文件
			if InStr (45,sInfo,"filename=""",1) > 0 then
				set oFileInfo= new FileInfo
				'取得文件属性
				iFindStart = InStr(iFindEnd,sInfo,"filename=""",1)+10
				iFindEnd = InStr(iFindStart,sInfo,"""",1)
				sFileName = Mid (sinfo,iFindStart,iFindEnd-iFindStart)
				oFileInfo.FileName = GetFileName(sFileName)
				oFileInfo.FilePath = GetFilePath(sFileName)
				oFileInfo.FileExt = GetFileExt(sFileName)
				iFindStart = InStr(iFindEnd,sInfo,"Content-Type: ",1)+14
				iFindEnd = InStr(iFindStart,sInfo,vbCr)
				oFileInfo.FileType = Mid (sinfo,iFindStart,iFindEnd-iFindStart)
				oFileInfo.FileStart = iInfoEnd
				oFileInfo.FileSize = iFormStart -iInfoEnd -2
				oFileInfo.FormName = sFormName
				oFileInfo.FileText=AllowFiles
				if oFileInfo.filesize>(MaxDownFileSize*1024) then
					oFileInfo.ErrCode=1
					oFileInfo.ErrMsg="大小限制，最大只能上传" & MaxDownFileSize & "M的文件，您上传的文件大小是" & FormatNumber( oFileInfo.filesize / 1024 , 2 ) & "M。"
				elseif instr(AllowFiles,lcase(oFileInfo.FileExt))=0 then '如果只是图片可用oFileInfo.FileType来判断是否包含image/
					oFileInfo.ErrCode=2
					oFileInfo.ErrMsg="类型限制，只允许上传“" & AllowFiles & "”这几种文件类型，您上传的文件类型是" & oFileInfo.FileExt & "。"
				else
					set testStream = Server.CreateObject("adodb.stream")
					testStream.Type = 1
					testStream.Mode = 3
					testStream.Open
					savePosition=oUpFileStream.Position '保存oUpFileStream的位置，下面要恢复
					oUpFileStream.Position = oFileInfo.FileStart
					oUpFileStream.CopyTo testStream,oFileInfo.FileSize
					testStream.Position = 0
					testStream.Type = 2
					testStream.Charset ="gb2312"
					strContent=lcase(testStream.ReadText)'以文本方式读取，然后判断是否包含图马相关的字符串，尽管乱码，但是基本字符串还是能检查出来的
					strContent=replace(strContent,chr(0),"")
					oFileInfo.FileText=strContent
					for intMKW=0 to ubound(vMumaKeyWord)
						if instr(strContent,vMumaKeyWord(intMKW))>0 then
							if instr(oFileInfo.FileType,"image/")>0 then
								oFileInfo.ErrCode=3
								oFileInfo.ErrMsg="要上传的图片“" & sFileName & "”含有木马。" & vMumaKeyWord(intMKW)
							else
								oFileInfo.ErrCode=4
								oFileInfo.ErrMsg="要上传的文件“" & sFileName & "”含有木马。" & vMumaKeyWord(intMKW)
							end if
							exit for
						end if
					next
					oUpFileStream.Position = savePosition '恢复oUpFileStream，本身的位置
					set testStream=nothing
				end if

				intItemCount=intItemCount+1'当一个file控件选择上传多个文件，添加到字典的sFormName会提示重复，所以后面加个索引区分 20180604
				file.add sFormName & "_" & intItemCount,oFileInfo
				set oFileInfo=nothing
			else
				'如果是表单项目
				tStream.Close
				tStream.Type = 1
				tStream.Mode = 3
				tStream.Open
				oUpFileStream.Position = iInfoEnd 
				oUpFileStream.CopyTo tStream,iFormStart-iInfoEnd-2
				tStream.Position = 0
				tStream.Type = 2
				tStream.Charset = "utf-8"
				sFormvalue = tStream.ReadText
				intItemCount=intItemCount+1
				form.Add sFormName & "_" & intItemCount,sFormvalue
			end if
			tStream.Close
			iFormStart = iFormStart+iStart+2
			'如果到文件尾了就退出
		loop until (iFormStart+2) = iFormEnd 
		RequestBinDate=""
		set tStream = nothing
	End Sub

	Private Sub Class_Terminate  
		'清除变量及对像
		if not Request.TotalBytes<1 then
		oUpFileStream.Close
		set oUpFileStream =nothing
		end if
		Form.RemoveAll
		File.RemoveAll
		set Form=nothing
		set File=nothing
	End Sub
	'取得文件路径
	Private function GetFilePath(FullPath)
		If FullPath <> "" Then
			GetFilePath = left(FullPath,InStrRev(FullPath, "\"))
		Else
			GetFilePath = ""
		End If
	End function
	'取得文件名
	Private function GetFileName(FullPath)
		If FullPath <> "" Then
			GetFileName = mid(FullPath,InStrRev(FullPath, "\")+1)
		Else
			GetFileName = ""
		End If
	End function
	'取得扩展名
	Private function GetFileExt(FullPath)
		If FullPath <> "" Then
			GetFileExt = mid(FullPath,InStrRev(FullPath, ".")+1)
		Else
			GetFileExt = ""
		End If
	End function
	'调试用，输出日志'
	Private sub WriteToFile(s)
		set fsoaa=createobject("scripting.filesystemobject")
		set ff=fsoaa.OpenTextFile(Server.MapPath("debug.txt"),8 ,true)
		ff.writeline now & " " & s
		ff.close
	End sub
End Class

'文件属性类
Class FileInfo
	dim FormName,FileName,FilePath,FileSize,FileType,FileStart,FileExt,FileText,ErrMsg,ErrCode
	Private Sub Class_Initialize
		FileName = ""
		FilePath = ""
		FileSize = 0
		FileStart= 0
		FormName = ""
		FileType = ""
		FileExt  = ""
		FileText = ""
		ErrCode  = 0
		ErrMsg   = ""
	End Sub
	'保存文件方法
	Public function SaveToFile(FullPath)
		SaveToFile=1
		if trim(fullpath)="" or right(fullpath,1)="/" then exit function
		set oFileStream=CreateObject("Adodb.Stream")
		oFileStream.Type=1
		oFileStream.Mode=3
		oFileStream.Open
		oUpFileStream.position=FileStart
		oUpFileStream.copyto oFileStream,FileSize
		oFileStream.SaveToFile FullPath,2
		oFileStream.Close
		set oFileStream=nothing 
		SaveToFile=0
	end function
End Class
%>