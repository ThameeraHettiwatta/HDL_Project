onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+input_image -L xpm -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.input_image xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {input_image.udo}

run -all

endsim

quit -force
