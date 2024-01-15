echo $PATH
DIRECTORY="$PROTOCOL/$METHOD/$TRANSPORT/$TLS/"
cat <<EOF
::group::sing-box version
$(sing-box version)
::endgroup::
EOF
sing-box run -c $DIRECTORY/client.json >sing-box_client.log 2>&1 &
SING_CLIENT_PID=$!
if [[ "$PROTOCOL" == "vmess" ]];then
    DIRECTORY="$PROTOCOL/$TRANSPORT/$TLS/"
fi
if [[ "$PROTOCOL" != "direct" ]];then
    sing-box run -c $DIRECTORY/server.json >sing-box_server.log 2>&1 &
    SING_SERVER_PID=$!
fi
sleep 1
iperf3 -s 127.0.0.1 -p 5202 > iperf3_server.log 2>&1 &
SERVER_PID=$!
iperf3 -c 127.0.0.1 -p 5201 > iperf3_client.log 2>&1 &
CLIENT_PID=$!
wait $CLIENT_PID
kill $SERVER_PID $SING_SERVER_PID $SING_CLIENT_PID

cat <<EOF
::group::sing-box server log
$(cat sing-box_server.log)
::endgroup::
::group::sing-box client log
$(cat sing-box_client.log)
::endgroup::
::group::iperf3 server log
$(cat iperf3_server.log)
::endgroup::
::group::iperf3 client log
$(cat iperf3_client.log)
::endgroup::
EOF