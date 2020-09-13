#!/usr/bin/python3.8
# -*- coding: utf-8 -*-
import logging
import os
import sys

import pandas.io.sql as psql
import psycopg2


def extract_data(sql, params=None):
    df = extract_dataframe(sql, params)
    results = df.to_dict(orient='records')
    df.drop(df.index, inplace=True)
    return results


def extract_dataframe(sql, params=None):
    if params:
        sql = sql.format(**params)
    conn = get_database_connection()
    df = psql.read_sql(sql, conn)
    conn.close()
    df.columns = map(str.lower, df.columns)
    return df


def get_database_connection():
    return psycopg2.connect(
        dbname=os.environ.get('DATABASE'),
        user=os.environ.get('USER'),
        password=os.environ.get('PASSWORD'),
        host=os.environ.get('HOST')
        # port=os.environ.get('PORT')
    )


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
