# openshift-mule-411

## Build Mule Builder image using Docker
```
git clone https://github.com/dkudale/openshift-mule-container.git
cd openshift-mule-container
docker build -t mule-esb-4.1.1:latest .

oc create imagestream mule-esb-4.1.1

oc tag <host>/mule-esb-4.1.1 mule-esb-project/mule-esb-4.1.1:latest

oc import-image mule-esb-4.1.1 --confirm --from=<host>/mule-esb-4.1.1

```

## Build Mule Builder image Openshift Build
```
oc new-project mule-esb-project --description="Mule ESB" --display-name="Mule ESB project"

git clone https://github.com/dkudale/openshift-mule-container.git
cd openshift-mule-container
oc create -f openshift-build.yaml

oc create -f templates/mule-411.json

```

## Build Image from Mule Source app

```
s2i build https://github.com/dkudale/mule-app.git mule-esb-4.1.1:latest mule-app

docker run -d -p 8081:8081 mule-app

curl http://localhost:8081/test
```

## Create app using Builder image and template
```
--param-file=-

oc new-app mule-esb-4.1.1:latest~https://github.com/dkudale/mule-app.git  --template=mule-4.1.1-s2i -l name=mule-app  -p APPLICATION_NAME=mule-app -p IMAGE_STREAM_NAMESPACE=mule-esb-project
```


## Template creation 
```
oc create -f https://raw.githubusercontent.com/dkudale/openshift-mule-container/master/templates/mule-411.json
```
