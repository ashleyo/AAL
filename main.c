#include "unistd.h"
extern void init(void);
extern void set_pin_as_output(int pin);
extern void change_pin_state(int pin, int f);
extern void clean_up(void);

int main(void)
{
	init();
	set_pin_as_output(21);
	change_pin_state(21,1);
	sleep(1);
	change_pin_state(21,0);
	clean_up();
	return 0;
}
