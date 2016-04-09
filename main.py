from ctypes import *
import time

gpl = CDLL("libgpiot.so")
gpl.init()
gpl.set_pin_as_output(21)
gpl.change_pin_state(21,1)
time.sleep(1)
gpl.change_pin_state(21,0)
gpl.clean_up()

