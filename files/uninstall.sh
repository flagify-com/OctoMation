#!/bin/bash

basedir=$(
  cd "$(dirname "$0")"
  pwd
)
current_name=$0
current_name=${current_name##*/}

RED="\033[31m"
ENDCOLOR="\033[0m"

function printLine() {
  echo -e "${RED}${1}${ENDCOLOR}"
}
silence=0
verbose=0
show_usage="args: \n \
  -s | --silence) silence表示是否静默卸载, 默认为0, 0表示非静默卸载, 1表示静默，推荐使用0 \n \
  -v | --verbose) verbose表示是否输出详细信息, 默认为0, 0表示不输出 \n \
  -h | --help )  \n "

OPT_ARGS=$(getopt -o s:v:h -al silence:,verbose:,help -- "$@")

basedir=$(
  cd "$(dirname "$0")"
  pwd
)
#if [[ "$is_docker" == "1" ]]; then
#    decompress_path=$basedir
#    backup_dir=$basedir
#    install_dir=$basedir
#fi

ret_code="$?"
if [[ "$ret_code" != 0 ]]; then
  printLine "args parse error: \n $show_usage"
  exit 1
fi

# echo "$OPT_ARGS"
eval set -- "$OPT_ARGS"

while [ -n "$1" ]; do
  case "$1" in
  -s | --silence)
    silence=$2
    shift 2
    ;;
  -v | --verbose)
    verbose=$2
    shift 2
    ;;
  -h | --help)
    echo -e "$show_usage"
    exit 1
    ;;
  --) break ;;
  *)
    echo -e "$1", "$2", "$show_usage"
    exit 1
    ;;
  esac
done
if [[ "${silence}" != "0" && "${silence}" != "1" ]]; then
  printLine "silence 只能为0/1，当前传入值为:${silence}，不合法"
  exit 1
elif [[ "${silence}" == "1" ]]; then
  prompt=0
else
  prompt=1
fi

if [[ "${verbose}" != "0" && "${verbose}" != "1" ]]; then
  printLine "verbose 只能为0/1，当前传入值为:${verbose}，不合法"
  exit 1
elif [[ "${verbose}" == "1" ]]; then
  set -x
fi

local_ip=$(ip a | grep -w 'inet' | grep 'global' | sed 's/^.*inet //g' | sed 's/\/[0-9].*$//g' | head -n 1)
if test -z ${local_ip}; then
  local_ip=127.0.0.1
fi
appenv=$SHAKESPEARE_HOME
if test -z $appenv; then
  appenv=/opt/shakespeare
fi
py_home=/opt/honeyguide_docker_python

function promot() {
  if [[ "${prompt}" == "0" ]]; then
    echo "silence mode,just remove"
    return
  fi
  while true; do
    read -p "confirm uninstall shakespeare[${local_ip}],will remove all data created by shakespeare and ai ? please enter the ip address for uninstall,N/n for skip : " yn
    case $yn in
    ${local_ip})
      echo "entered $yn,begin uninstall"
      break
      ;;
    [Nn]*)
      echo "entered $yn,will exit"
      exit 0
      ;;
    *) echo "confirm uninstall need enter ${local_ip} or skip by N/n " ;;
    esac
  done
}

function delete_job() {
  echo "========remove crontab"
  crontab -l >>crontab_jobs
  if grep 'shakespeare' crontab_jobs; then
    echo "has shakespeare job"
    sed -i -e "/shakespeare/d" crontab_jobs
    crontab crontab_jobs
    echo "reset job finished"
  else
    echo "no shakespeare job"
  fi
  if shakespeare version > /dev/null; then
      echo "====stop shakespeare"
      shakespeare stop
  fi

  if [ $(ps -ef | grep 'shakespeare' | grep -v grep | wc -l) -gt 0 ]; then
    ps -ef | grep shakespeare | grep -v grep | grep -v $current_name | awk '{print $2}' | xargs kill -9
  fi
}

function remove_shakespeare() {
  echo "====remove shakespeare"
  rm -rf /etc/nginx/conf.d/honeyguide.conf
  systemctl stop nginx
  sudo rm -rf /var/log/nginx
  sudo rm -rf /apps/logs/
  sudo rm -rf /etc/init.d/shakespeare*
  sudo rm -rf ${py_home}
  sudo rm -rf /opt/shakespeare/
}

function remove_mysql() {
  if [[ "$DEPLOY_ENV" == "docker" || "$S9E_DEPLOY_MYSQL" == "0" ]]; then
    echo "no need remove mysql:DEPLOY_ENV:$DEPLOY_ENV,S9E_DEPLOY_MYSQL:$S9E_DEPLOY_MYSQL"
    return
  fi
  echo "========romove mysql,DEPLOY_ENV:$DEPLOY_ENV,S9E_DEPLOY_MYSQL:$S9E_DEPLOY_MYSQL"
  sudo /usr/bin/systemctl stop mysql
  rm -rf /usr/local/mysql/data
  rm -rf /usr/local/bin/mysql
  sudo rm -rf /var/log/mysqld.log
}

function remove_env_file() {
  env_file=$1
  if [ -f ${env_file} ] || [ -L ${env_file} ]; then
    echo "========remove env ${env_file} ======="
    sed '/^PATH/d' ${env_file} | sed '/^export PATH/d' | sed '/^PY_3_HOME/d' | sed '/^SHAKESPEARE_HOME/d' | sed '/^JAVA_HOME/d' | sed '/^ES_HOME/d' | sed 's/^export/unset/g' | sed 's/=.*//g' >${basedir}/unset.sh
    source ${basedir}/unset.sh
    sudo rm -rf ${env_file}
    rm -rf ${basedir}/unset.sh
  fi
}

function remove_env() {
  echo "========remove shakespeare env"
  remove_env_file /etc/profile.d/app.sh
  remove_env_file /etc/profile.d/sp_mysql.sh
  remove_env_file /etc/profile.d/sp_deploy.sh
  remove_env_file /etc/profile.d/sp_monitor.sh
  remove_env_file /etc/profile.d/honeyguide_prepare.sh
  remove_env_file /etc/profile.d/sp_mongo.sh
  remove_env_file /etc/profile.d/apr.sh

  for file in /etc/profile.d/sp_deploy*.sh; do
    remove_env_file ${file}
  done

  if [ -d /var/log/hg ] || [ -f /var/log/hg ] || [ -L /var/log/hg ]; then
    echo "========remove hg install log"
    sudo rm -rf /var/log/hg
  fi

  echo "========remove env hosts from /etc/hosts==========="
  cat /etc/hosts
  echo "$(sed '/shakespeare hosts/,/shakespeare hosts end/d' /etc/hosts)" | sudo tee /etc/hosts
  echo "hosts removed:$(cat /etc/hosts)"

}

function remove_cdm() {
  if ! cmu -l &>/dev/null; then
    echo "codemeter not installed"
    return
  fi
  echo "========remove codemeter"
  cmu -l | grep "Serial Number" | awk -F'Serial Number' '{print $2}' | awk -F'and' '{print $1}' | xargs cmu --delete-cmact-license --serial
  sudo systemctl stop codemter
  sudo cmu -s130-1993001174 --delete-cmact-license
  sudo rpm -e AxProtector-devel-10.31.3477-500.x86_64
  sudo rpm -e AxProtector-10.31.3477-500.x86_64
  sudo rpm -e CodeMeter-6.81.3477-500.x86_64
  sudo rpm -e CodeMeter-lite-6.90.3691-500.x86_64
  sudo rpm -e CodeMeter-lite-7.10.4206-502.x86_64
  sudo rpm -e CodeMeter-lite-7.51.5429-500.x86_64
  sudo rm -rf /etc/wibu
  ps -ef | grep codemeter
  sudo systemctl status codemeter
}

remove_docker_base() {
  docker_data="$1"
  echo "docker is install by hg,will remove"
  sudo /usr/bin/systemctl stop docker
  sudo /usr/bin/systemctl disable docker
  sudo rm -rf /etc/systemd/system/docker.service
  sudo rm -rf /usr/lib/systemd/system/docker.service
  sudo rm -rf /etc/docker
  sudo /usr/bin/systemctl daemon-reload
  sudo /usr/bin/systemctl reset-failed

  sudo rm -rf /usr/local/bin/docker-compose
  sudo rm -rf /usr/bin/docker*
  sudo rm -rf /usr/bin/containerd*

  if [[ $(cat /proc/mounts | grep 'docker' | grep 'overlay' |wc -l) -gt 0 ]]; then
      echo "umount docker overlay"
      cat /proc/mounts | grep 'docker' | grep 'overlay' | awk '{print $2}' | xargs sudo umount
  else
      echo "not need remove docker overlay"
  fi
  echo "remove docker data directory :${docker_data}  "
  rm -rf ${docker_data}
  echo "docker removed"
}

stop_docker_container(){
  echo "stop docker containers"
  if [[ -f ${appenv}/docker-compose.yml ]]; then
      echo "stop docker compose by:${appenv}/docker-compose.yml"
      sudo docker-compose -f ${appenv}/docker-compose.yml down
  fi
  #安装未完成时的文件
  if [[ -f ${appenv}/docker/docker-compose.yml ]]; then
      echo "stop docker compose by:${appenv}/docker/docker-compose.yml"
      sudo docker-compose -f ${appenv}/docker/docker-compose.yml down
  fi
  while read -r line; do
      echo "stop docker compose by:${line}"
      sudo docker-compose -f ${line} down
  done <<< $(find ${appenv}/docker -name docker-compose.yml)

  python_compose=${py_home}/docker-compose.yml
  if [[ -f ${python_compose} ]]; then
      echo "stop docker compose by:${python_compose}"
      sudo docker-compose -f ${python_compose} down
  fi
  sudo docker network rm honeyGuide
}

remove_docker_images(){
  if [[ $(docker images|grep shakespeare|wc -l) -gt 0 ]]; then
      echo "remove docker images"
      docker images|grep shakespeare|awk '{print $3}'|xargs docker rmi -f
      # 有互相tag的镜像，需要两次才能删除成功
      if [[ $(docker images|grep shakespeare|wc -l) -gt 0 ]]; then
          docker images|grep shakespeare|awk '{print $3}'|xargs docker rmi -f
      fi
  else
      echo "shakespeare images not exist,skip remove"
  fi
}

remove_docker() {
  if ! sudo docker --version > /dev/null; then
      echo "docker not exist,skip remove"
      return 0
  fi
  docker_service_file=/etc/systemd/system/docker.service
  if [[ ! -f ${docker_service_file} ]]; then
      docker_service_file=/usr/lib/systemd/system/docker.service
  fi

  if test -f ${docker_service_file} && grep 'docker_data' ${docker_service_file} >/dev/null; then
    docker_data=$(grep 'docker_data' ${docker_service_file} | awk -F'graph=' '{print $2}')
    remove_docker_base "$docker_data"
  else
    stop_docker_container
    remove_docker_images
  fi
}

nodes_k8s_base_remove() {
  uninstall_node_by_ansible=${appenv}/k8s_env/ansible_script/uninstall/uninstall_env.yml
  node_hosts_inv=${appenv}/k8s_env/config/ansible_hosts.yaml
  if [[ ! -f ${uninstall_node_by_ansible} || ! -f ${node_hosts_inv} ]]; then
    echo "${uninstall_node_by_ansible} or $node_hosts_inv not exist ,skip nodes handle"
    return 0
  fi
  echo "=============ansible config begin================================="
  cat ${appenv}/k8s_env/config/ansible_hosts.yaml
  echo "===============ansible config end=================================="
  echo "uninstall node "

  ansible-playbook ${uninstall_node_by_ansible} -v -i "${node_hosts_inv}"
}

remove_k8s() {
  kk_file=${appenv}/soft/k8s/kk
  if [[ ! -f ${kk_file} ]]; then
    echo "kk not exist ,need uninstall k8s from install node(未安装k8s或需要从主节点执行卸载)"
    return 0
  fi
  kk_cfg=${appenv}/k8s_env/config/config.yaml
  if [[ -f ${kk_cfg} ]]; then
    echo "delete k8s by:${kk_file} delete cluster -y -f ${kk_cfg}"
    echo "==========================cluster config begin=================="
    cat ${kk_cfg}
    echo "==========================cluster config end=================="
    ${kk_file} delete cluster -y -f ${kk_cfg}
  else
    echo "delete k8s by:${kk_file} delete cluster -y"
    ${kk_file} delete cluster -y
  fi

}

check_uninstalled() {
  if [ $(ps -ef | grep 'shakespeare' | grep -v grep | wc -l) -gt 0 ]; then
    echo "ERROR*********** has shakespeare process,please check by:ps -ef|grep 'shakespeare'"
  fi

}

ai_uninstall() {
  echo "=========remove python and ai============="
  shakespeare-python-service uninstall
  echo "=========finished remove python and ai============="
}
promot
delete_job
remove_mysql
remove_k8s
#必须先停k8s,再操作节点
nodes_k8s_base_remove
remove_env
remove_cdm
remove_docker
ai_uninstall
check_uninstalled
remove_shakespeare

echo "=========please exit shell for reinstall[如有需要请务必退出终端后再安装]================"
