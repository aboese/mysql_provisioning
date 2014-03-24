insert into mysql.user select * from provisioning.user_delta pnu where NOT EXISTS (select 1 from mysql.user t where t.user=pnu.user and t.host=pnu.host) and pnu.user NOT IN ('DBAS_GO_HERE');
