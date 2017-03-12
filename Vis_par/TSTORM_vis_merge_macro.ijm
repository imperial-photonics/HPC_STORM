ARGS=getArgument();

setBatchMode(true);
parts=split(ARGS, ":");

HOME=parts[0];
TMPDIR=parts[1];

LOGPATH = HOME + "/Visualisation/temp_visualisation.log";

if (File.exists(LOGPATH))  {
File.append("Adding Merge log!", LOGPATH);
}
else  {
logf = File.open(LOGPATH);
File.append("Failed to find Visualisation log file!",LOGPATH);
}

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
if (hour<10) {TimeString = "0";} else {TimeString = "";}
TimeString = TimeString+hour+":";
if (minute<10) {TimeString = TimeString+"0";}
TimeString = TimeString+minute+":";
if (second<10) {TimeString = TimeString+"0";}
TimeString = TimeString+second;

File.append("Starting Merge at " + TimeString, LOGPATH);

// path to config file
CONFIG= HOME + "/args";

File.append("Looking for config file " + CONFIG, LOGPATH);

filestring=File.openAsString(CONFIG);
rows=split(filestring);

NNODES=4;

File.append("Using " + NNODES + " jobs.", LOGPATH);

parts=split(rows[1], ":");
WORK=parts[0];
FNAME=parts[1];
FULLNAME=split(FNAME, ".");
NAME=FULLNAME[0];


FINAL_LOGPATH = HOME + "/Visualisation/" + NAME + ".log";

File.append("renaming log file to " + FINAL_LOGPATH,LOGPATH);


if (File.exists(FINAL_LOGPATH))  {
File.delete(FINAL_LOGPATH);
}

File.rename(LOGPATH, FINAL_LOGPATH);
LOGPATH = FINAL_LOGPATH;


File.append("Nargs =  " + parts.length, LOGPATH);

if (parts.length == 6)  {
CALIB=parts[5];
CALPATH= WORK + "/" + CALIB;
File.append("Looking for calibration file " + CALPATH, LOGPATH);
THREED=File.exists(CALPATH); //Returns "1" (true) if the specified file exists.
}

if(THREED==0)  {
  EXT_STRING="_2D.ome.tif";
}
else  {
  EXT_STRING="_3D.ome.tif";
}


// load output from first 2 nodes to prime pump

NODE=1;

INPATH = WORK + "/tmp_" + NAME + "_" + NODE  + EXT_STRING;
File.append("Loading file  " + INPATH, LOGPATH);
run("Bio-Formats Importer", "open=["+INPATH+"] color_mode=Default rois_import=[ROI manager] view=[Standard ImageJ] stack_order=Default");
File.append("Deleting file  " + INPATH, LOGPATH);
err=File.delete(INPATH);
// now find name of imported data
INPATH = "tmp_" + NAME + "_" + NODE  + EXT_STRING;


NODE=2;

INPATH2 = WORK + "/tmp_" + NAME + "_" + NODE  + EXT_STRING;
File.append("Loading file  " + INPATH2, LOGPATH);
run("Bio-Formats Importer", "open=["+INPATH2+"] color_mode=Default rois_import=[ROI manager] view=[Standard ImageJ] stack_order=Default");
File.append("Deleting file  " + INPATH2, LOGPATH);
err=File.delete(INPATH2);
INPATH2 = "tmp_" + NAME + "_" + NODE  + EXT_STRING;

File.append("Combining stacks!" , LOGPATH);
run("Combine...", "stack1=["+INPATH+"] stack2=["+INPATH2+"] combine");



for (n=2; n<NNODES; n++)  {

NODE=n+1;

INPATH = WORK + "/tmp_" + NAME + "_" + NODE  + EXT_STRING;
File.append("Loading file  " + INPATH, LOGPATH);
run("Bio-Formats Importer", "open=["+INPATH+"] color_mode=Default rois_import=[ROI manager] view=[Standard ImageJ] stack_order=Default");
File.append("Deleting file  " + INPATH, LOGPATH);
err=File.delete(INPATH);
INPATH = "tmp_" + NAME + "_" + NODE  + EXT_STRING;

File.append("" , LOGPATH);
run("Combine...", "stack1=[Combined Stacks] stack2=["+INPATH+"] combine");

}


OUTPATH = TMPDIR + "/" + NAME + EXT_STRING;
File.append("Saving merged image to " + OUTPATH, LOGPATH);


//DEBUG!!
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
if (hour<10) {TimeString = "0";} else {TimeString = "";}
TimeString = TimeString+hour+":";
if (minute<10) {TimeString = TimeString+"0";}
TimeString = TimeString+minute+":";
if (second<10) {TimeString = TimeString+"0";}
TimeString = TimeString+second;
File.append("Complete save at  " + TimeString,LOGPATH);


run("Bio-Formats Exporter", "save=["+OUTPATH+"] compression=LZW");


close();



getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
if (hour<10) {TimeString = "0";} else {TimeString = "";}
TimeString = TimeString+hour+":";
if (minute<10) {TimeString = TimeString+"0";}
TimeString = TimeString+minute+":";
if (second<10) {TimeString = TimeString+"0";}
TimeString = TimeString+second;


File.append("exiting vis_merge_macro at " + TimeString,LOGPATH);


run("Quit");

