#!/usr/bin/env bash
# Docker 설치 점검 + 기본 운영 명령 + hello-world / ubuntu 실습
source "$(dirname "$0")/lib.sh"
start_log 03_docker_basic

section "설치 / 데몬 점검 (OrbStack 실행 중이어야 함)"
run 'docker --version'
run 'docker info --format "Server Version: {{.ServerVersion}} | OS: {{.OperatingSystem}} | CPUs: {{.NCPU}} | Mem: {{.MemTotal}} | Containers: {{.Containers}}"'
run 'docker context ls'

section "이미지 다운로드 / 목록"
run 'docker pull hello-world'
run 'docker pull ubuntu:22.04'
run 'docker images'

section "hello-world 실행"
run 'docker run --name hello hello-world'

section "ubuntu 컨테이너: 일회성 명령 (실행 후 바로 종료)"
run 'docker run --rm ubuntu:22.04 bash -c "ls / && echo hello from ubuntu && cat /etc/os-release | head -2"'

section "ubuntu 컨테이너: 백그라운드 유지 + exec 로 내부 명령"
run 'docker run -d --name ubuntu-keep ubuntu:22.04 sleep infinity'
run 'docker exec ubuntu-keep bash -c "echo inside container && ls /home && hostname"'
run 'docker ps'

section "운영: 로그 / 리소스"
run 'docker logs hello | head -5'
run 'docker stats --no-stream'

section "중지 / 전체 목록"
run 'docker stop ubuntu-keep'
run 'docker ps -a'

section "정리"
run 'docker rm hello ubuntu-keep'

echo "로그 저장: $LOG_FILE"
echo
echo ">>> 다음은 대화형이라 직접 실행 후 README 5-3 절에 관찰 결과를 적으세요:"
echo "    docker run -it --name u1 ubuntu:22.04 bash   # 내부에서 ls, echo 후 exit"
echo "    docker ps -a                                  # u1 이 Exited 인지 확인"
echo "    docker start u1 && docker attach u1           # 다시 붙고 exit → 또 종료됨"
echo "    docker start u1 && docker exec -it u1 bash    # exec 에서 exit → 컨테이너는 계속 Up"
echo "    docker ps && docker rm -f u1"
