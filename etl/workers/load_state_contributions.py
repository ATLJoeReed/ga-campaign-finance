#!/usr/bin/python3.8
# -*- coding: utf-8 -*-
import glob
import os

import pandas as pd

from utils import constants, constants_sql


def process(conn, logger):
    logger.info('<<Starting the data load process>>')
    cursor = conn.cursor()

    file_name = './extracted_files/ethics_report_all.csv'

    if os.path.exists(file_name):
        os.remove(file_name)

    logger.info('Loading data into dataframe')
    df = pd.concat(map(pd.read_csv, glob.glob(os.path.join('./extracted_files/', "*.csv"))), sort=True) # noqa
    df.columns = map(str.lower, df.columns)
    num_loaded = df.shape[0]
    logger.info(f'Loaded {num_loaded:,} contributions')
    logger.info('Cleaning data')
    # Both of the below replaces are needed to get the data inshape so it can
    # be loaded into Postgres.
    # Make sure the delimiter is not present in the data...
    df.replace('\|', ' ', regex=True, inplace=True) # noqa
    # Removing tab and line breaks...
    df.replace(to_replace=[r"\\t|\\n|\\r", "\t|\n|\r"], value=["", ""], regex=True, inplace=True) # noqa 

    df.to_csv(file_name, sep="|", index=False, header=False)

    logger.info('Starting to loading data into raw.ethics_report table')
    try:
        f = open(file_name, 'r')
        logger.info('Creating raw.ethics_report table')
        cursor.execute(constants_sql.CREATE_ETHICS_REPORT_SQL)
        logger.info('Bulk loading data into raw.ethics_report table')
        cursor.copy_from(f, 'raw.ethics_report', sep="|")
        logger.info('Adding id and ukey fields')
        cursor.execute(constants_sql.ALTER_ETHICS_REPORT_SQL)
        conn.commit()
        logger.info('Moving data from RAW schema to STAGE schema')
        cursor.execute(constants_sql.MOVE_DATA_TO_STAGE_SQL)
        conn.commit()
    except Exception as e:
        logger.debug(f'Error loading data: {e}')
        conn.rollback()
        return constants.FAILED_OBJECT
    finally:
        cursor.close()

    return constants.SUCCESS_OBJECT
    logger.info('<<Data load process complete>>')
