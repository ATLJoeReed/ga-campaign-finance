#!/usr/bin/python3.8
# -*- coding: utf-8 -*-
import datetime
from typing import List

from fastapi import APIRouter
from pydantic import BaseModel

from app.utils import constants, constants_sql, helpers


router = APIRouter()


class Top5Corporations(BaseModel):
    name: str
    amount: float


class Top5PACs(BaseModel):
    name: str
    amount: float


class BreakoutByType(BaseModel):
    donation_type: str
    number_donations: int
    total_donations: float
    percentage: float


class CampaignSummary(BaseModel):
    filerid: str
    committee_name: str
    candidate_name: str
    total: float
    top_5_corporates: List[Top5Corporations]
    top_5_pacs: List[Top5PACs]
    breakdown: List[BreakoutByType]


@router.get('/campaign_summary', response_model=(CampaignSummary))
def get_campaign_summary(filerid: str, start_date: datetime.date, end_date: datetime.date): # noqa
    """
    Get a campaign contributions summary report.

    NOTE: This is only looking at monetary contributions.

    - Query Example: ?filerid=**C2020000196**?start_date=**2019-06-30**?end_date=**2020-09-22**
    """ # noqa
    params = {'filerid': filerid, start_date: start_date, end_date: end_date}

    sql = constants_sql.GET_BREAKOUT_BY_TYPE_SQL
    breakout = helpers.extract_data(sql, params)

    sql = constants_sql.GET_TOP_5_CORPORATIONS_SQL
    top_5_corporatations = helpers.extract_data(sql, params)

    sql = constants_sql.GET_TOP_5_PACS_SQL
    top_5_pacs = helpers.extract_data(sql, params)

    sql = constants_sql.GET_CAMPAIGH_SUMMARY_SQL
    campaign_summary = helpers.extract_data(sql, params)

    if campaign_summary:
        return {
            'filerid': campaign_summary[0].get('filerid'),
            'committee_name': campaign_summary[0].get('committee_name'),
            'candidate_name': campaign_summary[0].get('candidate_name'),
            'total': campaign_summary[0].get('total_contributions'),
            'top_5_corporates': top_5_corporatations,
            'top_5_pacs': top_5_pacs,
            'breakdown': breakout,
        }
    else:
        return constants.CAMPAIGN_SUMMARY_SHELL
