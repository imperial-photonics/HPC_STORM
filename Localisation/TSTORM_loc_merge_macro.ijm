ARGS=getArgument();

setBatchMode(true);
parts=split(ARGS, ":");

WORK=parts[0];
TMPDIR=parts[1];

LOGPATH = WORK + "/Localisation/temp_localisation.log";

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
CONFIG= WORK + "/args";

File.append("Looking for config file " + CONFIG, LOGPATH);

filestring=File.openAsString(CONFIG);
rows=split(filestring);

SAVEPROTOCOL = "false";


for (r=0; r<rows.length; r++)  {

  parts=split(rows[r], ":");
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
    PROTPATH = TMPDIR + "/tmp_" + NAME + "-protocol.txt";
    File.append("Renaming protocol file  " + PROTPATH, LOGPATH);
    err=File.rename(PROTPATH, TMPDIR + "/" + NAME + "-protocol.txt");

    INPATH = TMPDIR + "tmp_" + NAME + ".csv";

    if (NEXTBLOCK == "1")  {
      // Only one block for this file so no merging required
      err=File.rename(INPATH, TMPDIR + "/" + NAME + ".csv");
    }
    else  {
      File.append("Importing file  " + INPATH, LOGPATH);
      run("Import results", "filepath=["+INPATH+"] fileformat=[CSV (comma separated)] livepreview=true rawimagestack= startingframe=1 append=false");

    }
  }
  else {   //BLOCK > 1
    INPATH = TMPDIR + "/tmp_" + NAME + "_" + BLOCK + ".csv";
    File.append("Importing file  " + INPATH, LOGPATH);
    run("Import results", "filepath=["+INPATH+"] fileformat=[CSV (comma separated)] livepreview=true rawimagestack= startingframe=["+FIRST+"] append=true");

    if (NEXTBLOCK == "1")  {
      OUTPATH = TMPDIR + "/" + NAME + ".csv";
      File.append("Exporting to file  " + OUTPATH, LOGPATH);
      run("Export results", "floatprecision=2 filepath=["+OUTPATH+"] fileformat=[CSV (comma separated)] id=true frame=true sigma=true bkgstd=true intensity=true saveprotocol=["+SAVEPROTOCOL+"] offset=true uncertainty=true y=true x=true");

    }

  }

}

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
if (hour<10) {TimeString = "0";} else {TimeString = "";}
TimeString = TimeString+hour+":";
if (minute<10) {TimeString = TimeString+"0";}
TimeString = TimeString+minute+":";
if (second<10) {TimeString = TimeString+"0";}
TimeString = TimeString+second;


File.append("Merge complete at  " + TimeString, LOGPATH);




FINAL_LOGPATH = WORK + "/Localisation/" + NAME + "_loc.log";

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

