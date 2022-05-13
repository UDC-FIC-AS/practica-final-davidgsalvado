#!/bin/bash
IP=$1

# DBs
gnome-terminal --tab --title="Messages database" -- bash -c "iex --name m_db@$IP --cookie a_cookie -S mix; $SHELL"
gnome-terminal --tab --title="Users database" -- bash -c "iex --name u_db@$IP --cookie a_cookie -S mix; $SHELL"

# Services
gnome-terminal --tab --title="Message Service 2" -- bash -c "iex --name s_m2@$IP --cookie a_cookie -S mix; $SHELL"
gnome-terminal --tab --title="Message Service 1" -- bash -c "iex --name s_m1@$IP --cookie a_cookie -S mix; $SHELL"
gnome-terminal --tab --title="User Service 1" -- bash -c "iex --name s_u1@$IP --cookie a_cookie -S mix; $SHELL"

# Load Balancers
gnome-terminal --tab --title="Message Load Balancer 2" -- bash -c "iex --name lb_m2@$IP --cookie a_cookie -S mix; $SHELL"
gnome-terminal --tab --title="Message Load Balancer 1" -- bash -c "iex --name lb_m1@$IP --cookie a_cookie -S mix; $SHELL"
gnome-terminal --tab --title="User Load Balancer 1" -- bash -c "iex --name lb_u1@$IP --cookie a_cookie -S mix; $SHELL"

# Directory
gnome-terminal --tab --title="Directory" -- bash -c "iex --name dir@$IP --cookie a_cookie -S mix; $SHELL"

# Clients
gnome-terminal --tab --title="Client 2" -- bash -c "iex --name c_2@$IP --cookie a_cookie -S mix; $SHELL"
gnome-terminal --tab --title="Client 1" -- bash -c "iex --name c_1@$IP --cookie a_cookie -S mix; $SHELL"

#Config
gnome-terminal --tab --title="Configuration" -- bash -c "iex --name config@$IP --cookie a_cookie -S mix; $SHELL"
