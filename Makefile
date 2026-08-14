.PHONY: validate validate-skill-evals validate-skill-routes validate-skill-index test-wtbp-router skill-eval ske commit-checklist commit-checklist-range review-staged review-range review-issue install-hooks

validate:
	./tooling/validate-repository.sh

validate-skill-evals:
	./tooling/validate-skill-evals.sh

validate-skill-routes:
	./tooling/validate-skill-routes.sh

validate-skill-index:
	./tooling/validate-skill-index.sh

test-wtbp-router:
	./tooling/test-wtbp-router.sh

skill-eval:
	@test -n "$(SKILL_ID)" || (echo "必须提供 SKILL_ID，例如 make skill-eval SKILL_ID=practice-search" >&2; exit 2)
	./tooling/run-skill-eval.sh "$(SKILL_ID)"

ske:
	SKILL_ID="$(if $(SKILL_ID),$(SKILL_ID),skill-evaluation)" $(MAKE) skill-eval

commit-checklist:
	./tooling/commit-checklist.sh

commit-checklist-range:
	@test -n "$(BASE_SHA)" || (echo "必须提供 BASE_SHA" >&2; exit 2)
	@test -n "$(HEAD_SHA)" || (echo "必须提供 HEAD_SHA" >&2; exit 2)
	./tooling/commit-checklist.sh --range "$(BASE_SHA)" "$(HEAD_SHA)"

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
