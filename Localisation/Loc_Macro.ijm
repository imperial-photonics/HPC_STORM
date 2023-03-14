ARGS=getArgument();
print(ARGS);
setBatchMode(true);
parts=split(ARGS, ":");

WORK=parts[0];
INPATH=parts[1];
FNAME=parts[2];
JOBNO=parts[3];
NJOBS=parts[4];
BLOCK=parts[5];
THREED=parts[6];
CAMERA=parts[7];
CALIB=parts[8];

fullname=split(FNAME, ".");
NAME=fullname[0];

LOGPATH = WORK + "/" + JOBNO + "/tmp_" + NAME + "_" + BLOCK + ".log";

if (File.exists(LOGPATH))  {
    File.delete(LOGPATH);
}

logf = File.open(LOGPATH);

File.append(ARGS,LOGPATH);

File.append("Opened log file at " + getTimeString(), LOGPATH);
File.append("ImageJ version " + getVersion(), LOGPATH);

// NB TMPDIR points to our own
// temporary directory
// but we should already be running from there anyway
if (BLOCK == "1")  {
    OUTPATH = "tmp_" + NAME + "_slice_1.csv";
    SAVEPROTOCOL = "true";
} else {
    OUTPATH = "tmp_" + NAME + "_slice_" +BLOCK + ".csv";
    SAVEPROTOCOL = "false";
}

if (THREED == 1)  {
    CALPATH=INPATH + "/" + CALIB;
}

FILEPATH=INPATH + "/" + FNAME;
//FILEPATH=FNAME;

if (!File.exists(FILEPATH))  {
    File.append("Error failed to find " + FILEPATH, LOGPATH);
}

File.append("Reading image metadata at "+getTimeString(), LOGPATH);

// Use Bio-Formats extensions to find the pixelSize & sizeT
run("Bio-Formats Macro Extensions");
Ext.setId(FILEPATH);
Ext.setSeries(0);
Ext.getPixelsPhysicalSizeX(pixelWidth);
PIXELWIDTH = pixelWidth * 1000;
File.append("pixel Width = " + PIXELWIDTH ,LOGPATH);
Ext.getSizeT(sizeT);
sizeT=parseInt(sizeT);
Ext.getSizeX(sizeX);
Ext.getSizeY(sizeY);
Ext.close();

FIRST = parseInt(BLOCK);
LAST = sizeT;
//FIRST =10000
//LAST=12000;

File.append("Frames from " + FIRST + " to " + LAST, LOGPATH);

//run("Memory & Threads...", "maximum=65536 parallel=24”);
File.append("Bio-Formats Importer"+","+"open="+FILEPATH+" color_mode=Default specify_range view=[Standard ImageJ] stack_order=Default t_begin="+FIRST+" t_end="+LAST+" t_step="+NJOBS+"",LOGPATH);
run("Bio-Formats Importer","open="+FILEPATH+" color_mode=Default specify_range view=[Standard ImageJ] stack_order=Default t_begin="+FIRST+" t_end="+LAST+" t_step="+NJOBS+"");




File.append("Imported Dataset to FIJI at " + getTimeString(), LOGPATH);

// Determine which Camera is in use & setup appropriately
// Can't find Camera Name with Bioformats library so it has already been found with commandline tool as CAMERA
if (CAMERA=="Prime95B")  {
    File.append("Using Prime95B values for Camera Setup!", LOGPATH);
    //if (isNaN(PIXELWIDTH)) PIXELWIDTH=110;  // default assumes 100x lens and normal camera pixel size
    run("Camera setup", "readoutnoise=1.8 offset=170.0 quantumefficiency=0.9 isemgain=false photons2adu=2.44 pixelsize=["+PIXELWIDTH+"]");
} else  if (CAMERA=="Andor_iXon_Ultra"){
    File.append("Using Andor iXon Ultra values for Camera Setup!", LOGPATH);
    if (isNaN(PIXELWIDTH)) PIXELWIDTH=130;  // default assumes 100x lens and normal camera pixel size
    run("Camera setup", "readoutnoise=0.0 offset=16.0 quantumefficiency=1.0 isemgain=true photons2adu=5.1 gainem=200.0 pixelsize=["+PIXELWIDTH+"]");
} else  if (CAMERA=="pco_camera"){
    File.append("Using pco_camera values for Camera Setup!", LOGPATH);
    if (isNaN(PIXELWIDTH)) PIXELWIDTH=65;  // default assumes 100x lens and normal camera pixel size
    run("Camera setup", "readoutnoise=2.1 offset=126 quantumefficiency=0.80 isemgain=false photons2adu=1 pixelsize=["+PIXELWIDTH+"]");
} else  if (CAMERA=="Andor_sCMOS_Camera"){
    File.append("Using Andor_sCMOS_Camera values for Camera Setup!", LOGPATH);
    if (isNaN(PIXELWIDTH)) PIXELWIDTH=65;  // default assumes 100x lens and normal camera pixel size
    run("Camera setup", "readoutnoise=1.8 offset=170.0 quantumefficiency=0.9 isemgain=false photons2adu=2.44 pixelsize=["+PIXELWIDTH+"]");
} else  if (CAMERA=="Grasshopper3_GS3-U3-23S6M"){
    File.append("Using Grasshopper3_GS3-U3-23S6M values for Camera Setup!", LOGPATH);
    if (isNaN(PIXELWIDTH)) PIXELWIDTH=58.6;  // default assumes 100x lens and normal camera pixel size
    if (PIXELWIDTH==0) PIXELWIDTH=58.6;
    run("Camera setup", "readoutnoise=6.1 offset=9 quantumefficiency=0.76 isemgain=false photons2adu=1 pixelsize=["+PIXELWIDTH+"]");
} else {
    // Assume it must be an Orca flash 4
    //File.append("Using HamamatsuHam_DCAM values for Camera Setup!", LOGPATH);
	File.append("Using Prime95B values for Camera Setup!", LOGPATH);
    if (isNaN(PIXELWIDTH)) PIXELWIDTH=64.5;
    //run("Camera setup", "readoutnoise=1.5 offset=20.0 quantumefficiency=0.82 isemgain=false photons2adu=0.458 pixelsize=["+PIXELWIDTH+"]");
	run("Camera setup", "readoutnoise=1.8 offset=170.0 quantumefficiency=0.9 isemgain=false photons2adu=2.44 pixelsize=["+PIXELWIDTH+"]");
    //Nope Assume is an Zyle
    //if (isNaN(PIXELWIDTH)) PIXELWIDTH=130; 
       //   run("Camera setup", "readoutnoise=0.9 offset=200 quantumefficiency=0.64 isemgain=false photons2adu=0.45 pixelsize=["+PIXELWIDTH+"]");
       // run("Camera setup", "readoutnoise=1.5 offset=200 quantumefficiency=0.70 isemgain=false photons2adu=0.20 pixelsize=["+PIXELWIDTH+"]");​
	   

if(THREED==0)  {
    File.append("Starting 2D localisation!",LOGPATH);
    run( "Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Non-maximum suppression] radius=3 threshold=[std(Wave.F1)] estimator=[PSF: Integrated Gaussian] sigma=1.6 method=[Weighted Least squares] full_image_fitting=false fitradius=4 mfaenabled=false renderer=[No Renderer]");
    //run( "Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Non-maximum suppression] radius=3 threshold=[1.25 * std(Wave.F1)] estimator=[PSF: Integrated Gaussian] sigma=1.6 method=[Maximum likelihood] full_image_fitting=false fitradius=4 mfaenabled=false renderer=[No Renderer]");
    // Sanity check!! Filter out zero intensities
    //FORMULA = "[intensity > 1]";
    //File.append("Filtering with " + FORMULA, LOGPATH);
    //N.B. formula is currently hardcoded due to possible syntax issue.
    //run("Show results table", "action=filter formula=[intensity > 1]");
} else {
    File.append("Starting 3D localisation!",LOGPATH);
    run("Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Local maximum] connectivity=8-neighbourhood threshold=[1.25 * std(Wave.F1)] estimator=[PSF: Elliptical Gaussian (3D astigmatism)] sigma=1.6 fitradius=8 method=[Weighted Least squares] calibrationpath=["+CALPATH+"] full_image_fitting=false mfaenabled=false renderer=[No Renderer]");
    //run("Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Local maximum] connectivity=8-neighbourhood threshold=[1.25 * std(Wave.F1)] estimator=[PSF: Elliptical Gaussian (3D astigmatism)] sigma=1.6 fitradius=8 method=[Maximum likelihood] calibrationpath=["+CALPATH+"] full_image_fitting=false mfaenabled=false renderer=[No Renderer]");
    // Sanity check!! Filter out zero intensities & uncertainty_z == Infinity
    //FORMULA = "[intensity > 1 & 1/uncertainty_z > 0]";
    //File.append("Filtering with " + FORMULA, LOGPATH);
    //N.B. formula is currently hardcoded due to possible syntax issue.
    //run("Show results table", "action=filter formula=[intensity > 1 & 1/uncertainty_z > 0 ]");
}

File.append("Finished Localization at " + getTimeString(), LOGPATH);

File.append("Exporting localisations to " + OUTPATH, LOGPATH);

if(THREED==0) {
    run("Export results", "floatprecision=2 filepath=["+OUTPATH+"] fileformat=[CSV (comma separated)] id=true frame=true sigma=true bkgstd=true intensity=true saveprotocol=["+SAVEPROTOCOL+"] offset=true uncertainty=true y=true x=true");
} else {
    run("Export results", "floatprecision=2 filepath=["+OUTPATH+"] fileformat=[CSV (comma separated)] chi2=true offset=true saveprotocol=["+SAVEPROTOCOL+"] bkgstd=true uncertainty_xy=true intensity=true x=true sigma2=true uncertainty_z=true y=true sigma1=true z=true id=true frame=true");
}

close();

File.append("Exported CSV result at " + getTimeString(),LOGPATH);
File.append("...",LOGPATH);
File.close(logf);

// Now write a config file N.B. Must be after closing log file or File.open() fails!!
CONFPATH = WORK + "/" + JOBNO  + "/tmp_conf_" + NAME + "_" + BLOCK + ".txt";
if (File.exists(CONFPATH))  {
    File.delete(CONFPATH);
}
conff = File.open(CONFPATH);
LINE = toString(FIRST)+":"+LAST+":"+PIXELWIDTH+":"+sizeX+":"+sizeY+":";
File.append(LINE, CONFPATH);
File.close(conff);

run("Quit");

function getTimeString() {
    getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
    if (hour<10) {TimeString = "0";} else {TimeString = "";}
    TimeString = TimeString+hour+":";
    if (minute<10) {TimeString = TimeString+"0";}
    TimeString = TimeString+minute+":";
    if (second<10) {TimeString = TimeString+"0";}
    TimeString = TimeString+second;
    return TimeString;
}

