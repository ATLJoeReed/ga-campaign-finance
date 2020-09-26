#!/usr/bin/python3.8
# -*- coding: utf-8 -*-
from fastapi import FastAPI

from app.routers import campaigns, contributions, health_check


app = FastAPI(
    title='Campaign Finance API',
    description='API to extract state campaign contributions.',
    version='0.1.0'
)

app.include_router(health_check.router, prefix='/api', tags=['Admin'])
app.include_router(campaigns.router, prefix='/api', tags=['Campaigns'])
app.include_router(contributions.router, prefix='/api', tags=['Contributions'])
