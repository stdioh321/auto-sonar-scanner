#!/bin/bash
usage(){
  echo "Uso: $0 -n NOME -s /home/pc/MEU_PROJETO/src -b master,release"
  echo ""
  echo "-n [NOME] (Nome do projeto)"
  echo "-s [SRC] Caminho do projeto \"/home/pc/meu-projeto/src\""
  echo "-b [BRANCH1,BRANCH2,...] Branches para testar. Min: 1"
  echo "-e [-Dsonar.algo1=algo1 -Dsonar.algo2=algo2 ] (Opcional) Parâmetros extras para o sonar-scanner"
}

if [[ -z $(which docker) ||  (-z $(which docker-compose) &&  -z $(docker compose 2> /dev/null)) ]]; then
  echo "Necessario ter instalado docker e docker-compose 😠😠😠"
  exit 1
elif [[ -z $(which docker-compose) ]]; then
  DOCKER_COMPOSE="docker compose"
else
  DOCKER_COMPOSE="docker-compose"
fi


while getopts ':e:s:b:n:h' opt; do
  case "$opt" in
    e)
      EXTRA_ARGS="$OPTARG"
      ;;
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

MYUID=$(id -u)
MYGID=$(id -g)

read -d '' tempDockerCompose << EOF
version: '3.3'
services:
  sonar:
    container_name: sonar
    image: diaslinoh/auto-sonar:0.0.2
    network_mode: host
  sonar-scanner:
    container_name: sonar-scanner
    image: diaslinoh/auto-sonar-scanner:0.0.2
    network_mode: host
    environment:
      - PROJECT_KEY=$PROJECT_KEY
      - BRANCHES=$BRANCHES
      - EXTRA_ARGS=$EXTRA_ARGS
    volumes:
      - $SRC_FOLDER:/temp/current
    depends_on:
      sonar:
        condition: service_healthy
EOF

$DOCKER_COMPOSE -f - build <<<"$tempDockerCompose"
$DOCKER_COMPOSE -f - up <<<"$tempDockerCompose"
$DOCKER_COMPOSE -f - down <<<"$tempDockerCompose"