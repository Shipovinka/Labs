#!/bin/bash

function monitoring {
	while true; do
		free -g | grep "Mem:" | awk '{printf "Total mem: %d; ", $2}' > $FILENAME
		free -g | grep "Mem:" | awk '{printf "Free mem: %d; ", $4}' >> $FILENAME
		free | grep "Mem" | awk '{printf "Usage mem: %.1f%%; ", $3/$2 * 100}' >> $FILENAME
		top -bn1 | grep "Cpu(s)" | awk '{printf "CPU usage: %.1f%%; ", 100 - $8}' >> $FILENAME
		df -h / | grep "Use%" | awk '{printf "Root/Disk usage: $5.0%; "}' >> $FILENAME
		uptime | awk '{printf "Load average per min: %.2f\n", $(NF-2)}' >> $FILENAME
		sleep 600
	done
}
CUR_DIR=($pwd)
YEAR=$(date | awk '{print $6}')
MON=$(date +%m)
DAY=$(date | awk '{print $3}')
#echo $YEAR-$DAY-$MON
FILENAME=system_report_$YEAR-$DAY-$MON.csv
#echo $FILENAME
FILE=lab2_log.txt

PARAM=$1
cd $HOME
if [ "$PARAM" = "START" ]; then

	if [ -f "lab2_log.txt" ]; then 
		current_id=$(< "$FILE")
		if kill -0 "$current_id" 2>/dev/null; then
			echo "lab2.sh is already started"
		else
			monitoring &
			current_id=$!
			echo $current_id > "$FILE"
			echo $current_id
		fi
	else
		monitoring &
		current_id=$!
		echo $current_id > "$FILE"
		echo $current_id
		
	fi

elif [ "$PARAM" = "STATUS" ]; then
	
	if [ -f "$FILE" ]; then
		current_id=$(< "$FILE")
		if kill -0 "$current_id" 2>/dev/null; then
			echo "lab2.sh is running"
		else
			echo "lab2.sh is not running"
		fi
	else
		echo "lab2.sh is not running"
	fi
	
elif [ "$PARAM" = "STOP" ]; then
	if [ -f "lab2_log.txt" ]; then
		current_id=$(< "$FILE")
		if kill -0 "$current_id" 2>/dev/null; then
			kill -9 "$current_id"
			rm -f "$FILE"
			echo "lab2.sh killed"
		fi
	else
		echo "lab2.sh was not started, nothing to kill"
	fi
else
	exit 0
fi
cd "$CUR_DIR"

#BASH – Лабораторная (2/3) 
#Написать shell файл, который принимает на вход три параметра #START|STOP|STATUS. 
#START запускает его в фоне и выдает PID процесса, 
#STATUS выдает состояние - запущен/нет, 
#STOP - останавливает PID
# При запуске скрипт должен проверять, не запущен ли уже другой его экземпляр, чтобы избежать дублирования
# Основные функции скрипта.  Мониторинг нескольких метрик:
# Скрипт должен каждые 10 минут собирать следующие данные:
# Память: общий объем, свободный объем, процент использования.
# ЦПУ: общая загрузка процессора (в процентах).
# Диск: использование корневого раздела (/) в процентах.
# Нагрузка: средняя нагрузка на систему за 1 минуту.
# Скрипт должен записывать данные в CSV-файл с именем system_report_YYYY-MM-DD.csv (где YYYY-MM-DD - текущая 
#дата). Формат строки:
# timestamp;all_memory;free_memory;%memory_used;%cpu_used;%disk_used;load_average_1m