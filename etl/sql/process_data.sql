set search_path to raw, stage, working, campaign_finance;

show search_path;


------------------------------------------------------------------------------------------------------------------------
-- Put the NULLs back inplace...
------------------------------------------------------------------------------------------------------------------------
update stage.ethics_report set committee_name = null where coalesce(committee_name, '') = '';
update stage.ethics_report set candidate_firstname = null where coalesce(candidate_firstname, '') = '';
update stage.ethics_report set candidate_middlename = null where coalesce(candidate_middlename, '') = '';
update stage.ethics_report set candidate_lastname = null where coalesce(candidate_lastname, '') = '';
update stage.ethics_report set candidate_suffix = null where coalesce(candidate_suffix, '') = '';
update stage.ethics_report set firstname = null where coalesce(firstname, '') = '';
update stage.ethics_report set lastname = null where coalesce(lastname, '') = '';
update stage.ethics_report set employer = null where coalesce(employer, '') = '';
update stage.ethics_report set occupation = null where coalesce(occupation, '') = '';
update stage.ethics_report set address = null where coalesce(address, '') = '';
update stage.ethics_report set city = null where coalesce(city, '') = '';
update stage.ethics_report set state = null where coalesce(state, '') = '';
update stage.ethics_report set zip = null where coalesce(zip, '') = '';
update stage.ethics_report set pac = null where coalesce(pac, '') = '';
update stage.ethics_report set election = null where coalesce(election, '') = '';
update stage.ethics_report set in_kind_description = null where coalesce(in_kind_description, '') = '';

select *
from stage.ethics_report;


------------------------------------------------------------------------------------------------------------------------
-- Cleanup "" in name fields...
------------------------------------------------------------------------------------------------------------------------
-- Candidate name...
update stage.ethics_report
    set candidate_firstname = trim(regexp_replace(replace(candidate_firstname, '"', ''), '\s+', ' ', 'g'));
update stage.ethics_report
    set candidate_firstname = trim(regexp_replace(replace(candidate_firstname, '"', ''), '\s+', ' ', 'g'));
update stage.ethics_report
    set candidate_middlename = trim(regexp_replace(replace(candidate_middlename, '"', ''), '\s+', ' ', 'g'));
update stage.ethics_report
    set candidate_lastname = trim(regexp_replace(replace(candidate_lastname, '"', ''), '\s+', ' ', 'g'));
update stage.ethics_report
    set candidate_suffix = trim(regexp_replace(replace(candidate_suffix, '"', ''), '\s+', ' ', 'g'));

-- Donor name...
update stage.ethics_report
    set firstname = trim(regexp_replace(replace(firstname, '"', ''), '\s+', ' ', 'g'));
update stage.ethics_report
    set lastname = trim(regexp_replace(replace(lastname, '"', ''), '\s+', ' ', 'g'));

-- Committee name...
update stage.ethics_report
    set committee_name = trim(regexp_replace(replace(committee_name, '"', ''), '\s+', ' ', 'g'));

select *
from stage.ethics_report
limit 5000;

------------------------------------------------------------------------------------------------------------------------
-- Setup table to fix state field...
------------------------------------------------------------------------------------------------------------------------
-- create schema working;
--
-- drop table if exists working.clean_states;
--
-- select distinct state as input_stage, null::text as corrected_state
-- into working.clean_states
-- from stage.ethics_report
-- order by input_city;

select *
from working.clean_states;

select ukey, address, city, state, zip
from stage.ethics_report as a
    inner join working.clean_states as b
        on a.state = b.input_state
where b.corrected_state is null
order by state, zip;

update stage.ethics_report
    set state = upper(trim(state));

update stage.ethics_report
    set state = b.corrected_state
from working.clean_states as b
where state = b.input_state
    and b.corrected_state is not null;

-- Manual fixing a few...
update stage.ethics_report
    set state = 'GA'
where city = 'KENNESAW'
    and state = '33';

update stage.ethics_report
    set state = 'GA'
where city = 'Richmond Hill'
    and state = '3631';

update stage.ethics_report
    set state = 'GA'
where city = 'Crawfordville'
    and zip = '30631';

update stage.ethics_report
    set state = 'GA'
where upper(trim(state)) = 'GEORGIA';

select ukey, address, city, state, zip
from stage.ethics_report
where trim(lower(state)) = 'g'
    and left(zip, 1) = '3';

update stage.ethics_report
    set state = 'GA'
where trim(lower(state)) = 'g'
    and left(zip, 1) = '3';

select ukey, address, city, state, zip
from stage.ethics_report
where state = 'GE'
    and left(zip, 1) = '3';

update stage.ethics_report
    set state = 'GA'
where state = 'GE'
    and left(zip, 1) = '3';

select ukey, address, city, state, zip
from stage.ethics_report as a
    inner join working.clean_states as b
        on a.state = b.input_state
where b.corrected_state is null
order by state, zip;

-- MANUAL EDIT A FEW WITH DATAGRIP...

select ukey, address, city, state, zip
from stage.ethics_report
where length(state) > 2
order by state;

select state, count(*) as cnt
from stage.ethics_report
group by state
order by cnt desc;

------------------------------------------------------------------------------------------------------------------------
-- Tag donation type...
------------------------------------------------------------------------------------------------------------------------
select
    donation_type,
    firstname,
    length(firstname) - length(replace(firstname,' ', '')) AS firstname_spaces,
    lastname,
    length(lastname) - length(replace(lastname,' ', '')) AS lastname_spaces,
    occupation,
    employer,
    pac
-- select *
from stage.ethics_report
where coalesce(donation_type, '') = ''
    and length(firstname) - length(replace(firstname,' ', '')) = 1
    and length(lastname) - length(replace(lastname,' ', '')) = 1;
-- where occupation is null
--     and coalesce(firstname, '') <> ''
-- limit 5000;

-- RESET
update stage.ethics_report
    set donation_type = null;

update stage.ethics_report
    set donation_type = 'Individual'
where coalesce(firstname, '') <> ''
    and coalesce(lastname, '') <> ''
    and coalesce(occupation, '') <> '';

update stage.ethics_report
    set donation_type = 'Corporate'
where coalesce(firstname, '') = ''
    and coalesce(lastname, '') <> ''
    and coalesce(occupation, '') = '';

update stage.ethics_report
    set donation_type = 'Individual'
where donation_type is null
    and coalesce(firstname, '') <> ''
    and coalesce(lastname, '') <> ''
    and length(firstname) - length(replace(firstname,' ', '')) = 0;

update stage.ethics_report
    set donation_type = 'Individual'
where donation_type is null
    and coalesce(firstname, '') <> ''
    and coalesce(lastname, '') <> ''
    and length(firstname) - length(replace(firstname,' ', '')) = 1
    and length(lastname) - length(replace(lastname,' ', '')) = 0;

update stage.ethics_report
    set donation_type = 'Individual'
where donation_type is null
    and coalesce(firstname, '') <> ''
    and coalesce(lastname, '') <> ''
    and length(firstname) - length(replace(firstname,' ', '')) = 2
    and length(lastname) - length(replace(lastname,' ', '')) = 0;

update stage.ethics_report
    set donation_type = 'Corporate'
where donation_type is null
    and coalesce(firstname, '') = ''
    and coalesce(lastname, '') <> '';

update stage.ethics_report
    set donation_type = 'Individual'
where donation_type is null
    and coalesce(firstname, '') <> ''
    and coalesce(lastname, '') <> ''
    and length(lastname) - length(replace(lastname,' ', '')) = 0;

-- Check the remaining and tag any that are individual...
select *
from stage.ethics_report
where donation_type is null
order by firstname;

update stage.ethics_report
    set donation_type = 'Corporate'
where donation_type is null;

/*
-- RESET...

update campaign_finance.stage.ethics_report
    set donation_type = 'Corporate'
where donation_type = 'Political Action Committee (PAC)';
*/

update stage.ethics_report
    set donation_type = 'Political Action Committee (PAC)'
where donation_type = 'Corporate'
    and lastname ilike '% PAC %';

update stage.ethics_report
    set donation_type = 'Political Action Committee (PAC)'
where donation_type = 'Corporate'
    and lastname ilike '% PAC, %';

update stage.ethics_report
    set donation_type = 'Political Action Committee (PAC)'
where donation_type = 'Corporate'
    and lastname ilike '% PAC';

update stage.ethics_report
    set donation_type = 'Political Action Committee (PAC)'
where donation_type = 'Corporate'
    and lastname ilike '%ALLPAC%';

update stage.ethics_report
    set donation_type = 'Political Action Committee (PAC)'
where donation_type = 'Corporate'
    and lastname ilike '%-PAC%';

update stage.ethics_report
    set donation_type = 'Political Action Committee (PAC)'
where donation_type = 'Corporate'
    and lastname ilike '%PAC-%';

update stage.ethics_report
    set donation_type = 'Political Action Committee (PAC)'
where donation_type = 'Corporate'
    and lastname ilike 'BEVPAC%';

update stage.ethics_report
    set donation_type = 'Political Action Committee (PAC)'
where donation_type = 'Corporate'
    and lastname ilike '%CUPAC%';

update stage.ethics_report
    set donation_type = 'Political Action Committee (PAC)'
where donation_type = 'Corporate'
    and lastname ilike '%HOSPAC%';

update stage.ethics_report
    set donation_type = 'Political Action Committee (PAC)'
where donation_type = 'Corporate'
    and lastname ilike '%UPSPAC%';

update stage.ethics_report
    set donation_type = 'Political Action Committee (PAC)'
where donation_type = 'Corporate'
    and lastname ilike '%Political%Action%Committee%';

update stage.ethics_report
    set donation_type = 'Political Action Committee (PAC)'
where donation_type = 'Corporate'
    and lastname ilike '%Political%Action%';


insert into working.pacs (pac_name)
select distinct a.lastname
from stage.ethics_report as a
    left join working.pacs as b
        on trim(a.lastname) = trim(b.pac_name)
where a.donation_type = 'Corporate'
    and a.lastname ilike '%PAC%'
    and b.pac_name is null
order by a.lastname;

-- Work through all the rows with validated = False...

select *
from working.pacs
order by pac_name;

delete from working.pacs
where not keep;

update working.pacs
    set validated = True;

-- Once all the rows in working.pacs looks good with keep = True and validated = True
-- Run this update statement...

update stage.ethics_report as a
    set donation_type = 'Political Action Committee (PAC)'
from working.pacs as b
where trim(a.lastname) = trim(b.pac_name)
    and a.donation_type = 'Corporate';

-- NEED MORE INSIGHT ABOUT PACs BEFORE TAGGING MORE OF THEM...
-- I have working.committee_info that might could be used to tag additional
-- PACs...

-- Review these and update manually...
with pacs as
(
    select distinct committeename
    from working.committee_info
    where committeetype = 'Political Action Committee'
)
select distinct a.lastname
from stage.ethics_report as a
    inner join pacs as b
        on trim(a.lastname) = trim(b.committeename)
where donation_type = 'Corporate'
order by lastname;

------------------------------------------------------------------------------------------------------------------------
-- Build out final tables...
------------------------------------------------------------------------------------------------------------------------

-- truncate table campaign_finance.fact_contributions;

delete
-- select count(*) as cnt
from campaign_finance.fact_contributions
where extract(year from contribution_date) = 2020;
-- 71287

select count(*) as cnt
from stage.ethics_report
where extract(year from contribution_date) = 2020;
-- 71328

insert into campaign_finance.fact_contributions
    (ukey, filerid, donation_type, firstname, lastname, employer, occupation, address,
    city, state, zip, contribution_date, contribution_type, pac, election, election_year,
    cash_amount, in_kind_amount, in_kind_description)
select
    ukey,
    filerid,
	donation_type,
	firstname,
	lastname,
	employer,
	occupation,
	address,
	city,
	state,
	zip,
	contribution_date,
	contribution_type,
	pac,
	election,
	election_year,
	cash_amount,
	in_kind_amount,
	in_kind_description
from stage.ethics_report
order by filerid, contribution_type, contribution_date;

select *
from campaign_finance.fact_contributions
where extract(year from contribution_date) != 2020
limit 5000;


-- Fix one committee_name so we are unique in the dim table...
update stage.ethics_report
    set committee_name = 'Committee to Elect Megan Lane Connell'
where filerid = 'C2018000163';

select count(distinct filerid) as cnt
from stage.ethics_report;
-- 777

-- truncate table campaign_finance.dim_campaigns;

insert into campaign_finance.dim_campaigns
    (filerid, committee_name, candidate_firstname, candidate_middlename, candidate_lastname, candidate_suffix)
select distinct
    a.filerid,
    a.committee_name,
    a.candidate_firstname,
    a.candidate_middlename,
    a.candidate_lastname,
    a.candidate_suffix
from stage.ethics_report as a
    left join campaign_finance.dim_campaigns as b
        on a.filerid = b.filerid
where b.filerid is null
order by a.filerid;

select *
from campaign_finance.dim_campaigns
order by ymd desc;

select *
from campaign_finance.dim_campaigns;

update campaign_finance.dim_campaigns set committee_name = null where coalesce(committee_name, '') = '';
update campaign_finance.dim_campaigns set candidate_firstname = null where coalesce(candidate_firstname, '') = '';
update campaign_finance.dim_campaigns set candidate_middlename = null where coalesce(candidate_middlename, '') = '';
update campaign_finance.dim_campaigns set candidate_lastname = null where coalesce(candidate_lastname, '') = '';
update campaign_finance.dim_campaigns set candidate_suffix = null where coalesce(candidate_suffix, '') = '';




update campaign_finance.dim_campaigns
    set is_pac = False;

select *
from working.committee_info;

update campaign_finance.dim_campaigns as a
    set is_pac = True
from working.committee_info as b
where a.filerid = b.filerid
    and b.committeetype = 'Political Action Committee';

select *
from campaign_finance.dim_campaigns
where is_pac;


