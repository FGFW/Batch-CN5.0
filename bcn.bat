1>1/* :
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
::
@echo off
md "%~dp0$testAdmin$" 2>nul
if not exist "%~dp0$testAdmin$" (
    echo bcn不具备所在目录的写入权限! >&2
    exit /b 1
) else rd "%~dp0$testAdmin$"

setlocal enabledelayedexpansion

set /a name=14,ver=12,info=38
set cmdList=get-tool del-tool find-tool
set get-tool=get-tool gt get
set del-tool=del-tool dt del
set find-tool=find-tool ft find
set arg2=%~2
set arg3=%~3

for %%i in (%cmdList%) do (
    for %%j in (!%%i!) do (
        if "%%j"=="%~1" set cmd=%%i
    )
)
for %%i in (name ver info) do (
    for %%j in (%~3 %~4 %~5) do (
        for /f "tokens=1,2 delims=:" %%k in ("%%j") do set %%k=%%l
    )
)

if "%cmd%"=="" (
    echo 命令不存在! >&2
    exit /b 1
) else if "%cmd%"=="del-tool" (
    rd /s /q "%~dp0%~2" 2>nul
    del "%~dp0%~2.exe","%~dp0%~2.cmd","%~dp0%~2.bat","%~dp0%~2.rar" 2>nul
)

if "%cmd%"=="find-tool" (
    cscript -nologo -e:jscript "%~f0" find-tool "%~2" "%name%" "%ver%" "%info%"|more
) else cscript -nologo -e:jscript "%~f0" %cmd% "%~2" "%~3"
endlocal&exit /b %errorlevel%
*/

var WShell  = new ActiveXObject('WScript.Shell');
var FSO     = new ActiveXObject('Scripting.FileSystemObject');
var XMLHTTP = new ActiveXObject('Microsoft.XMLHTTP');
var ADO     = new ActiveXObject('ADODB.Stream');
var Argv    = WScript.Arguments;
var bcnPath = FSO.GetFile(WScript.ScriptFullName).ParentFolder.Path + '\\';
var host    = 'http://batch-cn.qiniudn.com';

if (!FSO.FileExists(bcnPath + 'tool.@version.txt') || CheckListDate()) {
    download('/list/tool.@version.txt');
}
    
switch (Argv.Item(0)) {
    case 'get-tool':get_tool(Argv.Item(1), Argv.Item(2));break;
    case 'find-tool':find_tool(Argv.Item(1), Argv.Item(2), Argv.Item(3), Argv.Item(4));break;
}
WScript.Quit(1);

function get_tool(fileName, option)
{
    var list     = FSO.OpenTextFile(bcnPath + 'tool.@version.txt', 1).ReadAll();
    var fullName = list.match(new RegExp('^' + fileName + '(\\.[a-z]+ | )@?[^ ]+', 'mgi'));
    if (!(fullName instanceof Array)) {
        WScript.StdErr.WriteLine('未找到匹配的第三方!');
        WScript.Quit(1);
    }
    
    if (option == '') { //有无指定版本
        if (fullName.length != 1) {
            fullName = fullName.join('\n').match(/@.+$/m) + '/' + fullName.join('\n').match(/.+@/);
        } else {
            fullName = fullName.join('\n').match(/.+@/)[0];
        }
    } else {
        var ver  = fullName.join('\n').match(new RegExp(option + '$', 'm'));
        if (!(ver instanceof Array)) {
            WScript.StdErr.WriteLine('未找到匹配的第三方!');
            WScript.Quit(1);
        }
        fullName =  ver + '/' + fullName.join('\n').match(/.+@/);
    }
    
    fullName = fullName.replace(/[@ ]/g, '');
    fullName = fullName.match(/^[^ ]+/);
    
    if (!/\.[^/]+$/.test(fullName)) {
        fullName += '.exe';
    }

    download('/tool/' + fullName);
    if (/\.rar$/.test(fullName)) {
        unrar(fullName[0]);
    }
}

function find_tool(keyword, namel, verl, infol)
{
    var file = FSO.OpenTextFile(bcnPath + 'tool.@version.txt', 1);
    var pat  = new RegExp(keyword, 'i');
    while (!file.AtEndOfStream) {
        var line = file.ReadLine().replace(/@/, '');
        if (pat.test(line)) {
            var name = line.match(/[^ ]+/)[0].replace(/\.[a-z]+/i, '');line = line.replace(/[^ ]+/, '');
            var ver  = line.match(/[^ ]+/)[0];line = line.replace(/[^ ]+/, '');
            var info = line.match(/[^ ]+/)[0];line = line.replace(/[^ ]+/, '');
            var size = line.match(/\d+/)[0];
            WScript.Echo(cutStr(name, namel) + cutStr(ver, verl) + cutStr(info, infol) + (size / 1024).toFixed(1) + 'KB');
        }
    }
    
}

function cutStr(str, max)
{
    var l = 0, i, j, space = ' ';
    var strl = str.length, strl2 = 0;
    
    for (i = 0; i < strl; i++) {
        var c = str.charCodeAt(i);
        strl2 += ((c >= 0x0001 && c <= 0x007e) || (0xff60 <= c && c <= 0xcff9f)) ? 1 : 2
    }
    
    max = strl2 > max ? max - 3 : max;
    for (i = 0; i < strl && l < max; i++) {
        var c = str.charCodeAt(i);
        l += ((c >= 0x0001 && c <= 0x007e) || (0xff60 <= c && c <= 0xcff9f)) ? 1 : 2
    }
    for (j = 0; j < max - l + 1; j++) {
        space += ' ';
    }
    return str.substr(0, i) + (strl2 > max ? '...' : '') + space;
}

function unrar(fileName) {
    if (!FSO.FileExists(bcnPath + 'unrar.exe')) {
        download('/tool/unrar.exe');
    }
    WShell.Run('"' + bcnPath + 'unrar" x -o+ -y "' + bcnPath + fileName.replace(/.*\//, '') + '" "' + bcnPath + '"', 0, true);
}

function download(URL)
{
    var SavePath = bcnPath + URL.match(/[^/]+$/);
    XMLHTTP.Open('GET', host + URL + '?' + Math.random(), 0);
    XMLHTTP.Send();
    ADO.Mode = 3;
    ADO.Type = 1;
    ADO.Open();
    ADO.Write(XMLHTTP.ResponseBody);
    ADO.SaveToFile(SavePath, 2);
    ADO.Close();
}

function CheckListDate() //根据time.txt显示的上次更新时间决定是否更新list
{
    XMLHTTP.Open('GET', host + '/list/time.txt?' + Math.random(), 0);
    XMLHTTP.Send();
    ADO.Mode = 3;
    ADO.Type = 1;
    ADO.Open();
    ADO.Write(XMLHTTP.ResponseBody);
    ADO.Position = 0;
    ADO.Type = 2;
    ADO.CharSet = 'GB2312';
    var str = ADO.ReadText().replace(/[^0-9]/g, '');
    ADO.Close();
    var UpdateTime = Date.parse(new Date(str.substr(0,4), str.substr(4,2), str.substr(6,2), str.substr(8,2), str.substr(12,2), str.substr(14,2)));
    if (UpdateTime > Date.parse(FSO.GetFile(bcnPath + 'tool.@version.txt').DateCreated)) {
        return false;
    } else {
        return true;
    }
}
