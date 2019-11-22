#
# Makefile for ion, WebRTC Media server
#
PROG=ion
VERSION=0.0.1
# -----------------------------------------------------------------------------------------------------------------------
usage:
	@echo "WebRTC signaling server : $(PROG) $(VERSION)"
	@echo "usage: make [build|run|kill|docker|compose|ngrok|git]"
# -----------------------------------------------------------------------------------------------------------------------
build b $(PROG): *.go
	GO111MODULE=on go build -ldflags '-X main.AyameVersion=${VERSION}' -o $(PROG)

build-darwin bd: *.go
	GO111MODULE=on GOOS=darwin GOARCH=amd64 go build -ldflags '-X main.AyameVersion=${VERSION}' -o bin/$(PROG)-darwin
build-linux bl: *.go
	GO111MODULE=on GOOS=linux GOARCH=amd64 go build -ldflags '-s -w -X main.AyameVersion=${VERSION}' -o bin/$(PROG)-linux

check:
	GO111MODULE=on go test ./...

clean:
	@rm -rf ./record/* ./asset/record/*
	@ls -lF ./upload/* ./record/*

clobber:
	@make clean
	rm -rf $(PROG)
	@-docker rmi $(shell docker images -q "agilertc/ayame")
	@-docker system prune --force

web w:
	open http://localhost:3000/static

run r: $(PROG)
	./$(PROG)

kill k:
	pkill $(PROG)

log l:
	tail -f $(PROG).log
# ----------------------------------------------------------------------------------------
PROG_IMAGE=agilertc/$(PROG):$(VERSION)
PROG_NAME=$(PROG)
docker d:
	@echo "> make ([35mdocker[0m) [build|run|kill|ps] for [33m$(PROG_IMAGE)[0m"

docker-build db: *.go Dockerfile
	@-rm -rf asset/upload/* asset/record/*
	@-docker rmi $(PROG_IMAGE)
	@-PROG=$(PROG) docker build -f Dockerfile -t $(PROG_IMAGE) .
	@docker images $(PROG_IMAGE)

docker-run dr:
	@-docker run -d \
		-p=3000:3000 -p=3443:3443 \
		-v=$(PWD)/upload:/upload \
		-v=$(PWD)/record:/asset/record \
		--name=$(PROG_NAME) $(PROG_IMAGE)
	@docker ps

# docker rm -f $(PROG_NAME)
docker-kill dk:
	@-docker stop $(PROG_NAME) | xargs docker rm
	@docker ps

docker-clean dc:
	docker system prune --force
	docker rmi $(PROG_IMAGE)

docker-ps dp:
	@docker ps -f name=$(PROG_NAME)

docker-log dl:
	@docker logs -f $(PROG_NAME)

docker-upload du:
	@docker push $(PROG_IMAGE)

docker-open do:
	@open https://cloud.docker.com/u/agilertc/repository/docker/agilertc/ayame
# ----------------------------------------------------------------------------------------
compose c:
	@echo "> make ([35mcompose[0m) [up|down] for $(PROG)"

compose-up cu:
	@VERSION=$(VERSION) docker-compose up -d

compose-down cd:
	@VERSION=$(VERSION) docker-compose down

compose-ps cp:
	@VERSION=$(VERSION) docker-compose ps
# ----------------------------------------------------------------------------------------
ngrok n:
	@echo "> make (ngrok) [install|run]"

ngrok-install ni:
	snap install ngrok

ngrok-run nr:
	ngrok http 3000
#-----------------------------------------------------------------------------------------
open o:
	@echo "> make (open) [orig|page]"

open-orig oo:
	xdg-open https://github.com/pion/ion

open-page op:
	xdg-open https://github.com/sikang99/ion-update
#-----------------------------------------------------------------------------------------
git g:
	@echo "> make (git) [update|login|tag|status]"

git-update gu:
	git add .
	git commit -m "$(VERSION): upload and transcode files"
	git push

git-login gl:
	git config --global user.email "sikang99@gmail.com"
	git config --global user.name "Stoney Kang"
	git config --global push.default matching
	git config credential.helper store

git-tag gt:
	git tag $(VERSION)
	git push --tags

git-status gs:
	git status
	git log --oneline -5
#-----------------------------------------------------------------------------------------
