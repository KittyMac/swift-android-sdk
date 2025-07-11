
docker-release:
	-DOCKER_HOST=ssh://rjbowli@192.168.111.203 docker buildx create --name cluster_builder203 --platform linux/amd64
	-docker buildx create --name cluster_builder203 --platform linux/arm64 --append
	-docker buildx use cluster_builder203
	-docker buildx inspect --bootstrap
	-docker login
	
	cd ../ && docker buildx build --progress=plain --no-cache --platform linux/amd64 --push -t kittymac/swiftandroidsdk:latest .
	
	# @if echo "$(GIT_VERSION)" | grep -q '-'; then																												\
	# 	echo "BUILDING LATEST";																																	\
	# 	docker buildx build --platform linux/amd64 --push -t kittymac/swiftandroidsdk:latest . ;																\
	# else																																						\
	# 	echo "BUILDING LATEST AND TAG $(GIT_VERSION)";																											\
	# 	docker buildx build --platform linux/amd64 --push -t kittymac/swiftandroidsdk:latest -t kittymac/swiftandroidsdk:$(GIT_VERSION) . ;			    	\
	# fi

docker-extract:
	cd ../ && docker pull --platform linux/amd64 kittymac/swiftandroidsdk
	docker run --platform linux/amd64 --rm -v $(shell pwd):/outTemp kittymac/swiftandroidsdk /bin/bash -lc 'cp swift-release-android-aarch64-24-sdk.tar.xz /outTemp/swift-release-android-aarch64-24-sdk.tar.xz'
	docker run --platform linux/amd64 --rm -v $(shell pwd):/outTemp kittymac/swiftandroidsdk /bin/bash -lc 'cp swift-release-android-armv7-24-sdk.tar.xz /outTemp/swift-release-android-armv7-24-sdk.tar.xz'
	docker run --platform linux/amd64 --rm -v $(shell pwd):/outTemp kittymac/swiftandroidsdk /bin/bash -lc 'cp swift-release-android-x86_64-24-sdk.tar.xz /outTemp/swift-release-android-x86_64-24-sdk.tar.xz'
	


docker-shell:
	cd ../ && docker pull --platform linux/amd64 kittymac/swiftandroidsdk
	cd ../ && docker run --rm -it --entrypoint bash kittymac/swiftandroidsdk
