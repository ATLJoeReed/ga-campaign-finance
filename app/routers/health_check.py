#!/usr/bin/python3.8
# -*- coding: utf-8 -*-
from fastapi import APIRouter


router = APIRouter()


@router.get("/health_check", tags=["Admin"])
async def check_health():
    return {'status': 'alive'}
