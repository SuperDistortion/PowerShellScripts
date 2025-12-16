#CB122680
robocopy "\\10.33.80.16\Data" "E:\RMXMatl\ConAgg" /mov /R:1 /W:5 /MT:32 /log:"c:\scripts\RMXMatlUsage\carmxmaterialusagelog.txt"

#CBS97216
robocopy "\\10.33.80.15\Data" "E:\RMXMatl\ConAgg" /mov /R:1 /W:5 /MT:32 /log+:"c:\scripts\RMXMatlUsage\carmxmaterialusagelog.txt"

#CBS90206
robocopy "\\10.57.24.15\Data" "E:\RMXMatl\ConAgg" /mov /R:1 /W:5 /MT:32 /log+:"c:\scripts\RMXMatlUsage\carmxmaterialusagelog.txt"

#CBHS62578 St Joseph
robocopy "\\10.57.8.15\Data" "E:\RMXMatl\CST" /mov /R:1 /W:5 /MT:32 /log+:"c:\scripts\RMXMatlUsage\cscstcompaniesrmxmaterialusagelog.txt"