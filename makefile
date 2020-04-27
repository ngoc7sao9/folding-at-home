.PHONY: help

help: ##show this help.
	@IFS=$$'\n' ; \
	help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##/:/'`); \
	printf "%-30s %s\n" "target" "help" ; \
	printf "%-30s %s\n" "------" "----" ; \
	for help_line in $${help_lines[@]}; do \
			IFS=$$':' ; \
			help_split=($$help_line) ; \
			help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
			help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
			printf '\033[36m'; \
			printf "%-30s %s" $$help_command ; \
			printf '\033[0m'; \
			printf "%s\n" $$help_info; \
	done

lint: ##test files for syntax errors
	yamllint . || true
	markdownlint . || true
	hadolint build/Dockerfile || true

pretty: ##correct formatting errors
	prettier --parser=markdown --write '*.md' '**/*.md' || true
	prettier --parser=yaml --write '*.y*ml' '**/*.y*ml' || true

buildx: ## build locally
	make pretty
	make lint
	docker buildx build --load --platform linux/amd64 --build-arg=VERSION=7.6.9 --build-arg=VERSION_MAJOR=7.6 --build-arg=VCS_REF=1 --build-arg=BUILD_DATE=1 --tag "stefancrain/folding-at-home:local" -f ./build/Dockerfile ./build/

run-local: ## test locally
	docker run "stefancrain/folding-at-home:local"
