insert into silver.erp_cust_az12(
cid, 
bdate, 
gen
)


select 
case when cid like 'NASAW000%' then substring(cid, len(cid)-4, len(cid))
	 when cid like 'AW000%' then substring(cid, len(cid)-4, len(cid))
	 else cid
end cid,
case when bdate > getdate() then null
else bdate
end as bdate,
case when upper(trim(gen)) in ('F', 'Female') then 'Female'
	 when upper(trim(gen)) in ('M', 'Male') then 'Male'
	 else 'n/a'
end as gen
from bronze.erp_cust_az12

 select * from silver.erp_cust_az12