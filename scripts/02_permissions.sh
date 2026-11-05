#!/usr/bin/env bash
# 권한 실습: 파일 1개 + 디렉토리 1개 권한 변경 전/후 비교
source "$(dirname "$0")/lib.sh"
start_log 02_permissions
mkdir -p "$ROOT/practice" && cd "$ROOT/practice"

section "실습 대상 준비"
run 'printf "#!/bin/sh\necho script executed\n" > hello.sh'
run 'mkdir -p secret_dir && echo "data" > secret_dir/a.txt'

section "[파일] 변경 전 (기본 644: rw-r--r--)"
run 'chmod 644 hello.sh'
run 'ls -l hello.sh'
run './hello.sh'   # 실행 권한(x)이 없어 Permission denied 발생 → 트러블슈팅 1

section "[파일] 변경 후 755 (rwxr-xr-x)"
run 'chmod 755 hello.sh'
run 'ls -l hello.sh'
run './hello.sh'

section "[파일] 기호 표기 사용: u=rwx,go=r (= 744)"
run 'chmod u=rwx,go=r hello.sh'
run 'ls -l hello.sh'

section "[디렉토리] 변경 전 755"
run 'chmod 755 secret_dir'
run 'ls -ld secret_dir'
run 'ls secret_dir'

section "[디렉토리] 변경 후 700 (소유자만 접근)"
run 'chmod 700 secret_dir'
run 'ls -ld secret_dir'

section "[디렉토리] 읽기 권한 제거 (300: -wx) → 목록 조회 불가 관찰"
run 'chmod 300 secret_dir'
run 'ls -ld secret_dir'
run 'ls secret_dir'            # r 없음 → 목록 불가
run 'cat secret_dir/a.txt'     # x 있음 → 이름을 알면 접근 가능

section "원복"
run 'chmod 755 secret_dir && ls -ld secret_dir'

echo "로그 저장: $LOG_FILE"
