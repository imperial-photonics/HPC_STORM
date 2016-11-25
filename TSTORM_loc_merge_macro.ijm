PATH=getArgument();

setBatchMode(true);

filestring=File.openAsString(PATH);
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
    err=File.rename(PROTPATH, WORK + "/" + NAME + "-protocol.txt");

    INPATH = WORK + "/tmp_" + NAME + ".csv";

    if (NEXTBLOCK == "1")  {
      // Only one block for this file so no merging required
      err=File.rename(INPATH, WORK + "/" + NAME + ".csv");
    }
    else  {
      run("Import results", "filepath=["+INPATH+"] fileformat=[CSV (comma separated)] livepreview=true rawimagestack= startingframe=1 append=false");
      err=File.delete(INPATH);
    }
  }
  else {   //BLOCK > 1
    INPATH = WORK + "/tmp_" + NAME + BLOCK + ".csv";
    run("Import results", "filepath=["+INPATH+"] fileformat=[CSV (comma separated)] livepreview=true rawimagestack= startingframe=["+FIRST+"] append=true");
    err=File.delete(INPATH);

    if (NEXTBLOCK == "1")  {
      OUTPATH = WORK + "/" + NAME + ".csv";
      run("Export results", "filepath=["+OUTPATH+"] fileformat=[CSV (comma separated)] id=true frame=true sigma=true bkgstd=true intensity=true saveprotocol=["+SAVEPROTOCOL+"] offset=true uncertainty=true y=true x=true");

    }

  }

}

run("Quit");

