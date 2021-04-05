; Win + V:      Escribe contenido portapapeles
; Win + C:      Cambia modo CRLF
; Control + E:  Sale del script
; ESC o PAUSA:  Detiene escritura automatica


AutoType := false
ReplaceCRLF := false

SetKeyDelay 0, 0

^e::ExitApp

SetCancelHotkeys(state){
    Hotkey, Pause, stop, % state
    Hotkey, Esc, stop, % state
}

StopAutotype()
{
    global AutoType
    AutoType := false
    SetCancelHotkeys("Off")
}

#c::
SwitchCRLF()
{
    global ReplaceCRLF
    ReplaceCRLF := !ReplaceCRLF
    if (ReplaceCRLF) {
        MsgBox, Modo CRLF ON
    } else {
        MsgBox, Modo CRLF OFF
    }
}

#v::
AutoTypeClipboard()
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


    i := 1 ; Indices empiezan en 1
    while (AutoType AND i <= StrLen(clip)) {
        char := % SubStr(clip, i, 1)
        DllCall("Sleep", "UInt", 1) ; Sleep rapido
        SendRaw, % char
        i++
    }
    StopAutotype()
}

stop:
StopAutotype()