ARGS=getArgument()
setBatchMode(true);
parts=split(ARGS, ":");
WORK=parts[0];
FIRST=parts[1];
LAST=parts[2];
BLOCK=parts[3];
print(WORK);
print(FIRST);
print(LAST);
print(BLOCK)
//run("Memory & Threads...", "maximum=4096 parallel=16”);
run("Bio-Formats Importer","open="+WORK+"/teststack.tif color_mode=Default specify_range view=Hyperstack stack_order=XYCZT z_begin="+FIRST+" z_end="+LAST+" z_step=1");
run("Camera setup", "isemgain=false pixelsize=126.0 offset=350 photons2adu=0.5");
run( "Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Non-maximum suppression] radius=3 threshold=std(Wave.F1) estimator=[PSF: Integrated Gaussian] sigma=1.6 method=[Maximum likelihood] full_image_fitting=false fitradius=4 mfaenabled=false renderer=[No Renderer]");
print("about to export")
run("Export results", "filepath=["+WORK+"/result"+BLOCK+".csv] fileformat=[CSV (comma separated)] id=true frame=false sigma=true bkgstd=true intensity=true saveprotocol=true offset=true uncertainty=true y=true x=true");
close();
run("Quit");