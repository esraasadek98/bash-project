 #!/bin/bash
mkdir DBMS 2>> ./.error.log

echo "Welcome To DBMS"
function mainMenu {
  echo -e "\n---------Main Menu-------------+"
  echo "1. create DB"
  echo "2. Connect DB"
  echo "3. Drop DB"
  echo "4. list  DBs"
  echo "5. Exit"
  echo -e "Enter Choice: \c"
  read ch
  case $ch in
    1)  createDB ;;
    2)  connectDB;;
    3)  dropDB ;;
    4)  ls ./DBMS ; mainMenu;;
    5) exit ;;
    *) echo " Wrong Choice " ; mainMenu;
  esac
}


function createDB {
  echo -e "Enter Database Name: \c"
  read dbName
  mkdir ./DBMS/$dbName
  if [[ $? == 0 ]]
  then
    echo "Database Created Successfully"
  else
    echo "Error Creating Database $dbName"
  fi
  mainMenu
}
function connectDB {
  echo -e "Enter Database Name: \c"
  read dbName
  cd ./DBMS/$dbName 2>>./.error.log
  if [[ $?==0 ]]; then
    echo "Database $dbName was Successfully Selected"
    tablesMenu
  else
    echo "Database $dbName wasn't found"
    mainMenu
  fi
}

function dropDB {
  echo -e "Enter Database Name: \c"
  read dbName
  rm -r ./DBMS/$dbName 2>>./.error.log
  if [[ $? == 0 ]]; then
    echo "Database Dropped Successfully"
  else
    echo "Database Not found"
  fi
  mainMenu
}
function tablesMenu {
  echo -e "\n---------Main Menu-------------+"
  echo "1. create table"
  echo "2. list tables"
  echo "3. Drop table"
  echo "4. insert into table"
  echo "5. select all "
  echo "6. selectCol"
  echo "7. delete from table"
  echo "8. update table"
  echo "9. Exit"
  echo -e "Enter Choice: \c"
  read ch
  case $ch in
    1)  createtable ;;
    2)  ls -1 $tableName; tablesMenu;;
    3)  dropTable ;;
    4)  insert;;
    5)  selectAll;;
    6)  selectCol;;
    7)  deleteFromTable;;
    8)  updateTable;;
    9)  exit ;;
    *)  echo " Wrong Choice " ; tablesMenu;
  esac
}
function createtable {
  echo -e "Table Name: \c"
  read tableName
  if [[ -f $tableName ]]; then
    echo "table already existed ,choose another name"
    tablesMenu
  fi
  echo -e "Number of Columns: \c"
  read colsNum
  counter=1
  sep="|"
  rSep="\n"
  pKey=""
  metaData="Field"$sep"Type"$sep"key"
  while [ $counter -le $colsNum ]
  do
    echo -e "Name of Column No.$counter: \c"
    read colName

    echo -e "Type of Column $colName: "
    select var in "int" "str"
    do
      case $var in
        int ) colType="int";break;;
        str ) colType="str";break;;
        * ) echo "Wrong Choice" ;;
      esac
    done
    if [[ $pKey == "" ]]; then
      echo -e "Make PrimaryKey ? "
      select var in "yes" "no"
      do
        case $var in
          yes ) pKey="PK";
          metaData+=$rSep$colName$sep$colType$sep$pKey;
          break;;
          no )
          metaData+=$rSep$colName$sep$colType$sep""
          break;;
          * ) echo "Wrong Choice" ;;
        esac
      done
    else
      metaData+=$rSep$colName$sep$colType$sep""
    fi
    if [[ $counter == $colsNum ]]; then
      temp=$temp$colName
    else
      temp=$temp$colName$sep
    fi
    ((counter++))
  done
  touch .$tableName

  echo -e $metaData  >> .$tableName
  touch $tableName
  echo -e $temp >> $tableName
  if [[ $? == 0 ]]
  then
    echo "Table Created Successfully"
    tablesMenu
  else
    echo "Error Creating Table $tableName"
    tablesMenu
  fi
}

function dropTable {
  echo -e "Enter Table Name: \c"
  read tName
  rm $tName .$tName 2>>./.error.log
  if [[ $? == 0 ]]
  then
    echo "Table Dropped Successfully"
  else
    echo "Error Dropping Table $tName"
  fi
  tablesMenu
}
function insert {
  echo -e "Table Name: \c"
  read tableName
  if ! [[ -f $tableName ]]; then
    echo "Table $tableName isn't existed ,choose another Table"
    tablesMenu
  fi
  colsNum=`awk 'END{print NR}' .$tableName`
  sep="|"
  rSep="\n"
  for (( i = 2; i <= $colsNum; i++ )); do
    colName=$(awk 'BEGIN{FS="|"}{ if(NR=='$i') print $1}' .$tableName)
    colType=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $2}' .$tableName)
    colKey=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $3}' .$tableName)
    echo -e "$colName ($colType) = \c"
    read data

    # Validate Input
    if [[ $colType == "int" ]]; then
      while ! [[ $data =~ ^[0-9]*$ ]]; do
        echo -e "invalid DataType !!"
        echo -e "$colName ($colType) = \c"
        read data
      done
    fi

    if [[ $colKey == "PK" ]]; then
      while [[ true ]]; do
        if [[ $data =~ ^[`awk 'BEGIN{FS="|" ; ORS=" "}{if(NR != 1)print $(('$i'-1))}' $tableName`]$ ]]; then
          echo -e "invalid input for Primary Key !!"
        else
          break;
        fi
        echo -e "$colName ($colType) = \c"
        read data
      done
    fi

    #Set row
    if [[ $i == $colsNum ]]; then
      row=$row$data$rSep
    else
      row=$row$data$sep
    fi
  done
  echo -e $row"\c" >> $tableName
  if [[ $? == 0 ]]
  then
    echo "Data Inserted Successfully"
  else
    echo "Error Inserting Data into Table $tableName"
  fi
  row=""
  tablesMenu
}
function selectAll {
  echo -e "Enter Table Name: \c"
  read tName
  column -t -s '|' $tName 2>>./.error.log
  if [[ $? != 0 ]]
  then
    echo "Error Displaying Table $tName"
  fi
  tablesMenu
}

function selectCol {
  echo -e "Enter Table Name: \c"
  read tName
  echo -e "Enter Column Number: \c"
  read colNum
  awk 'BEGIN{FS="|"}{print $'$colNum'}' $tName
  tablesMenu
}
function deleteFromTable {
  echo -e "Enter Table Name: \c"
  read tName
  echo -e "Enter Column_pk name: \c"
  read field
  f_pk=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tName)
  if [[ $f_pk == "" ]]
  then
    echo "Not Found"
    tablesMenu
  else
    echo -e "Enter Condition Value: \c"
    read val
    res=$(awk 'BEGIN{FS="|"}{if ($'$f_pk'=="'$val'") print $'$f_pk'}' $tName 2>>./.error.log)
    if [[ $res == "" ]]
    then
      echo "Value Not Found"
      tablesMenu
    else
      NR=$(awk 'BEGIN{FS="|"}{if ($'$f_pk'=="'$val'") print NR}' $tName 2>>./.error.log)
      sed -i ''$NR'd' $tName 2>>./.error.log
      echo "Row Deleted Successfully"
      tablesMenu
    fi
  fi
}
function updateTable {
  echo -e "Enter Table Name: \c"
  read tName
  echo -e "Enter Condition Column name: \c"
  read field
  fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tName)
  if [[ $fid == "" ]]
  then
    echo "Not Found"
    tablesMenu
  else
    echo -e "Enter Condition Value: \c"
    read val
    res=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print $'$fid'}' $tName 2>>./.error.log)
    if [[ $res == "" ]]
    then
      echo "Value Not Found"
      tablesMenu
    else
      echo -e "Enter FIELD name to set: \c"
      read setField
      setFid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$setField'") print i}}}' $tName)
      if [[ $setFid == "" ]]
      then
        echo "Not Found"
        tablesMenu
      else
        echo -e "Enter new Value to set: \c"
        read newValue
        NR=$(awk 'BEGIN{FS="|"}{if ($'$fid' == "'$val'") print NR}' $tName 2>>./.error.log)
        oldValue=$(awk 'BEGIN{FS="|"}{if(NR=='$NR'){for(i=1;i<=NF;i++){if(i=='$setFid') print $i}}}' $tName 2>>./.error.log)
        echo $oldValue
        sed -i ''$NR's/'$oldValue'/'$newValue'/g' $tName 2>>./.error.log
        echo "Row Updated Successfully"
        tablesMenu
      fi
    fi
  fi
}


mainMenu
tablesMenu
