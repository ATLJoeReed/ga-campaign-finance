set search_path to raw, stage, working, campaign_finance;
show search_path;

-- Pull basic informatoin on campaign...
select
    a.filerid,
    b.committee_name,
    trim(regexp_replace(concat(b.candidate_firstname, ' ', b.candidate_middlename, ' ', b.candidate_lastname, ' ', b.candidate_suffix), '\s+', ' ', 'g')) as candidate_name,
    sum(a.cash_amount)::numeric(38, 2) as total_contributions
from campaign_finance.fact_contributions as a
    inner join campaign_finance.dim_campaigns as b
        on a.filerid = b.filerid
where a.filerid = 'C2020000517'
    and coalesce(a.election_year, extract(year from contribution_date)) = 2020
    and contribution_type = 'Monetary'
group by a.filerid, b.committee_name, b.candidate_firstname, b.candidate_middlename, b.candidate_lastname, b.candidate_suffix;

-- Top 5 PAC Donors
select
    coalesce(lastname, firstname) as name,
    sum(cash_amount) as amount
from campaign_finance.fact_contributions
where filerid = 'C2020000517'
    and coalesce(election_year, extract(year from contribution_date)) = 2020
    and contribution_type = 'Monetary'
    and donation_type = 'Political Action Committee (PAC)'
group by coalesce(lastname, firstname)
order by amount desc
limit 5;

-- Top 5 Corporate Donors...
select
    coalesce(lastname, firstname) as name,
    sum(cash_amount) as amount
from campaign_finance.fact_contributions
where filerid = 'C2020000305'
    and coalesce(election_year, extract(year from contribution_date)) = 2020
    and contribution_type = 'Monetary'
    and donation_type = 'Corporate'
group by coalesce(lastname, firstname)
order by amount desc
limit 5;

select *
from dim_campaigns
where filerid = 'C2020000305'

select *
from fact_contributions
where filerid = 'C2020000305'
    and donation_type = 'Corporate'

select *
from fact_contributions
where donation_type = 'Corporate'
    and lastname is null;

select *
from fact_contributions
where donation_type = 'Political Action Committee (PAC)'
    and lastname is null;



-- Breakout By Type...
with count_all_donations as
(
    select
        count(*) as total_number_donations,
        sum(cash_amount) as total_donations
    from campaign_finance.fact_contributions
    where filerid = 'C2020000517'
        and coalesce(election_year, extract(year from contribution_date)) = 2020
        and contribution_type = 'Monetary'
)
select
    a.donation_type,
    b.total_number_donations,
    b.total_donations,
    count(*) as number_donations,
    sum(a.cash_amount)::numeric(38,2) as total_donations,
    (count(*)::float / b.total_number_donations * 100)::numeric(10, 3) as percent
from campaign_finance.fact_contributions as a
cross join count_all_donations as b
where a.filerid = 'C2020000517'
    and coalesce(a.election_year, extract(year from a.contribution_date)) = 2020
    and a.contribution_type = 'Monetary'
group by a.donation_type, b.total_number_donations, b.total_donations
order by a.donation_type;






with count_all_donations as
(
    select count(*) as total_number_donations
    from campaign_finance.fact_contributions
    where filerid = 'C2020000196'
        and coalesce(election_year, extract(year from contribution_date)) = 2020
        and contribution_type = 'Monetary'
)
select
    a.donation_type,
    count(*) as number_donations,
    sum(a.cash_amount)::numeric(38,2) as total_donations,
    (count(*)::float / b.total_number_donations * 100)::numeric(10, 3) as percent
from campaign_finance.fact_contributions as a
cross join count_all_donations as b
where a.filerid = 'C2020000196'
    and coalesce(a.election_year, extract(year from a.contribution_date)) = 2020
    and a.contribution_type = 'Monetary'
group by a.donation_type, b.total_number_donations
order by a.donation_type;



select
    filerid,
    committee_name,
    candidate_firstname,
    candidate_middlename,
    candidate_lastname,
    candidate_suffix
from campaign_finance.dim_campaigns
where left(filerid, 1) = 'C'
order by candidate_lastname, candidate_firstname;


select
    filerid,
    committee_name
from campaign_finance.dim_campaigns
where left(filerid, 2) = 'NC'
order by committee_name;



