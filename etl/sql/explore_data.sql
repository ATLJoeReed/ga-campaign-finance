set search_path to raw, stage, working, campaign_finance;
show search_path;

-- Amount of money given to PAC by contribution year...
select
    extract(year from contribution_date) as contribution_year,
    sum(coalesce(nullif(a.cash_amount, 0), a.in_kind_amount))::numeric(38, 2) as total_contributions
from campaign_finance.fact_contributions as a
    inner join campaign_finance.dim_campaigns as b
        on a.filerid = b.filerid
where b.is_pac
group by extract(year from contribution_date)
order by contribution_year;

-- Amount of money given to PAC by election year...
select
    coalesce(a.election_year, extract(year from contribution_date)) as election_year,
    sum(coalesce(nullif(a.cash_amount, 0), a.in_kind_amount))::numeric(38, 2) as total_contributions
from campaign_finance.fact_contributions as a
    inner join campaign_finance.dim_campaigns as b
        on a.filerid = b.filerid
where b.is_pac
    and coalesce(a.election_year, extract(year from contribution_date)) between 2017 and 2020
group by coalesce(a.election_year, extract(year from contribution_date))
order by election_year;

-- Campaign Overview...
select
    a.filerid,
    b.committee_name,
    trim(regexp_replace(concat(b.candidate_firstname, ' ', b.candidate_middlename, ' ', b.candidate_lastname, ' ', b.candidate_suffix), '\s+', ' ', 'g')) as candidate_name,
    min(a.contribution_date) as start_contributions,
    max(a.contribution_date) as end_contributions,
    count(case when contribution_type = 'Monetary' then 1 else null end) as num_monetary_contributions,
    sum(cash_amount)::numeric(38, 2) as total_monetary_contribution,
    count(case when contribution_type = 'In-Kind' then 1 else null end) as num_in_kind_contributions,
    sum(in_kind_amount)::numeric(38, 2) as total_in_kind_contribution,
    count(case when donation_type = 'Individual' then 1 else null end) as num_individual_contributions,
    sum(case when donation_type = 'Individual' then cash_amount else 0 end)::numeric(38, 2) as total_individual_contributions,
    avg(case when donation_type = 'Individual' then cash_amount else null end)::numeric(38, 2) as avg_individual_donation,
    count(case when donation_type = 'Corporate' then 1 else null end) as num_corporate_contributions,
    sum(case when donation_type = 'Corporate' then cash_amount else 0 end)::numeric(38, 2) as total_corporate_contributions,
    count(case when donation_type = 'Political Action Committee (PAC)' then 1 else null end) as num_pac_contributions,
    sum(case when donation_type = 'Political Action Committee (PAC)' then cash_amount else 0 end)::numeric(38, 2) as total_pac_contributions
from campaign_finance.fact_contributions as a
    inner join campaign_finance.dim_campaigns as b
        on a.filerid = b.filerid
where a.filerid in ('C2020000155', 'C2013000208', 'C2008000422', 'C2020000196', 'C2020000517')
    and coalesce(a.election_year, extract(year from contribution_date)) = 2020
--     and election = 'General'
group by a.filerid, b.committee_name, b.candidate_firstname, b.candidate_middlename, b.candidate_lastname, b.candidate_suffix
order by filerid;

-- Top 5 PAC contributions...
select
    a.filerid,
    b.committee_name,
    a.donation_type,
    a.lastname as contributor,
    sum(coalesce(nullif(a.cash_amount, 0), a.in_kind_amount))::numeric(38, 2) as total_contributions
from campaign_finance.fact_contributions as a
    inner join campaign_finance.dim_campaigns as b
        on a.filerid = b.filerid
where a.filerid = 'C2020000517'
    and a.donation_type = 'Political Action Committee (PAC)'
    and coalesce(a.election_year, extract(year from contribution_date)) = 2020
group by a.filerid, b.committee_name, a.donation_type, a.lastname
order by total_contributions desc
limit 5;


-- Top 10 Corporate contributions...
select
    a.filerid,
    b.committee_name,
    a.donation_type,
    a.lastname as contributor,
    sum(coalesce(nullif(a.cash_amount, 0), a.in_kind_amount))::numeric(38, 2) as total_contributions
from campaign_finance.fact_contributions as a
    inner join campaign_finance.dim_campaigns as b
        on a.filerid = b.filerid
where a.filerid = 'C2020000517'
    and a.donation_type = 'Corporate'
    and coalesce(a.election_year, extract(year from contribution_date)) = 2020
group by a.filerid, b.committee_name, a.donation_type, a.lastname
order by total_contributions desc
limit 10;

-- Top 10 Individual contributions...
select
    a.filerid,
    b.committee_name,
    trim(regexp_replace(concat(b.candidate_firstname, ' ', b.candidate_middlename, ' ', b.candidate_lastname, ' ', b.candidate_suffix), '\s+', ' ', 'g')) as candidate_name,
    a.donation_type,
    trim(regexp_replace(concat(a.firstname, ' ', a.lastname), '\s+', ' ', 'g')) as contributor,
    sum(coalesce(nullif(a.cash_amount, 0), a.in_kind_amount))::numeric(38, 2) as total_contributions
from campaign_finance.fact_contributions as a
    inner join campaign_finance.dim_campaigns as b
        on a.filerid = b.filerid
where a.filerid = 'C2020000517'
    and a.donation_type = 'Individual'
    and coalesce(a.election_year, extract(year from contribution_date)) = 2020
group by a.filerid, b.committee_name, a.donation_type, a.firstname, a.lastname,
    b.candidate_firstname, b.candidate_middlename, b.candidate_lastname, b.candidate_suffix
order by total_contributions desc
limit 10;

-- Top campaigns by total contributions for election year 2020...
select
    a.filerid,
    c.committeetype as committee_type,
    b.committee_name,
    trim(regexp_replace(concat(b.candidate_firstname, ' ', b.candidate_middlename, ' ', b.candidate_lastname, ' ', b.candidate_suffix), '\s+', ' ', 'g')) as candidate_name,
    sum(coalesce(nullif(a.cash_amount, 0), a.in_kind_amount))::numeric(38, 2) as total_contributions
from campaign_finance.fact_contributions as a
    inner join campaign_finance.dim_campaigns as b
        on a.filerid = b.filerid
    left join working.committee_info as c
        on a.filerid = c.filerid
where coalesce(a.election_year, extract(year from contribution_date)) = 2020
group by a.filerid, c.committeetype, b.committee_name, b.candidate_firstname, b.candidate_middlename,
    b.candidate_lastname, b.candidate_suffix
order by total_contributions desc;

select *
from campaign_finance.fact_contributions
where filerid = 'C2020000517'
order by coalesce(nullif(cash_amount, 0), in_kind_amount)::numeric(38, 2) desc;

select
    b.filerid, b.committee_name,
    trim(regexp_replace(concat(b.candidate_firstname, ' ', b.candidate_middlename, ' ', b.candidate_lastname, ' ', b.candidate_suffix), '\s+', ' ', 'g')) as candidate_name,
    a.donation_type, a.firstname, a.lastname, a.employer, a.occupation, a.address, a.city, a.state, a.zip,
    a.contribution_date, a.contribution_type, a.election, a.election_year, a.cash_amount, a.in_kind_amount,
    a.in_kind_description
-- select count(*) as cnt
from campaign_finance.fact_contributions as a
    inner join campaign_finance.dim_campaigns as b
        on a.filerid = b.filerid
where coalesce(a.election_year, extract(year from contribution_date)) = 2020
    and upper(left(a.filerid, 1)) = 'C'
order by a.filerid, a.contribution_date;


select
    b.filerid, b.committee_name, c.committeetype as committee_type,
    a.donation_type, a.firstname, a.lastname, a.employer, a.occupation, a.address, a.city, a.state, a.zip,
    a.contribution_date, a.contribution_type, a.election, a.election_year, a.cash_amount, a.in_kind_amount,
    a.in_kind_description
-- select count(*) as cnt
from campaign_finance.fact_contributions as a
    inner join campaign_finance.dim_campaigns as b
        on a.filerid = b.filerid
    inner join working.committee_info as c
        on a.filerid = c.filerid
where coalesce(a.election_year, extract(year from contribution_date)) = 2020
    and upper(left(a.filerid, 2)) = 'NC'
order by a.filerid, a.contribution_date;



