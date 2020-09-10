set search_path to raw, stage, working, campaign_finance;

show search_path;

------------------------------------------------------------------------------------------------------------------------
-- Load backfill data into RAW schema...
------------------------------------------------------------------------------------------------------------------------

-- using DataGrip to blow this data in...

select count(*) as cnt
from raw.ethics_report_2020;

-- Backfill years (pull this data once and load)
--    * 2017 - Qty: 91,310
--    * 2018 - Qty: 277,411
--    * 2019 - Qty: 109,327


--    * 2020 - Qty: 71287

-- Building a unique key so we can always look back at the raw data...

alter table raw.ethics_report_2017 add column id serial, add column ukey text;
alter table raw.ethics_report_2018 add column id serial, add column ukey text;
alter table raw.ethics_report_2019 add column id serial, add column ukey text;
alter table raw.ethics_report_2020 add column id serial, add column ukey text;

update raw.ethics_report_2017 set ukey = '2017_' || id::text;
update raw.ethics_report_2018 set ukey = '2018_' || id::text;
update raw.ethics_report_2019 set ukey = '2019_' || id::text;
update raw.ethics_report_2020 set ukey = '2020_' || id::text;

------------------------------------------------------------------------------------------------------------------------
-- Move all the data out of RAW in into STAGE for processing...
------------------------------------------------------------------------------------------------------------------------

-- truncate table stage.ethics_report;

insert into stage.ethics_report
    (ukey, filerid, committee_name, candidate_firstname, candidate_middlename, candidate_lastname, candidate_suffix,
    firstname, lastname, employer, occupation, address, city, state, zip, contribution_date, contribution_type,
    pac, election, election_year, cash_amount, in_kind_amount, in_kind_description)
select ukey, filerid, committee_name, candidate_firstname, candidate_middlename, candidate_lastname, candidate_suffix,
    firstname, lastname, employer, occupation, address, city, state, zip, date::date, type,
    pac, election, election_year, cash_amount, in_kind_amount, in_kind_description
from raw.ethics_report_2017
union all
select ukey, filerid, committee_name, candidate_firstname, candidate_middlename, candidate_lastname, candidate_suffix,
    firstname, lastname, employer, occupation, address, city, state, zip, date::date, type,
    pac, election, election_year, cash_amount, in_kind_amount, in_kind_description
from raw.ethics_report_2018
union all
select ukey, filerid, committee_name, candidate_firstname, candidate_middlename, candidate_lastname, candidate_suffix,
    firstname, lastname, employer, occupation, address, city, state, zip, date::date, type,
    pac, election, election_year, cash_amount, in_kind_amount, in_kind_description
from raw.ethics_report_2019
union all
select ukey, filerid, committee_name, candidate_firstname, candidate_middlename, candidate_lastname, candidate_suffix,
    firstname, lastname, employer, occupation, address, city, state, zip, date::date, type,
    pac, election, election_year, cash_amount, in_kind_amount, in_kind_description
from raw.ethics_report_2020;

-- Check data load...
select
    extract(year from contribution_date) as contribution_year,
    count(*) as num_donations,
    min(contribution_date) as start_date,
    max(contribution_date) as end_date,
    sum(coalesce(nullif(cash_amount, 0), in_kind_amount)) as sum_donation_amount
from stage.ethics_report
group by extract(year from contribution_date)
order by contribution_year;

select
    extract(year from contribution_date) as contribution_year,
    contribution_type,
    count(*) as num_donations,
    min(contribution_date) as start_date,
    max(contribution_date) as end_date,
    sum(coalesce(nullif(cash_amount, 0), in_kind_amount)) as sum_donation_amount
from stage.ethics_report
group by extract(year from contribution_date), contribution_type
order by contribution_year, contribution_type;

select *
from stage.ethics_report
limit 5000;





