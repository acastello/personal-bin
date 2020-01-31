#!/bin/sh

time {
read -sn1 -p "Press any key to start"
echo -en "\r"
read -n1 -p "Press any key to stop "
}
