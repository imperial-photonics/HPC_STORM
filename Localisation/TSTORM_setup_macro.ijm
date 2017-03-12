ARGS=getArgument();

setBatchMode(true);
parts=split(ARGS, ":");

WORK=parts[0];
FNAME=parts[1];


if (parts.length == 4)  {
    CALIB=parts[2];
    HOME=parts[3];
    CALPATH=WORK + "/" + CALIB;
    THREED=File.exists(CALPATH); //Returns "1" (true) if the specified file exists.
}
else {
    THREED=0;
    HOME=parts[2];
}

FILEPATH=WORK + "/" + FNAME;
ERR=File.exists(FILEPATH);

if(ERR!=1)  {
print("Unable to find file", FILEPATH);
run("Quit");
}

// Use Bio-Formats to find the size of the original data
run("Bio-Formats Macro Extensions");
Ext.setId(FILEPATH);
Ext.setSeries(0);
Ext.getSizeT(sizeT);

PBS_INDEX=parseInt(PBS_INDEX);

OUTPATH = HOME + "/args";

if (File.exists(OUTPATH))  {
File.delete(OUTPATH);
}

outf = File.open(OUTPATH);

sizeT=parseInt(sizeT);

BLOCK= floor(sizeT/88);

FIRSTFRAME=1;
NROWS=10;

// Create a config file asking for NROWS jobs
for (r=0; r<NROWS; r++)  {

    LASTFRAME = FIRSTFRAME + ((r+3) * BLOCK);

    if (r== (NROWS -1)) {
        LASTFRAME = sizeT;
    }

    LINE= WORK + ":" + FNAME + ":" + toString(FIRSTFRAME) + ":" + toString(LASTFRAME) + ":" + toString(r + 1);

    FIRSTFRAME = LASTFRAME + 1;

    if(THREED!=0)  {
        LINE = LINE + ":" + CALIB;
    }
    File.append(LINE,OUTPATH);
}

File.close(outf);

run("Quit");