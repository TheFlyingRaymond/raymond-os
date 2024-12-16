// # include "print.h"


typedef signed char int8_t;
typedef signed short int int16_t;
typedef signed int int32_t;
typedef signed long long int int64_t;

typedef unsigned char uint8_t;
typedef unsigned short int uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long long int uint64_t;

void put_char(uint8_t char_asci);

/**
 *  字符串打印，必须以\0结尾.
 */ 
void put_str(char* message);

/**
 * 以16进制的形式打印数字.
 */ 
void put_int(uint32_t num);



int __main(void) {
    put_char('k');
    put_char('e');
    put_char('r');
    put_char('n');
    put_char('e');
    put_char('l');
    put_char('\n');
    put_char('1');
    put_char('2');
    put_char('\b');
    put_char('3');
    put_char('\n');
    put_str("I am kernel!\n");

    put_int(7);
    put_char('\n');
    put_int(0x7c00);

    while (1);
    return 0;
}