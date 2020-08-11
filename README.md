# Introduction

Springboot Starterkit provides developers an ability to get a containered springboot application on local systems and helps them to deploy to to Kubernetes with minimal or no understanding of Kubernetes. The starterkit is build using Docker and Kubernetes best practices and hence developers can just write application logic without worrying about Docker and Kubernetes complexities.

# Local Development using Docker
Springboot Js Starterkit can be used to set up a containerized node web applications on your local system using docker-compose.

## Prerequisites  
* Install [Docker](https://docs.docker.com/get-docker/)
* Install [docker-composer](https://docs.docker.com/compose/install/)

## Download Starterkit

### Using git
```bash
git clone git@github.com:srijanone/springboot-starterkit.git
```

### Using wget
```bash
wget https://github.com/srijanone/springboot-starterkit/archive/master.zip
unzip master.zip
```

## Start the application
```bash
cd springboot-starterkit
docker-composer build
docker-compose up -d
```
Upon executing the commands above check if the respective services are up & running

```bash
docker-compose ps
             Name                     Command         State           Ports         
------------------------------------------------------------------------------------
springboot-starterkit_spring_1   java -jar /app.jar   Up      0.0.0.0:8080->8080/tcp
$ curl localhost:8080
Hello Docker World%                                               
```

Check whether the application is accessible via browser, open localhost:8080 in your favorite browser

## Stop the application
```
docker-compose down
```

# Deploying the nodejs application to Kubernetes(PKS)

## Prerequisites  
* Install [helm](https://helm.sh/docs/intro/install/)
* Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

----
**NOTE**
This tutorial is only to get familiar with Kubernetes and is not recommended for production enviroment which should have well build CI/CD process.
----

## Set up the application locally

## Deploy the application to Kubernetes

### Prerequisite
* A docker repository is created on harbor.

### Authenticate to harbor

```bash
export DOCKERKUSER=my-user
export DOCKERPASS=my-password
docker login -u $DOCKERUSER -p $DOCKERPASS harbor.pks.aws.foo.com/srijan/my-spring-app
```

----
**NOTE**
Please replace DOCKERUSER and DOCKERPASS with your harbor username and password
----

### Build the image locally

```bash
export REPOSITORY_URL=harbor.pks.aws.foo.com/srijan/my-spring-app
docker build -t $REPOSITORY_URL:v1 .
```

### Push the image to harbor
```bash
docker push $REPOSITORY_URL:v1
```

### Login to PKS
```
export USERNAME=my-user
export PASSWORD=my-password
pks login -a api.pks.aws.yogendra.me -u $USERNAME -p $PASSWORD -k
```
Check the cluster to which you have access
```bash
pks clusters
PKS Version     Name     k8s Version  Plan Name  UUID                                  Status     Action
1.8.0-build.16  sandbox  1.17.5       small      0a405ecc-1034-47e7-a550-10781a846a07  succeeded  UPGRADE
1.8.0-build.16  devops   1.17.5       small      75d2b8d3-6a0e-4305-8586-b18c7abc95b3  succeeded  UPGRADE
```

Generate configuration file for the required cluster
```
pks get-credentials devops > devops.yaml
```
Check if cluster is accessible
```
kubectl cluster-info
Kubernetes master is running at https://devops-k8s.aws.yogendra.me.:8443
CoreDNS is running at https://devops-k8s.aws.yogendra.me.:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

### Create a namespace
```
kubectl create ns my-app
```

### Deploy docker image to Kubernetes cluster

The starterkit ships with pre-baked kubernetes deployment manifest to deploy the application to Kubernetes. Execute the command below to deploy your docker image to PKS cluster.
```
kubectl apply -f springboot.yaml
```

Check if application is running
```
$ kubectl get po -n my-app
NAME                          READY   STATUS    RESTARTS   AGE
springboot-74c6664448-4blvx   1/1     Running   0          13s
```
```
kubectl get svc -n my-app
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
springboot   ClusterIP   10.105.151.229   <none>        8080/TCP   39s
```

In case the external IP shows <PENDING> it implies that the cluster does not provide a Loadbalancer, in that case you can build a proxy to the concerned service

```
kubectl port-forward  -n my-app svc/my-app 8080:8080
Forwarding from 127.0.0.1:8080 -> 3000
Forwarding from [::1]:8080 -> 3000
Handling connection for 8080
```

Access the application
```
curl localhost:8080
Hello Docker World
```
