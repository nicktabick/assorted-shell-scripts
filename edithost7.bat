REM EditHost7
REM Enables hostfile editing on recent versions of Windows
REM Author: Nick Tabick, nicktabick@gmail.com

cd %systemroot%\system32\drivers\etc
attrib -s -h -r hosts
notepad %systemroot%\system32\drivers\etc\hosts