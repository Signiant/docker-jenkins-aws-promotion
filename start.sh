#!/bin/bash

for FILENAME in /credentials/*.tar; do
	tar xvpf /credentials/$FILENAME -C /home/$BUILD_USER
done

#start sshd
/usr/sbin/sshd -D