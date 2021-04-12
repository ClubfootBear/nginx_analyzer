#! /bin/bash
echo "Start of script" 

array_lenght=$(cat "$1" | wc -l)
echo "array_lenght: $array_lenght" 


prc_1=$(echo "scale=4; $array_lenght * 0.01" | bc | sed -e 's/^\./0./' -e 's/^-\./-0./' | grep -E -o "[0-9]{1,}")

prc_5=$(echo "scale=4; $array_lenght * 0.05" | bc | sed -e 's/^\./0./' -e 's/^-\./-0./' | grep -E -o "[0-9]{1,}")
prc_10=$(echo "scale=4; $array_lenght * 0.1" | bc | sed -e 's/^\./0./' -e 's/^-\./-0./' | grep -E -o "[0-9]{1,}")
prc_20=$(echo "scale=4; $array_lenght * 0.2" | bc | sed -e 's/^\./0./' -e 's/^-\./-0./' | grep -E -o "[0-9]{1,}")
prc_80=$(echo "scale=4; $array_lenght * 0.8" | bc | sed -e 's/^\./0./' -e 's/^-\./-0./' | grep -E -o "[0-9]{1,}")
prc_90=$(echo "scale=4; $array_lenght * 0.9" | bc | sed -e 's/^\./0./' -e 's/^-\./-0./' | grep -E -o "[0-9]{1,}")
prc_99=$(echo "scale=4; $array_lenght * 0.99" | bc | sed -e 's/^\./0./' -e 's/^-\./-0./' | grep -E -o "[0-9]{1,}")


# function anomaly() {
# }




array_rt=$(grep -E -o "\brt=\b[0-9]{0,}.[0-9]{1,}" $(echo "$1") | grep -E -o "[0-9]{1,}.[0-9]{1,}")
array_uct=$(grep -E -o 'uct="[0-9]{0,}.[0-9]{1,}"' $(echo "$1") | grep -E -o "[0-9]{1,}.[0-9]{1,}")
array_uht=$(grep -E -o 'uht="[0-9]{0,}.[0-9]{1,}"' $(echo "$1") | grep -E -o "[0-9]{1,}.[0-9]{1,}")
array_urt=$(grep -E -o 'urt="[0-9]{0,}.[0-9]{1,}"' $(echo "$1") | grep -E -o "[0-9]{1,}.[0-9]{1,}")



anomaly_rt15=$(echo "$array_rt" | sort -rh | head -n 15)
anomaly_uct15=$(echo "$array_uct" | sort -rh | head -n 15)
anomaly_uht15=$(echo "$array_uht" | sort -rh | head -n 15)
anomaly_urt15=$(echo "$array_urt" | sort -rh | head -n 15)

# echo "15 numbers of the top"
# echo $array_rt15



function anomaly() {
  local count=0

  local newarray
  newarray=("$@")

  local newarray_anomaly
  newarray_anomaly=$(echo "$newarray" | sort -rh | head -n $2)

  #local array_count
  #array_count=$(echo "$newarray" | wc -l)

  #prc="$2"
  # echo "prc: $prc"

  for i in $newarray_anomaly
    do
      count=$(echo "scale=4; $count + $i" | bc)
    done

  echo $(echo "scale=4; $count / $2" | bc | sed -e 's/^\./0./' -e 's/^-\./-0./')
}

function percentile() {
  local count=0

  local newarray
  newarray=("$@")

  local newarray_prcntl
  newarray_prcntl=$(echo "$newarray" | sort -rh | tail -n $2)

  #local array_count
  #array_count=$(echo "$newarray" | wc -l)

  #prc="$2"
  #echo "prc: $prc"

  for i in $newarray_prcntl
    do
      count=$(echo "scale=4; $count + $i" | bc)
    done
  
  #echo "count $count"
  echo $(echo "scale=4; $count / $2" | bc | sed -e 's/^\./0./' -e 's/^-\./-0./')
}



echo "Начинаем считать Аномали_1"
anomaly_1_rt=$(anomaly "${array_rt[*]}" $prc_1)
anomaly_1_uct=$(anomaly "${array_uct[*]}" $prc_1)
anomaly_1_uht=$(anomaly "${array_uht[*]}" $prc_1)
anomaly_1_urt=$(anomaly "${array_urt[*]}" $prc_1)
echo "Посчитали Аномали_1"

echo "Начинаем считать Перцентиль_80"
percentile_80_rt=$(percentile "${array_rt[*]}" $prc_80)
percentile_80_uct=$(percentile "${array_uct[*]}" $prc_80)
percentile_80_uht=$(percentile "${array_uht[*]}" $prc_80)
percentile_80_urt=$(percentile "${array_urt[*]}" $prc_80)
echo "Посчитали Перцентиль_80"

echo "Начинаем считать Перцентиль_99"
percentile_99_rt=$(percentile "${array_rt[*]}" $prc_99)
percentile_99_uct=$(percentile "${array_uct[*]}" $prc_99)
percentile_99_uht=$(percentile "${array_uht[*]}" $prc_99)
percentile_99_urt=$(percentile "${array_urt[*]}" $prc_99)
echo "Посчитали Перцентиль_99"

#echo "$percntl_1;5;7; $(echo $array_rt15)" > res.xls

echo "Anomaly_rt;Anomaly_uct;Anomaly_uht;Anomaly_urt;" > res.xls
echo "$anomaly_1_rt;$anomaly_1_uct;$anomaly_1_uht;$anomaly_1_urt" >> res.xls
echo " ; ; ; ;" >> res.xls

echo "Top_15_Anomaly_rt;Top_15_Anomaly_uct;Top_15_Anomaly_uht;Top_15_Anomaly_urt;" >> res.xls
echo "$(echo $anomaly_rt15);$(echo $anomaly_uct15);$(echo $anomaly_uht15);$(echo $anomaly_urt15);" >> res.xls
echo " ; ; ; ;" >> res.xls

echo "Percentile_80_rt;Percentile_80_uct;Percentile_80_uht;Percentile_80_urt;" >> res.xls
echo "$percentile_80_rt;$percentile_80_uct;$percentile_80_uht;$percentile_80_urt" >> res.xlsecho " ; ; ; ;" >> res.xls
echo " ; ; ; ;" >> res.xls

echo "Percentile_99_rt;Percentile_99_uct;Percentile_99_uht;Percentile_99_urt;" >> res.xls
echo "$percentile_99_rt;$percentile_99_uct;$percentile_99_uht;$percentile_99_urt" >> res.xlsecho " ; ; ; ;" >> res.xls
echo " ; ; ; ;" >> res.xls

echo "Finish"