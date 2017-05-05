ARGS=getArgument();
setBatchMode(true);
parts=split(ARGS, ":");
WORK=parts[0];
FNAME=parts[1];
FIRST=parts[2];
LAST=parts[3];
BLOCK=parts[4];

if (parts.length == 10)  {
CALIB=parts[5];
CALPATH= WORK + "/" + CALIB;
THREED=File.exists(CALPATH); //Returns "1" (true) if the specified file exists.
LATERAL_UNCERTAINTY=parts[6];
POST=parts[7];
TMPDIR=parts[8];
HOME=parts[9];
}
else  {
THREED=0;
LATERAL_UNCERTAINTY=parts[5];
POST=parts[6];
TMPDIR=parts[7];
HOME=parts[8];
}


fullname=split(FNAME, ".");
NAME=fullname[0];


LOGPATH = WORK + "/" + NAME + "_" + POST + ".log";

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

File.append("TMPDIR = " + TMPDIR , LOGPATH);


File.append("Lateral Uncertainty = " + LATERAL_UNCERTAINTY, LOGPATH);


FILEPATH=WORK + "/" + FNAME;

ERR=File.exists(FILEPATH);


if(ERR!=1)  {
File.append("Unable to find raw data file!",LOGPATH)
close();
run("Quit");
}

// Use Bio-Formats to find the size of the original data
run("Bio-Formats Macro Extensions");
Ext.setId(FILEPATH);
Ext.setSeries(0);
Ext.getSizeX(sizeX);
File.append("sizeX = " + sizeX, LOGPATH);
Ext.getSizeY(sizeY);
File.append("sizeY = " + sizeY, LOGPATH);
Ext.getPixelsPhysicalSizeX(pixelWidth);
PIXELWIDTH = pixelWidth * 1000;
File.append("pixel Width = " + PIXELWIDTH ,LOGPATH);


//run("Memory & Threads...", "maximum=8192 parallel=20”);
run("Bio-Formats Importer","open=FILEPATH color_mode=Default specify_range view=[Standard ImageJ] stack_order=Default t_begin=1 t_end=2 t_step=1");

// Use imagej to get pixelsize
getPixelSize(unit, pixelWidth, pixelHeight);
PIXELWIDTH = pixelWidth * 1000;
File.append("pixel Width = " + PIXELWIDTH ,LOGPATH);

// find required magnification to get 25nm pixels
MAGNIFICATION = toString(parseFloat(PIXELWIDTH)/25);
File.append("Calculated magnification  = " + MAGNIFICATION ,LOGPATH);


// Determine which Camera is in use & setup appropriately
COMMAND= "grep Prime95B " + FILEPATH;
if(indexOf(exec(COMMAND), "matches") > -1)  {
  //Prime95B Camera detected
  File.append(" using Prime95B values for Camera Setup!", LOGPATH);
  run("Camera setup", "readoutnoise=0.0 offset=170.0 quantumefficiency=0.9 isemgain=false photons2adu=2.44 pixelsize=["+PIXELWIDTH+"]");
}
else  {
  File.append(" using Orca values for Camera Setup!", LOGPATH);
  run("Camera setup", "readoutnoise=0.0 offset=350.0 quantumefficiency=0.9 isemgain=false photons2adu=0.5 pixelsize=["+PIXELWIDTH+"]");
}


CSVPATH = TMPDIR + "/" + NAME + ".csv";

File.append("Importing .csv file " + CSVPATH,LOGPATH);

run("Import results", "detectmeasurementprotocol=false filepath=["+CSVPATH+"] fileformat=[CSV (comma separated)] livepreview=false rawimagestack= startingframe=1 append=false");


// Post_processing

if(indexOf(POST, "SIGMA") > -1)  {

  File.append("Performing sigma filtering.", LOGPATH);
  PYPATH = HOME + "/Visualisation/csv_sigma_mode.py";

  COMMAND = "python " + PYPATH + " -i " + CSVPATH;
  MODE = exec(COMMAND);

  if (MODE == -1)  {

    File.append("ERROR! Failed to find Mode of csv file!! " ", LOGPATH);
  }
  else {


   File.append("Mode of sigma distribution =  " + MODE, LOGPATH);

    MODEF = parseFloat(MODE);
    RANGE = MODEF * 0.2;
    UPPER_LIM = toString(MODEF + RANGE,2);
    LOWER_LIM = toString(MODEF - RANGE,2);
    if(THREED==0)  {
      FORMULA = "[sigma < " + UPPER_LIM + " & sigma > " + LOWER_LIM + " ]";
    }
    else  {
      FORMULA = "[sigma1 < " + UPPER_LIM + " & sigma1 > " + LOWER_LIM + " ]";
    }

    File.append("Filtering with " + FORMULA, LOGPATH);

    run("Show results table", "action=filter formula=["+FORMULA+"]");
  }

}


if(indexOf(POST, "DRIFT") > -1)  {

  File.append("Performing drift correction.", LOGPATH);
  run("Show results table", "action=drift magnification=["+MAGNIFICATION+"] method=[Cross correlation] ccsmoothingbandwidth=1.0 save=false steps=6 showcorrelations=false");


  File.append("Drift coeection done!", LOGPATH);
  selectWindow("Drift");
  DRIFTPATH = WORK + "/" + NAME + "_drift.tiff";
  File.append("Saving drift graph to " + DRIFTPATH, LOGPATH);
  saveAs("Tiff", DRIFTPATH);
  close();

}



NAME = NAME + "_" + POST;


POSTPATH = TMPDIR + "/" + NAME + ".csv";

File.append("Saving post-processed localisations as " + POSTPATH, LOGPATH);
run("Export results", "filepath=["+POSTPATH+"] fileformat=[CSV (comma separated)] id=true frame=true sigma=true bkgstd=true intensity=true saveprotocol=true offset=true uncertainty=true y=true x=true");


if(THREED==0)  {
File.append("Starting 2D visualisation!",LOGPATH);


//run("Visualization", "imleft=0.0 imtop=0.0 imwidth=["+sizeX+"] imheight=["+sizeY+"] renderer=[Averaged shifted histograms] magnification=["+MAGNIFICATION+"] colorizez=false threed=false shifts=2");

run("Visualization", "imleft=0.0 imtop=0.0 imwidth=["+sizeX+"] imheight=["+sizeY+"] renderer=[Normalized Gaussian] magnification=["+MAGNIFICATION+"] dx=["+LATERAL_UNCERTAINTY+"] colorizez=false threed=false dzforce=false");
    OUTPATH = TMPDIR + "/" + NAME + "_2D.ome.tif";
}
else  {
File.append("Starting 3D visualisation!",LOGPATH);

//run("Visualization", "imleft=0.0 imtop=0.0 imwidth=["+sizeX+"] imheight=["+sizeY+"] renderer=[Averaged shifted histograms] zrange=-600:30:600 magnification=["+MAGNIFICATION+"] colorizez=false threed=true shifts=2 zshifts=2");

run("Visualization", "imleft=0.0 imtop=0.0 imwidth=["+sizeX+"] imheight=["+sizeY+"] renderer=[Normalized Gaussian] zrange=-600:30:600 dxforce=false magnification=["+MAGNIFICATION+"] dx=["+LATERAL_UNCERTAINTY+"] colorizez=false dz=70.0 threed=true dzforce=false");
    OUTPATH = TMPDIR + "/" + NAME + "_3D.ome.tif";
}



run("Enhance Contrast...", "saturated=0.01 process_all use"); // lets brightest 0.01% of pixels saturate
run("8-bit");

File.append("Exporting visualisaton as ome.tiff to " + OUTPATH, LOGPATH);


run("Bio-Formats Exporter", "save=["+OUTPATH+"] compression=LZW");


if(File.exists(OUTPATH) != 1 ) {
File.append("Failed to write " + OUTPATH, LOGPATH);
}

// Delete original .csv file from TMPDIR so as not to overwrite unnecessarily
File.delete(CSVPATH);


getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
if (hour<10) {TimeString = "0";} else {TimeString = "";}
TimeString = TimeString+hour+":";
if (minute<10) {TimeString = TimeString+"0";}
TimeString = TimeString+minute+":";
if (second<10) {TimeString = TimeString+"0";}
TimeString = TimeString+second;

File.append("exiting Visualisation macro at "+ TimeString, LOGPATH);
File.close(logf);


close();
run("Quit");