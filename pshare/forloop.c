/*- Includes ----------------------------------------------------------------*/
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>
#include <stdarg.h>
#include "soc.h"

//-----------------------------------------------------------------------------
void halt(void)
{
  *(volatile uint32_t *)0x80000000 = 1; // Simulation only
}

void main(void) {
  volatile int a;
  volatile int i;

  for(i=0;i<10;i++) {
    a=i+5;
  }
  
  halt(); 
  
}