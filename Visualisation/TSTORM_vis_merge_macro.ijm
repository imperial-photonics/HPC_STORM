HOME=getArgument();

setBatchMode(true);

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

NNODES=rows.length;

File.append("Using " + NNODES + " nodes.", LOGPATH);

parts=split(rows[1], ":");
WORK=parts[0];
FNAME=parts[1];
FULLNAME=split(FNAME, ".");
NAME=FULLNAME[0];

//TBD 3D loop

for (n=0; n<NNODES; n++)  {

NODE=n+1;

INPATH = WORK + "/tmp_" + NAME + "_" + NODE  + "_2D.ome.tif";
File.append("Loading file  " + INPATH, LOGPATH);

run("Bio-Formats Importer", "open=["+INPATH+"] color_mode=Default rois_import=[ROI manager] view=[Standard ImageJ] stack_order=Default");


File.append("Deleting file  " + INPATH, LOGPATH);
err=File.delete(INPATH);


}

File.append("Converting images to Stack" , LOGPATH);
run("Images to Stack", "name=Stack title=[] use");
File.append("Making Montage" , LOGPATH);
run("Make Montage...", "columns=1 rows=["+NNODES+"] scale=1");
selectWindow("Montage");

OUTPATH = WORK + "/" + NAME + "_2D.ome.tif";
File.append("Saving merged image to " + OUTPATH, LOGPATH);
run("Bio-Formats Exporter", "save=["+OUTPATH+"] compression=Uncompressed");

// close all windows
while (nImages>0) {
selectImage(nImages);
close();
}



FINAL_LOGPATH = HOME + "/Visualisation/" + NAME + ".log";

File.append("renaming log file to " + FINAL_LOGPATH,LOGPATH);


if (File.exists(FINAL_LOGPATH))  {
File.delete(FINAL_LOGPATH);
}

File.rename(LOGPATH, FINAL_LOGPATH);


getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
if (hour<10) {TimeString = "0";} else {TimeString = "";}
TimeString = TimeString+hour+":";
if (minute<10) {TimeString = TimeString+"0";}
TimeString = TimeString+minute+":";
if (second<10) {TimeString = TimeString+"0";}
TimeString = TimeString+second;


File.append("exiting vis_merge_macro at " + TimeString,FINAL_LOGPATH);

close();

run("Quit");

