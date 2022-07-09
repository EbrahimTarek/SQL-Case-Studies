##1.create Tables
create table Sales (cutomer_id int,order_date Date,product_id int )
select * from Sales
alter table Sales
alter column cutomer_id varchar(1)
insert into Sales
values
('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
select * from Sales
create table menu ( product_id int , product_name varchar(5),price int )
select * from menu
insert into menu 
values
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
select *from menu
CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
select * from Sales
select * from menu
select * from members
--2.start data cleaning
create view total_table
as 
select cutomer_id , order_date , S.product_id , M.product_name , M.price , E.join_date
from Sales S 
join menu M
on S.product_id = M.product_id
left join members E
on S.cutomer_id = E.customer_id

--3.What is the total amount each customer spent at the restaurant?
select cutomer_id , SUM(price) as totalamount
from total_table
group by cutomer_id

--4.How many days has each customer visited the restaurant?
select cutomer_id , COUNT(distinct order_date) as no_of_visits
from total_table
group by cutomer_id

--5.What was the first item from the menu purchased by each customer?
with cte as 
(
select cutomer_id , product_name , ROW_NUMBER() over ( partition by cutomer_id order by order_date) as row_num
from total_table
)
select cutomer_id , product_name
from cte
where row_num = 1

--6.What is the most purchased item on the menu and how many times was it purchased by all customers?
select top 1 product_name , COUNT(product_id) as number_of_purchases
from total_table
group by product_name
order by 2 desc

--7.Which item was the most popular for each customer?
with cte 
as
(
select cutomer_id,product_name, COUNT(product_id) as totalproduct , dense_rank() over (order by COUNT(product_id) desc ) as ranknumber 
from total_table
group by cutomer_id,product_name
)
select *
from cte 
where rownumber = 1

--8.Which item was purchased first by the customer after they became a member?
with cte as (
select cutomer_id , product_name ,order_date, join_date , ROW_NUMBER() over (partition by cutomer_id order by order_date) rownumber
from total_table
where join_date < order_date
)
select cutomer_id , product_name , order_date , join_date
from cte
where rownumber = 1

--9.Which item was purchased just before the customer became a member?
select * from total_table
with cte as 
(
select cutomer_id , product_name ,order_date, join_date , ROW_NUMBER() over (partition by cutomer_id order by order_date desc) rownumber
from total_table
where join_date > order_date
)
select cutomer_id , product_name , order_date , join_date
from cte
where rownumber = 1

--10.What is the total items and amount spent for each member before they became a member?
select * from total_table
select cutomer_id , COUNT(product_id) totalitems , SUM(price) totalamount
from total_table
where order_date < join_date
group by cutomer_id

--11.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select cutomer_id,
sum (case when product_name = 'sushi' 
	 then price*20
	 else price * 10 
	end ) as totalprice 
from total_table
group by cutomer_id

--12.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
--not just sushi - how many points do customer A and B have at the end of January?
with lll
as 
(
select *,DATEADD(DAY,6,join_date) as valid_date , EOMONTH(join_date) as the_end_date
from total_table
)
select cutomer_id , 
sum (case when product_name = 'sushi' then price*20
	 when order_date between join_date and valid_date then price*20
	 else price*10
end ) as totalprice
from lll
where order_date <= the_end_date
group by cutomer_id

--Bonus questions
with cte as (
select * ,
case when order_date >= join_date then 'Y'
	 else 'N'
end as member
from total_table
)
select * ,
case when member = 'N' then null
	 else dense_rank() over (partition by cutomer_id , member order by order_date )
end as ranking 
from cte







