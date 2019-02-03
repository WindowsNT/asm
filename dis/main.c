#include <stdio.h>

#include <dos.h>
#include "types.h"
#include "extern.h"

extern char far *get_ptr_1(char far* x,int b);
#pragma aux get_ptr_1 = \
    "mov ax,1401h"       \
    "int 0f0h"            \
    parm   [cx dx] [bx] \
    value     [ds si]    \
    modify    [ax];



char dsr[100];
char far * fpp = 0;
char sz = 0;
int im = 0;
int ty = 0;
int hook(struct ud_t *ud_obj)
{
        char a1 = UD_EOI;
      
        if (!fpp)       
                return UD_EOI;
        if (im >= sz)
                return UD_EOI;
		im++;
		a1 = fpp[im];
        return a1;
}

int main(int argc,char** argv)
{

        ud_t ud_obj;
		char rb = 0;


		if (!fpp)
		{
			fpp = get_ptr_1(0,0);
			if (!fpp)
				return UD_EOI;
			ty = fpp[0];
			ud_set_mode(&ud_obj, ty);
			sz = fpp[1];
			im = 1;
		}


        ud_init(&ud_obj);
        ud_set_input_hook(&ud_obj, hook);
        ud_set_syntax(&ud_obj, UD_SYN_INTEL);
		for (;;)
		{
			rb = ud_disassemble(&ud_obj);
			if (!rb)
				break;
			sprintf(dsr, "%s", ud_insn_asm(&ud_obj));
			get_ptr_1(dsr, rb);
			break;
		}

        //printf("kkk");
   // return 0;

//    ud_set_input_buffer(&ud_obj, "\x90\x90\x90\x90", 4);
   //ud_set_input_file(&ud_obj, stdin);
   // ud_set_mode(&ud_obj, 64);


    return 0;
}
