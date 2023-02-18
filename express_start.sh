#!/bin/bash

echo "
                                                      __               __   
.-----.--.--.-----.----.-----.-----.-----.    .-----.|  |_.---.-.----.|  |_ 
|  -__|_   _|  _  |   _|  -__|__ --|__ --|    |__ --||   _|  _  |   _||   _|
|_____|__.__|   __|__| |_____|_____|_____|____|_____||____|___._|__|  |____|
            |__|                        |______|                            

An automated script to start an Express.js project

* using Typescript
"

# Get users choices
printf "Project's name: "
read PROJECT_NAME

printf "Main server filename (with no extension): "
read MAIN_FILENAME

printf "Database choice for prisma
[postgresql OR sqlite OR mysql OR mongodb OR cockroach]
> "
read DB


mkdir "./${PROJECT_NAME}"
cd ${PROJECT_NAME}


# Init project
echo "Starting project..."
npm init -y
sed -i '3i  "type": "module",' package.json


echo "Downloading dependencies..."
npm i @prisma/client cors express
npm i -D ts-node-dev typescript @types/cors @types/express prisma

sed -i '8s/.*/    "build": "tsc",/' package.json
sed -i '9i   "dev": "tsnd --exit-child src/server.ts"' package.json


echo "Creating main file"
mkdir "./src/"


echo "import express from 'express'
import cors from 'cors'
import { PrismaClient } from '@prisma/client'


const app = express()
const prisma = new PrismaClient({ log: ['query'] })


app.use(express.json())
app.use(cors())


app.get('/', async (req, res) => {
  const ___ = await prisma

  return res.status(200).json(___)
})


app.post('/', async (req, res) => {
  const ___ = await prisma

  return res.status(201).json(___)
})


app.listen(3333)" >> "./src/${MAIN_FILENAME}.ts"


npx tsc --init

sed -i '29s/.*/    "rootDir": ".\/src",                                  \/* Specify the root folder within your source files. *\//' tsconfig.json
sed -i '30s/.*/    "moduleResolution": "node",                       /* Specify how TypeScript looks up a file from a given module specifier. *\//' tsconfig.json
sed -i '52s/.*/    "outDir": "./build",                                   /* Specify an output folder for all emitted files. *\//' tsconfig.json


npx prisma init --datasource-provider ${DB}


# Setup files using some best practices (e.g. deploy)

