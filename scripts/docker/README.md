# Release to Docker Hub

```bash
docker login --username=USER_NAME
docker tag IMAGE_ID sparkfhe/sparkfhe-standalone:latest
docker push sparkfhe/sparkfhe-standalone
```