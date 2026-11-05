#!/usr/bin/env bash
# 바인드 마운트: 호스트 파일 변경이 재빌드 없이 컨테이너에 즉시 반영되는지 확인
source "$(dirname "$0")/lib.sh"
start_log 05_bind_mount
cd "$ROOT"
docker rm -f bind-web >/dev/null 2>&1

section "호스트 디렉토리 준비"
run 'mkdir -p mount-demo && echo "<h1>BEFORE - bind mount</h1>" > mount-demo/index.html'
run 'cat mount-demo/index.html'

section "바인드 마운트로 실행 (호스트 ./mount-demo → 컨테이너 /usr/share/nginx/html)"
run 'docker run -d -p 8083:80 --name bind-web -v "$ROOT/mount-demo":/usr/share/nginx/html my-web:1.0'
sleep 2
run 'docker inspect bind-web --format "{{range .Mounts}}{{.Type}}: {{.Source}} -> {{.Destination}}{{end}}"'

section "변경 전 응답"
run 'curl -s http://localhost:8083'

section "호스트에서 파일 수정 (컨테이너 재시작/재빌드 없음)"
run 'echo "<h1>AFTER - edited on host at $(date +%H:%M:%S)</h1>" > mount-demo/index.html'

section "변경 후 응답"
run 'curl -s http://localhost:8083'

section "반대 방향: 컨테이너에서 만든 파일이 호스트에 보이는지"
run 'docker exec bind-web sh -c "echo created-in-container > /usr/share/nginx/html/from_container.txt"'
run 'ls -l mount-demo && cat mount-demo/from_container.txt'

section "읽기 전용(:ro) 마운트 시 컨테이너 쓰기 실패 관찰 → 트러블슈팅 3"
run 'docker rm -f bind-web'
run 'docker run -d --name bind-web -v "$ROOT/mount-demo":/usr/share/nginx/html:ro my-web:1.0'
run 'docker exec bind-web sh -c "echo x > /usr/share/nginx/html/x.txt"'
run 'docker rm -f bind-web'

echo "로그 저장: $LOG_FILE"
