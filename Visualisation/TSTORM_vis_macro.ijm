ARGS=getArgument();

setBatchMode(true);
parts=split(ARGS, ":");

WORK=parts[0];
FNAME=parts[1];

if (parts.length == 9)  {
HOME=parts[6];
LATERAL_UNCERTAINTY=parts[7];
PBS_INDEX=parts[8];
}
else  {
HOME=parts[5];
LATERAL_UNCERTAINTY=parts[6];
PBS_INDEX=parts[7];
}

fullname=split(FNAME, ".");
NAME=fullname[0];

LOGPATH = HOME + "/Visualisation/tmp_" + PBS_INDEX + ".log";

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


FIRST=parts[2];
LAST=parts[3];
BLOCK=parts[4];

THREED=0;

if (parts.length == 8)  {
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
Ext.getSizeY(sizeY);

File.append("sizeX = " + sizeX, LOGPATH);
File.append("sizeY = " + sizeY, LOGPATH);

CSVPATH = WORK + "/" + NAME + "_reconstr.csv";

run("Camera setup", "isemgain=false pixelsize=126.0 offset=350 photons2adu=0.5");

File.append("Importing .csv file " + CSVPATH,LOGPATH);

run("Import results", "filepath=["+CSVPATH+"] fileformat=[CSV (comma separated)] livepreview=false rawimagestack= startingframe=1 append=false");

// path to config file
CONFIG= HOME + "/args";
File.append("Looking for config file " + CONFIG, LOGPATH);
filestring=File.openAsString(CONFIG);
rows=split(filestring);
NNODES=rows.length;
File.append("Processing on "  + NNODES + " nodes.", LOGPATH);

for (r=0; r<rows.length; r++)  {

// Calculate which section of the final image to visualise
STRIP_SIZEY= floor(sizeY/NNODES);
PBS_INDEX=parseInt(PBS_INDEX);
File.append("PBS_INDEX = " + PBS_INDEX, LOGPATH);
IMTOP=STRIP_SIZEY * (PBS_INDEX -1);
File.append("imtop = " + IMTOP, LOGPATH);


// N.B. if the image is not exactly divisble then some lines may be lost!
// Unfortunately imagej requires all images in a stack to be thw sam size!


File.append("Visualising " + STRIP_SIZEY + " lines from " + IMTOP , LOGPATH);


if(THREED==0)  {
File.append("Starting 2D visualisation!",LOGPATH);

run("Visualization", "imleft=0.0 imtop=["+IMTOP+"] imwidth=["+sizeX+"] imheight=["+STRIP_SIZEY+"] renderer=[Normalized Gaussian] dxforce=false magnification=12.6 dx=["+LATERAL_UNCERTAINTY+"] colorizez=false threed=false dzforce=false");
    OUTPATH = WORK + "/tmp_" + NAME + "_" + PBS_INDEX + "_2D.ome.tif";
}
else  {
File.append("Starting 3D visualisation!",LOGPATH);
run("Visualization", "imleft=0.0 imtop=["+IMTOP+"] imwidth=["+sizeX+"] imheight=["+STRIP_SIZEY+"] renderer=[Normalized Gaussian] zrange=-600:30:600 dxforce=false magnification=12.6 dx=["+LATERAL_UNCERTAINTY+"] colorizez=false dz=70.0 threed=true dzforce=false");
    OUTPATH = WORK + "/tmp_" + NAME + "_" + PBS_INDEX + "_3D.ome.tif";
}

File.append("Exporting visualisaton as ome.tiff to " + OUTPATH, LOGPATH);
run("Misc...", "divide=Infinity debug");

run("Bio-Formats Exporter", "save=["+OUTPATH+"] compression=Uncompressed");


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
File.append("...",LOGPATH);
File.close(logf);


close();
run("Quit");