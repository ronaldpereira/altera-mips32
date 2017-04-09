transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Ronald/Documents/Dropbox/UFMG/OC2/tp/teste-modelsim/code {C:/Users/Ronald/Documents/Dropbox/UFMG/OC2/tp/teste-modelsim/code/tp.v}
vlog -vlog01compat -work work +incdir+C:/Users/Ronald/Documents/Dropbox/UFMG/OC2/tp/teste-modelsim/code {C:/Users/Ronald/Documents/Dropbox/UFMG/OC2/tp/teste-modelsim/code/displayDecoder.v}
vcom -93 -work work {C:/Users/Ronald/Documents/Dropbox/UFMG/OC2/tp/teste-modelsim/code/mem_data.vhd}
vcom -93 -work work {C:/Users/Ronald/Documents/Dropbox/UFMG/OC2/tp/teste-modelsim/code/mem_inst.vhd}

