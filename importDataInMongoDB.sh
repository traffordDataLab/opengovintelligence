#!/usr/bin/env bash
# This script will insert the CSV data files into your MongoDB Cluster.
# MongoDB URI should be provided in $1 or will default to mongodb://localhost/opengovintelligence.
# Example: ./importDataInMongoDB.sh mongodb+srv://LOGIN:PASSWORD@cluster0-abcde.mongodb.net/opengovintelligence

database="opengovintelligence"
dataset_folder="data/RDF/datasets/"
files=$(find $dataset_folder -type f -name "input.csv" | sed "s|$dataset_folder||g")

for f in $files
do
  echo Found file $f;
  collection=$(echo $f | sed "s|/.*||; s|-|_|g")
  echo Writting in MongoDB to database "$database" in collection "$collection".
  mongoimport --drop --type csv --headerline --uri ${1:-mongodb://localhost/$database} -c $collection $dataset_folder$f
  echo
done
