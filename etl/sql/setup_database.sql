show search_path;

create schema raw;
create schema stage;
create schema working;
create schema campaign_finance;

set search_path to raw, stage, working, campaign_finance;

------------------------------------------------------------------------------------------------------------------------
-- RAW schema...
------------------------------------------------------------------------------------------------------------------------

-- Nothing to build as the data in this schema is a dump and load...

------------------------------------------------------------------------------------------------------------------------
-- WORKING schema...
------------------------------------------------------------------------------------------------------------------------
-- This data is derived from the incoming data...
create table working.clean_states
(
	input_state text,
	corrected_state text
);

alter table working.clean_states owner to kyptguqrobwxyb;

-- This data is extracted from the URL:
--   https://media.ethics.ga.gov/search/campaign/Campaign_Namesearchresults_NC.aspx?CommitteeType=1&CommitteeName=
create table working.committee_info
(
	nameid integer,
	filerid text,
	committeetype text,
	committeename text,
	address text,
	address2 text,
	city text,
	state text,
	zip text,
	telephone text,
	chairperson text,
	chairpersonaddress text,
	chairpersoncsz text,
	treasurer text,
	treasureraddress text,
	treasurercsz text
);

alter table working.committee_info owner to kyptguqrobwxyb;

-- This data is derived from the incoming data...
create table working.pacs
(
	keep boolean default true,
	pac_name text,
	validated boolean
);

alter table working.pacs owner to kyptguqrobwxyb;

------------------------------------------------------------------------------------------------------------------------
-- STAGE schema...
------------------------------------------------------------------------------------------------------------------------
drop table if exists stage.ethics_report;

create table stage.ethics_report
(
    ukey text primary key,
    ymd timestamp default now(),
	filerid text,
	committee_name text,
	candidate_firstname text,
	candidate_middlename text,
	candidate_lastname text,
	candidate_suffix text,
	donation_type text,
	firstname text,
	lastname text,
	employer text,
	occupation text,
	address text,
	city text,
	state text,
	zip text,
	contribution_date date,
	contribution_type text,
	pac text,
	election text,
	election_year integer,
	cash_amount numeric(38, 2),
	in_kind_amount numeric(38, 2),
	in_kind_description text
);

alter table stage.ethics_report owner to kyptguqrobwxyb;

------------------------------------------------------------------------------------------------------------------------
-- CAMPAIGN_FINANCE schema...
------------------------------------------------------------------------------------------------------------------------

drop table if exists campaign_finance.dim_campaigns;

create table campaign_finance.dim_campaigns
(
    filerid text primary key,
    ymd timestamp default now(),
    is_pac bool,
    committee_name text,
    candidate_firstname text,
    candidate_middlename text,
    candidate_lastname text,
    candidate_suffix text
);

alter table campaign_finance.dim_campaigns owner to kyptguqrobwxyb;

create index dim_campaigns_idx
    on campaign_finance.dim_campaigns
        (filerid, committee_name, candidate_firstname, candidate_lastname);

drop table if exists campaign_finance.fact_contributions;

create table campaign_finance.fact_contributions
(
	ukey text primary key,
	ymd timestamp default now(),
	filerid text,
	donation_type text,
	firstname text,
	lastname text,
	employer text,
	occupation text,
	address text,
	city text,
	state text,
	zip text,
	contribution_date date,
	contribution_type text,
	pac text,
	election text,
	election_year integer,
	cash_amount numeric(38,2),
	in_kind_amount numeric(38,2),
	in_kind_description text
);

alter table campaign_finance.fact_contributions owner to kyptguqrobwxyb;

create index fact_contributions_filerid_idx
    on campaign_finance.fact_contributions
        (filerid);

create index fact_contributions_contributor_idx
    on campaign_finance.fact_contributions
        (firstname, lastname);
