MYSQL_LOG:=./log/mysql/slow.log
NGX_LOG:=./log/nginx/access.log

DB_HOST:=127.0.0.1
DB_PORT:=3306
DB_USER:=isucon
DB_PASS:=isucon
DB_NAME:=isubata

MYSQL_CMD:=mysql -h$(DB_HOST) -P$(DB_PORT) -u$(DB_USER) -p$(DB_PASS) $(DB_NAME)

mysql:
	${MYSQL_CMD}

run:
	docker-compose up

before: 
	#git pull
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


alp:
	sudo alp ltsv -c alp.yml

pt:
	sudo pt-query-digest $(MYSQL_LOG)

out:
	./out.sh
