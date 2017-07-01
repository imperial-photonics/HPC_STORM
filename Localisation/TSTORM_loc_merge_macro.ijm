ARGS=getArgument();

setBatchMode(true);
parts=split(ARGS, ":");

WORK=parts[0];
FNAME=parts[1];

LOGPATH = WORK + "/Localisation/temp_localisation.log";

if (File.exists(LOGPATH))  {
File.append("Adding Merge log!", LOGPATH);
}
else  {
logf = File.open(LOGPATH);
File.append("Failed to find Localisation log file!",LOGPATH);
}


if (parts.length == 4)  {
NJOBS=parts[2];
TMPDIR=parts[3];

}
else  {
NJOBS=parts[3];
TMPDIR=parts[4];
}

fullname=split(FNAME, ".");
NAME=fullname[0];



getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
if (hour<10) {TimeString = "0";} else {TimeString = "";}
TimeString = TimeString+hour+":";
if (minute<10) {TimeString = TimeString+"0";}
TimeString = TimeString+minute+":";
if (second<10) {TimeString = TimeString+"0";}
TimeString = TimeString+second;

File.append("Starting Merge at " + TimeString, LOGPATH);



SAVEPROTOCOL = "false";


for (j=0; j<NJOBS; j++)  {

  if (j == 0)  {

    // rename protocol file
    PROTPATH = TMPDIR + "/tmp_" + NAME + "-protocol.txt";
    File.append("Renaming protocol file  " + PROTPATH, LOGPATH);
    err=File.rename(PROTPATH, TMPDIR + "/" + NAME + "-protocol.txt");

    INPATH = TMPDIR + "/tmp_" + NAME + ".csv";

    if (NJOBS == 1)  {
      // Only one block for this file so no merging required
      err=File.rename(INPATH, TMPDIR + "/" + NAME + ".csv");
    }
    else  {
      File.append("Importing file  " + INPATH, LOGPATH);
      run("Import results", "filepath=["+INPATH+"] fileformat=[CSV (comma separated)] livepreview=false rawimagestack= startingframe=1 append=false");

    }
  }
  else {   //j > 1

    JOB = toString(j + 1);

    // Get first frame from config file
    CONFPATH = TMPDIR + "/tmp_conf_" + NAME + "_" + JOB + ".txt";
    //File.append("Reading config from " + CONFPATH, LOGPATH);
    filestring=File.openAsString(CONFPATH);
    parts=split(filestring, ":");
    FIRST=parts[0];
    File.append("First frame = " + FIRST, LOGPATH);

    INPATH = TMPDIR + "/tmp_" + NAME + "_" + JOB + ".csv";
    File.append("Importing file  " + INPATH, LOGPATH);
    run("Import results", "filepath=["+INPATH+"] fileformat=[CSV (comma separated)] livepreview=false rawimagestack= startingframe=["+FIRST+"] append=true");

    if (j == NJOBS -1)  {
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


run("Quit");

