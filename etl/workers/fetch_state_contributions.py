#!/usr/bin/python3.8
# -*- coding: utf-8 -*-
import glob
import os
import shutil
import time

from utils import constants, helpers


def process(logger):
    logger.info('<<Starting the contribution fetch process>>')
    # clear out the extracted files directory...
    for f in glob.glob('./extracted_files/*'):
        os.remove(f)

    logger.info('Getting Seneium browser object')
    try:
        browser = helpers.get_browser()
    except Exception as e:
        logger.error(f'Getting Senenium browser object: {e}')
        return constants.FAILED_OBJECT

    months = constants.EXTRACT_MONTHS_2020
    for month in months:
        start_date, end_date, file_suffix = month
        logger.info(f'Extracting contributions between {start_date} and {end_date}') # noqa
        try:
            url = helpers.build_url(start_date, end_date, logger)
            browser.get(url)
            browser.find_element_by_id("ContentPlaceHolder1_Export").click()
            logger.info(f'Saving contributions to file ethics_report{file_suffix}.csv') # noqa
            # TODO: Change this to wait till file is created...
            time.sleep(10)
            os.rename(
                'StateEthicsReport.csv',
                f'ethics_report{file_suffix}.csv'
            )
            logger.info('Moving file into ./extracted_files/ directory')
            shutil.move(
                f'./ethics_report{file_suffix}.csv',
                f'./extracted_files/ethics_report{file_suffix}.csv',
            )
        except Exception as e:
            logger.error(f'Extracting file: {e}')
            browser.quit()
            return constants.FAILED_OBJECT

    browser.quit()
    logger.info('<<Contribution fetch process complete>>')
    return constants.SUCCESS_OBJECT
