/*

    MRE for CMSIS6/QEMU/GCCARM

*/

#include "qm7.h"

//-------------------------------------------------------------------
uint16_t read_u16(uint32_t address)
{
    uint16_t ret = 0;
    ret = *(volatile uint16_t*)address;
    return ret;
}

//-------------------------------------------------------------------
// read uint32_t from some address
uint32_t read_u32(uint32_t address)
{
    uint32_t ret = 0;
    ret = *(volatile uint32_t*)address;
    return ret;
}

//-------------------------------------------------------------------
// write uint32_t to some address
void write_u32(uint32_t address, uint32_t value)
{
    *(volatile uint32_t*)address = value;
}


//-------------------------------------------------------------------
// called from startup
void _start()
{
    //
    uint32_t address = 0x2000000;
    //
    uint16_t v16 = read_u16(address);
    uint32_t v32 = read_u32(address);
}
