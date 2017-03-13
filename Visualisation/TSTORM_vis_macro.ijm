ARGS=getArgument();
setBatchMode(true);
parts=split(ARGS, ":");
WORK=parts[0];
FNAME=parts[1];

if (parts.length == 9)  {
LATERAL_UNCERTAINTY=parts[6];
HOME=parts[7];
TMPDIR=parts[8];
}
else  {
LATERAL_UNCERTAINTY=parts[5];
HOME=parts[6];
TMPDIR=parts[7];
}


fullname=split(FNAME, ".");
NAME=fullname[0];

LOGPATH = HOME + "/Visualisation/" + NAME + ".log";


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


FIRST=parts[2];
LAST=parts[3];
BLOCK=parts[4];


THREED=0;

if (parts.length == 9)  {
  CALIB=parts[5];
  CALPATH= WORK + "/" + CALIB;
  THREED=File.exists(CALPATH); //Returns "1" (true) if the specified file exists.

}

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


CSVPATH = WORK + "/" + NAME + "_reconstr.csv";

File.append("Importing .csv file " + CSVPATH,LOGPATH);



run("Import results", "filepath=["+CSVPATH+"] fileformat=[CSV (comma separated)] livepreview=false rawimagestack= startingframe=1 append=false");




if(THREED==0)  {
File.append("Starting 2D visualisation!",LOGPATH);

run("Visualization", "imleft=0.0 imtop=0.0 imwidth=["+sizeX+"] imheight=["+sizeY+"] renderer=[Normalized Gaussian] dxforce=false magnification=12.6 dx=["+LATERAL_UNCERTAINTY+"] colorizez=false threed=false dzforce=false");
    OUTPATH = TMPDIR + "/" + NAME + "_2D.ome.tif";
}
else  {
File.append("Starting 3D visualisation!",LOGPATH);
run("Visualization", "imleft=0.0 imtop=0.0 imwidth=["+sizeX+"] imheight=["+sizeY+"] renderer=[Normalized Gaussian] zrange=-600:30:600 dxforce=false magnification=12.6 dx=["+LATERAL_UNCERTAINTY+"] colorizez=false dz=70.0 threed=true dzforce=false");
    OUTPATH = TMPDIR + "/" + NAME + "_3D.ome.tif";
}



run("Enhance Contrast...", "saturated=0.01 process_all use"); // lets brightest 0.01% of pixels saturate
run("8-bit");

File.append("Exporting visualisaton as ome.tiff to " + OUTPATH, LOGPATH);


run("Bio-Formats Exporter", "save=["+OUTPATH+"] compression=LZW");


if(File.exists(OUTPATH) != 1 ) {
File.append("Failed to write " + OUTPATH, LOGPATH);
}


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