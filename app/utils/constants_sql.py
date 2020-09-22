#!/usr/bin/python3.8
# -*- coding: utf-8 -*-
GET_BREAKOUT_BY_TYPE_SQL = """
with count_all_donations as
(
    select count(*) as total_number_donations
    from campaign_finance.fact_contributions
    where filerid = '{filerid}'
        and coalesce(election_year, extract(year from contribution_date)) = 2020
        and contribution_type = 'Monetary'
)
select
    a.donation_type,
    count(*) as number_donations,
    sum(a.cash_amount)::numeric(38,2) as total_donations,
    (count(*)::float / b.total_number_donations * 100)::numeric(10, 3) as percentage
from campaign_finance.fact_contributions as a
cross join count_all_donations as b
where a.filerid = '{filerid}'
    and a.contribution_date between '{start_date}' and '{end_date}'
    -- and coalesce(a.election_year, extract(year from a.contribution_date)) = 2020
    and a.contribution_type = 'Monetary'
group by a.donation_type, b.total_number_donations
order by a.donation_type;
""" # noqa

GET_CAMPAIGH_SUMMARY_SQL = """
select
    a.filerid,
    b.committee_name,
    trim(regexp_replace(concat(b.candidate_firstname, ' ', b.candidate_middlename, ' ', b.candidate_lastname, ' ', b.candidate_suffix), '\s+', ' ', 'g')) as candidate_name,
    sum(a.cash_amount)::numeric(38, 2) as total_contributions
from campaign_finance.fact_contributions as a
    inner join campaign_finance.dim_campaigns as b
        on a.filerid = b.filerid
where a.filerid = '{filerid}'
    and a.contribution_date between '{start_date}' and '{end_date}'
    -- and coalesce(a.election_year, extract(year from contribution_date)) = 2020
    and contribution_type = 'Monetary'
group by a.filerid, b.committee_name, b.candidate_firstname, b.candidate_middlename, b.candidate_lastname, b.candidate_suffix;
""" # noqa

GET_TOP_5_CORPORATIONS_SQL = """
select
    lastname as name,
    sum(cash_amount) as amount
from campaign_finance.fact_contributions
where filerid = '{filerid}'
    and a.contribution_date between '{start_date}' and '{end_date}'
    -- and coalesce(election_year, extract(year from contribution_date)) = 2020
    and contribution_type = 'Monetary'
    and donation_type = 'Corporate'
group by lastname
order by amount desc
limit 5;
"""

GET_TOP_5_PACS_SQL = """
select
    lastname as name,
    sum(cash_amount) as amount
from campaign_finance.fact_contributions
where filerid = '{filerid}'
    and a.contribution_date between '{start_date}' and '{end_date}'
    -- and coalesce(election_year, extract(year from contribution_date)) = 2020
    and contribution_type = 'Monetary'
    and donation_type = 'Political Action Committee (PAC)'
group by lastname
order by amount desc
limit 5;
"""
