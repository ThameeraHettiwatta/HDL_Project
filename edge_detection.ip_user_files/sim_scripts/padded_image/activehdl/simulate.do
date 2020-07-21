onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+padded_image -L xil_defaultlib -L secureip -O5 xil_defaultlib.padded_image

do {wave.do}

view wave
view structure

do {padded_image.udo}

run -all

endsim

quit -force
