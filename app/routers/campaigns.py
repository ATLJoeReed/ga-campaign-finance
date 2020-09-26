#!/usr/bin/python3.8
# -*- coding: utf-8 -*-
from typing import List, Optional

from fastapi import APIRouter
from pydantic import BaseModel

from app.utils import constants_sql, helpers


router = APIRouter()


class Candidates(BaseModel):
    filerid: str
    committee_name: Optional[str]
    candidate_firstname: Optional[str]
    candidate_middlename: Optional[str]
    candidate_lastname: Optional[str]
    candidate_suffix: Optional[str]


@router.get('/candidates', response_model=List[Candidates])
def get_all_candidates():
    """
    Get all candidates.
    """
    sql = constants_sql.GET_ALL_CANDIDATES_SQL
    return helpers.extract_data(sql)


class Committees(BaseModel):
    filerid: str
    committee_name: str


@router.get('/committees', response_model=List[Committees])
def get_all_committees():
    """
    Get all committees.
    """
    sql = constants_sql.GET_ALL_COMMITTEES_SQL
    return helpers.extract_data(sql)
