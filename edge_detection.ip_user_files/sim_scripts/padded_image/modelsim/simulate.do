onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xil_defaultlib -L secureip -lib xil_defaultlib xil_defaultlib.padded_image

do {wave.do}

view wave
view structure
view signals

do {padded_image.udo}

run -all

quit -force
