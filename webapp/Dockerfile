FROM golang:1.15

WORKDIR /home/isucon/isubata/webapp
COPY . .

WORKDIR /home/isucon/isubata/webapp/go
#RUN make

EXPOSE 5000

RUN go get -u github.com/cosmtrek/air
WORKDIR /home/isucon/isubata/webapp/go

CMD ["air", "-c", "air.toml"]

#ENTRYPOINT ["/home/isucon/isubata/webapp/go/isubata"]
