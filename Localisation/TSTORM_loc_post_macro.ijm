ARGS=getArgument();
print(ARGS);
setBatchMode(true);
parts=split(ARGS, ":");

WORK=parts[0];
FNAME=parts[1];
JOBNO=parts[2];
NJOBS=parts[3];
BLOCK=parts[4];
THREED=parts[5];
CAMERA=parts[6];
CALIB=parts[7];
PIXELSIZE=parts[8];
POST=parts[9];

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

File.append("Starting Import Result at " + getTimeString(), LOGPATH);

sizeX=1200;
sizeY=1200;

SAVEPROTOCOL = "true";

INPATH = WORK + "/" + JOBNO + "/" + NAME + ".csv";

File.append("Importing file  " + INPATH, LOGPATH);
run("Import results", "filepath=["+INPATH+"] detectmeasurementprotocol=true fileformat=[CSV (comma separated)] livepreview=false rawimagestack= startingframe=1 append=false");

File.append("Import complete at  " + getTimeString(), LOGPATH);


//************************************  End of Import ************************


if (LATERAL_RES != "0")  {
    File.append("Lateral_res =  " + LATERAL_RES, LOGPATH);

    FILEPATH=TMPDIR + "/" + FNAME;
    ERR=File.exists(FILEPATH);

	File.append("Begin PostPorcessing at " + detTimeString(), LOGPATH);

    if (CAMERA=="Prime95B")  {
        //Prime95B Camera detected
        File.append("Using Prime95B values for Camera Setup!", LOGPATH);
        run("Camera setup", "readoutnoise=1.8 offset=170.0 quantumefficiency=0.9 isemgain=false photons2adu=2.44 pixelsize=["+PIXELWIDTH+"]");
    } else  {
        // Assume it must be an Andor
        File.append("Using Orca values for Camera Setup!", LOGPATH);
        run("Camera setup", "readoutnoise=1.5 offset=350.0 quantumefficiency=0.9 isemgain=false photons2adu=0.5 pixelsize=["+PIXELWIDTH+"]");
    }

    // find required magnification to get 25nm pixels
    MAGNIFICATION = toString(parseFloat(PIXELWIDTH)/25);
    File.append("Calculated magnification  = " + MAGNIFICATION ,LOGPATH);

    // Post_processing
    if(indexOf(POST, "SIGMA") > -1)  {
        // Sigma processing will not work yet as needs python
        File.append("Performing sigma filtering.", LOGPATH);
        PYPATH = TMPDIR + "/csv_sigma_mode.py";
      
        COMMAND = "python " + PYPATH + " -i " + CSVPATH;
        MODE = exec(COMMAND);
      
        if (MODE == -1)  {
            File.append("ERROR! Failed to find Mode of csv file!! ", LOGPATH);
        } else {
            File.append("Mode of sigma distribution =  " + MODE, LOGPATH);
            MODEF = parseFloat(MODE);
            RANGE = MODEF * 0.2;
            UPPER_LIM = toString(MODEF + RANGE,2);
            LOWER_LIM = toString(MODEF - RANGE,2);
            if(THREED==0)  {
                FORMULA = "[sigma < " + UPPER_LIM + " & sigma > " + LOWER_LIM + " ]";
            } else  {
                FORMULA = "[sigma1 < " + UPPER_LIM + " & sigma1 > " + LOWER_LIM + " ]";
            }

            File.append("Filtering with " + FORMULA, LOGPATH);
            run("Show results table", "action=filter formula=["+FORMULA+"]");

            File.append("Finished Filtering at " + getTimeStrin(), LOGPATH);
		}
    } else {
		FORMULA = "[(intensity > 1)]";
        File.append("Filtering with " + FORMULA, LOGPATH);
        run("Show results table", "action=filter formula=["+FORMULA+"]");

		File.append("Finished Filtering at " + getTimeString(), LOGPATH);

	}

    if(indexOf(POST, "DRIFT") > -1)  {
        File.append("Performing drift correction.", LOGPATH);
        run("Show results table", "action=drift magnification=["+MAGNIFICATION+"] method=[Cross correlation] ccsmoothingbandwidth=1.0 save=false steps=6 showcorrelations=false");
        File.append("Drift correction done!", LOGPATH);
        selectWindow("Drift");
        DRIFTPATH = WORK + "/" + JOBNO  + "/" + NAME + "_drift.tiff";
        File.append("Saving drift graph to " + DRIFTPATH, LOGPATH);
        saveAs("Tiff", DRIFTPATH);
        close();

		File.append("Finished Drift Correction at " + geetTimeString(), LOGPATH);
    }

    POSTNAME = NAME + "_final";
    POSTPATH = WORK + "/" + JOBNO  + "/" + POSTNAME + ".csv";

    File.append("Saving post-processed localisations as " + POSTPATH, LOGPATH);
    run("Export results", "filepath=["+POSTPATH+"] fileformat=[CSV (comma separated)] id=true frame=true sigma=true bkgstd=true intensity=true saveprotocol=true offset=true uncertainty=true y=true x=true");

    if(THREED==0) {
        File.append("Starting 2D visualisation!",LOGPATH);
	    run("Visualization", "imleft=0.0 imtop=0.0 imwidth=["+sizeX+"] imheight=["+sizeY+"] renderer=[Averaged shifted histograms] magnification=["+MAGNIFICATION+"] colorize=false threed=false shifts=2");
        OUTPATH = WORK + "/" + JOBNO  + "/" + POSTNAME + "_2D.ome.tiff";
    }
    else  {
        File.append("Starting 3D visualisation!",LOGPATH);
	    run("Visualization", "imleft=0.0 imtop=0.0 imwidth=["+sizeX+"] imheight=["+sizeY+"] renderer=[Averaged shifted histograms] zrange=-600:60:600 pickedlut=[16 colors] magnification=["+MAGNIFICATION+"] colorize=true threed=true shifts=2 zshifts=2");
        OUTPATH = WORK + "/" + JOBNO  + "/" + POSTNAME + "_3D.ome.tiff";
    }

    run("Enhance Contrast...", "saturated=0.35 process_all use"); // lets brightest 0.01% of pixels saturate
    run("16-bit");

	File.append("Finished Visualization at " + getTimeString(), LOGPATH);

    File.append("Exporting visualisation as ome.tiff to " + OUTPATH, LOGPATH);
    run("Bio-Formats Exporter", "save=["+OUTPATH+"] compression=LZW");

    if(File.exists(OUTPATH) != 1 ) {
      File.append("Failed to write " + OUTPATH, LOGPATH);
    }

  }
}  //End of Visualisation

File.append("closing " + toString(nImages) + " images." ,LOGPATH);

while (nImages>0) { 
    selectImage(nImages);
    close();
}

File.append("exiting loc_post_macro at " + getTimeString(), LOGPATH);

File.close(logf);

run("Quit");

function getTimeString() {
    getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
    if (hour<10) {TimeString = "0";} else {TimeString = "";}
    TimeString = TimeString+hour+":";
    if (minute<10) {TimeString = TimeString+"0";}
    TimeString = TimeString+minute+":";
    if (second<10) {TimeString = TimeString+"0";}
    TimeString = TimeString+second;
    return TimeString;
}

