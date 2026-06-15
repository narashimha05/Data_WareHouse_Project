select * from bronze.crm_cust_info;

-- check for nulls or duplicates in primary key

select cst_id, count(*) from bronze.crm_cust_info
group by cst_id
having count(*)>1 or cst_id is NULL


select * from bronze.crm_cust_info
where cst_id = 29466;

-- What we Found: it had creation dates and we have to keep the lastest creation date. we need to use Window function to rank it.

select * from (
select *,
row_number() over (partition by cst_id order by cst_create_date DESC) as flag_last
from bronze.crm_cust_info
)t where flag_last = 1

-- check for unwanted spaces
select cst_lastname from bronze.crm_cust_info 
where cst_lastname!=trim(cst_lastname)


select 
cst_id, 
cst_key, 
TRIM(cst_firstname) as cst_firstname,
TRIM(cst_lastname) as cst_lastname,
case when UPPER(TRIM(cst_martial_status)) = 'S' then 'Single'
	 when UPPER(TRIM(cst_martial_status)) = 'M' then 'Married'
	 else 'n/a'
end as cst_martial_status,
case when UPPER(TRIM(cst_gndr)) = 'F' then 'Female'
	 when UPPER(TRIM(cst_gndr)) = 'M' then 'Male'
	 else 'n/a'
end as cst_gndr,
cst_create_date
from (
select *,
row_number() over (partition by cst_id order by cst_create_date DESC) as flag_last
from bronze.crm_cust_info
)t where flag_last = 1


-- check for martial status and gender cardinality
select distinct(cst_martial_status) from bronze.crm_cust_info


-- final
insert into silver.crm_cust_info(
cst_id,
cst_key, 
cst_firstname,
cst_lastname,
cst_martial_status,
cst_gndr,
cst_create_date
)

select 
cst_id, 
cst_key, 
TRIM(cst_firstname) as cst_firstname,
TRIM(cst_lastname) as cst_lastname,
case when UPPER(TRIM(cst_martial_status)) = 'S' then 'Single'
	 when UPPER(TRIM(cst_martial_status)) = 'M' then 'Married'
	 else 'n/a'
end as cst_martial_status,
case when UPPER(TRIM(cst_gndr)) = 'F' then 'Female'
	 when UPPER(TRIM(cst_gndr)) = 'M' then 'Male'
	 else 'n/a'
end as cst_gndr,
cst_create_date
from (
select *,
row_number() over (partition by cst_id order by cst_create_date DESC) as flag_last
from bronze.crm_cust_info
)t where flag_last = 1

-- checking

select * from silver.crm_cust_info

