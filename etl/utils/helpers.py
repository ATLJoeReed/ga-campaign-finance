#!/usr/bin/python3.8
# -*- coding: utf-8 -*-
import logging
import sys

import psycopg2
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

from utils import settings


def build_url(start_date, end_date, logger):
    from_to = f"&From={start_date}&To={end_date}"
    url = f"http://media.ethics.ga.gov/search/Campaign/Campaign_ByContributionsearchresults.aspx?Contributor=&Zip=&City=&ContTypeID=0&PAC=&Employer=&Occupation={from_to}&Cash=&InK=&Filer=&Candidate=&Committee=" # noqa
    return url


def get_browser():
    chrome_options = Options()
    chrome_options.add_argument('--headless')
    return webdriver.Chrome(
        executable_path="/Users/skunkworks/Development/chromedriver",
        options=chrome_options
    )


def get_database_connection():
    return psycopg2.connect(**settings.DB_CONN)


def setup_logger_stdout(logger_name):
    logger = logging.getLogger(logger_name)
    logger.setLevel(logging.DEBUG)
    ch = logging.StreamHandler(sys.stdout)
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    ch.setFormatter(formatter)
    logger.addHandler(ch)
    return logger
