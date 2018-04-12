.PHONY: create-bosh-lite delete-bosh-lite stemcell compile image all test clean

create-bosh-lite:
	./scripts/bosh-lite.sh create-env

delete-bosh-lite:
	./scripts/bosh-lite.sh delete-env

stemcell:
	./scripts/stemcell.sh

compile:
	./scripts/compile_release.sh

image:
	./scripts/create_image.sh

all: create-bosh-lite stemcell compile image

test:
	./scripts/test.sh

clean: delete-env
	rm -rf workspace/*