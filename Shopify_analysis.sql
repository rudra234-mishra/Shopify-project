select*from Orders
-----Total Amount
select sum(Amount) as total_amount
from Products
---KPI REQUIREMENTS-----
-----Total Quantity sold
select sum(quantity) as total_quantity
from Products
----Total Profit
select sum(profit) as Total_profit
from Products
----Average Order value
select sum(Amount)/count(distinct Order_ID)
from Products
----Profit/Loss by month
select datename(month,Order_Date) as Month,sum(profit) as Profit_loss
from Orders as o
join Products as p
on o.Order_ID=p.Order_ID
group by datename(month,Order_Date)
order by Profit_loss
----Top 3 products category
with cte as(
select Category,Sub_Category,sum(profit) as total_profit,
ROW_NUMBER()over(partition by category order by sum(profit)desc) as df
from Orders as o
join Products as p
on o.Order_ID=p.Order_ID
group by Category,Sub_Category)
select Category,Sub_Category,total_profit
from cte 
where df<=3
-----Each Month best products
select month,category,sub_category,total_profit
from(
select DATENAME(month,Order_Date)as month,Category,Sub_Category,sum(profit) as total_profit,
ROW_NUMBER()over(partition by datename(month,order_date) order by sum(profit) desc) as df
from Orders as o
join Products as p
on o.Order_ID=p.Order_ID
group by DATENAME(month,Order_Date),Category,Sub_Category
)rudra where df=1
----Each month a single product based on each Category that sold most
with cte as(
select datename(month,order_date) as month,Category,Sub_Category,count(o.order_id) as total_quantity,
ROW_NUMBER()over(partition by datename(month,order_date),category order by count(o.order_id) desc) as df
from Orders as o
join Products as p
on o.Order_ID=p.Order_ID
group by datename(month,order_date) ,Category,Sub_Category
)
select month,category,sub_category,total_quantity
from cte 
where df=1
-----Quantity by category
select Category,round(sum(quantity)*100/(select sum(quantity) from orders as o1 join Products as p1 
on o1.Order_ID=p1.Order_ID),2) as pct
from Orders as o
join Products as p
on o.Order_ID=p.Order_ID
group by Category
order by pct desc
----Payment mode percentage
select PaymentMode,round(count(o.order_id)*100/(select count(o1.order_id) from Orders as o1 join Products as p1
on o1.Order_ID=p1.Order_ID),2) as pct
from Orders as o
join Products as p
on o.Order_ID=p.Order_ID
group by PaymentMode
order by pct desc
----Top 5 state and their corresponding city by amount
with cte as(
select state,City,sum(amount) as total,
ROW_NUMBER()over(partition by state order by sum(amount) desc) as df
from Orders as o
join Products as p
on o.Order_ID =p.Order_ID
group by State,city
)
select top 5 state,city,total
from cte 
where df=1
order by total desc
----Top 5 customers
select top 5 o.CustomerName,sum(quantity) as total
from Orders as o
join Products as p
on o.Order_ID=p.Order_ID
group by o.CustomerName
order by total desc
----
