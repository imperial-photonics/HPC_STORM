ARGS=getArgument()
setBatchMode(true);
parts=split(ARGS, ":");
WORK=parts[0];
FIRST=parts[1];
LAST=parts[2];
BLOCK=parts[3];

if (BLOCK == "1")  {
  OUTPATH = WORK + "/result.csv";
  SAVEPROTOCOL = "true";
}
else  {
  OUTPATH = WORK + "/result" + BLOCK + ".csv";
  SAVEPROTOCOL = "false";
}


run("Memory & Threads...", "maximum=4096 parallel=1”);
run("Bio-Formats Importer","open="+WORK+"/fakeStorm.ome.tiff color_mode=Default specify_range view=Hyperstack stack_order=XYCZT z_begin="+FIRST+" z_end="+LAST+" z_step=1");
run("Camera setup", "isemgain=false pixelsize=126.0 offset=350 photons2adu=0.5");
run( "Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Non-maximum suppression] radius=3 threshold=std(Wave.F1) estimator=[PSF: Integrated Gaussian] sigma=1.6 method=[Maximum likelihood] full_image_fitting=false fitradius=4 mfaenabled=false renderer=[No Renderer]");
run("Export results", "filepath=["+OUTPATH+"] fileformat=[CSV (comma separated)] id=true frame=true sigma=true bkgstd=true intensity=true saveprotocol=["+SAVEPROTOCOL+"] offset=true uncertainty=true y=true x=true");
close();
run("Quit");