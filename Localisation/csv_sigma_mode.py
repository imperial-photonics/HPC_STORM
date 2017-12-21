#!/usr/bin/env python
import sys, csv, getopt
import pandas as pd
import numpy

def find_mode(ndarray,axis=0):
    if ndarray.size == 1:
        return (ndarray[0],1)
    elif ndarray.size == 0:
        raise Exception('Attempted to find mode on an empty array!')
    try:
        axis = [i for i in range(ndarray.ndim)][axis]
    except IndexError:
        raise Exception('Axis %i out of range for array with %i dimension(s)' % (axis,ndarray.ndim))

    srt = numpy.sort(ndarray,axis=axis)
    dif = numpy.diff(srt,axis=axis)
    shape = [i for i in dif.shape]
    shape[axis] += 2
    indices = numpy.indices(shape)[axis]
    index = tuple([slice(None) if i != axis else slice(1,-1) for i in range(dif.ndim)])
    indices[index][dif == 0] = 0
    indices.sort(axis=axis)
    bins = numpy.diff(indices,axis=axis)
    location = numpy.argmax(bins,axis=axis)
    mesh = numpy.indices(bins.shape)
    index = tuple([slice(None) if i != axis else 0 for i in range(dif.ndim)])
    index = [mesh[i][index].ravel() if i != axis else location.ravel() for i in range(bins.ndim)]
    #counts = bins[tuple(index)].reshape(location.shape)
    index[axis] = indices[tuple(index)]
    modals = srt[tuple(index)].reshape(location.shape)
    mode = modals[()]
    return (mode)



# Store input and output file names
ifile=''

# Read command line args
if len(sys.argv) != 3:
    print ('Usage: csv_uncertainty_mode -i <inputfile>')
    sys.exit(1)

try:
    opts, args = getopt.getopt(sys.argv[1:],"i:")
except getopt.GetoptError:
    print ('Usage: csv_uncertainty_mode -i <inputfile>')
    sys.exit(1)

###############################
# o == option
# a == argument passed to the o
###############################
for o, a in opts:
    if o == '-i':
        ifile=a
    else:
        print ('Usage: csv_sigma_mode -i <inputfile>')
        sys.exit(1)



# read headers only
df = pd.read_csv(ifile, nrows=1)

header_txt = "FAIL!"

#test for a 2D file
test_txt = "sigma [nm]"
try:
  sig = df[test_txt]
  header_txt = test_txt
except:
  pass

if header_txt == "FAIL!":
  #test for a 3D file
  test_txt = "sigma1 [nm]"
  try:
    sig = df[test_txt]
    header_txt = test_txt
  except:
    pass

if header_txt != "FAIL!":
  #read the whole of the appropriate sigma col
  df = pd.read_csv(ifile, usecols=[header_txt])
  sig = df[header_txt]
  sigma = numpy.array(sig)
  rounded = numpy.around(sigma, decimals=1)
  mask = rounded < 210
  result = rounded[mask,...]
  #mean  = numpy.mean(result)
  #mean = numpy.around(mean, decimals=1)
  #print(mean)
  #print ';'
  mode  = find_mode(result);
  print(mode)
else:
  print("-1")












