default: build

clean:
	rm -rf bin
	rm -rf .build

build:
	swift build --configuration release
	mkdir -p bin
	cp -a .build/release/appcastgen bin/

.PHONY: build clean
