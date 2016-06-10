WORK=getArgument()
setBatchMode(true)
run("Bio-Formats Importer","open="+WORK+"/teststack.tif color_mode=Default view=Hyperstack stack_order=XYCZT use_virtual_stack");
//run("Bio-Formats Importer","open=/Users/imunro/STORM_Optimisation/speedtest/teststack.tif color_mode=Default view=Hyperstack stack_order=XYCZT use_virtual_stack");
run("Camera setup", "isemgain=false pixelsize=126.0 offset=350 photons2adu=0.5")
run( "Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Non-maximum suppression] radius=3 threshold=std(Wave.F1) estimator=[PSF: Integrated Gaussian] sigma=1.6 method=[Maximum likelihood] full_image_fitting=false fitradius=4 mfaenabled=false renderer=[No Renderer]")
run("Export results", "filepath=["+WORK+"/result.csv] fileformat=[CSV (comma separated)] id=true frame=true sigma=true bkgstd=true intensity=true saveprotocol=true offset=true uncertainty=true y=true x=true")
close()
run("Quit");