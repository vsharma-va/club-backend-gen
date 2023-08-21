from fastapi import FastAPI
from routers.auth import auth

app = FastAPI()
app.include_router(auth.router)