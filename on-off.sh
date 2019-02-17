#!/bin/sh

esc=$(printf '\033')
sed -e "s,\\<on\\>,${esc}[32m&${esc}[0m," \
    -e "s,\\<off\\>,${esc}[31m&${esc}[0m,"
