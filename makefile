LIBNAME=gpiot
VERS=1
BUILD=1.0.0

all: test

object:	gpio.s
	gcc -c -fPIC -o gpio.o gpio.s
	gcc -shared -fPIC -Wl,-soname,lib$(LIBNAME).so.1 -o lib$(LIBNAME).so.$(BUILD) gpio.o -lc

install: object
	rm -f /usr/local/lib/lib$(LIBNAME)*
	cp lib$(LIBNAME).so.$(BUILD) /usr/local/lib/lib$(LIBNAME).so.$(BUILD)
	ln -s /usr/local/lib/lib$(LIBNAME).so.$(BUILD) /usr/local/lib/lib$(LIBNAME).so.$(VERS)
	ln -s /usr/local/lib/lib$(LIBNAME).so.$(BUILD) /usr/local/lib/lib$(LIBNAME).so
	ldconfig

test: install
	gcc -o test main.c -l$(LIBNAME)

clean:
	rm -f *.o
	rm -f lib$(LIBNAME).*
	
