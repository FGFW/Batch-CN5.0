
这里的版本比官方的多了一个gt.bat
gt sed 
等于：
bcn get-tool sed

::  bcn 5.0  by bailong360 @www.bathome.net
:: 首发兼更新地址:http://www.bathome.net/thread-32322-1-1.html
::
:: 用法(不区分大小写):
::  bcn get-tool sed          下载第三方sed
::  bcn get-tool sed 4.0.7    下载4.0.7版的sed
::  bcn del-tool sed          删除第三方sed
::  bcn find-tool sed         在列表中搜索包含关键词sed的第三方
::  bcn find-tool sed name:10 设置输出列表中name行的宽度为10字节
::
:: get-tool可以用get,gt代替
:: del-tool可以用del,gt代替
:: find-tool可以用find,ft代替
:: find-tool宽度默认值name:14 ver:12 info:38
:: rar格式的第三方将会调用unrar.exe进行解压,如果不存在将会自动下载