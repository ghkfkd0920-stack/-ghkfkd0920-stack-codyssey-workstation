#!/usr/bin/env bash
# Docker 볼륨 영속성: 컨테이너를 삭제해도 볼륨의 데이터는 남는다
source "$(dirname "$0")/lib.sh"
start_log 06_volume
docker rm -f vol-test vol-test2 >/dev/null 2>&1
docker volume rm mydata >/dev/null 2>&1

section "볼륨 생성 / 확인"
run 'docker volume create mydata'
run 'docker volume ls'
run 'docker volume inspect mydata'

section "컨테이너 1에 연결 후 데이터 기록"
run 'docker run -d --name vol-test -v mydata:/data ubuntu:22.04 sleep infinity'
run 'docker exec vol-test bash -c "echo hi-from-vol-test-$(date +%s) > /data/hello.txt && cat /data/hello.txt"'

section "컨테이너 1 삭제 (삭제 전/후 목록)"
run 'docker ps -a --filter name=vol-test'
run 'docker rm -f vol-test'
run 'docker ps -a --filter name=vol-test'
run 'docker volume ls --filter name=mydata'

section "새 컨테이너 2에 같은 볼륨 연결 → 데이터 유지 확인"
run 'docker run -d --name vol-test2 -v mydata:/data ubuntu:22.04 sleep infinity'
run 'docker exec vol-test2 cat /data/hello.txt'

section "비교: 볼륨 없이 컨테이너 내부에만 쓴 데이터는 삭제와 함께 사라짐"
run 'docker run -d --name no-vol ubuntu:22.04 sleep infinity'
run 'docker exec no-vol bash -c "echo temp > /tmp/temp.txt && cat /tmp/temp.txt"'
run 'docker rm -f no-vol'
run 'docker run --rm --name no-vol ubuntu:22.04 cat /tmp/temp.txt'

section "정리 (볼륨은 남겨둠)"
run 'docker rm -f vol-test2'

echo "로그 저장: $LOG_FILE"
