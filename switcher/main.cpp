#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include <string>
#include <iostream>
using namespace std;

extern char far *get_ptr_1(char far* x,int b);
#pragma aux get_ptr_1 = \
    "mov ax,1401h"       \
    "int 0f0h"            \
    parm   [cx dx] [bx] \
    value     [ds si]    \
    modify    [ax];


extern int HasDMMI();
#pragma aux HasDMMI = "mov ax,0000h" "int 0f0h"  value     [ax]   modify    [ax];



int main(int,char**)
{
	exit(0);
	printf("Switcher DMMI Client, (C) Chourdakis Michael.\r\n");
	int i = HasDMMI();
	if (i != 0xFACE)
	{
		printf("Switcher requires a DMMI Server.\r\n");
		exit(1);
	}

	char cmd[100] = { 0 };
	for (;;)
	{
		cout << "* ";
		cin >> cmd;
		string c = cmd;
		if (c == "exit" || c == "quit")
		{
			break;
		}

		if (c == "help")
		{
			cout << "Commands available: help, exit, quit" << endl;
			continue;
		}

		if (c == "load")
		{

		}
	}

	printf("Switcher End.\r\n");
	return 0;
}
