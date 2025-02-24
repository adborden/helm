.PHONY: docs lint test

docs:
	helm-docs

lint:
	ct lint --target-branch main

test:
	kubectl config use-context kind-kind
	ct install --target-branch main
