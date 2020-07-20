onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib padded_image_opt

do {wave.do}

view wave
view structure
view signals

do {padded_image.udo}

run -all

quit -force
