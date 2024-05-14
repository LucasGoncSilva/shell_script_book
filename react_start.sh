#!/bin/bash

echo "
                        __               __               __   
.----.-----.---.-.----.|  |_     .-----.|  |_.---.-.----.|  |_ 
|   _|  -__|  _  |  __||   _|    |__ --||   _|  _  |   _||   _|
|__| |_____|___._|____||____|____|_____||____|___._|__|  |____|
                           |______|                            

An automated script to start a React project using Vite
"

# Get users choices
printf "Project's name: "
read PROJECT_NAME


mkdir ${PROJECT_NAME}
cd ${PROJECT_NAME}

# npm create vite@latest
npm create vite@latest ${PROJECT_NAME} -- --template react-ts
