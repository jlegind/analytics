runHbase="false"
runHive="false"
runHadoop="false"
runPrepare="false"
runFigures="false"
runJson="false"
runHtml="false"

destination_db="analytics"
snapshot_db="snapshot"

[[ $* =~ (^| )"-runHbase"($| ) ]] && runHbase="true" 
[[ $* =~ (^| )"-runHive"($| ) ]] && runHive="true" 
[[ $* =~ (^| )"-runHadoop"($| ) ]] && runHadoop="true" 
[[ $* =~ (^| )"-runPrepare"($| ) ]] && runPrepare="true"
[[ $* =~ (^| )"-runFigures"($| ) ]] && runFigures="true"
[[ $* =~ (^| )"-runJson"($| ) ]] && runJson="true"
[[ $* =~ (^| )"-runHtml"($| ) ]] && runHtml="true"

if [ $runHbase == "true" ];then
  echo 'Running hbase stages (import and geo/taxonomy table creation)'
  ./hive/normalize/build_raw_scripts.sh
  ./hive/normalize/create_tmp_raw_tables.sh
  ./hive/normalize/create_tmp_interp_tables.sh
  ./hive/normalize/create_occurrence_tables.sh
else 
  echo 'Skipping hbase stage (add -runHbase to command to run it)'
fi

if [ $runHive == "true" ];then
  echo 'Running hive stages (Existing tables are replaced)'
  prepare_file="hive/process/prepare.q"
  ./hive/process/build_prepare_script.sh $prepare_file
  hive --hiveconf DB="$destination_db" --hiveconf SNAPSHOT_DB="$snapshot_db" -f $prepare_file 
  hive --hiveconf DB="$destination_db" -f hive/process/occ_kingdom_basisOfRecord.q
  hive --hiveconf DB="$destination_db" -f hive/process/occ_dayCollected.q
  hive --hiveconf DB="$destination_db" -f hive/process/occ_yearCollected.q
  hive --hiveconf DB="$destination_db" -f hive/process/occ_complete.q
  hive --hiveconf DB="$destination_db" -f hive/process/occ_complete_v2.q
  hive --hiveconf DB="$destination_db" -f hive/process/occ_cells.q
  
  hive --hiveconf DB="$destination_db" -f hive/process/spe_kingdom.q
  hive --hiveconf DB="$destination_db" -f hive/process/spe_dayCollected.q
  hive --hiveconf DB="$destination_db" -f hive/process/spe_yearCollected.q
  
  hive --hiveconf DB="$destination_db" -f hive/process/repatriation.q
else 
  echo 'Skipping hive stage (add -runHive to command to run it)'
fi

if [ $runHadoop == "true" ];then
  echo 'Downloading the CSVs from Hadoop (Existing data are overwritten)'
  rm -fr hadoop
  mkdir hadoop
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_country_kingdom_basisofrecord hadoop/occ_country_kingdom_basisOfRecord.csv
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_publishercountry_kingdom_basisofrecord hadoop/occ_publisherCountry_kingdom_basisOfRecord.csv 
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_kingdom_basisofrecord hadoop/occ_kingdom_basisOfRecord.csv
  
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_country_daycollected hadoop/occ_country_dayCollected.csv
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_publishercountry_daycollected hadoop/occ_publisherCountry_dayCollected.csv 
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_daycollected hadoop/occ_dayCollected.csv
  
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_country_yearcollected hadoop/occ_country_yearCollected.csv
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_publishercountry_yearcollected hadoop/occ_publisherCountry_yearCollected.csv 
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_yearcollected hadoop/occ_yearCollected.csv

#  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_country_basisofrecord_complete hadoop/occ_country_basisOfRecord_complete.csv
#  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_publishercountry_basisofrecord_complete hadoop/occ_publisherCountry_basisOfRecord_complete.csv
#  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_basisofrecord_complete hadoop/occ_basisOfRecord_complete.csv

  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_country_complete hadoop/occ_country_complete.csv
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_publishercountry_complete hadoop/occ_publisherCountry_complete.csv
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_complete hadoop/occ_complete.csv
  
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_country_repatriation hadoop/occ_country_repatriation.csv
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_publishercountry_repatriation hadoop/occ_publisherCountry_repatriation.csv 
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_repatriation hadoop/occ_repatriation.csv

  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_country_cell_one_deg hadoop/occ_country_cell_one_deg.csv
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_publishercountry_cell_one_deg hadoop/occ_publisherCountry_cell_one_deg.csv 
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_cell_one_deg hadoop/occ_cell_one_deg.csv

  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_country_cell_point_one_deg hadoop/occ_country_cell_point_one_deg.csv
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_publishercountry_cell_point_one_deg hadoop/occ_publisherCountry_cell_point_one_deg.csv 
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_cell_point_one_deg hadoop/occ_cell_point_one_deg.csv

  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_country_cell_half_deg hadoop/occ_country_cell_half_deg.csv
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_publishercountry_cell_half_deg hadoop/occ_publisherCountry_cell_half_deg.csv 
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/occ_cell_half_deg hadoop/occ_cell_half_deg.csv

  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/spe_country_kingdom hadoop/spe_country_kingdom.csv
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/spe_publishercountry_kingdom hadoop/spe_publisherCountry_kingdom.csv 
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/spe_kingdom hadoop/spe_kingdom.csv 
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/spe_country_kingdom_observation hadoop/spe_country_kingdom_observation.csv
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/spe_publishercountry_kingdom_observation hadoop/spe_publisherCountry_kingdom_observation.csv 
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/spe_kingdom_observation hadoop/spe_kingdom_observation.csv 
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/spe_country_kingdom_specimen hadoop/spe_country_kingdom_specimen.csv
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/spe_publishercountry_kingdom_specimen hadoop/spe_publisherCountry_kingdom_specimen.csv 
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/spe_kingdom_specimen hadoop/spe_kingdom_specimen.csv 
  
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/spe_country_daycollected hadoop/spe_country_dayCollected.csv
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/spe_publishercountry_daycollected hadoop/spe_publisherCountry_dayCollected.csv 
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/spe_daycollected hadoop/spe_dayCollected.csv
  
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/spe_country_yearcollected hadoop/spe_country_yearCollected.csv
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/spe_publishercountry_yearcollected hadoop/spe_publisherCountry_yearCollected.csv 
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/spe_yearcollected hadoop/spe_yearCollected.csv

  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/spe_country_repatriation hadoop/spe_country_repatriation.csv
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/spe_publishercountry_repatriation hadoop/spe_publisherCountry_repatriation.csv 
  hadoop dfs -getmerge /user/hive/warehouse/"$destination_db".db/spe_repatriation hadoop/spe_repatriation.csv
else 
  echo 'Skipping hadoop copy stage (add -runHadoop to command to run it)'
fi

if [ $runPrepare == "true" ];then
  echo 'Removing the reports output folder'
  rm -fr report

  echo 'Preparing the CSVs'
  Rscript R/csv/occ_kingdomBasisOfRecord.R 
  Rscript R/csv/occ_dayCollected.R 
  Rscript R/csv/occ_yearCollected.R 
  Rscript R/csv/occ_complete.R
  Rscript R/csv/occ_repatriation.R 
  Rscript R/csv/occ_cells.R 
  Rscript R/csv/spe_kingdom.R 
  Rscript R/csv/spe_dayCollected.R 
  Rscript R/csv/spe_yearCollected.R
  Rscript R/csv/spe_repatriation.R 
  
  # this should be removed when http://dev.gbif.org/issues/browse/POR-2455 is fixed
  rm -Rf report/country/UK
else 
  echo 'Skipping prepare CSV stage (add -runPrepare to command to run it)'
fi

if [ $runFigures == "true" ];then
  echo 'Generating the figures'
  Rscript R/report.R 
else
  echo 'Skipping create figures stage (add -runFigures to command to run it)'
fi 

if [ $runJson == "true" ];then
  echo 'Creating the Json'
  Rscript R/html-json/createJson.R 
else
  echo 'Skipping create json stage (add -runJson to command to run it)'
fi

if [ $runHtml == "true" ];then
  echo 'Creating the HTML'
  Rscript R/html-json/createHtml.R 
else
  echo 'Skipping create html stage (add -runHtml to command to run it)'
fi
