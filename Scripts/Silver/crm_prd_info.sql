select * from bronze.crm_prd_info

-- check primary key
select prd_id, count(*) from bronze.crm_prd_info 
group by prd_id
having count(*) >1

-- extracting category ID

select prd_id, 
prd_key, 
replace(substring(prd_key, 1,5), '-', '_') as cat_id,
substring(prd_key, 7, len(prd_key)) as prd_key,
prd_nm, 
prd_cost, 
prd_line, 
cast(prd_start_dt as date) as prd_start_dt,
cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt
from bronze.crm_prd_info

-- spacing check in prd_nm

select prd_nm from bronze.crm_prd_info where prd_nm != trim(prd_nm)

-- check for nulls or negative numbers

select prd_cost from bronze.crm_prd_info where prd_cost<0 or prd_cost is null

select prd_id, 
prd_key, 
replace(substring(prd_key, 1,5), '-', '_') as cat_id,
substring(prd_key, 7, len(prd_key)) as prd_key,
prd_nm, 
isnull(prd_cost,0) as prd_cost, 
case
	when upper(trim(prd_line)) = 'M' then 'Mountain'
	when upper(trim(prd_line)) = 'R' then 'Road'
	when upper(trim(prd_line)) = 'S' then 'Other Sales'
	when upper(trim(prd_line)) = 'T' then 'Touring'
	else 'n/a'
	end as prd_line,
prd_start_dt,
prd_end_dt 
from bronze.crm_prd_info

-- data standardization & consistency

select distinct prd_line from bronze.crm_prd_info



-- transitioning to silver 

insert into silver.crm_prd_info (
prd_id,
cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
)

select prd_id, 
replace(substring(prd_key, 1,5), '-', '_') as cat_id,
substring(prd_key, 7, len(prd_key)) as prd_key,
prd_nm, 
isnull(prd_cost,0) as prd_cost, 
case
	when upper(trim(prd_line)) = 'M' then 'Mountain'
	when upper(trim(prd_line)) = 'R' then 'Road'
	when upper(trim(prd_line)) = 'S' then 'Other Sales'
	when upper(trim(prd_line)) = 'T' then 'Touring'
	else 'n/a'
	end as prd_line,
cast(prd_start_dt as date) as prd_start_dt,
cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt
from bronze.crm_prd_info


-- checking
select * from silver.crm_prd_info 
where prd_end_dt < prd_start_dt