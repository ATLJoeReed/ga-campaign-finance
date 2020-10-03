set search_path to raw, stage, working, campaign_finance;

show search_path;

with branch_candidates as
(
    select election, name, branch_id || '.json' as file_name, filerid
    from stage.candidates_general_2020_with_filerid
    where filerid is not null
),
candidate_summary as
(
    select
        filerid,
        count(*) as number_donations,
        sum(cash_amount)::numeric(38,2) as total_donations
    from campaign_finance.fact_contributions
    where contribution_date between '2019-06-30' and '2020-10-03'
        and contribution_type = 'Monetary'
    group by filerid
)
select a.*, b.number_donations, b.total_donations
from branch_candidates as a
    left join candidate_summary as b
        on a.filerid = b.filerid
order by b.total_donations desc;


select distinct filerid
from campaign_finance.fact_contributions
where filerid in (
    'C2020000223',
    'C2020000366',
    'C2010000369',
    'C2019000306',
    'C2020000219',
    'C2012002045',
    'C2016000124',
    'C2020000203',
    'C2020000083'
)

select *
from campaign_finance.fact_contributions
where filerid in (
    'C2020000219',
    'C2020000366',
    'C2020000223'
)
order by contribution_date desc;

select *
from campaign_finance.dim_campaigns
where filerid in (
    'C2020000219',
    'C2020000366',
    'C2020000223'
)


select *
from campaign_finance.dim_campaigns
where filerid in (
    'C2020000223',
    'C2020000366',
    'C2010000369',
    'C2019000306',
    'C2020000219',
    'C2012002045',
    'C2016000124',
    'C2020000203',
    'C2020000083'
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
    and a.contribution_type = 'Monetary'
group by a.donation_type, b.total_number_donations
order by a.donation_type;
