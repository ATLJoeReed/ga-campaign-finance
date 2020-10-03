set search_path to raw, stage, working, campaign_finance;

show search_path;

select *
from working.pacs;

-- Per Walter via email 2020.10.02
insert into working.pacs (keep, pac_name, validated)
values
    (True, 'Fair Fight', True),
    (True, 'Fair Fight Inc', True),
    (True, 'Fair Fight, Inc.', True);

select *
from working.pacs
where pac_name ilike '%Fair%Fight%';

-- Too many variations for Fair Fight...change to this and added it to
-- process_data.sql
update campaign_finance.fact_contributions
    set donation_type = 'Political Action Committee (PAC)'
where lastname ilike '%Fair%Fight%';

select *
from campaign_finance.fact_contributions
where lastname ilike '%Fair%Fight%';
