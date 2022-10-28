#! /bin/bash

export jsess=$(XnatDataClientCerebro -r http://10.48.86.212:8080/REST/projects/COBRA/archive_spec -u hcpadmin -p hcp22)
echo ${jsess}