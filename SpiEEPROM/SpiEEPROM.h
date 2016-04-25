#ifndef SpiEEPROM_h

#define WRSR    1
#define WRITE   2
#define READ    3
#define WRDI    4
#define RDSR    5
#define WREN    6

#include <Arduino.h>

class SpiEEPROM {
    public:
        SpiEEPROM(byte clock, byte cs);
        char read(int addr);
        char write(int addr, char data);
    private:
        byte _cs;
};
#endif
