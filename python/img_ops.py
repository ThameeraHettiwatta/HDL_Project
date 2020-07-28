import cv2
import base64
import numpy as np


#convolution function
def convolve(img, kernel, img_width, kernel_width):
    output_img = []
    output_width = img_width - 2
    for i in range(output_width * output_width):
        pixel_val = 0
        
        for j, kernel_val in enumerate(kernel):
            kernel_x_index = j % kernel_width
            kernel_y_index = j // kernel_width
            img_x_index = i % output_width
            img_y_index = i // output_width
            input_val_index = ((img_y_index + kernel_y_index) * img_width) + (img_x_index +kernel_x_index) #update vhdl if this is correct
            pixel_val += img[input_val_index] * kernel_val
        
        output_img.append(pixel_val)

    #clip values
    for i in range(len(output_img)):
        output_img[i] = (max(0, min(255, output_img[i])))
    return output_img

#apply padding
def padding(img, img_width):
    output_img = []
    output_width = img_width + 2
    for i in range(output_width * output_width):
        img_x_index = i % output_width
        img_y_index = i // output_width #update vhdl?

        #edges
        if (i == 0):
           output_img.append(img[0])
        elif (i == (output_width * output_width) -1):
            output_img.append(img[-1])
        elif (i == output_width -1 ):
            output_img.append(img[img_width -1])
        elif (i == output_width * (output_width -1)):
            output_img.append(img[img_width * (img_width -1)])
        
        #borders
        elif (img_y_index == 0):
            output_img.append(img[i -1])
        elif (img_y_index == (output_width -1)):
            output_img.append(img[((img_y_index - 2) * img_width) + (img_x_index -1)])
        elif (img_x_index == 0):
            output_img.append(img[((img_y_index - 1) * img_width) + img_x_index])
        elif (img_x_index == (output_width -1)):
            output_img.append(img[((img_y_index - 1) * img_width) + img_x_index -2])
        
        #other values
        else:
            #print(((img_y_index - 1) * img_width) + (img_x_index -1))
            output_img.append(img[((img_y_index - 1) * img_width) + (img_x_index -1)])

    return output_img

def write_to_hex(img, filename):
    #img = np.array(img).astype(int)
    file = open(filename, 'w')
    index = 0
    for pixel in img:
        file.write(str(hex(pixel))[2:])
        # file.write(str(index))
        file.write(' ')
        # file.write(str(pixel))
        # file.write('\n')
        # index += 1
    file.close()

kernel = [-1, -1, -1, -1, 8, -1, -1, -1, -1]
kernel_width = 3

#load image
image = cv2.imread('lena_gray.bmp', cv2.IMREAD_GRAYSCALE)

#crop
cropped = cv2.resize(image, (5,5))
width, height = cropped.shape
print (width, height)

#serialize image
serial = cropped.reshape(width * height)
write_to_hex(serial, "hex_input.txt")


#add padding
padded = padding(serial, width)
padded_img = np.array(padded).reshape([width+2, height+2])
cv2.imwrite("padded_out.bmp", padded_img)
print(padded)

write_to_hex(padded, "hex_padded.txt")

#apply filter
filtered = convolve(padded, kernel, width+2, kernel_width)

write_to_hex(filtered, "hex_filtered.txt")
print(filtered)

#write output
filtered = np.array(filtered).reshape([width, height])
cv2.imwrite("lena_out.bmp", filtered)
