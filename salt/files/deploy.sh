#!/bin/bash
RN=/ton-node/ton_node_no_kafka
EXTRA_ARGS=
TD=`dirname $RN`
RNGIT=~/git/rustnet/docker-compose/ton-node
CONFIGS_DIR=$TD/configs
CONFD=$TD/setup
CPCMD=ln #you can set it to "ln" or "cp" in case of different partitions

export ADNL_PORT="39393"
export NETWORK_TYPE="rustnet.ton.dev"
export RCONSOLE_PORT="3931"

cd $TD && rm -fr ./*
for D in tools logs db configs `basename $CONFD`
do
  [ ! -d $TD/$D ] && mkdir $TD/$D
done

cd ~/git
$CPCMD ton-node/target/release/ton_node $RN
$CPCMD tools/target/release/console $TD/tools/
$CPCMD tools/target/release/keygen $TD/tools/
$CPCMD tonos-cli/target/release/tonos-cli $TD/tools/

cp -a $RNGIT/scripts $TD/
cp -a $RNGIT/configs $TD/

cd /ton-node
cp ~/git/fld.ton.dev/configs/rustnet.ton.dev/ton-global.config.json configs/
cd configs && ../tools/tonos-cli config --url="https://${NETWORK_TYPE}"

NODE_IP_ADDR=""
until [[ "$(echo "${NODE_IP_ADDR}" | grep "\." -o | wc -l)" -eq 3 ]]; do
    NODE_IP_ADDR="$(curl -sS ipv4bot.whatismyipaddress.com)"
done

cat ${CONFIGS_DIR}/default_config.json | jq \
".log_config_name = \"$CONFD/log_cfg.yml\" | \
.ton_global_config_name = \"$CONFD/ton-global.config.json\" | \
.internal_db_path = \"${TD}/db\" | \
.ip_address = \"${NODE_IP_ADDR}:${ADNL_PORT}\" | \
.control_server_port = $RCONSOLE_PORT" > ${CONFD}/default_config.json

sed -E 's/target\/log(\/tvm.log)/\'${TD}'\/logs\/\1/' \
  ${CONFIGS_DIR}/log_cfg.yml > ${CONFD}/log_cfg.yml

$TD/tools/keygen > ${CONFD}/${HOSTNAME}_console_client_keys.json
jq -c '.public' ${CONFD}/${HOSTNAME}_console_client_keys.json \
  > ${CONFD}/console_client_public.json

export CALL_RN="$RN --configs ${CONFD}"
echo -n "---INFO: Genegate Rnode config.json..."
$CALL_RN --ckey "$(cat "${CONFD}/console_client_public.json")" &
sleep 10
pkill $RN &>/dev/null

for CF in config.json console_config.json
do
if [ ! -f "${CONFD}/$CF" ]; then
    echo "###-ERROR: ${CONFD}/$CF does not created!"
    exit 1
fi
done

jq ".client_key = $(jq .private "${CONFD}/${HOSTNAME}_console_client_keys.json")" \
  "${CONFD}/console_config.json" > console_config.json.tmp
jq ".config = $(cat console_config.json.tmp)" \
  "${CONFIGS_DIR}/console_template.json" >"${CONFD}/console.json" && rm -f console_config.json.tmp


cat <<THECONTENT > ${CONFD}/ton-node.service
[Unit]
Description=TON Node
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=always
RestartSec=1
User=$USER
StandardOutput=append:${TD}/logs/node.log
StandardError=append:${TD}/logs/node.log
LimitNOFILE=2048000
ExecStart=$RN --configs "${CONFD}" ${EXTRA_ARGS}
[Install]
WantedBy=multi-user.target

THECONTENT


