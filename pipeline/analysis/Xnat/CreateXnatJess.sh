#! /bin/bash

export jsess=$(XnatDataClientCerebro -r http://10.48.86.212:8080/data/JSESSION -u hcpadmin -p hcp22 -m POST)
jsess=${jsess:0:32}

echo ${jsess:0:32}