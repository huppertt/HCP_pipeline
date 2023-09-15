#! /bin/bash

export jsess=$(XnatDataClientCerebro -r http://xnat.mrrc.upmc.edu/data/JSESSION -u huppertt -p nirsoptical -m POST)
jsess=${jsess:0:32}

echo ${jsess:0:32}