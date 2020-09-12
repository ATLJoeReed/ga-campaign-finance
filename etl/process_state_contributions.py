import os
import sys

from utils import helpers

from workers import fetch_state_contributions
from workers import load_state_contributions


def process_state_contributions(logger):
    logger.info('Starting to process state contributions')

    # Step #1 - Extract all contributions for 2020...
    results = fetch_state_contributions.process(logger)
    if results.get('status') == 'Fail':
        sys.exit(1)

    conn = helpers.get_database_connection()

    # Step #2 - Load all contributions into raw.ethics_report in Postgres...
    results = load_state_contributions.process(conn, logger)
    if results.get('status') == 'Fail':
        conn.close()
        sys.exit(1)

    # Step #3 - Clean and prepare data to load into final table...


if __name__ == '__main__':
    # move to working directory...
    abspath = os.path.abspath(__file__)
    dname = os.path.dirname(abspath)
    os.chdir(dname)

    logger = helpers.setup_logger_stdout('process_state_contributions')

    process_state_contributions(logger)
