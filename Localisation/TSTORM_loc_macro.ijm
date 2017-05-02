ARGS=getArgument()
setBatchMode(true);
parts=split(ARGS, ":");
WORK=parts[0];
FNAME=parts[1];
FIRST=parts[2];
LAST=parts[3];
BLOCK=parts[4];

if (parts.length == 7)  {
TMPDIR=parts[6];
}
else  {
TMPDIR=parts[5];
}

fullname=split(FNAME, ".");
NAME=fullname[0];

LOGPATH = WORK + "/Localisation/tmp_" + NAME + "_" + BLOCK + ".log";

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


// NB output to TMPDIR seems to fail here so TMPDIR points to our own
//temporary directory
if (BLOCK == "1")  {
OUTPATH = TMPDIR + "/tmp_" + NAME + ".csv";
SAVEPROTOCOL = "true";
}
else  {
OUTPATH = TMPDIR + "/tmp_" + NAME + "_" +BLOCK + ".csv";
SAVEPROTOCOL = "false";
}


THREED=0;

if (parts.length == 7)  {
  CALIB=parts[5];
  CALPATH= WORK + "/" + CALIB;
  THREED=File.exists(CALPATH); //Returns "1" (true) if the specified file exists.
File.append("3D!",LOGPATH);
}
else  {
File.append("2D!",LOGPATH);
}


//run("Memory & Threads...", "maximum=8192 parallel=20”);
File.append("Importing file " + FNAME,LOGPATH);
run("Bio-Formats Importer","open="+WORK+"/"+FNAME+" color_mode=Default specify_range view=[Standard ImageJ] stack_order=Default t_begin="+FIRST+" t_end="+LAST+" t_step=1");


// Use imagej to get pixelsize
getPixelSize(unit, pixelWidth, pixelHeight);
PIXELWIDTH = pixelWidth * 1000;
File.append("pixel Width = " + PIXELWIDTH ,LOGPATH);

run("Camera setup", "readoutnoise=0.0 offset=350.0 quantumefficiency=0.9 isemgain=false photons2adu=0.5 pixelsize=["+PIXELWIDTH+"]");


if(THREED==0)  {
File.append("Starting 2D localisation!",LOGPATH);
run( "Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Non-maximum suppression] radius=3 threshold=[1.25 * std(Wave.F1)] estimator=[PSF: Integrated Gaussian] sigma=1.6 method=[Weighted Least squares] full_image_fitting=false fitradius=4 mfaenabled=false renderer=[No Renderer]");
}
else  {
File.append("Starting 3D localisation!",LOGPATH);
run("Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Local maximum] connectivity=8-neighbourhood threshold=[1.25 * std(Wave.F1)] estimator=[PSF: Elliptical Gaussian (3D astigmatism)] sigma=1.6 fitradius=8 method=[Weighted Least squares] calibrationpath=["+CALPATH+"] full_image_fitting=false mfaenabled=false renderer=[No Renderer]");
}

// Sanity check!! Filter out zero intensities
FORMULA = "[intensity > 1]";
File.append("Filtering with " + FORMULA, LOGPATH);
run("Show results table", "action=filter formula=["+FORMULA+"]");


File.append("Exporting localisaton as .csv to " + OUTPATH, LOGPATH);
run("Export results", "floatprecision=2 filepath=["+OUTPATH+"] fileformat=[CSV (comma separated)] id=true frame=true sigma=true bkgstd=true intensity=true saveprotocol=["+SAVEPROTOCOL+"] offset=true uncertainty=true y=true x=true");


getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
if (hour<10) {TimeString = "0";} else {TimeString = "";}
TimeString = TimeString+hour+":";
if (minute<10) {TimeString = TimeString+"0";}
TimeString = TimeString+minute+":";
if (second<10) {TimeString = TimeString+"0";}
TimeString = TimeString+second;

File.append("exiting loc_macro at " + TimeString,LOGPATH);
File.append("...",LOGPATH);
File.close(logf);

close();
run("Quit");