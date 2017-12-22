ARGS=getArgument();

setBatchMode(true);
parts=split(ARGS, ":");

INPATH=parts[0];
FNAME=parts[1];

THREED=0;

if (parts.length == 8)  {
  WORK=parts[2];
  NJOBS=parts[3];
  TMPDIR=parts[4];
  JOBNO=parts[5];
  LATERAL_RES=parts[6];
  POST=parts[7];
}
else  {
  WORK=parts[3];
  NJOBS=parts[4];
  TMPDIR=parts[5];
  JOBNO=parts[6];
  LATERAL_RES=parts[7];
  POST=parts[8];
  THREED=1;
}

LOGPATH = WORK + "/" + JOBNO + "/temp_localisation.log";

if (File.exists(LOGPATH))  {
  File.append("Adding Merge log!", LOGPATH);
}
else  {
  logf = File.open(LOGPATH);
  File.append("Failed to find Localisation log file!",LOGPATH);
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
      run("Import results", "filepath=["+INPATH+"] detectmeasurementprotocol=true fileformat=[CSV (comma separated)] livepreview=false rawimagestack= startingframe=1 append=false");

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
      CSVPATH = TMPDIR + "/" + NAME + ".csv";
      File.append("Exporting to file  " + CSVPATH, LOGPATH);
      run("Export results", "floatprecision=2 filepath=["+CSVPATH+"] fileformat=[CSV (comma separated)] id=true frame=true sigma=true bkgstd=true intensity=true saveprotocol=["+SAVEPROTOCOL+"] offset=true uncertainty=true y=true x=true");

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


//************************************  End of MERGE ************************


if (LATERAL_RES != "0")  {
  File.append("Lateral_res =  " + LATERAL_RES, LOGPATH);

  FILEPATH=TMPDIR + "/" + FNAME;
  ERR=File.exists(FILEPATH);

  if(ERR!=1)  {
    File.append("Unable to find raw data file! Aborting Visualisation!",LOGPATH)
  }
  
  INPATH = TMPDIR + "/" + NAME + ".csv";
  if (parseInt(File.length(INPATH)) < 100)  {
       File.append(".csv Localisations file too small! Aborting Visualisation!",LOGPATH)
  }
 
  
  if(ERR==1  &&  parseInt(File.length(INPATH)) > 100)  {
  
    // .csv must be imported as the merge simply renames
    if (NJOBS == 1)  {
      File.append("Importing .csv file  " + INPATH, LOGPATH);
      run("Import results", "filepath=["+INPATH+"] detectmeasurementprotocol=true fileformat=[CSV (comma separated)] livepreview=false rawimagestack= startingframe=1 append=false");
      
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


    // Look for Camera Name
    field="Camera Name";
    CAMERANAME="";
    Ext.getMetadataValue(field,CAMERANAME);

    if(indexOf(CAMERANAME, "Andor") > -1)  {
      field="GainMultiplier";
      GAINEM="";
      Ext.getMetadataValue(field,GAINEM);
      File.append("gain = " + GAINEM ,LOGPATH);

      File.append("Using Andor DU-897 values for Camera Setup! With Gainem " + GAINEM, LOGPATH);
      run("Camera setup", "offset=99.74 quantumefficiency=1.0 isemgain=true photons2adu=5.32 gainem=["+GAINEM+"] pixelsize=["+PIXELWIDTH+"]");
    }
    else {
      // Determine which Camera is in use & setup appropriately
      COMMAND= "grep Prime95B " + FILEPATH;
      if(indexOf(exec(COMMAND), "matches") > -1)  {
        //Prime95B Camera detected
        File.append("Using Prime95B values for Camera Setup!", LOGPATH);
        run("Camera setup", "readoutnoise=1.8 offset=170.0 quantumefficiency=0.9 isemgain=false photons2adu=2.44 pixelsize=["+PIXELWIDTH+"]");
      }
      else  {
        File.append(" using Orca values for Camera Setup!", LOGPATH);
        run("Camera setup", "readoutnoise=1.5 offset=350.0 quantumefficiency=0.9 isemgain=false photons2adu=0.5 pixelsize=["+PIXELWIDTH+"]");
      }
    }

    Ext.close();

    // find required magnification to get 25nm pixels
    MAGNIFICATION = toString(parseFloat(PIXELWIDTH)/25);
    File.append("Calculated magnification  = " + MAGNIFICATION ,LOGPATH);

    // Post_processing
    if(indexOf(POST, "SIGMA") > -1)  {

      File.append("Performing sigma filtering.", LOGPATH);
      PYPATH = TMPDIR + "/csv_sigma_mode.py";
      
      COMMAND = "python " + PYPATH + " -i " + INPATH;
      
      File.append("Command = " + COMMAND, LOGPATH);
      MODE = exec(COMMAND);
      
      if (MODE == -1)  {
        File.append("ERROR! Failed to find Mode of csv file!! ", LOGPATH);
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
      File.append("Drift correction done!", LOGPATH);

      if(nImages > 0)  {
        selectWindow("Drift");
        DRIFTPATH = TMPDIR + "/" + NAME + "_drift.tiff";
        File.append("Saving drift graph to " + DRIFTPATH, LOGPATH);
        saveAs("Tiff", DRIFTPATH);
        close();
      }
      else
        File.append("Warning! No drift results to save! ", LOGPATH);
    }


    POSTNAME = NAME + "_" + POST;
    POSTPATH = TMPDIR + "/" + POSTNAME + ".csv";

    File.append("Saving post-processed localisations as " + POSTPATH, LOGPATH);
    run("Export results", "filepath=["+POSTPATH+"] fileformat=[CSV (comma separated)] id=true frame=true sigma=true bkgstd=true intensity=true saveprotocol=true offset=true uncertainty=true y=true x=true");

    if(THREED==0)  {
      File.append("Starting 2D visualisation!",LOGPATH);
      run("Visualization", "imleft=0.0 imtop=0.0 imwidth=["+sizeX+"] imheight=["+sizeY+"] renderer=[Normalized Gaussian] magnification=["+MAGNIFICATION+"] dx=["+LATERAL_RES+"] colorizez=false threed=false dzforce=false");
      OUTPATH = TMPDIR + "/" + POSTNAME + "_2D.ome.tiff";
    }
    else  {
      File.append("Starting 3D visualisation!",LOGPATH);
      run("Visualization", "imleft=0.0 imtop=0.0 imwidth=["+sizeX+"] imheight=["+sizeY+"] renderer=[Normalized Gaussian] zrange=-600:30:600 dxforce=false magnification=["+MAGNIFICATION+"] dx=["+LATERAL_RES+"] colorizez=false dz=70.0 threed=true dzforce=false");
      OUTPATH = TMPDIR + "/" + POSTNAME + "_3D.ome.tiff";
    }

    run("Enhance Contrast...", "saturated=0.01 process_all use"); // lets brightest 0.01% of pixels saturate
    run("8-bit");

    File.append("Exporting visualisation as ome.tiff to " + OUTPATH, LOGPATH);
    run("Bio-Formats Exporter", "save=["+OUTPATH+"] compression=LZW");

    if(File.exists(OUTPATH) != 1 ) {
      File.append("Failed to write " + OUTPATH, LOGPATH);
    }
    

  }
}  //End of Visualisation


FINAL_LOGPATH = WORK + "/" + JOBNO + "/" + NAME + "_loc.log";

File.append("renaming log file to " + FINAL_LOGPATH,LOGPATH);

File.append("closing " + toString(nImages) + " images." ,LOGPATH);
while (nImages>0) { 
  selectImage(nImages);
  close(); 
}
 

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


File.append("exiting loc_merge_macro at " + TimeString, FINAL_LOGPATH);

//File.close(logf);

run("Quit");

