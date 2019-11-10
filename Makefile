build:
	docker build docker -t andrchalov/pgmailer:2.0.0

run:
	docker run -it --name pgmailer andrchalov/pgmailer:2.0.0

push:
	docker push andrchalov/pgmailer:2.0.0
