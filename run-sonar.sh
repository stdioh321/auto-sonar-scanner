#!/bin/bash
usage(){
  echo "Uso: $0 -n NOME -s /home/pc/MEU_PROJETO/src -b master,release"
  echo ""
  echo "-n [NOME] (Nome do projeto)"
  echo "-s [SRC] Caminho do projeto \"/home/pc/meu-projeto/src\""
  echo "-b [BRANCH1,BRANCH2,...] Branches para testar. Min: 1"
}

while getopts ':s:b:n:h' opt; do
  case "$opt" in
    s)
      SRC_FOLDER="$OPTARG"
      ;;

    b)
      BRANCHES="$OPTARG"
      ;;

    n)
      PROJECT_KEY="$OPTARG"
      ;;

    h)
      usage
      exit 0
      ;;

    :)
      echo -e "opção requer um argumento: -$OPTARG"
      usage
      exit 1
      ;;

    ?)
      usage
      exit 1
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

if [[ -z  $SRC_FOLDER || -z  $BRANCHES || -z $PROJECT_KEY ]]; then
  echo Faltaram parâmetros 😠😠😠
  usage
  exit 1
fi

read -d '' tempDockerCompose << EOF
version: '3.0'
services:
  sonar:
    container_name: sonar
    image: diaslinoh/auto-sonar:0.0.1
    network_mode: host
    logging:
      driver: "syslog"
  sonar-scanner:
    container_name: sonar-scanner
    image: diaslinoh/auto-sonar-scanner:0.0.1
    network_mode: host
    environment:
      - PROJECT_KEY=$PROJECT_KEY
      - BRANCHES=$BRANCHES
    volumes:
      - $SRC_FOLDER:/usr/src
    depends_on:
      sonar:
        condition: service_healthy
EOF

docker-compose -f - build <<<"$tempDockerCompose"
docker-compose  -f - up <<<"$tempDockerCompose"