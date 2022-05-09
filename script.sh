#!/bin/bash
IP=$1
gnome-terminal --tab --title="Client" -- bash -c "iex --name client@$IP --cookie a_cookie -S mix; $SHELL" #client
gnome-terminal --tab --title="Directory" -- bash -c "iex --name dir@$IP --cookie a_cookie -S mix; $SHELL" #directory
gnome-terminal --tab --title="User Load Balancer" -- bash -c "iex --name lb_u1@$IP --cookie a_cookie -S mix; $SHELL" #user load balancer
gnome-terminal --tab --title="Message Load Balancer" -- bash -c "iex --name lb_m1@$IP --cookie a_cookie -S mix; $SHELL" #message load balancer
gnome-terminal --tab --title="User Service" -- bash -c "iex --name s_u1@$IP --cookie a_cookie -S mix; $SHELL" #user service
gnome-terminal --tab --title="Message Service" -- bash -c "iex --name s_m1@$IP --cookie a_cookie -S mix; $SHELL" #message service
gnome-terminal --tab --title="Users database" -- bash -c "iex --name u_db@$IP --cookie a_cookie -S mix; $SHELL" #users database
gnome-terminal --tab --title="Messages database" -- bash -c "iex --name m_db@$IP --cookie a_cookie -S mix; $SHELL" #messages database
