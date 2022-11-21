## How to use Docker Swarm

1. Comment not needed strings in docker-compose file:
``` 
# healthcheck: 
# test: ["CMD", "curl", "-f", "http://backend:8081/api/status"]
# interval: 10m
# timeout: 10s
# retries: 3
```
2. Create a new file docker-compose.stack.yml with such content:
``` 
version: "3"
services:
	frontend:
		deploy:
			replicas: 2
			placement:
				constraints: [node.role == manager]
	backend:
		deploy:
			replicas: 2
			placement:
				constraints: [node.role == manager]
	mongo:
		deploy:
			replicas: 1
			placement:
				constraints: [node.role == manager]
``` 
3. You need to initialize the Swarm Mode by running the init command
```docker swarm init```
4. Please check the Nodes on you machine
```docker node ls``` 
5 Now you can run the docker swarm Real World application
```
docker stack deploy -c docker-compose.yml -c docker-compose.stack.yml realworld
```

### We hope you enjoy our product. See you next time!!! 
