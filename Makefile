MYSQL_LOG:=./log/mysql/slow.log
NGX_LOG:=./log/nginx/access.log

DB_HOST:=127.0.0.1
DB_PORT:=3306
DB_USER:=isucon
DB_PASS:=isucon
DB_NAME:=isubata

PROJECT_ROOT:=/home/webservice/isucon7-qualify
BUILD_DIR:=/home/webservice/isucon7-qualify/webapp/go
BIN_NAME:=isubata

MYSQL_CMD:=mysql -h$(DB_HOST) -P$(DB_PORT) -u$(DB_USER) -p$(DB_PASS) $(DB_NAME)

mysql:
	${MYSQL_CMD}

run-local:
	docker-compose -f docker-compose.local.yaml up

run-instance:
	docker-compose -f docker-compose.yaml up

build: FORCE
	cd $(BUILD_DIR);\
	make

dev: FORCE build
	cd $(BUILD_DIR); \
	./$(BIN_NAME)


before:  FORCE
	#git pull # comment off on isucon instance
	$(eval when := $(shell date "+%s"))
	mkdir -p ./log/$(when)
	@if [ -f $(NGX_LOG) ]; then \
		sudo mv -f $(NGX_LOG) ./log/$(when)/ ; \
	fi
	@if [ -f $(MYSQL_LOG) ]; then \
		sudo mv -f $(MYSQL_LOG) ./log/$(when)/ ; \
	fi
	#sudo cp nginx.conf /etc/nginx/nginx.conf
	#sudo cp my.cnf /etc/mysql/my.cnf
	#sudo systemctl restart nginx
	# sudo systemctl restart mysql


alp: FORCE
	sudo alp ltsv -c alp.yml

pt: FORCE
	sudo pt-query-digest $(MYSQL_LOG)

out: FORCE
	./out.sh


setup: FORCE
	sudo yum install -y wget unzip percona-toolkit
	# # git config`
	#git config --global user.email "hoge@example.com"
	#git config --global user.name "king"
	# alp
	wget https://github.com/tkuchiki/alp/releases/download/v1.0.3/alp_linux_amd64.zip
	unzip -o alp_linux_amd64.zip
	sudo mv alp /usr/local/bin/
	sudo chmod +x /usr/local/bin/alp
	rm alp_linux_amd64.zip
	# slack notifier
	wget https://github.com/catatsuy/notify_slack/releases/download/v0.4.8/notify_slack-linux-amd64.tar.gz
	mkdir setup_tmp
	tar zxvf notify_slack-linux-amd64.tar.gz -C ./setup_tmp
	sudo mv ./setup_tmp/notify_slack /usr/local/bin/
	sudo chmod +x /usr/local/bin/notify_slack
	rm notify_slack-linux-amd64.tar.gz
	rm -rf ./setup_tmp

FORCE:
.PHONY: FORCE

