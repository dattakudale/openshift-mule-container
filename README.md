# openshift-mule-411

Build Image from Mule Source app

```
s2i https://github.com/dkudale/mule-app.git mule-esb-4.1.1:latest hello

docker run -d -p 8081:8081 hello

curl http://localhost:8081/test
```