#NoEnv
; #SingleInstance Force
#NoTrayIcon
#KeyHistory 0
SetBatchLines -1
ListLines, Off
Process, Priority, , A
; SendMode Input ; Forces Send and SendRaw to use SendInput buffering for speed.
; SetTitleMatchMode, 3 ; A window's title must exactly match WinTitle to be a match.
; SetWorkingDir, %A_ScriptDir%
; SplitPath, A_ScriptName, , , , MyScriptName ; store the script file name (without extension) in MyScriptName
; DetectHiddenWindows,On
SetWinDelay, -1 ; Remove short delay done automatically after every windowing command except IfWinActive and IfWinExist
; SetKeyDelay, -1, -1 ; Remove short delay done automatically after every keystroke sent by Send or ControlSend
; SetMouseDelay,-1 ; Remove short delay done automatically after Click and MouseMove/Click/Drag
; #MaxThreadsPerHotkey,1 ; no re-entrant hotkey handling

; CoordMode, ToolTip, Screen

; ToolTip, %1%, %2%, %3%, 1
; ToolTip, %4%, %5%, %6%, 2
; ToolTip, %7%, %8%, %9%, 3
; ToolTip, %10%, %11%, %12%, 4
; ToolTip, %13%, %14%, %15%, 5
; ToolTip, %16%, %17%, %18%, 6
; ToolTip, %19%, %20%, %21%, 7
; ToolTip, %22%, %23%, %24%, 8
; ToolTip, %25%, %26%, %27%, 9
; ToolTip, %28%, %29%, %30%, 10
; ToolTip, %31%, %32%, %33%, 11
; ToolTip, %34%, %35%, %36%, 12
; ToolTip, %37%, %38%, %39%, 13
; ToolTip, %40%, %41%, %42%, 14
; ToolTip, %43%, %44%, %45%, 15
; ToolTip, %46%, %47%, %48%, 16
; ToolTip, %49%, %50%, %51%, 17
; ToolTip, %52%, %53%, %54%, 18
; ToolTip, %55%, %56%, %57%, 19
; ToolTip, %58%, %59%, %60%, 20

Sleep, 5000

