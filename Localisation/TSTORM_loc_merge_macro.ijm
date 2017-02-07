HOME=getArgument();

setBatchMode(true);

LOGPATH = HOME + "/Localisation/temp_localisation.log";

if (File.exists(LOGPATH))  {
File.append("Adding Merge log!", LOGPATH);
}
else  {
logf = File.open(LOGPATH);
File.append("Failed to find Localisation log file!",LOGPATH);
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

SAVEPROTOCOL = "false";

for (r=0; r<rows.length; r++)  {

  parts=split(rows[r], ":");
  WORK=parts[0];
  FNAME=parts[1];
  FIRST=parts[2];
  BLOCK=parts[4];
  FULLNAME=split(FNAME, ".");
  NAME=FULLNAME[0];


  if (r < (rows.length - 1))  {
    parts=split(rows[r +1], ":");
    NEXTBLOCK=parts[4];
  }
  else  {
    NEXTBLOCK = "1";
  }

  if (BLOCK == "1")  {

    // rename protocol file
    PROTPATH = WORK + "/tmp_" + NAME + "-protocol.txt";
    File.append("Renaming protocol file  " + PROTPATH, LOGPATH);
    err=File.rename(PROTPATH, WORK + "/" + NAME + "-protocol.txt");

    INPATH = WORK + "/tmp_" + NAME + ".csv";

    if (NEXTBLOCK == "1")  {
      // Only one block for this file so no merging required
      err=File.rename(INPATH, WORK + "/" + NAME + ".csv");
    }
    else  {
      File.append("Importing file  " + INPATH, LOGPATH);
      run("Import results", "filepath=["+INPATH+"] fileformat=[CSV (comma separated)] livepreview=true rawimagestack= startingframe=1 append=false");
      File.append("Deleting file  " + INPATH, LOGPATH);
      err=File.delete(INPATH);
    }
  }
  else {   //BLOCK > 1
    INPATH = WORK + "/tmp_" + NAME + "_" + BLOCK + ".csv";
    File.append("Importing file  " + INPATH, LOGPATH);
    run("Import results", "filepath=["+INPATH+"] fileformat=[CSV (comma separated)] livepreview=true rawimagestack= startingframe=["+FIRST+"] append=true");
    err=File.delete(INPATH);
    File.append("Deleting file  " + INPATH, LOGPATH);

    if (NEXTBLOCK == "1")  {
      OUTPATH = WORK + "/" + NAME + ".csv";
      File.append("Exporting to file  " + OUTPATH, LOGPATH);
      run("Export results", "filepath=["+OUTPATH+"] fileformat=[CSV (comma separated)] id=true frame=true sigma=true bkgstd=true intensity=true saveprotocol=["+SAVEPROTOCOL+"] offset=true uncertainty=true y=true x=true");

    }

  }

}


//Post_Processing!

POSTPATH = WORK + "/" + NAME + "_reconstr.csv";

// Drift correction

DRIFTPATH = WORK + "/" + NAME + "_drift.tiff";

File.append("Performing drift correction.", LOGPATH);
run("Show results table", "action=drift magnification=12.0 method=[Cross correlation] save=false steps=6 showcorrelations=false");
selectWindow("Drift");
File.append("Saving drift graph to " + DRIFTPATH, LOGPATH);
saveAs("Tiff", DRIFTPATH);
close();


File.append("Saving post-processed localisations as " + POSTPATH, LOGPATH);
run("Export results", "filepath=["+POSTPATH+"] fileformat=[CSV (comma separated)] id=true frame=true sigma=true bkgstd=true intensity=true saveprotocol=["+SAVEPROTOCOL+"] offset=true uncertainty=true y=true x=true");


FINAL_LOGPATH = HOME + "/Localisation/" + NAME + ".log";

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


File.append("exiting loc_merge_macro at " + TimeString,FINAL_LOGPATH);

close();

run("Quit");

