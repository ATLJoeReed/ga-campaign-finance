set search_path to raw, stage, working, campaign_finance;

show search_path;

select *
from working.pacs;

-- Per Walter via email 2020.10.02
insert into working.pacs (keep, pac_name, validated)
values (True, 'Fair Fight', True);

select *
from working.pacs;
