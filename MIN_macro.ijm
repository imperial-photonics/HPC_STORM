WORK=getArgument()
open(""+WORK+"/teststack.tif")
//run("Bio-Formats Importer","open="+WORK+"/teststack.tif color_mode=Default view=Hyperstack stack_order=XYCZT use_virtual_stack");
close()
run("Quit");