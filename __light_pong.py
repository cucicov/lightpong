#!/usr/bin/python

import smbus
import time
import OSC

class multiplex:
    
    def __init__(self, bus):
        self.bus = smbus.SMBus(bus)

    def channel(self, address=0x70,channel=0):  # values 0-7 indictae the channel, anything else (eg -1) turns off all channels
        
        if   (channel==0): action = 0x01
        elif (channel==1): action = 0x02
        elif (channel==2): action = 0x03
        elif (channel==3): action = 0x04
        elif (channel==4): action = 0x05
        elif (channel==5): action = 0x06
        elif (channel==6): action = 0x07
        elif (channel==7): action = 0x08
        else : action = 0x00

        #self.bus.write_byte_data(address,0x04,action)  #0x04 is the register for switching channels 
        self.bus.write_byte(address,2**channel)

    def read_luminance(self):
        # TSL2561 address, 0x39(57)
        # Select control register, 0x00(00) with command register, 0x80(128)
        #		0x03(03)	Power ON mode
        self.bus.write_byte_data(0x39, 0x00 | 0x80, 0x03)
        # TSL2561 address, 0x39(57)
        # Select timing register, 0x01(01) with command register, 0x80(128)
        #		0x02(02)	Nominal integration time = 402ms
        self.bus.write_byte_data(0x39, 0x01 | 0x80, 0x02)
        
        # Read data back from 0x0C(12) with command register, 0x80(128), 2 bytes
        # ch0 LSB, ch0 MSB
        data = self.bus.read_i2c_block_data(0x39, 0x0C | 0x80, 2)

        # Read data back from 0x0E(14) with command register, 0x80(128), 2 bytes
        # ch1 LSB, ch1 MSB
        data1 = self.bus.read_i2c_block_data(0x39, 0x0E | 0x80, 2)

        # Convert the data
        ch0 = data[1] * 256 + data[0]       # full spectrum
        ch1 = data1[1] * 256 + data1[0]     # infrared
        return (ch0)      # visible light value
    
if __name__ == '__main__':
    
    bus=1       # 0 for rev1 boards etc.    
    plexer = multiplex(bus)
    #server = OSC.OSCServer(('127.0.0.1', 4957))
    c = OSC.OSCClient()
    #c.connect(('127.0.0.1', 4957))   # connect to P5
    c.connect(('127.0.0.1', 4957))   # connect to P5

    print("connected to port 9779")

    while True:

        time.sleep(0.2)

        address=0x70
        oscmsg = OSC.OSCMessage()
        oscmsg.setAddress("/playerOne")

        #print("player 1 ");
        for ch in range(8):
        #ch = 0;
            try:
                plexer.channel(address, ch)
                luminance = plexer.read_luminance()
            except:
                luminance = -1
            #print(ch, luminance)
            oscmsg.append(str(luminance))
        print (oscmsg)
        c.send(oscmsg)

        address=0x71
        oscmsg = OSC.OSCMessage()
        oscmsg.setAddress("/playerTwo")
        #oscmsg.clear
        #print("player 2 ");
        for ch in range(8):
            try:
                plexer.channel(address, ch)
                luminance = plexer.read_luminance()
            except:
                luminance = -1
            #print(ch, luminance)
            oscmsg.append(str(luminance))
        
        print (oscmsg)
        c.send(oscmsg)



#   time.sleep(0.5)
#   max = MAX44009()

    

