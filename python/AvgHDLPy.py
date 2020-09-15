import serial
import io
import time
from PIL import Image
import numpy as np

ser =serial.Serial()
print(ser.name)
ser.baudrate = 9600
ser.port = 'COM4'
ser.open()


img = Image.open("lena_gray.bmp", mode='r')
print(img.mode)
img=img.convert(mode='L')
print(img.mode)
image=np.array(img)
image=image.flatten()

for i in range(len(image)):
    #print(i , image[i])
    ser.write(bytes([image[i]]))

arr = []

for i in range(625):
    
    cur_byte=ser.read(1)
    #print (cur_byte)
    arr.append(int.from_bytes(cur_byte , "big"))

arr = np.array(arr)
arr = np.resize(arr, (25 , 25))
im = Image.fromarray(arr)
im.show()
