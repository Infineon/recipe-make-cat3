source [find interface/jlink.cfg]
transport select swd
set CHIPNAME &&CY_OPENOCD_CHIP&&
source [find target/&&CY_OPEN_OCD_FILE&&]
${_TARGETNAME} configure -rtos auto -rtos-wipe-on-reset-halt 1
