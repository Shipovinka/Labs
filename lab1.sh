#!/bin/bash

REP="$1"
BRANCH1="$2"
BRANCH2="$3"
FILE=tmp_lab3.txt
touch $FILE
echo "$REP" > "$FILE"
PATH1=$(grep -oP "[^/]+(?=\.git)" "$FILE")
#echo "$PATH1"
rm -f "$FILE"
git clone "$REP" 2>/dev/null
if test -d "$PATH1"; then
	cd "$PATH1"
	git fetch --all
	if git ls-remote --exit-code --heads origin "$BRANCH1" >/dev/null &&
   git ls-remote --exit-code --heads origin "$BRANCH2" >/dev/null; then
		REPORT_FILE="../diff_report_${BRANCH1}_vs_${BRANCH2}.txt"
		touch "$REPORT_FILE"
		git diff "origin/$BRANCH1" "origin/$BRANCH2" > "$REPORT_FILE"
		echo "Open diff_report_${BRANCH1}_vs_${BRANCH2}.txt to see difference between branches"
	else
		echo "No such branch"
		exit 1
	fi
else
	echo "Can't clone repository"
	exit 1
fi

#Нужно написать ряд shell скриптов:
# Написать shell файл, который принимает на вход три параметра: ссылку на удаленный репозиторий, имя ветки 1 и имя ветки 2. 
#На выходе формирует TXT файл со списком файлов которые отличаются между ветками. 
#Файл формируется в формате diff_report_<BRANCH_1>_vs_<BRANCH_2>.txt (например, diff_report_main_develop.txt). Отчет должен содержать структурированную информацию о 
#различиях.
#Пример выходного отчета:
# Отчет о различиях между ветками
#================================
# Реопзиторий:    https://github.com/example/project.git
# Ветка 1:     main
# Ветка 2:        
# develop
# Дата генерации: 2023-10-25 14:30:15
# ================================
# СПИСОК ИЗМЕНЕННЫХ ФАЙЛОВ:
# A       
#src/new_feature.py
# M       README.md
# D       old_script.sh
# M       config/config.yaml
# СТАТИСТИКА:
# Всего измененных файлов: 4
# Добавлено (A):    1
# Удалено (D):      1
# Изменено (M):     2
