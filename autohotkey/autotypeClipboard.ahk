; Win + V:         Escribe contenido portapapeles (Devuan, Fedora, *BSD)
; Win + Alt + V:   Pega lento (Solaris)
; Win + Shift + V: Pega ultrafast no delay (because we can)
; Win + C:         Cambia modo CRLF
; Control + E:     Sale del script
; ESC o PAUSA:     Detiene escritura automatica

; Substring titulo ventana en la que habilitar pegado. Vacio (:=) lo desactiva
TargetWindowTitleContains := "VirtualBox"
KeyDelay := 4 ; Retardo entre teclas modo normal
SlowKeyDelay := 20 ; Retardo entre teclas modo lento

; Performance tweaks
#NoEnv ; No comprueba variables de entorno
#KeyHistory 0 ; Desactiva historial de teclas
SetBatchLines, -1 ; Elimina delay entre directivas (lineas del script)

; Estado inicial
AutoType := false
ReplaceCRLF := true

; Retardo entre teclas pulsar/depulsar nulo (se ajusta con Sleep)
SetKeyDelay 0, 0

; Anade o elimina los bindings de las teclas de parada
; cambiando entre script (las consume) o utilizacion normal (bypass)
SetCancelHotkeys(state)
{
    Hotkey, Pause, stop, % state
    Hotkey, Esc, stop, % state
}

; Senaliza parada al bucle de escritura
StopAutotype()
{
    global AutoType
    AutoType := false
    SetCancelHotkeys("Off")
}

; Bucle escritura automatica
AutoTypeClipboard(delay)
{
    ; Comprueba si el titulo de la ventana contiene la substring
    global TargetWindowTitleContains
    if (TargetWindowTitleContains) {
        WinGetActiveTitle, currentWindowTitle
        if (!InStr(currentWindowTitle, TargetWindowTitleContains)) {
            MsgBox, Pegado desactivado si el titulo de la ventana no contiene "%TargetWindowTitleContains%"
            return
        }
    }

    global AutoType
    global ReplaceCRLF

    ; Bindea teclas parada
    SetCancelHotkeys("On")
    AutoType := true

    ; Obtiene ventana actual para parar si se pierde el focus
    WinGet, targetWindow, ID, A

    ; Modo CRLF
    if (ReplaceCRLF) {
        clip := % StrReplace(clipboard,"`r")
    } else {
        clip := % clipboard
    }

    i := 1 ; Indices empiezan en 1
    while (AutoType AND i <= StrLen(clip)) {
        ; Obtiene chars uno a uno
        char := % SubStr(clip, i, 1)

        ; Delay entre teclas
        if (delay)
            DllCall("kernel32.dll\Sleep", "UInt", delay) ; Sleep rapido

        ; Comprueba si sigue teniendo el focus de la ventana
        WinGet, currentWindow, ID, A
        if (currentWindow != targetWindow)
            break

        ; Teclea char
        SendRaw, % char
        i++
    }
    StopAutotype()
}

AutoType(delay)
{
    ; Espera a que se suelte la tecla win para empezar
    ; Evita escribir "comandos" al tener la tecla win pulsada
    KeyWait LWin
    KeyWait RWin
    KeyWait Shift
    KeyWait Alt
    KeyWait v

    AutoTypeClipboard(delay)
}

; Activa o desactiva modo CRLF
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

; Guarda el id de la ventana con focus actual
MarkWindow()
{
    global WindowMark

    WinGet, WindowMark, ID, A
    WinGetTitle, wintitle, ahk_id %WindowMark%
    MsgBox, Ventana marcada para pegado: %wintitle%
}

; Escritura con autofocus a ventana marcada
AutoTypeWindow(delay)
{
    global WindowMark

    KeyWait LWin
    KeyWait RWin
    KeyWait Alt
    KeyWait z

    WinActivate ahk_id %WindowMark%
    WinWaitActive ahk_id %WindowMark%

    AutoTypeClipboard(delay)
}

; Keybindings
#c::SwitchCRLF()
#v::AutoType(KeyDelay)
#!v::AutoType(SlowKeyDelay)
#+v::AutoType(0)
#z::AutoTypeWindow(KeyDelay)
#!z::MarkWindow()
^e::ExitApp

; Label binding dinamico teclas parada
stop:
StopAutotype()