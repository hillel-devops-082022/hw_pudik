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
5. Now you can run the docker swarm Real World application
```
docker stack deploy -c docker-compose.yml -c docker-compose.stack.yml realworld
```

### HW24. Kubernetes. Realworld app
- Work with StorageClass, PersistentVolumesClaims, PersistentVolumes
- Work with Deployments, StatefulSets
- Work with Services, Ingress

#### Run code:
- Start minikube cluster
  ````bash
  minikube start  --no-vtx-check -p first-cluster # start cluster
  minikube addons enable csi-hostpath-driver -p first-cluster # enable csi StorageClass
  minikube addons enable ingress -p first-cluster # enable ingress Controller
  ````
- Add DNS records to hosts file
  ````bash
  echo "$(minikube ip -p first-cluster) realworld.local.io" | sudo tee -a /etc/hosts # frontend
  echo "$(minikube ip -p first-cluster) backend.realworld.local.io" | sudo tee -a /etc/hosts # backend 
  echo "$(minikube ip -p first-cluster) adminmongo.realworld.local.io" | sudo tee -a /etc/hosts # adminmongo
  ````
- Set first-cluster as default for kubectl
  ````bash
  kubectl config use-context first-cluster # set first-cluster as default
  ````
- Deploy mongoDB
  ````bash
  kubectl apply -f pvc_mongo.yml # create PersistentVolumesClaims for future mongodb pods
  kubectl apply -f statefulset_mongo.yml # deploy mongodb
  kubectl apply -f svc_mongo.yml # create service for mongodb
  ````
- Deploy backend
  ````bash
  kubectl apply -f deployment-backend.yml # deploy backend
  kubectl apply -f svc_backend.yml # create service for backend
  kubectl apply -f ingress_backend.yml # create ingress for backend to make it reachable from the outside of cluster
  ````
- Deploy frontend
  ````bash
  kubectl apply -f deployment-frontend.yml # deploy frontend
  kubectl apply -f svc_frontend.yml # create service for frontend
  kubectl apply -f ingress_frontend.yml # create ingress for frontend to make it reachable from the outside of cluster
  ````
- Deploy mongo-admin
  ````bash
  kubectl apply -f statefulset_mongo_admin.yml # deploy mongo_admin
  kubectl apply -f svc_mongo_admin.yml # create service for mongo_admin
  kubectl apply -f ingress_mongo_admin.yml # create ingress for mongo_admin to make it reachable from the outside of cluster
  ````

#### Verify
 - Use `kubectl get pods` to control application start
 - http://realworld.local.io/register - registration is required
 - http://adminmongo.realworld.local.io (mongodb://mongo/conduit as connection string)

#### Stop code:
- Remove all created resources
  ````bash
  kubectl delete -f mongo_admin
  kubectl delete -f frontend
  kubectl delete -f backend
  kubectl delete -f mongodb
  ````
- Remove DNS-records from hosts file
  ````bash
  sudo sed -i -E "/$(minikube ip -p first-cluster) (backend.|adminmongo.)?realworld.local.io/d" /etc/hosts
  ````
- Delete cluster
  ````bash
  minikube delete -p first-cluster
  ````

### We hope you enjoy our product. See you next time!!! 
