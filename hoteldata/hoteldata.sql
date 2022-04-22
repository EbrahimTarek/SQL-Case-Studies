-- to rename the database
	sp_renamedb 'master','newdatabase'
-- or
	alter database master
	modify name = newdatabase

--select data from two tables and insert it into one table
	select * into newtable
	from
		(select * from h2018
		union
		select * from h2019
		union
		select * from h2020
		) a
select * from newtable

-- make arrival date only one date
	alter table newtable
	add arrival_date date
	update newtable
	set arrival_date = datefromparts(arrival_date_year,month(arrival_date_month +'1,1'),arrival_date_day_of_month)
	select * from newtable
	alter table newtable
	drop column arrival_date_day_of_month,arrival_date_year,arrival_date_month,arrival_date_week_number
	select distinct lead_time from newtable

-- to calculate revenue group by(hotel,arrival_date)
	alter table newtable
	add revenue int
	update newtable
	set revenue = (stays_in_week_nights + stays_in_weekend_nights)*adr
	select  hotel,arrival_date,cast(sum((stays_in_week_nights + stays_in_weekend_nights)*adr) as int) revenue from newtable
	group by hotel,arrival_date
	order by revenue 
	select * from newtable
	alter table newtable
	drop column stays_in_weekend_nights,stays_in_week_nights

-- to convert datetime to date
	alter table newtable
	add reservation_date date
	update newtable
	set reservation_date = CAST(reservation_status_date as date)
	alter table newtable
	drop column reservation_status_date

-- to aggregate adults & children & babies
	alter table newtable
	add persons int
	update newtable
	set persons = adults + children + babies
	alter table newtable
	drop column adults , children , babies 

-- delete unnecessary columns
	ALTER TABLE NEWTABLE
	DROP COLUMN COMPANY
	SELECt * from newtable

-- replace null values in agent with (0)
	set agent = isnull(agent,0) from newtable
	select * from newtable

-- join hotels & marketsegment & mealcost
		select h.hotel,h.market_segment,h.persons,h.arrival_date,h.reservation_date,h.market_segment,m.Discount,h.revenue,h.meal
		,k.Cost,h.agent
		from newtable  h
		left join marketsegment m
		on h.market_segment = m.market_segment
		left join mealcost k
		on k.meal = h.meal
		

