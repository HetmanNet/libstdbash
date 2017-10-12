#!/bin/bash

# Viktor Matvieienko <viktor.matvieienko@gmail.com> 2017
# LibStdBash

# Перевірка методу використання
if [ `basename "$0"` == "libstdbash.sh" ]
then
	echo "This is not a script, it's a library!"
	exit 1
fi

# Вивід інформації (ведення логу та сповіщення користувача)
function libstdbash_print {

	# за умовчання
	local facility="user"
	local level
	local mesg="empty"
	local name="libstdbash"
	local pid_in_systemd
	local prev_mesg

	# приймаємо вхідну строку
	mesg="'$*'"

	# визначаємо тип повідомлення
	local type="`echo $mesg | cut -f 1 -d " "`"
	case ${type:1} in
		ERROR|ERR )
			level="error"
			prev_mesg="\e[1;41m::  ERROR  ::\e[0m \t\e[0;31m"
			;;
		WARNING|WARN )
			level=${type,,}
			prev_mesg="\e[1;31m:: WARNING ::\e[0m"
			;;
		INFO )
			level="notice"
			prev_mesg="\e[1;93m:: NOTICE  ::\e[0m"
			;;
		DEBUG )
			level=${type,,}
			prev_mesg="\e[1;107m::  DEBUG  ::\e[0m"
			;;
		* )
			level="info"
			prev_mesg="\e[1;97m::  INFO   ::\e[0m"
			;;
	esac
	if [ "$level" != "info" ]
	then
		mesg=${mesg#$type}
		mesg=${mesg::-1}
	fi

	# перевіряємо чи запущено через systemd
	name="`basename "$0"`"
	name=${name%.sh}
	pid_in_systemd="`systemctl -p \"MainPID\" show "$name".service 2>/dev/null`"
	if [ $? -eq 0 ]
	then
		if [ ${pid_in_systemd:8} -eq $$ ]
		then
        		facility="deamon"
			systemctl is-active $name.timer
			if [ $? -eq 0 ]
			then
				facility="cron"
			fi
		fi
	fi

	# визначаємо чи працюємо в терміналі користувача
	tty -s
	if [ $? -eq 0 ]
	then
		echo -e "$prev_mesg $mesg \e[0m"
	fi

	# вивід до логу
	prev_mesg="`echo $prev_mesg | cut -f 2 -d " "`"
	logger --id=$$ -t "`basename "$0"`" -p $facility.$level [$prev_mesg] $mesg
}

