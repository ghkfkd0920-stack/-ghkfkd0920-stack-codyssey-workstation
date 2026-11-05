#!/usr/bin/env bash
# 터미널 기본 조작: 위치 확인/목록(숨김 포함)/이동/생성/복사/이동·이름변경/삭제/내용 확인/빈 파일
source "$(dirname "$0")/lib.sh"
start_log 01_terminal
cd "$ROOT"

section "현재 위치 / 목록 (숨김 파일 포함)"
run 'pwd'
run 'ls -la'

section "디렉토리 생성 및 이동 (상대 경로 vs 절대 경로)"
run 'mkdir -p practice/docs'
run 'cd practice && pwd'          # 상대 경로로 이동
run "cd \"$ROOT/practice\" && pwd" # 절대 경로로 이동
cd practice

section "빈 파일 생성 / 내용 쓰기 / 내용 확인"
run 'touch empty.txt'
run 'ls -l empty.txt'
run 'echo "hello codyssey" > memo.txt'
run 'cat memo.txt'

section "복사"
run 'cp memo.txt docs/memo_copy.txt'
run 'ls -la docs'

section "이동 / 이름 변경"
run 'mv empty.txt renamed.txt'
run 'mv renamed.txt docs/'
run 'ls -la . docs'

section "삭제"
run 'rm docs/renamed.txt'
run 'rm -r docs'
run 'ls -la'

echo "로그 저장: $LOG_FILE"
