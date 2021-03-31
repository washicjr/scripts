robocopy c:\windows\fonts z:\bkp\c\windows\fonts /w:1 /r:1 /mir
robocopy c:\sysutil z:\bkp\c\sysutil /w:1 /r:1 /mir
robocopy d:\sysutil z:\bkp\d\sysutil /w:1 /r:1 /mir
robocopy c:\progra~1 z:\bkp\c\progra~1 /w:1 /r:1 /mir
robocopy c:\progra~2 z:\bkp\c\progra~2 /w:1 /r:1 /mir
robocopy c:\programdata z:\bkp\c\programdata /w:1 /r:1 /mir /xj /xd C:\ProgramData\Microsoft\Windows\WER\ReportArchive /xd C:\ProgramData\Microsoft\Crypto
robocopy P:\sysutil\bin z:\bkp\p\sysutil\bin /w:1 /r:1 /mir /XD $RECYCLE.BIN "System Volume Information"
robocopy e:\ z:\bkp\e /w:1 /r:1 /mir /XD $RECYCLE.BIN "System Volume Information"
robocopy c:\users\clarence z:\bkp\c\users\clarence /w:1 /r:1 /mir /xj
robocopy d:\users\clarence z:\bkp\d\users\clarence /w:1 /r:1 /mir /xj