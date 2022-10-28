#!/bin/bash

my_sge_task_id=$1

paramsFile=$2

source $paramsFile


my_scan=${functional_usable_scanids[$my_sge_task_id]}


XNATRestClient=${xnatpipeline}/xnat-tools/XNATRestClient

qcFileName=$workdir/level2QC_${my_scan}.xml

date=`date "+%Y%m%d%H%M"`

qc_id=$xnat_id"_SCAN${my_scan}_LEVEL2_FUNCTIONAL_QC"_$date

timeStamp=`date +"%Y-%m-%dT%T"`
dateTime=`date +"%Y-%m-%d"`




cat << EOF > $qcFileName
<!--Sample XML file generated by XMLSpy v2009 sp1 #(http://www.altova.com)-->
EOF
echo '<xnat:QCAssessment ID="'$qc_id'" type="FUNCTIONAL_QC" project="'$project'" label="'$qc_id'" xsi:schemaLocation="http://nrg.wustl.edu/xnat xnat.xsd"' >> $qcFileName
echo 'xmlns:xnat="http://nrg.wustl.edu/xnat"' >> $qcFileName
echo 'xmlns:prov="http://www.nbrin.net/prov" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' >> $qcFileName
echo '<xnat:date>'$dateTime'</xnat:date>' >> $qcFileName

echo '<xnat:imageSession_ID>'$xnat_id'</xnat:imageSession_ID>' >> $qcFileName


echo '<xnat:scans>' >> $qcFileName

echo '<xnat:scan id="'$my_scan'">' >> $qcFileName
echo '<xnat:scanStatistics xsi:type="xnat:statisticsData">' >> $qcFileName


###################################
# Fourier Coefficients -  None
# only plots
###################################

###################################
# Motion Outliers 
# 
###################################

for line in `cat $workdir/MotionOutlier/$my_scan/${my_scan}_mo.dat`
do
  measure=`echo $line | awk '{split($1,a,"="); print a[1]};'`
  value=`echo $line | awk '{split($1,a,"="); print a[2]};'`
  echo '<xnat:additionalStatistics name="'$measure'">'$value'</xnat:additionalStatistics>' >> $qcFileName
done


###################################
# BIRN Human QA -  Measures
# HTML
###################################

###################################
# Wavelet Kurtosis
# only plots
###################################


human_qa_dir=$workdir/BIRN

derivedDataQA="$human_qa_dir/$my_scan"

bxhOutputFile=${my_scan}_image.xml

outputXMLFileName="$derivedDataQA/qa_events_"$bxhOutputFile".xml"
outputHTMLFileName="data/archive/experiments/"$xnat_id"/assessors/"$qc_id"/out/resources/BIRN_DATA/files/web_access_index.html"


pushd $human_qa_dir/$my_scan
	sed -e 's+src="\(.*\)"+src="'$host'data/archive/experiments/'$xnat_id'/assessors/'$qc_id'/out/resources/BIRN_DATA/files/\1"+' index.html > web_access_index_temp.html
	sed -e 's+href="index.css"+href="'$host'/style/birn/index.css"+' web_access_index_temp.html > web_access_index.html
	\rm -f web_access_index_temp.html
	
popd

mean_masked_fwhmx=`grep mean_masked_fwhmx $outputXMLFileName | awk -F\> '{print $2}' | awk -F\< '{print $1}'`
mean_masked_fwhmy=`grep mean_masked_fwhmy $outputXMLFileName | awk -F\> '{print $2}' | awk -F\< '{print $1}'`
mean_masked_fwhmz=`grep mean_masked_fwhmz $outputXMLFileName | awk -F\> '{print $2}' | awk -F\< '{print $1}'`
mean_middle_slice=`grep mean_middle_slice $outputXMLFileName | awk -F\> '{print $2}' | awk -F\< '{print $1}'`
mean_sfnr_middle_slice=`grep mean_sfnr_middle_slice $outputXMLFileName | awk -F\> '{print $2}' | awk -F\< '{print $1}'`
mean_snr_middle_slice=`grep mean_snr_middle_slice $outputXMLFileName | awk -F\> '{print $2}' | awk -F\< '{print $1}'`



#############################################################################
#  export script output to XNAT QCAssessment derived data xml file
#############################################################################


echo "<xnat:additionalStatistics name="\""BIRN_MEAN"\"">${mean_middle_slice}</xnat:additionalStatistics>" >>  $qcFileName
echo "<xnat:additionalStatistics name="\""BIRN_SNR"\"">${mean_snr_middle_slice}</xnat:additionalStatistics>" >>  $qcFileName
echo "<xnat:additionalStatistics name="\""BIRN_SFNR"\"">${mean_sfnr_middle_slice}</xnat:additionalStatistics>" >>  $qcFileName

echo "<xnat:additionalStatistics name="\""BIRN_MEAN_MASKED_FWHMX"\"">${mean_masked_fwhmx}</xnat:additionalStatistics>"   >>  $qcFileName
echo "<xnat:additionalStatistics name="\""BIRN_MEAN_MASKED_FWHMY"\"">${mean_masked_fwhmy}</xnat:additionalStatistics>"   >>  $qcFileName
echo "<xnat:additionalStatistics name="\""BIRN_MEAN_MASKED_FWHMZ"\"">${mean_masked_fwhmz}</xnat:additionalStatistics>"   >>  $qcFileName
echo "<xnat:addField name="\""BIRN_HTML"\"">$outputHTMLFileName</xnat:addField>" >> $qcFileName





echo '</xnat:scanStatistics>' >> $qcFileName

echo '</xnat:scan>' >> $qcFileName

echo '</xnat:scans>' >> $qcFileName
echo '</xnat:QCAssessment>' >> $qcFileName

################################
# Upload the XML
#
################################

restPath="data/archive/projects/${project}/subjects/${subjectlabel}/experiments/${sessionId}/assessors/${qc_id}"
echo $restPath

echo curl -u ${user}:${passwd} -H "Content-Type:text/xml" -X PUT --data-binary @$qcFileName $aliasHost/$restPath

curl -u ${user}:${passwd} -H "Content-Type:text/xml" -X PUT --data-binary @$qcFileName $aliasHost/$restPath


################################
# Upload the various files
#
################################


################################
# Fourier Slope Statistics
#
################################

pushd $workdir/FourierSlope/${my_scan}

zip -r fourier_${my_scan} *

$XNATRestClient -host $aliasHost -u $user -p $passwd -m PUT -remote "$restPath/out/resources/FOURIER_COEFFICIENTS_DATA" 

$XNATRestClient -host $aliasHost -u $user -p $passwd -m PUT -remote "$restPath/resources/FOURIER_COEFFICIENTS_DATA/files?extract=true\&label=FOURIER_COEFFICIENTS_DATA\&content=FOURIER_COEFFICIENTS_DATA" -local fourier_${my_scan}.zip

popd

################################
# MotionOutliers
#
################################

pushd $workdir/MotionOutlier/${my_scan}

zip -r motionoutlier_${my_scan} *

$XNATRestClient -host $aliasHost -u $user -p $passwd -m PUT -remote "$restPath/out/resources/MOTIONOUTLIER_DATA" 

$XNATRestClient -host $aliasHost -u $user -p $passwd -m PUT -remote "$restPath/resources/MOTIONOUTLIER_DATA/files?extract=true\&label=MOTIONOUTLIER_DATA\&content=MOTIONOUTLIER_DATA" -local motionoutlier_${my_scan}.zip

popd

################################
# BIRN HUMAN QA
#
################################

pushd $workdir/BIRN/${my_scan}

zip -r birn_${my_scan} *

$XNATRestClient -host $aliasHost -u $user -p $passwd -m PUT -remote "$restPath/out/resources/BIRN_DATA" 

$XNATRestClient -host $aliasHost -u $user -p $passwd -m PUT -remote "$restPath/resources/BIRN_DATA/files?extract=true\&label=BIRN_DATA\&content=BIRN_DATA" -local birn_${my_scan}.zip

popd


################################
# Wavelet Statistics
#
################################

pushd $workdir/WaveletKurtosis/${my_scan}

zip -r wavelet_${my_scan} *

$XNATRestClient -host $aliasHost -u $user -p $passwd -m PUT -remote "$restPath/out/resources/WAVELETSTATISTICS_DATA" 

$XNATRestClient -host $aliasHost -u $user -p $passwd -m PUT -remote "$restPath/resources/WAVELETSTATISTICS_DATA/files?extract=true\&label=WAVELETSTATISTICS_DATA\&content=WAVELETSTATISTICS_DATA" -local wavelet_${my_scan}.zip

popd





exit 0
