#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#NoEnv ; No comprueba variables de entorno
#KeyHistory 0 ; Desactiva historial de teclas
SetBatchLines, -1 ; Elimina delay entre directivas (lineas del script)

running := false

SetCancelHotkeys(state)
{
    Hotkey, Pause, stop, % state
    Hotkey, Esc, stop, % state
}

PressEnter()
{
    KeyWait LWin
    KeyWait RWin
    KeyWait Enter

    SetCancelHotkeys("On")
    global running
    running := true

    while (running) {
        Sleep 1000
        Send {Enter}
    }
    StopAutotype()
}

; Senaliza parada al bucle de escritura
StopAutotype()
{
    global running
    running := false
    SetCancelHotkeys("Off")
}

#enter::PressEnter()

stop:
StopAutotype()