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

ALTER_ETHICS_REPORT_SQL = """
alter table raw.ethics_report
    add column id serial,
    add column ukey text;
update raw.ethics_report_2017 set ukey = '2020_' || id::text;
"""
