import fastapi
from typing import Optional
import uvicorn

api = fastapi.FastAPI()


@api.get('/api/healthy')
def config():
    return {
        'healthy': True
    }

@api.get('/api/ready')
def config():
    return {
        'ready': True
    }

uvicorn.run(api, host="0.0.0.0", port=8000)