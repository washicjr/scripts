Net use v: \\192.168.1.2\vita /PERSISTENT:NO /user:nativ nativ 
robocopy E:\music\alac\ v:\alac\ *.* /s /e /purge /w:1 /r:1 /XO /XN /XD meta /XD lyrics /XD pdf /XF albumartsmall.jpg
robocopy E:\music\m4a\ v:\m4a\ *.* /s /e /purge /w:1 /r:1 /XO /XN /XD meta /XD lyrics /XD pdf /XF albumartsmall.jpg
robocopy E:\music\mp3\ v:\mp3\ *.* /s /e /purge /w:1 /r:1 /XO /XN /XD meta /XD lyrics /XD pdf /XF albumartsmall.jpg

