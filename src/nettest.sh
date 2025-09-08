#!/usr/bin/bash

# ------------------------------
# Зависимости: jq curl iproute2
# ------------------------------

CURL_TIMEOUT=1
RESTART_TIMEOUT=60

C_OFF='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_WHITE='\033[0;97m'
C_GRAY='\033[0;37m'


main() {
	clear
	show_header
	show_isp

	# Проверка доступности
	echo -e "   $C_GREEN▄$C_OFF"

	# Требуются права root
	#gateway=`sudo ip route get 8.8.8.8 | awk '{print $3}' | head -1`
	#test_host "$gateway"       "Роутер\t"

	test_host "ya.ru"          "РуНет\t"
	test_host "google.com"     "Интернет\t"
	test_host "medium.com"    "Настоящий интернет"   last
}


# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=


show_isp() {
	# Защита от поисковиков, выдраны с сайта SpeedTest от РТ
	secret_1=`echo aHR0cHM6Ly93d3cucW1zLnJ1L2FwaS9hc25fcHJvdmlkZXIvYXNuCg== | base64 -d`
	secret_2=`echo WC1BUEktS2V5OiBmODVmMTJiOTQyYWIwYTg4MThlYjY2ZDY0YjI0NGVlNQo= | base64 -d`

	result=`curl -m$CURL_TIMEOUT -s -H "$secret_2" "$secret_1"`
	ret=$?

	echo ""
	if [[ $ret == 0 ]]
	then
		echo -e "   ⦿ IP адрес:\t\t\t$C_GRAY`echo $result | jq -r .ip`$C_OFF"
		echo -e "   ⦿ Интернет-провайдер:\t$C_GRAY`echo $result | jq -r .provider_name`$C_OFF"
	else
		echo -e "   $C_RED⦿$C_OFF Не удалось определить IP и провайдера"
	fi
	echo ""
}


test_host() {
	curl -sm$CURL_TIMEOUT $1 > /dev/null 2>&1
	ret=$?

	if [[ "$ret" == "0" ]]
	then
		echo -e "   $C_GREEN█$C_OFF $C_WHITE$2\t\t$C_GRAY$1$C_OFF"
		[[  "$3" == "last" ]] && echo -e "   $C_GREEN▀$C_OFF"
	else
		echo -e "   $C_RED█ $2\t\t$C_GRAY$1$C_OFF"
		[[  "$3" == "last" ]] && echo -e "   $C_RED▀$C_OFF"
	fi
}


show_header() {
	echo ""
	echo -e "\e[38;5;71m  ┏━┓╻ ╻┏┓╻┏━╸╺┳╸   ┏━┓┏━┓┏━┓┏━╸"
	echo -e "\e[38;5;77m  ┣┳┛┃ ┃┃┗┫┣╸  ┃    ┏━┛┃┃┃┏━┛┗━┓"
	echo -e "\e[38;5;83m  ╹┗╸┗━┛╹ ╹┗━╸ ╹    ┗━╸┗━┛┗━╸┗━┛$C_OFF"
}


while true
do
	main

	echo ""
	echo -e "   \e[38;5;157mНажмите Enter для выхода, иначе проверка$C_OFF"
	echo -e "   \e[38;5;194mбудет перезапущена через $RESTART_TIMEOUT сек...$C_OFF"
	echo ""

	read -t $RESTART_TIMEOUT ret
	if [[ $? -lt 128 ]]
	then
		exit 0
	fi
done