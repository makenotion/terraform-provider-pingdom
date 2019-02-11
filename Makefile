RELEASE := $(GOPATH)/bin/github-release

$(RELEASE):
	go get -u github.com/aktau/github-release

release: $(RELEASE)
ifndef version
	@echo "Please provide a version"
	exit 1
endif
ifndef GITHUB_TOKEN
	@echo "Please set GITHUB_TOKEN in the environment"
	exit 1
endif
	git tag $(version)
	git push origin --tags
	mkdir -p releases/$(version)
	GOOS=linux GOARCH=amd64 go build -o releases/$(version)/terraform-provider-pingdom-linux-amd64 .
	GOOS=darwin GOARCH=amd64 go build -o releases/$(version)/terraform-provider-pingdom-darwin-amd64 .
	GOOS=windows GOARCH=amd64 go build -o releases/$(version)/terraform-provider-pingdom-windows-amd64 .
	# these commands are not idempotent so ignore failures if an upload repeats
	$(RELEASE) release --user makenotion --repo terraform-provider-pingdom --tag $(version) || true
	$(RELEASE) upload --user makenotion --repo terraform-provider-pingdom --tag $(version) --name terraform-provider-pingdom-linux-amd64 --file releases/$(version)/terraform-provider-pingdom-linux-amd64 || true
	$(RELEASE) upload --user makenotion --repo terraform-provider-pingdom --tag $(version) --name terraform-provider-pingdom-darwin-amd64 --file releases/$(version)/terraform-provider-pingdom-darwin-amd64 || true
	$(RELEASE) upload --user makenotion --repo terraform-provider-pingdom --tag $(version) --name terraform-provider-pingdom-windows-amd64 --file releases/$(version)/terraform-provider-pingdom-windows-amd64 || true
