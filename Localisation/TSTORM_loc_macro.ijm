ARGS=getArgument()
setBatchMode(true);
parts=split(ARGS, ":");

WORK=parts[1];
FNAME=parts[2];
JOBNO=parts[3];
NJOBS=parts[4];
BLOCK=parts[5];
THREED=parts[6];
CALIB=parts[7];

fullname=split(FNAME, ".");
NAME=fullname[0];

LOGPATH = WORK + "/" + JOBNO + "/tmp_" + NAME + "_" + BLOCK + ".log";

if (File.exists(LOGPATH))  {
    File.delete(LOGPATH);
}

logf = File.open(LOGPATH);

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
if (hour<10) {TimeString = "0";} else {TimeString = "";}
TimeString = TimeString+hour+":";
if (minute<10) {TimeString = TimeString+"0";}
TimeString = TimeString+minute+":";
if (second<10) {TimeString = TimeString+"0";}
TimeString = TimeString+second;

File.append("Opened log file at " + TimeString, LOGPATH);

// NB TMPDIR points to our own
// temporary directory
// but we should already be running form there anyway
if (BLOCK == "1")  {
    OUTPATH = "tmp_" + NAME + "_slice_1.csv";
    SAVEPROTOCOL = "true";
} else {
    OUTPATH = "tmp_" + NAME + "_slice_" +BLOCK + ".csv";
    SAVEPROTOCOL = "false";
}

if (THREED == 1)  {
    CALPATH=CALIB;
}
 
//FILEPATH=TMPDIR + "/" + FNAME;
FILEPATH=FNAME;

if (!File.exists(FILEPATH))  {
    File.append("Error failed to find " + FILEPATH, LOGPATH);
}

// Use Bio-Formats to find the pixelSize & sizeT
run("Bio-Formats Macro Extensions");
Ext.setId(FILEPATH);
Ext.setSeries(0);
Ext.getPixelsPhysicalSizeX(pixelWidth);
PIXELWIDTH = pixelWidth * 1000;
File.append("pixel Width = " + PIXELWIDTH ,LOGPATH);
Ext.getSizeT(sizeT);
sizeT=parseInt(sizeT);
//sizeT=100;

FIRST = parseInt(BLOCK);
LAST = sizeT;

File.append("Frames from " + FIRST + " to " + LAST, LOGPATH);

//run("Memory & Threads...", "maximum=65536 parallel=24”);
//File.append("Importing file " + FILEPATH ,LOGPATH);
run("Bio-Formats Importer","open="+FILEPATH+" color_mode=Default specify_range view=[Standard ImageJ] stack_order=Default t_begin="+FIRST+" t_end="+LAST+" t_step="+NJOBS+"");


getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
if (hour<10) {TimeString = "0";} else {TimeString = "";}
TimeString = TimeString+hour+":";
if (minute<10) {TimeString = TimeString+"0";}
TimeString = TimeString+minute+":";
if (second<10) {TimeString = TimeString+"0";}
TimeString = TimeString+second;

File.append("Imported Dataset to FIJI at " + TimeString, LOGPATH);

// Look for Camera Name
//field="Camera Name";
//CAMERANAME="";
//Ext.getMetadataValue(field,CAMERANAME);

//if(indexOf(CAMERANAME, "Andor") > -1)  {
//field="GainMultiplier";
//GAINEM="";
//Ext.getMetadataValue(field,GAINEM);

//File.append("Using Andor DU-897 values for Camera Setup! With Gainem " + GAINEM, LOGPATH);
//run("Camera setup", "offset=99.74 quantumefficiency=1.0 isemgain=true photons2adu=5.32 gainem=["+GAINEM+"] pixelsize=["+PIXELWIDTH+"]");
//}
//else {

// Determine which Camera is in use & setup appropriately
COMMAND= "grep Prime95B " + FILEPATH;
if(indexOf(exec(COMMAND), "matches") > -1)  {
//Prime95B Camera detected
File.append("Using Prime95B values for Camera Setup!", LOGPATH);
run("Camera setup", "readoutnoise=1.8 offset=170.0 quantumefficiency=0.9 isemgain=false photons2adu=2.44 pixelsize=["+PIXELWIDTH+"]");
}
else  {
File.append("Using Orca values for Camera Setup!", LOGPATH);
run("Camera setup", "readoutnoise=1.5 offset=350.0 quantumefficiency=0.9 isemgain=false photons2adu=0.5 pixelsize=["+PIXELWIDTH+"]");
}
//}

Ext.close();


if(THREED==0)  {
File.append("Starting 2D localisation!",LOGPATH);
run( "Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Non-maximum suppression] radius=3 threshold=[1.25 * std(Wave.F1)] estimator=[PSF: Integrated Gaussian] sigma=1.6 method=[Weighted Least squares] full_image_fitting=false fitradius=4 mfaenabled=false renderer=[No Renderer]");
// Sanity check!! Filter out zero intensities
//FORMULA = "[intensity > 1]";
//File.append("Filtering with " + FORMULA, LOGPATH);
//N.B. formula is currently hardcoded due to possible syntax issue.
//run("Show results table", "action=filter formula=[intensity > 1]");
}
else  {
File.append("Starting 3D localisation!",LOGPATH);
run("Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Local maximum] connectivity=8-neighbourhood threshold=[1.25 * std(Wave.F1)] estimator=[PSF: Elliptical Gaussian (3D astigmatism)] sigma=1.6 fitradius=8 method=[Weighted Least squares] calibrationpath=["+CALPATH+"] full_image_fitting=false mfaenabled=false renderer=[No Renderer]");
// Sanity check!! Filter out zero intensities & uncertainty_z == Infinity
//FORMULA = "[intensity > 1 & 1/uncertainty_z > 0]";
//File.append("Filtering with " + FORMULA, LOGPATH);
//N.B. formula is currently hardcoded due to possible syntax issue.
//run("Show results table", "action=filter formula=[intensity > 1 & 1/uncertainty_z > 0 ]");
}


getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
if (hour<10) {TimeString = "0";} else {TimeString = "";}
TimeString = TimeString+hour+":";
if (minute<10) {TimeString = TimeString+"0";}
TimeString = TimeString+minute+":";
if (second<10) {TimeString = TimeString+"0";}
TimeString = TimeString+second;

File.append("Finished Localization at " + TimeString, LOGPATH);



File.append("Exporting localisations to " + OUTPATH, LOGPATH);
run("Export results", "floatprecision=2 filepath=["+OUTPATH+"] fileformat=[CSV (comma separated)] id=true frame=true sigma=true bkgstd=true intensity=true saveprotocol=["+SAVEPROTOCOL+"] offset=true uncertainty=true y=true x=true");

close();


getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
if (hour<10) {TimeString = "0";} else {TimeString = "";}
TimeString = TimeString+hour+":";
if (minute<10) {TimeString = TimeString+"0";}
TimeString = TimeString+minute+":";
if (second<10) {TimeString = TimeString+"0";}
TimeString = TimeString+second;

File.append("Exported CSV result at " + TimeString,LOGPATH);
File.append("...",LOGPATH);
File.close(logf);

// Now write a config file N.B. Must be after closing log file or File.open() fails!!
CONFPATH = WORK + "/" + JOBNO  + "/tmp_conf_" + NAME + "_" + BLOCK + ".txt";
if (File.exists(CONFPATH))  {
File.delete(CONFPATH);
}
conff = File.open(CONFPATH);
LINE = toString(FIRST) + ":" + toString(LAST);
File.append(LINE, CONFPATH);
File.close(conff);


run("Quit");
