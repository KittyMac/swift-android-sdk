
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


docker-shell: docker-release
	cd ../ && docker pull --platform linux/amd64 kittymac/swiftandroidsdk
	cd ../ && docker run --rm -it --entrypoint bash kittymac/swiftandroidsdk
