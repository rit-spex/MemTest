#include <SPI.h>
#include <SpiEEPROM.h>

SpiEEPROM::SpiEEPROM(byte clock, byte cs){
    SPI.begin();
    digitalWrite(cs, HIGH);


    SPI.setClockDivider(SPI_CLOCK_DIV2);    // Sets clock speed to 8Mhz off of the Uno's 16Mhz

    _cs = cs;                               // cs pin is set
}

char SpiEEPROM::read(int addr){
    char data;

    digitalWrite(_cs, LOW);         // pull cs low to access the chip
    SPI.transfer(READ);
    SPI.transfer((char)(addr >> 8));
    SPI.transfer((char)addr);

    data = SPI.transfer(0xFF);

    digitalWrite(_cs, HIGH);        // pull cs high to disable before exiting
    return data;

}

char SpiEEPROM::write(int addr, char data){
    digitalWrite(_cs, LOW);         // pull cs low to access the chip
    SPI.transfer(WREN);
    digitalWrite(_cs, HIGH);        // need to bring high to set wren latch

    digitalWrite(_cs, LOW);
    SPI.transfer(WRITE);
    SPI.transfer((char)(addr >> 8));
    SPI.transfer((char)addr);
    SPI.transfer(data);

    digitalWrite(_cs, HIGH);        // set high to disable the device
    return data;
}
