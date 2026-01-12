#!/bin/zsh

# ПУТИ (настрой под себя)
BASE_DIR="$HOME/Desktop/mastery-journey"
PLAN_FILE="$BASE_DIR/plan.md"
REPORT_FILE="$BASE_DIR/report.md"
CYCLE_FILE="$BASE_DIR/cycle.md"
LAB_DIR="$BASE_DIR/laboratory"
SUB_DIR="$BASE_DIR/substrate"

# ЦВЕТА
green='\033[0;32m'
blue='\033[0;34m'
yellow='\033[0;33m'
red='\033[0;31m'
nc='\033[0m'

case $1 in
  "start")
    DAY=$2
    if [[ -z $DAY ]]; then echo "${red}Ошибка: укажи день (D01-D07)${nc}"; exit 1; fi

    echo "# ОПЕРАТИВНЫЙ ПЛАН: $DAY ($(date +'%A, %d.%m.%y' | tr '[:lower:]' '[:upper:]'))" > $PLAN_FILE
    echo "**СТАРТ**: $(date +%H:%M) | **ЛОКАЦИЯ**: $BASE_DIR\n" >> $PLAN_FILE

    # Достаем крючок из последнего отчета
    LAST_HOOK=$(grep "**🪝 КРЮЧОК**" $REPORT_FILE | tail -n 1 | sed 's/.*🪝 КРЮЧОК\*\*://' | xargs)
    if [[ -n $LAST_HOOK ]]; then
      echo "## ⚡️ КРЮЧОК С ПРОШЛОГО ЗАНЯТИЯ:\n> $LAST_HOOK\n" >> $PLAN_FILE
    fi

    # Парсим дисциплины из cycle.md
    DAY_IDX=$(echo $DAY | sed 's/D0//;s/D//')
    COL_NUM=$((DAY_IDX + 1))
    grep "^| [0-9]" $CYCLE_FILE | while read -r line; do
      VAL=$(echo "$line" | awk -F'|' "{print \$$((COL_NUM+1))}" | xargs)
      if [[ "$VAL" =~ [1-9] ]]; then
        DISC=$(echo "$line" | awk -F'|' '{print $2}' | xargs)
        SHORT_NAME=$(echo "$DISC" | awk '{print $2}' | tr '[:upper:]' '[:lower:]' | sed 's/&/n/')
        echo "## $DISC ($VAL ч)" >> $PLAN_FILE
        echo "- [ ] Тема/Теория (substrate/$SHORT_NAME)" >> $PLAN_FILE
        echo "- [ ] Практика (laboratory/$SHORT_NAME)" >> $PLAN_FILE
        echo "" >> $PLAN_FILE
        mkdir -p "$LAB_DIR/$SHORT_NAME" "$SUB_DIR/$SHORT_NAME"
      fi
    done
    echo "${green}Система запущена. Начни с крючка:${nc} $LAST_HOOK"
    ;;

  "edit")
    micro "$PLAN_FILE"
    ;;

  "status")
    echo "${blue}--- ТЕКУЩИЙ ПРОГРЕСС ---${nc}"
    DONE=$(grep -c "\[x\]" $PLAN_FILE)
    TOTAL=$(grep -c "\[.\]" $PLAN_FILE)
    echo "Выполнено: $DONE из $TOTAL"
    echo "------------------------"
    sed -n '/##/,$p' $PLAN_FILE
    ;;

  "sync")
    MSG=${2:-"daily update"}
    DAY_TAG=$(grep "ОПЕРАТИВНЫЙ ПЛАН" $PLAN_FILE | awk '{print $3}')
    git add .
    git commit -m "report: daily sync $DAY_TAG + $MSG"
    git push
    echo "${green}Зеленый квадрат подтвержден.${nc}"
    ;;

  "finish")
        echo "${yellow}--- ЗАВЕРШЕНИЕ ДНЯ (Final Delta Edition) ---${nc}"
        
        # 1. Замер времени
        FINISH_TIME=$(date +%H:%M)
        START_TIME=$(grep "**СТАРТ**" $PLAN_FILE | sed -E 's/.*\*\*СТАРТ\*\*:[ ]?([0-9]{2}:[0-9]{2}).*/\1/')
        
        if [[ -n $START_TIME ]]; then
            start_ts=$(date -d "$START_TIME" +%s)
            finish_ts=$(date -d "$FINISH_TIME" +%s)
            diff=$(( (finish_ts - start_ts) / 60 ))
            DURATION="$((diff / 60))ч $((diff % 60))м"
        else
            DURATION="не определено"
        fi
    
        # 2. Аналитика
        echo -n "${yellow}Чему научился (резюме)?${nc} "
        read SUMMARY
        echo -n "${yellow}Твой 'крючок' на завтра?${nc} "
        read HOOK
        
        DAY_TAG=$(grep "ОПЕРАТИВНЫЙ ПЛАН" $PLAN_FILE | head -n 1 | awk '{print $3}')
        TEMP_DAILY="$BASE_DIR/temp_daily.md"
    
        # 3. Сборка отчета (Парсер с поддержкой RU/EN 'x' и вложенности)
        {
          echo "# 🏁 REPORT: $(date +'%Y-%m-%d') ($DAY_TAG)"
          echo "> **ВРЕМЯ**: $START_TIME — $FINISH_TIME | **ЗАТРАЧЕНО**: $DURATION"
          echo "> **🎯 РЕЗЮМЕ**: $SUMMARY"
          echo "> **🪝 КРЮЧОК**: $HOOK"
          echo "\n---"
          
          echo "\n### ✅ ВЫПОЛНЕНО (Achievements):"
          # Регулярка [xXхХ] ловит и английскую, и русскую "Х"
          awk '
            /^## / { last_h=$0; h_printed=0; in_print=0 }
            /\[[xXхХ]\]/ { 
                if(!h_printed) { print "\n"last_h; h_printed=1 }
                print; in_print=1; next 
            }
            /\[[[:space:]]\]/ { in_print=0; next }
            /^[[:space:]]+/ { if(in_print) print }
            /^$/ { if(in_print) print "" }
          ' $PLAN_FILE
    
          echo "\n\n### ⏳ ОСТАТОК (Backlog/Debt):"
          awk '
            /^## / { last_h=$0; h_printed=0; in_print=0 }
            /\[[[:space:]]\]/ { 
                if(!h_printed) { print "\n"last_h; h_printed=1 }
                print; in_print=1; next 
            }
            /\[[xXхХ]\]/ { in_print=0; next }
            /^[[:space:]]+/ { if(in_print) print }
            /^$/ { if(in_print) print "" }
          ' $PLAN_FILE
          echo "\n\n"
        } > $TEMP_DAILY
    
        # 4. Склейка (LIFO)
        if [[ -f $REPORT_FILE ]]; then
            cat $TEMP_DAILY $REPORT_FILE > "$REPORT_FILE.tmp" && mv "$REPORT_FILE.tmp" $REPORT_FILE
        else
            mv $TEMP_DAILY $REPORT_FILE
        fi
        rm -f $TEMP_DAILY
    
        # 5. Git и Очистка
        echo "${blue}Синхронизирую...${nc}"
        git add $REPORT_FILE $PLAN_FILE
        git commit -m "report: $DAY_TAG duration: $DURATION"
        
        if git push; then
            echo "${green}Все в облаке. Чищу стол.${nc}"
            find $LAB_DIR -mindepth 1 -delete
            find $SUB_DIR -mindepth 1 -delete
            echo "План на сегодня выполнен." > $PLAN_FILE
        else
            echo "${red}Ошибка Git! Папки не очищены.${nc}"
            exit 1
        fi
        ;;
  *)
    echo "Команды: start [D..], edit, status, sync [msg], finish"
    ;;
esac
