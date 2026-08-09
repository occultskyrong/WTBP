.PHONY: validate review-staged review-range install-hooks

validate:
	./tooling/validate-repository.sh

review-staged:
	./tooling/review-staged.sh

review-range:
	@test -n "$(BASE_SHA)" || (echo "必须提供 BASE_SHA" >&2; exit 2)
	@test -n "$(HEAD_SHA)" || (echo "必须提供 HEAD_SHA" >&2; exit 2)
	./tooling/review-staged.sh --range "$(BASE_SHA)" "$(HEAD_SHA)"

install-hooks:
	./tooling/install-git-hooks.sh
