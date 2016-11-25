ARGS=getArgument()
setBatchMode(true);
parts=split(ARGS, ":");
WORK=parts[0];
FNAME=parts[1];
FIRST=parts[2];
LAST=parts[3];
BLOCK=parts[4];

THREED=0;

if (parts.length == 6)  {
  CALIB=parts[5];
  CALPATH= WORK + "/" + CALIB;
  THREED=File.exists(CALPATH); //Returns "1" (true) if the specified file exists.
}


fullname=split(FNAME, ".");
NAME=fullname[0];

if (BLOCK == "1")  {
  OUTPATH = WORK + "/tmp_" + NAME + ".csv";
  SAVEPROTOCOL = "true";
}
else  {
  OUTPATH = WORK + "/tmp_" + NAME + BLOCK + ".csv";
  SAVEPROTOCOL = "false";
}


//run("Memory & Threads...", "maximum=8192 parallel=20”);
run("Bio-Formats Importer","open="+WORK+"/"+FNAME+" color_mode=Default specify_range view=Hyperstack stack_order=XYCZT t_begin="+FIRST+" t_end="+LAST+" t_step=1");
run("Camera setup", "isemgain=false pixelsize=126.0 offset=350 photons2adu=0.5");
if(THREED==0)  {
run( "Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Non-maximum suppression] radius=3 threshold=std(Wave.F1) estimator=[PSF: Integrated Gaussian] sigma=1.6 method=[Weighted Least squares] full_image_fitting=false fitradius=4 mfaenabled=false renderer=[No Renderer]");
}
else  {
run("Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Local maximum] connectivity=8-neighbourhood threshold=std(Wave.F1) estimator=[PSF: Elliptical Gaussian (3D astigmatism)] sigma=1.6 fitradius=8 method=[Weighted Least squares] calibrationpath=["+CALPATH+"] full_image_fitting=false mfaenabled=false renderer=[No Renderer]");
}
run("Export results", "filepath=["+OUTPATH+"] fileformat=[CSV (comma separated)] id=true frame=true sigma=true bkgstd=true intensity=true saveprotocol=["+SAVEPROTOCOL+"] offset=true uncertainty=true y=true x=true");
close();
run("Quit");