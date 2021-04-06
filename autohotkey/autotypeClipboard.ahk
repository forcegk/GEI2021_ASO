; Win + V:         Escribe contenido portapapeles (Devuan, Fedora, *BSD)
; Win + Alt + V:   Pega lento (Solaris)
; Win + Shift + V: Pega ultrafast no delay (because we can)
; Win + C:         Cambia modo CRLF
; Control + E:     Sale del script
; ESC o PAUSA:     Detiene escritura automatica

KeyDelay := 4
SlowKeyDelay := 20

#NoEnv
#KeyHistory 0
SetBatchLines, -1

AutoType := false
ReplaceCRLF := false

SetKeyDelay 0, 0

SetCancelHotkeys(state)
{
    Hotkey, Pause, stop, % state
    Hotkey, Esc, stop, % state
}

StopAutotype()
{
    global AutoType
    AutoType := false
    SetCancelHotkeys("Off")
}

AutoTypeClipboard(delay)
{
    global AutoType
    global ReplaceCRLF

    SetCancelHotkeys("On")
    AutoType := true

    if (ReplaceCRLF) {
        clip := % StrReplace(clipboard,"`r")
    } else {
        clip := % clipboard
    }

    ; Espera a que se suelte la tecla win para empezar
    ; Evita escribir "comandos" al tener la tecla win pulsada
    KeyWait LWin
    KeyWait RWin
    KeyWait Shift
    KeyWait Alt
    KeyWait v

    i := 1 ; Indices empiezan en 1
    while (AutoType AND i <= StrLen(clip)) {
        char := % SubStr(clip, i, 1)
        if (delay)
            DllCall("kernel32.dll\Sleep", "UInt", delay) ; Sleep rapido (kernel32.dll\Sleep)
        SendRaw, % char
        i++
    }
    StopAutotype()
}

SwitchCRLF()
{
    global ReplaceCRLF
    ReplaceCRLF := !ReplaceCRLF
    if (ReplaceCRLF) {
        MsgBox, Modo CRLF OFF
    } else {
        MsgBox, Modo CRLF ON
    }
}

#c::SwitchCRLF()
#v::AutoTypeClipboard(KeyDelay)
#!v::AutoTypeClipboard(SlowKeyDelay)
#+v::AutoTypeClipboard(0)
^e::ExitApp

stop:
StopAutotype()