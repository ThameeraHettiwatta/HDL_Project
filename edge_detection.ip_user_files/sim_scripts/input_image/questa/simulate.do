onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib input_image_opt

do {wave.do}

view wave
view structure
view signals

do {input_image.udo}

run -all

quit -force
