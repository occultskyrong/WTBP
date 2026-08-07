.PHONY: validate review-staged install-hooks

validate:
	./tooling/validate/validate-repository.sh

review-staged:
	./tooling/review/review-staged.sh

install-hooks:
	./scripts/install-git-hooks.sh
