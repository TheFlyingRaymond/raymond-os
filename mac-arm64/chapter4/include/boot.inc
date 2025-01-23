;---------------------------loader和kernel-------------
LOADER_BASE_ADDR equ 0x900
LOADER_START_SECTOR equ 0x2
PAGE_DIR_TABLE_POS equ 0x100000

; 页表相关属性
PG_P equ 1b
PG_RW_R equ 00b
PG_RW_W equ 10b
PG_US_S equ 000b
PG_US_U equ 100b