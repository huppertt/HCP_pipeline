file=$1
fileOut=$2

echo "${fileOut}"

rm ${fileOut}

scanDetailsCSV=scan_details.csv

cp ${file} tmp.txt
sed -i 's/*/#/g' tmp.txt

names=($(grep -oP '(?<=pip:name>)[^<]+' "tmp.txt"))
values=($(grep -oP '(?<=unique>)[^<]+' "tmp.txt"))

for i in ${!values[*]}
do
	echo "${names[$i+2]}=${values[$i]}"
	echo "${names[$i+2]}=${values[$i]}">>${fileOut}
done

source ${fileOut}
h=`hostname -s`

if [ ${h} = "cerebro"  ] ; then
    echo "Running on Cerebro"

    xnatpipeline=/disk/HCP/pipeline/xnat_remote

    echo "host=http://10.48.86.212:8080/">>${fileOut}
    echo "aliasHost=http://10.48.86.212:8080/">>${fileOut}
    echo "user=hcpadmin">>${fileOut}
    echo "xnatpipeline=/disk/HCP/pipeline/xnat_remote">>${fileOut}
    host=http://10.48.86.212:8080/
    aliasHost=http://10.48.86.212:8080/
    user=hcpadmin

    passwd=hcp22
#   passwd=$(${xnatpipeline}/xnat-tools/XnatDataClientCerebro -r ${host}/data/JSESSION -u ${user} -p hcp22 -m POST)
#passwd=${passwd:0:32}

    echo "passwd=${passwd}">>${fileOut}
fi


restPath="${host}data/archive/projects/${project}/subjects/${subjectlabel}/experiments/${sessionId}/scans?columns=ID,xnat:imageScanData/frames,type,series_description&format=csv"
curl -k -u ${user}:${passwd} -G "$restPath" > ${scanDetailsCSV}

functional_usable_scanids=($(grep "fMRI_" ${scanDetailsCSV} |  awk '{split($0,a,","); print a[6];}' | cut -f6 -d/))

echo "declare -a functional_usable_scanids=(${functional_usable_scanids[*]})">>${fileOut}

rm tmp.txt
