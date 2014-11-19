/*
o------------------------------------------------------------o
|                 AutoJoinDomain(加域精灵)                   |
(------------------------------------------------------------)
| By RobinTech                  / A Script file for AHK      |
|------------------------------------------------------------|
|                                                            |
| 自動加域程序可透過AHK腳本自動化操作，輕鬆將本地PC加入公司網域. |
| 網管只需輸入相關信息，即可在短短30s內實現包括自動加域、開啟adm |
| inistrator帳戶、開啟網卡802.1x認證等操作，極大地提高了工作效率|
|                                                            |
|------------------------------------------------------------|
| Function                                                   |
|------------------------------------------------------------|
| 1.自動加域                                                  |
| 2.開啟并設置本地administrator帳戶、密碼                      |
| 3.將域用戶加入本地administrator組                           |
| 4.開啟并設置網卡802.1x認證                                  |
|----------------------------------------------------------- |
| Readme                                                     |
|----------------------------------------------------------- |
| 1.適用系統：Win7                                            |
| 2.運行前請確保Win7 UAC已關閉                                |
| 3.確保已連線至公司網域                                      |                                  
| 4.程序運行過程中，請勿操作鍵鼠，并耐心等待                    |
| 5.用戶名輸入格式範例:Jack_cheng                             |                                  
| 6.已內置本地管理員密碼#*c1234,可編輯腳本line 66更改，再重新編譯|
|----------------------------------------------------------- |
| Release History                                            |
|----------------------------------------------------------- |
|11/14/2014: 1.0版，若網卡802.1x關閉情況下，可自動偵測開啟；改善程序執行效率；美化圖標|
|10/27/2014: Beta版，增加程式穩定性；改進NetBIOS主機名算法     |
|10/01/2014: Alpha版,基本function正常可用                     |
o------------------------------------------------------------o
*/

;*****************************************************
;                    窗體UI代碼
;*****************************************************
Gui, Font, S8 CDefault Bold Underline, Verdana
Gui, Font, S10 CDefault, 新細明體
Gui, Font, ,
Gui, Font, S10 Cdefault, 微软雅黑
Gui, Font, S12 Cdefault, 微软雅黑
Gui, Add, Text, x32 y20 w80 h20 , 域用户名
Gui, Add, Text, x32 y60 w80 h20 , 公司网域
Gui, Add, Text, x32 y100 w80 h20 , 管理员账户
Gui, Add, Text, x32 y140 w80 h20 , 管理员密码
Gui, Add, Edit, x122 y20 w160 h30 vUserName
Gui, Add, Edit, x122 y60 w160 h30 vDomain
Gui, Add, Edit, x122 y100 w160 h30 vAdministrator
Gui, Add, Edit, x122 y140 w160 h30 +Password vAdminpassword
Gui, Add, Button, x32 y180 w90 h30 , 确定
Gui, Add, Button, x192 y180 w90 h30 , 取消
; Generated using SmartGUI Creator 4.0
Gui, Show, x749 y428 h228 w317, AutoJoinDomain v1.0SC
Return

Button取消:
GuiClose:
ExitApp
Button确定:
Gui,Submit
;------------------------------------------------------
;            開啟并設定本地管理員帳號、密碼
Run, %ComSpec% /c net user administrator #*c1234 /active:yes
;------------------------------------------------------            
;                    主機名算法
;------------------------------------------------------
FullName = %UserName%
StringReplace, FullName1, FullName, _, , All
StringLen, FullName1Len, FullName1
if (FullName1Len >= 11)
{
   StringLeft, FullName1, FullName1, 11
}
Random, rand, 0, 9
PCName = %FullName1%-PC%rand%

;******************************************************
;                   自動加域代碼
;******************************************************
;1.系統內容-更改
#Persistent
DetectHiddenText, On
SetTitleMatchMode, 2
SetBatchLines, -1
run SYSDM.CPL
WinWait, 系统属性
ControlSend,,!c,系统属性
Sleep, 1000
WinWait, 计算机名/域更改
ControlSetText, Edit1, %PCName%, 计算机名/域更改
Control, Check, ,Button3, 计算机名/域更改
ControlSetText, Edit3, %Domain%, 计算机名/域更改
SendInput {Enter}
;2.输入管理员账户、密码
WinWait, Windows 安全
WinActivate, Windows 安全
Sleep, 1000
ControlSetText, Edit1, %Administrator%, Windows 安全
ControlSetText, Edit2, %Adminpassword%, Windows 安全
SendInput {Enter}
;3.第一次弹出确认框
WinWait, 计算机名/域更改, 欢迎加入
SendInput {Enter}
Sleep, 1000

;*****************************************************
;           將域用戶加入本地Administrators組
;*****************************************************
Run, lusrmgr.msc
WinWaitActive, lusrmgr - [本地用户和组(本地)]
SendInput,{Down}{Down}
Sleep, 800
SendInput,{Tab}{enter}
sleep 1000
WinWaitActive, Administrators 属性
ControlSend, , !d, Administrators 属性
Sleep, 1000
WinWait, Windows 安全
WinActivate, Windows 安全
Sleep, 1000
ControlSetText, Edit1, %Administrator%, Windows 安全
ControlSetText, Edit2, %Adminpassword%, Windows 安全
SendInput,{enter}
Sleep, 1000
SendInput,%UserName%
Sleep, 500
SendInput,{enter}
WinActivate, Administrators 属性
ControlSend, Button3, {enter}, Administrators 属性
Sleep, 500
ControlSend, Button3, {enter}, Administrators 属性
Sleep, 2000

;***************************************************
;               開啟并設置網卡802.1x認證
;***************************************************
Runwait, %ComSpec% /c sc config dot3svc start= auto && net start dot3svc
FileInstall, c:\Program Files\802.1x.xml, %A_ProgramFiles%\1.xml, 1
Run, %ComSpec% /c netsh lan add profile filename="%A_ProgramFiles%\1.xml" interface="本地连接"
Run, %ComSpec% /c netsh lan add profile filename="%A_ProgramFiles%\1.xml" interface="本地连接 2"
Sleep, 3500

;**************************************************
;4.继续加域操作（激活第二次弹出的确认框）
WinActivate, 计算机名/域更改
SendInput {Enter}
WinActivate, 系统属性
ControlSend, Button3, {Enter}, 系统属性
;WinWait, Microsoft Windows
;SendInput r
Sleep, 2000
MsgBox 程序已完成，请手动重启
return
