function  fakeSTORM(  )
% generate synthetic STORM data
% and store as ome-tiff

% replace path to BFMatlab Toolbox  for your own machine
%addpath('/Users/imunro/FLIMfit/FLIMfitFrontEnd/BFMatlab');

% verify that enough memory is allocated
bfCheckJavaMemory();

autoloadBioFormats = 1;

% load the Bio-Formats library into the MATLAB environment
status = bfCheckJavaPath(autoloadBioFormats);
assert(status, ['Missing Bio-Formats library. Either add loci_tools.jar '...
            'to the static Java path or add it to the Matlab path.']);

% initialize logging
loci.common.DebugTools.enableLogging('ERROR');

java.lang.System.setProperty('javax.xml.transform.TransformerFactory', 'com.sun.org.apache.xalan.internal.xsltc.trax.TransformerFactoryImpl');
OMEXMLService = loci.formats.services.OMEXMLServiceImpl();

sizeY = 256;
sizeX = 256;

sizeZ = 4;

data = ones(sizeX, sizeY,sizeZ,1,1).* 20;
data = poissrnd(data);

data(128,128,1,1,1) = 128;
data(127,128,1,1,1) = 100;
data(129,128,1,1,1) = 100;
data(128,127,1,1,1) = 100;
data(128,129,1,1,1) = 100;

data(128,128,2,1,1) = 128;
data(127,128,2,1,1) = 100;
data(129,128,2,1,1) = 100;
data(128,127,2,1,1) = 100;
data(128,129,2,1,1) = 100;

data(128,128,3,1,1) = 128;
data(127,128,3,1,1) = 100;
data(129,128,3,1,1) = 100;
data(128,127,3,1,1) = 100;
data(128,129,3,1,1) = 100;

data(128,128,4,1,1) = 128;
data(127,128,4,1,1) = 100;
data(129,128,4,1,1) = 100;
data(128,127,4,1,1) = 100;
data(128,129,4,1,1) = 100;

data = data + 350;
data16 = uint16(data);

outputPath = 'fakeStorm.ome.tiff';

if exist(outputPath, 'file') == 2
        delete(outputPath);
end

bfsave(data16, outputPath);
