#!/bin/bash
apt-get install -y strace

if [ $? -ne 0 ]; then
	exit 1
fi