ALTER_ETHICS_REPORT_SQL = """
alter table raw.ethics_report
    add column id serial,
    add column ukey text;

update raw.ethics_report set ukey = '2020_' || id::text;
"""

CREATE_ETHICS_REPORT_SQL = """
drop table if exists raw.ethics_report;

create table raw.ethics_report
(
    address text,
    candidate_firstname text,
    candidate_lastname text,
    candidate_middlename text,
    candidate_suffix text,
    cash_amount numeric,
    city text,
    committee_name text,
    date text,
    election text,
    election_year text,
    employer text,
    filerid text,
    firstname text,
    in_kind_amount numeric,
    in_kind_description text,
    lastname text,
    occupation text,
    pac text,
    state text,
    type text,
    zip text
);

alter table raw.ethics_report owner to kyptguqrobwxyb;
"""

MOVE_DATA_TO_STAGE_SQL = """
truncate table stage.ethics_report;

insert into stage.ethics_report
    (ukey, filerid, committee_name, candidate_firstname, candidate_middlename,
    candidate_lastname, candidate_suffix, firstname, lastname, employer,
    occupation, address, city, state, zip, contribution_date, contribution_type,
    pac, election, election_year, cash_amount, in_kind_amount, in_kind_description)
select ukey, filerid, committee_name, candidate_firstname, candidate_middlename,
    candidate_lastname, candidate_suffix, firstname, lastname, employer,
    occupation, address, city, state, zip, date::date, type,
    pac, election, left(nullif(election_year, ''), 4)::int,
    cash_amount, in_kind_amount, in_kind_description
from raw.ethics_report;
""" # noqa
