generate:
	@test -f .env || (echo ".env 파일이 없습니다. .env.example을 참고해 생성하세요." && exit 1)
	mise exec -- tuist install
	set -a && . ./.env && set +a && mise exec -- tuist generate
