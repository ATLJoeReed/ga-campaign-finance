#!/usr/bin/python3.8
# -*- coding: utf-8 -*-
from fastapi import FastAPI

from routers import campaigns, health_check


app = FastAPI(
    title='Campaign Finance API',
    description='API to extract state campaign contributions.',
    version='0.1.0'
)

app.include_router(health_check.router, prefix='/api', tags=['Admin'])
app.include_router(campaigns.router, prefix='/api', tags=['Campaigns'])
