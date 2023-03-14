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
POST=parts[8];
LATERAL_RES=parts[9];

fullname=split(FNAME, ".");
NAME=fullname[0];

CONF=File.openAsString(WORK+"/"+JOBNO+"/tmp_conf_"+NAME+"_1.txt");
parts=split(CONF,":");
PIXELWIDTH=parts[2];
sizeX=parts[3];
sizeY=parts[4];

LOGPATH = WORK + "/" + JOBNO + "/temp_localisation.log";

if (File.exists(LOGPATH))  {
    File.append("Adding Merge log!", LOGPATH);
}
else  {
    logf = File.open(LOGPATH);
    File.append("Failed to find Localisation log file!",LOGPATH);
}

File.append("Configuration: Pixelwidth="+PIXELWIDTH+", sizeX="+sizeX+", sizeY="+sizeY, LOGPATH);
File.append("Starting Import Result at " + getTimeString(), LOGPATH);

//sizeX=1200;
//sizeY=1200;

SAVEPROTOCOL = "true";

//INPATH = WORK + "/" + JOBNO + "/" + NAME + ".csv";
INPATH = NAME + ".csv";

File.append("Importing file  " + INPATH, LOGPATH);
run("Import results", "filepath=["+INPATH+"] detectmeasurementprotocol=true fileformat=[CSV (comma separated)] livepreview=false rawimagestack= startingframe=1 append=false");

File.append("Import complete at  " + getTimeString(), LOGPATH);


//************************************  End of Import ************************


if (LATERAL_RES != "0")  {
    File.append("Lateral_res =  " + LATERAL_RES, LOGPATH);

	File.append("Begin PostProcessing at " + getTimeString(), LOGPATH);

    // Determine which Camera is in use & setup appropriately
    // Can't find Camera Name with Bioformats library so it has already been found with commandline tool as CAMERA
    if (CAMERA=="Prime95B")  {
        File.append("Using Prime95B values for Camera Setup!", LOGPATH);
        run("Camera setup", "readoutnoise=1.8 offset=170.0 quantumefficiency=0.9 isemgain=false photons2adu=2.44 pixelsize=["+PIXELWIDTH+"]");
    } else  if (CAMERA=="Andor_iXon_Ultra"){
        File.append("Using Andor iXon Ultra values for Camera Setup!", LOGPATH);
        run("Camera setup", "readoutnoise=0.0 offset=16.0 quantumefficiency=1.0 isemgain=true photons2adu=5.1 gainem=200.0 pixelsize=["+PIXELWIDTH+"]");
    } else  if (CAMERA=="pco_camera"){
        File.append("Using pco_camera values for Camera Setup!", LOGPATH);
        run("Camera setup", "readoutnoise=2.1 offset=126 quantumefficiency=0.80 isemgain=false photons2adu=1 pixelsize=["+PIXELWIDTH+"]");
    } else  if (CAMERA=="Andor_sCMOS_Camera"){
        File.append("Using Andor_sCMOS_Camera values for Camera Setup!", LOGPATH);
        run("Camera setup", "readoutnoise=1.8 offset=170.0 quantumefficiency=0.9 isemgain=false photons2adu=2.44 pixelsize=["+PIXELWIDTH+"]");
    } else  if (CAMERA=="Grasshopper3_GS3-U3-23S6M"){
        File.append("Using Grasshopper3_GS3-U3-23S6M values for Camera Setup!", LOGPATH);
        run("Camera setup", "readoutnoise=6.1 offset=9 quantumefficiency=0.76 isemgain=false photons2adu=1 pixelsize=["+PIXELWIDTH+"]");
    } else {
        // Assume it must be an Orca flash 4
    //File.append("Using Orca values for Camera Setup!", LOGPATH);
	
	//File.append("Using HamamatsuHam_DCAM values for Camera Setup!", LOGPATH);
    //if (isNaN(PIXELWIDTH)) PIXELWIDTH=64.5;
    //run("Camera setup", "readoutnoise=1.5 offset=20.0 quantumefficiency=0.82 isemgain=false photons2adu=0.458 pixelsize=["+PIXELWIDTH+"]");
	
    //if (isNaN(PIXELWIDTH)) PIXELWIDTH=65;
    //run("Camera setup", "readoutnoise=1.5 offset=350.0 quantumefficiency=0.9 isemgain=false photons2adu=0.5 pixelsize=["+PIXELWIDTH+"]");
    //Nope Assume is an Prime95B
	File.append("Using Prime95B values for Camera Setup!", LOGPATH);
    if (isNaN(PIXELWIDTH)) PIXELWIDTH=106; 
    //      run("Camera setup", "readoutnoise=0.9 offset=200 quantumefficiency=0.64 isemgain=false photons2adu=0.45 pixelsize=["+PIXELWIDTH+"]");
    //   // run("Camera setup", "readoutnoise=1.5 offset=200 quantumefficiency=0.70 isemgain=false photons2adu=0.20 pixelsize=["+PIXELWIDTH+"]");​
	run("Camera setup", "readoutnoise=1.8 offset=170.0 quantumefficiency=0.9 isemgain=false photons2adu=2.44 pixelsize=["+PIXELWIDTH+"]");
    }

    // find required magnification to get 25nm pixels
    MAGNIFICATION = toString(parseFloat(PIXELWIDTH)/LATERAL_RES);
    File.append("Calculated magnification  = " + MAGNIFICATION ,LOGPATH);

    // Post_processing
    if(indexOf(POST, "SIGMA")>-1 && THREED==0)  {
        // Sigma processing to select the interquartile range of sigma values, for 2D data only
        // A simple example of what can be calculated using sort and awk

        File.append("Performing sigma filtering.", LOGPATH);

        // Awk selects every 100th localisation and prints out the sigma value, which are then sorted into order, finally the 2nd awk selects the n/10, n/2 and 3n/4 values
        // On most datasets this is a good approximation to the 10th 50th and 75th centiles of the distribution, but a lot faster than processing the whole dataset.
        COMMAND = "awk 'BEGIN{FS=\",\"}{if (NR%100 == 0) print $5}' " +INPATH + " | sort -k1n,1 | awk '{ a[i++]=$1; } END { print a[int(i/10)] \":\" a[int(i/2)] \":\" a[int(3*i/4)] \":\";}'";
        File.append("Running external command: " + COMMAND, LOGPATH);

        CENTILES = exec("sh", "-c", COMMAND);
        parts=split(CENTILES,":");
        LC=parts[0];
        UC=parts[2];

        File.append("Interquartile range of sigma distribution =  " + LC + " to " + UC, LOGPATH);
        FORMULA = "( sigma > " + LC + " & sigma < " + UC + " )";
        File.append("Filtering with " + FORMULA, LOGPATH);
        run("Show results table", "action=filter formula=["+FORMULA+"]");
        File.append("Finished Filtering at " + getTimeString(), LOGPATH)

    } else {
        if (THREED==0) {
		    FORMULA = "(intensity > 1)";
        } else {
            FORMULA = "(intensity > 1) & (uncertainty_z < 500)";
        }
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

		File.append("Finished Drift Correction at " + getTimeString(), LOGPATH);
    }

    POSTNAME = NAME + "_final";
    POSTPATH = WORK + "/" + JOBNO  + "/" + POSTNAME + ".csv";

    File.append("Saving post-processed localisations as " + POSTPATH, LOGPATH);
    if(THREED==0) {
        run("Export results", "floatprecision=2 filepath=["+POSTPATH+"] fileformat=[CSV (comma separated)] sigma=true intensity=true chi2=true offset=true saveprotocol=true x=true y=true bkgstd=true id=true uncertainty_xy=true frame=true");
    } else {
        run("Export results", "floatprecision=2 filepath=["+POSTPATH+"] fileformat=[CSV (comma separated)] chi2=true offset=true saveprotocol=true bkgstd=true uncertainty_xy=true intensity=true x=true sigma2=true uncertainty_z=true y=true sigma1=true z=true id=true frame=true");
    }

    if(THREED==0) {
        File.append("Starting 2D visualisation!",LOGPATH);
	    run("Visualization", "imleft=0.0 imtop=0.0 imwidth=["+sizeX+"] imheight=["+sizeY+"] renderer=[Averaged shifted histograms] magnification=["+MAGNIFICATION+"] colorize=false threed=false shifts=2");
        File.append("Finished Visualization at " + getTimeString(), LOGPATH);
        OUTPATH = WORK + "/" + JOBNO  + "/" + POSTNAME + "_2D.ome.tiff";
        run("Enhance Contrast...", "saturated=0.35 process_all use"); // lets brightest 0.35% of pixels saturate
        run("16-bit");

        run("Scale Bar...", "width=10 height=24 font=100 color=White background=None location=[Lower Right] bold");

        File.append("Exporting visualisation as ome.tiff to " + OUTPATH, LOGPATH);
        run("Bio-Formats Exporter", "save=["+OUTPATH+"] compression=LZW");
        File.append("Visualisation exported at " + getTimeString(), LOGPATH);
    } else  {
        File.append("Starting 3D visualisation!",LOGPATH);
	    run("Visualization", "imleft=0.0 imtop=0.0 imwidth=["+sizeX+"] imheight=["+sizeY+"] renderer=[Averaged shifted histograms] zrange=-500:50:500 magnification=["+MAGNIFICATION+"] colorize=false threed=true shifts=2 zshifts=2");
        File.append("Finished Visualization at " + getTimeString(), LOGPATH);
        OUTPATH = WORK + "/" + JOBNO  + "/" + POSTNAME + "_3D.ome.tiff";

        // 3D visualisation is as a colour coded 2d image where colour is the average z position for each xy pixel position
        // code below assumes -500:50:500 zrange, colour scale and scale bar are added 

        setBatchMode(true);
        im_stack=getImageID();
        run("Z Project...", "projection=[Sum Slices]");
        sum_id=getImageID();
        run("Add...", "value=0.001"); // to avoid divide by zero

        selectImage(im_stack);
        run("Macro...", "code=v=v*z stack");
        run("Z Project...", "projection=[Sum Slices]");
        sumz_id=getImageID();

        imageCalculator("Divide 32-bit", sumz_id, sum_id);  // calculates average image position in z
        avgz_id=getImageID();

        newImage("ramp", "32-bit ramp", 512, 64, 1);  // z-scale bar
        run("Multiply...", "value=15.000");
        run("Add...","value=2.0");
        run("Copy");
        selectImage(avgz_id);
        makeRectangle(256, 256, 512, 64);
        run("Paste");
        run("Select None");
        setMinAndMax(1, 18);
        run("Spectrum");

        selectImage(sum_id);
        run("Enhance Contrast...", "saturated=0.3 normalize");
        run("Gamma...", "value=0.50");        // use for intensity in final image
        setColor(1.0);
        fillRect(256, 256, 512, 64);

        selectImage(avgz_id);
        run("RGB Color");
        run("Split Channels");
        blue=getImageID();
        green=blue+1;
        red=green+1;

        imageCalculator("Multiply 32-bit", red, sum_id);
        rename("red");
        imageCalculator("Multiply 32-bit", green, sum_id);
        rename("green");
        imageCalculator("Multiply 32-bit", blue, sum_id);
        rename("blue");
        run("Merge Channels...", "c1=red c2=green c3=blue create");

        run("RGB Color");
        setBatchMode(false);

        run("Scale Bar...", "width=10 height=24 font=100 color=White background=None location=[Lower Right] bold");
        setColor(0xffffff);
        setFont("SansSerif", 100, "bold");
        setJustification("center");
        drawString("z(nm)",512,256);
        setJustification("right");
        drawString("-400",320,256);
        setJustification("left");
        drawString("400",704,256);

        File.append("Exporting visualisation as ome.tiff to " + OUTPATH, LOGPATH);
        run("Bio-Formats Exporter", "save=["+OUTPATH+"] compression=LZW");
        File.append("Visualisation exported at " + getTimeString(), LOGPATH);
    }

    if(File.exists(OUTPATH) != 1 ) {
        File.append("Failed to write " + OUTPATH, LOGPATH);
    }
}  //End of Visualisation

File.append("closing " + toString(nImages) + " images." ,LOGPATH);

while (nImages>0) { 
    selectImage(nImages);
    close();
}

File.append("exiting loc_post_macro at " + getTimeString(), LOGPATH);

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

