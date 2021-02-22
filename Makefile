MYSQL_LOG:=/var//log/mysql/slow.log
NGX_LOG:=/var/log/nginx/access.log

DB_HOST:=127.0.0.1
DB_PORT:=63306
DB_USER:=isucon
DB_PASS:=isucon
DB_NAME:=isubata

PROJECT_ROOT:=/home/webservice/isucon7-qualify
BUILD_DIR:=/home/webservice/isucon7-qualify/webapp/go
SOURCE_DIR:=/home/webservice/isucon7-qualify/webapp/go/src/isubata
BIN_NAME:=isubata

MYSQL_CMD:=mysql -h$(DB_HOST) -P$(DB_PORT) -u$(DB_USER) -p$(DB_PASS) $(DB_NAME)

mysql:
	${MYSQL_CMD}

run-local:
	docker-compose -f docker-compose.local.yaml up

run-instance:
	docker-compose -f docker-compose.yaml up

deps: FORCE
	cd $(BUILD_DIR);\
	go mod download

gachi: FORCE before build restart

build: FORCE
	cd $(BUILD_DIR);\
	go build -o $(BIN_NAME) $(SOURCE_DIR)

dev: FORCE build
	cd $(BUILD_DIR); \
	./$(BIN_NAME)
	ssh 172.31.23.229 cd $(BUILD_DIR); \
	./$(BIN_NAME)



restart:
	sudo systemctl daemon-reload
	sudo systemctl restart isubata.golang.service
	ssh 172.31.23.229 sudo systemctl daemon-reload
	ssh 172.31.23.229 sudo systemctl restart isubata.golang.service


log: FORCE
	sudo journalctl -u isubata.golang -n10 -f

before:  FORCE
	git pull
	$(eval when := $(shell date "+%s"))
	mkdir -p ./log/$(when)
	@if [ -f $(NGX_LOG) ]; then \
		sudo mv -f $(NGX_LOG) ./log/$(when)/ ; \
	fi
	#@if [ ssh 172.31.20.105  -f $(MYSQL_LOG) ]; then \
	#	ssh 172.31.20.105 sudo mv -f $(MYSQL_LOG) ./log/$(when)/ ; \
	#fi

	# nginx
	sudo cp ./nginx/nginx.conf /etc/nginx/nginx.conf
	sudo cp ./nginx/conf.d/my.conf /etc/nginx/conf.d/my.conf
	# mysql
	sudo cp ./files/app/isubata.golang.service /etc/systemd/system/isubata.golang.service
	#sudo cp ./files/db/mysqld.cnf /etc/mysql/my.cnf
	scp ./files/db/mysqld.cnf 172.31.28.127:~/mysqld.cnf
	ssh  172.31.28.127 sudo cp ~/mysqld.cnf /etc/mysql/my.cnf
	sudo systemctl restart nginx
	#sudo systemctl restart mysqld.service
	ssh 172.31.28.127 sudo systemctl restart mysqld.service
	# another app
	scp -r /home/webservice/isucon7-qualify 172.31.23.229:/home/webservice/
	ssh 172.31.23.229 sudo cp ~/isucon7-qualify/files/app/isubata.golang.service /etc/systemd/system/isubata.golang.service


alp: FORCE
	sudo alp ltsv -c alp.yml

pt: FORCE
	ssh 172.31.28.127 sudo pt-query-digest $(MYSQL_LOG)

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

