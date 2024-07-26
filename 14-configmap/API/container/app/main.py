import fastapi
import os
from typing import Optional
import uvicorn

api = fastapi.FastAPI()


@api.get('/api/config')
def config():
    return {
        'message': os.getenv('CONFIG_MESSAGE', 'Message not set')
    }


uvicorn.run(api, host="0.0.0.0", port=8000)