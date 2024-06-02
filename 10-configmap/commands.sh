# build and test container locally
docker build -t scottenriquez/fastapi-example ./API/container/
docker run -p 8080:8000 scottenriquez/fastapi-example
curl http://localhost:8080/api/config

# deploy container to Elastic Container Registry
npm install
cd API
cdk deploy

