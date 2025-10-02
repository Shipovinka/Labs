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

YEAR=$(date | awk '{print $6}')
MON=$(date +%m)
DAY=$(date | awk '{print $3}')
#echo $YEAR-$DAY-$MON
FILENAME=system_report_$YEAR-$DAY-$MON.csv
#echo $FILENAME

PARAM=$1
if [ "$PARAM" = "START" ]; then
	if [ -f "lab2_log.txt" ]; then 
		count=$(< lab2_log.txt)
	else
		touch lab2_log.txt
		count=0
	fi
	if [ "$count" = "$!" ]; then
		monitoring &
	fi
	echo $!
	echo $! > lab2_log.txt
	
elif [ "$PARAM" = "STATUS" ]; then
	count=$(ps aux | grep "lab2.sh" | grep -v grep | grep -v $$ | wc -l) #исключили процесс, который проверяет статус (grep с именем процесса) и считаем только фоновые процессы
	if [ $count -ge 2 ]; then
        echo "lab2.sh is running"
    else
        echo "lab2.sh is not running"
    fi
	
elif [ "$PARAM" = "STOP" ]; then
	kill -9 $(ps aux | grep "lab2.sh" | grep -v grep | awk '{print $2}')
else
	exit 0
fi


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