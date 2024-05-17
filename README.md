# msconvert-launcher
Script to launch msconvert jobs on Windows



Actually the script are not that useful and its maybe more convenient to launch the command directly in the command line. 

```bash
ls /path/to/your/raw/files/* | xargs -I {} msconvert "{}" -o "/path/to/your/converted/files" --mzML --64 --zlib
```

Here are the possible arguments for msconvert:

```bash
msconvert --help
```

```bash
 msconvert
Usage: msconvert [options] [filemasks]
Convert mass spec data file formats.

Return value: # of failed files.

Options:
  -f [ --filelist ] arg              : specify text file containing filenames
  -o [ --outdir ] arg (=.)           : set output directory ('-' for stdout)
                                     [.]
  -c [ --config ] arg                : configuration file (optionName=value)
  --outfile arg                      : Override the name of output file.
  -e [ --ext ] arg                   : set extension for output files
                                     [mzML|mzXML|mgf|txt|mz5]
  --mzML                             : write mzML format [default]
  --mzXML                            : write mzXML format
  --mz5                              : write mz5 format
  --mgf                              : write Mascot generic format
  --text                             : write ProteoWizard internal text format
  --ms1                              : write MS1 format
  --cms1                             : write CMS1 format
  --ms2                              : write MS2 format
  --cms2                             : write CMS2 format
  -v [ --verbose ]                   : display detailed progress information
  --64                               : set default binary encoding to 64-bit
                                     precision [default]
  --32                               : set default binary encoding to 32-bit
                                     precision
  --mz64                             : encode m/z values in 64-bit precision
                                     [default]
  --mz32                             : encode m/z values in 32-bit precision
  --inten64                          : encode intensity values in 64-bit
                                     precision
  --inten32                          : encode intensity values in 32-bit
                                     precision [default]
  --noindex                          : do not write index
  -i [ --contactInfo ] arg           : filename for contact info
  -z [ --zlib ]                      : use zlib compression for binary data
  --numpressLinear [=arg(=2e-09)]    : use numpress linear prediction
                                     compression for binary mz and rt data
                                     (relative accuracy loss will not exceed
                                     given tolerance arg, unless set to 0)
  --numpressLinearAbsTol [=arg(=-1)] : desired absolute tolerance for linear
                                     numpress prediction (e.g. use 1e-4 for a
                                     mass accuracy of 0.2 ppm at 500 m/z,
                                     default uses -1.0 for maximal accuracy).
                                     Note: setting this value may substantially
                                     reduce file size, this overrides relative
                                     accuracy tolerance.
  --numpressPic                      : use numpress positive integer
                                     compression for binary intensities
                                     (absolute accuracy loss will not exceed
                                     0.5)
  --numpressSlof [=arg(=0.0002)]     : use numpress short logged float
                                     compression for binary intensities
                                     (relative accuracy loss will not exceed
                                     given tolerance arg, unless set to 0)
  -n [ --numpressAll ]               : same as --numpressLinear --numpressSlof
                                     (see https://github.com/fickludd/ms-numpre
                                     ss for more info)
  -g [ --gzip ]                      : gzip entire output file (adds .gz to
                                     filename)
  --filter arg                       : add a spectrum list filter
  --chromatogramFilter arg           : add a chromatogram list filter
  --merge                            : create a single output file from
                                     multiple input files by merging file-level
                                     metadata and concatenating spectrum lists
  --runIndexSet arg                  : for multi-run sources, select only the
                                     specified run indices
  --simAsSpectra                     : write selected ion monitoring as
                                     spectra, not chromatograms
  --srmAsSpectra                     : write selected reaction monitoring as
                                     spectra, not chromatograms
  --combineIonMobilitySpectra        : write all ion mobility or Waters SONAR
                                     bins/scans in a frame/block as one
                                     spectrum instead of individual spectra
  --acceptZeroLengthSpectra          : some vendor readers have an efficient
                                     way of filtering out empty spectra, but it
                                     takes more time to open the file
  --ignoreMissingZeroSamples         : some vendor readers do not include zero
                                     samples in their profile data; the default
                                     behavior is to add the zero samples but
                                     this option disables that
  --ignoreUnknownInstrumentError     : if true, if an instrument cannot be
                                     determined from a vendor file, it will not
                                     be an error
  --stripLocationFromSourceFiles     : if true, sourceFile elements will be
                                     stripped of location information, so the
                                     same file converted from different
                                     locations will produce the same mzML
  --stripVersionFromSoftware         : if true, software elements will be
                                     stripped of version information, so the
                                     same file converted with different
                                     versions will produce the same mzML
  --singleThreaded [=arg(=1)] (=2)   : if true, reading and writing spectra
                                     will be done on a single thread
  --help                             : show this message, with extra detail on
                                     filter options
  --help-filter arg                  : name of a single filter to get detailed
                                     help for
  --show-examples                    : show examples of how to run
                                     msconvert.exe

Spectrum List Filters
=====================
(run this program with --help to see details for all filters)
index <index_value_set>
id <id_set>
msLevel <mslevels>
chargeState <charge_states>
precursorRecalculation
mzRefiner input1.pepXML input2.mzid [msLevels=<1->]
[thresholdScore=<CV_Score_Name>] [thresholdValue=<floatset>]
[thresholdStep=<float>] [maxSteps=<count>]
lockmassRefiner mz=<real> mzNegIons=<real (mz)> tol=<real (1.0 Daltons)>
precursorRefine
peakPicking [<PickerType> [snr=<minimum signal-to-noise ratio>]
[peakSpace=<minimum peak spacing>] [msLevel=<ms_levels>]]
scanNumber <scan_numbers>
scanEvent <scan_event_set>
scanTime <scan_time_range>
sortByScanTime
stripIT
metadataFixer
titleMaker <format_string>
threshold <type> <threshold> <orientation> [<mslevels>]
mzWindow <mzrange>
mzPrecursors <precursor_mz_list> [mzTol=<mzTol (10 ppm)>]
[target=<selected|isolated> (selected)] [mode=<include|exclude (include)>]
defaultArrayLength <peak_count_range>
zeroSamples <mode> [<MS_levels>]
mzPresent <mz_list> [mzTol=<tolerance> (0.5 mz)] [type=<type> (count)]
[threshold=<threshold> (10000)] [orientation=<orientation> (most-intense)]
[mode=<include|exclude (include)>]
scanSumming [precursorTol=<precursor tolerance>] [scanTimeTol=<scan time
tolerance in seconds>] [ionMobilityTol=<ion mobility tolerance>]
thermoScanFilter <exact|contains> <include|exclude> <match string>
MS2Denoise [<peaks_in_window> [<window_width_Da>
[multicharge_fragment_relaxation]]]
MS2Deisotope [hi_res [mzTol=<mzTol>]] [Poisson [minCharge=<minCharge>]
[maxCharge=<maxCharge>]]
ETDFilter [<removePrecursor> [<removeChargeReduced> [<removeNeutralLoss>
[<blanketRemoval> [<matchingTolerance> ]]]]]
demultiplex massError=<tolerance and units, eg 0.5Da (default 10ppm)>
nnlsMaxIter=<int (50)> nnlsEps=<real (1e-10)> noWeighting=<bool (false)>
demuxBlockExtra=<real (0)> variableFill=<bool (false)> noSumNormalize=<bool
(false)> optimization=<(none)|overlap_only> interpolateRT=<bool (true)>
minWindowSize=<real (0.2)>
chargeStatePredictor [overrideExistingCharge=<true|false (false)>]
[maxMultipleCharge=<int (3)>] [minMultipleCharge=<int (2)>]
[singleChargeFractionTIC=<real (0.9)>] [maxKnownCharge=<int (0)>]
[makeMS2=<true|false (false)>]
turbocharger [minCharge=<minCharge>] [maxCharge=<maxCharge>]
[precursorsBefore=<before>] [precursorsAfter=<after>] [halfIsoWidth=<half-width
of isolation window>] [defaultMinCharge=<defaultMinCharge>]
[defaultMaxCharge=<defaultMaxCharge>] [useVendorPeaks=<useVendorPeaks>]
activation <precursor_activation_type>
collisionEnergy low=<real> high=<real> [mode=<include|exclude (include)>]
[acceptNonCID=<true|false (true)] [acceptMissingCE=<true|false (false)]
analyzer <analyzer>
analyzerType <analyzer>
polarity <polarity>
diaUmpire params=<filepath to DiaUmpire .params file>


Chromatogram List Filters
=========================
index <index_value_set>
lockmassRefiner mz=<real> mzNegIons=<real (mz)> tol=<real (1.0 Daltons)>


Questions, comments, and bug reports:
https://github.com/ProteoWizard
support@proteowizard.org

ProteoWizard release: 3.0.22105 (8bd5986)
Build date: Apr 15 2022 03:14:46
```




For example, to convert all the files in a folder, you can use the following command:
```bash
ls /y/public/QE_plus_unifr/raw/2024/05/* | xargs -I {} msconvert "{}" -o "/y/public/QE_plus_unifr/converted/2024/05" --mzML --64 --zlib
```

It is also possible to convert a single file:

```bash
ls /y/public/QE_plus_unifr/raw/dump/20240517_CVOL_mapp_01_79_01.raw | xargs -I {} msconvert "{}" -o "/y/public/QE_plus_unifr/converted/" --mzML --64 --zlib
```


 

  