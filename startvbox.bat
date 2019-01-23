g:\virtualbox\VBoxManage.exe unregistervm asmtest
g:\virtualbox\VBoxManage.exe registervm "%1"
set VBOX_GUI_DBG_AUTO_SHOW=true
set VBOX_GUI_DBG_ENABLED=true
g:\virtualbox\VBoxManage.exe startvm asmtest -E VBOX_GUI_DBG_AUTO_SHOW=true -E VBOX_GUI_DBG_ENABLED=true
