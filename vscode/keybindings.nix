[
    {
        key = "alt+cmd+left";
        command = "workbench.action.navigateBack";
    }
    {
        key = "ctrl+-";
        command = "-workbench.action.navigateBack";
    }
    {
        key = "alt+cmd+left";
        command = "-workbench.action.terminal.focusPreviousPane";
        when = "terminalFocus && terminalHasBeenCreated || terminalFocus && terminalProcessSupported";
    }
    {
        key = "alt+cmd+left";
        command = "-workbench.action.previousEditor";
    }
    {
        key = "alt+cmd+right";
        command = "workbench.action.navigateForward";
    }
    {
        key = "ctrl+shift+-";
        command = "-workbench.action.navigateForward";
    }
    {
        key = "alt+cmd+right";
        command = "-workbench.action.terminal.focusNextPane";
        when = "terminalFocus && terminalHasBeenCreated || terminalFocus && terminalProcessSupported";
    }
    {
        key = "alt+cmd+right";
        command = "-workbench.action.nextEditor";
    }
]