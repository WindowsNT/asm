
#include <stdio.h>

#include <dos.h>
#include "types.h"
#include "extern.h"

void cb()
{
 char d[100];
 
    union REGS i, o;
    i.x.ax = 0; 
int86(0Xf0, &i, &o);

  
}

int main(int argc,char** argv)
{
    //printf("kkk");
   // return 0;
    ud_t ud_obj;

    ud_init(&ud_obj);
    ud_set_input_buffer(&ud_obj, "\x90\x90\x90\x90", 4);
   //ud_set_input_file(&ud_obj, stdin);
    ud_set_mode(&ud_obj, 64);
    ud_set_syntax(&ud_obj, UD_SYN_INTEL);

    while (ud_disassemble(&ud_obj)) {
        printf("\t%s\n", ud_insn_asm(&ud_obj));
    }

    return 0;
}
