.PHONY: validate review-staged review-range review-issue install-hooks

validate:
	./tooling/validate-repository.sh

review-staged:
	./tooling/review-staged.sh

review-range:
	@test -n "$(BASE_SHA)" || (echo "必须提供 BASE_SHA" >&2; exit 2)
	@test -n "$(HEAD_SHA)" || (echo "必须提供 HEAD_SHA" >&2; exit 2)
	./tooling/review-staged.sh --range "$(BASE_SHA)" "$(HEAD_SHA)"

review-issue:
	@test -n "$(ISSUE_EVENT_PATH)" || (echo "必须提供 ISSUE_EVENT_PATH" >&2; exit 2)
	./tooling/review-issue-body.sh "$(ISSUE_EVENT_PATH)"

install-hooks:
	./tooling/install-git-hooks.sh
