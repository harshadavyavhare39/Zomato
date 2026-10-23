create database zomatadb;
use zomatadb;

create table users(
user_id INT PRIMARY KEY,
name VARCHAR(50),
email VARCHAR(50),
password VARCHAR(10));

SELECT * FROM users;
select * from restaurants;
select * from orders;
select * from order_details;
select * from menu;
select * from food;
select * from delivery_partner;

## List of questions for the Zomato SQL dataset :
-- ================================================================================================================
-- 1.  Counts of rows
 select count(*) from delivery_partner;
 select count(*) from food;
 select count(*) from menu;
 select count(*) from order_details;
 select count(*) from orders;
 select count(*) from restaurants;
 select count(*) from users;
 -- ===============================================================================================================
 -- 2. Finding the null values
 select count(*) from delivery_partner
 where partner_id is null or partner_name is null;
 
 select count(*) from delivery_partner
 where partner_id is null or partner_name is null;

select count(*) from food
 where f_id is null or f_name is null or type is null;
 
select count(*) from menu
 where menu_id is null or 
 r_id is null or 
 f_id is null or 
 price is null;
          
select count(*) from order_details
 where id is null or order_id is null or f_id is null;

select count(*) from orders
 where order_id is null or
 user_id is null or
 r_id is null or
 amount is null or
 date is null or
 date is null or
 partner_id is null or
 delivery_time is null or
 delivery_rating is null or
 restaurant_rating is null ;
 
 select count(*) from restaurants
 where r_id is null 
 or r_name is null 
 or cuisine is null;
 
 select count(*) from users
 where user_id is null
 or name is null 
 or email is null or password;
 
 -- ====================================================================================================================
 -- 3.  Find numbers of orders placed by each customers
 select u.name, u.user_id, count(order_id) as no_of_orders from orders o
 join users u
 on u.user_id = o.user_id
 group by u.user_id,u.name;
 
 -- ======================================================================================================================
 -- 4. Find restaurant with most number of menu items
 select restaurants.r_name,count(r_id) as total_item from restaurants
 join menu
 on menu.r_id = restaurants.r_id;
 
 -- =========================================================================================================================
 -- 5. Find number of votes and average rating for all the restaurants
 select * from orders;
 select restaurants.r_name,count(orders.restaurant_rating) as number_of_votes, round(avg(orders.restaurant_rating), 2) as average_rating 
 from orders
 inner join restaurants
 on orders.r_id = restaurants.r_id
 group by restaurants.r_name;
 
-- ===========================================================================================================================
 -- 6.Find the food that is been sold at most number of restaurants
 select m.f_id, f_name, count(distinct m.r_id) as restaurants_counts
 from food f
 inner join menu m 
 on f.f_id = m.f_id
 group by m.f_id, f.f_name
 order by restaurants_counts desc
 limit 2;
 
 -- ===============================================================================================================================
 
-- 7.Find restaurant with maximum revenue iN May month
select restaurants.r_name, max(orders.amount) as max_revenue from orders
join restaurants
on restaurants.r_id = orders.r_id
where month(orders.date) = 5
group by restaurants.r_name, restaurants.r_id
order by max_revenue desc
limit 1;

-- ================================================================================================================================
 -- 8. Find restaurants with sales greater then 1500
 select r.r_name restaurants_name, sum(o.amount) as total_sales from restaurants r
 inner join orders o
 on r.r_id = o.r_id
 group by r.r_id, r.r_name
 having sum(o.amount) > 1500
 order by total_sales desc;
 
 -- =================================================================================================================================
 -- 9.  Find customers who have never ordered
 select u.name from users u
 where u.user_id not in (Select user_id from orders);
 
  -- =================================================================================================================================
  
 -- 10 Show order detail of a perticular customer in a given date range
select * from orders 
where user_id = 3 
and orders.date BETWEEN '2022-05-10' and '2022-07-31';

 -- =================================================================================================================================
 
-- 11. Customer favorite food 
select users.name,food.f_name, count(*) as order_count from users
inner join order_details
on users.user_id = order_details.id
inner join food
on order_details.f_id = food.f_id
group by users.name, food.f_name
order by order_count desc;

-- OR

WITH food_count AS (
 SELECT 
  u.user_id,
  u.name,
  f.f_name,
  COUNT(*) AS order_count,
  ROW_number() OVER (
  PARTITION BY u.user_id
  ORDER BY COUNT(*) DESC
  
  ) AS rn
  from users u 
  JOIN orders o 
     ON u.user_id = o.user_id
  JOIN Order_details od
    ON o.order_id = od.order_id
  JOIN food f
    ON od.f_id = f.f_id
GROUP BY u.user_id, u.name, f.f_name
)

select name,f_name, order_count
from food_count
where rn = 1;

 -- =================================================================================================================================
 
-- 12.Find the most costly restaurants
select r.r_name,sum(o.amount) as total_amount
from orders o
inner join restaurants r
on o.r_id = r.r_id
group by r.r_id, r.r_name
order by total_amount desc
limit 1;

 -- =================================================================================================================================

-- 13.Finding Delivery partners compunsation 
select dp.partner_id, dp.partner_name, sum(o.amount) as compunsation
from delivery_partner dp
inner join orders o 
on dp.partner_id = o.partner_id
group by dp.partner_id, dp.partner_name;

 -- =================================================================================================================================

-- 14 Find coorelation between delivery_time and total_rating
select 
( count(*) * sum(delivery_time * delivery_rating)
- sum(delivery_time) * sum(delivery_rating)
)
/
sqrt(
    (
    count(*) * sum(delivery_time * delivery_time)
    - pow(sum(delivery_time), 2)
   )
   *
   (
      count(*) * sum(delivery_rating * delivery_rating)
      - pow(sum(delivery_rating), 2)
	)
) as correlation
from orders;

 -- =================================================================================================================================
 
-- 15 Find all the veg restaurants
select r_name 
from restaurants
where r_id in (
   select m.r_id
   from menu m
   inner join food f
   on m.f_id = f.f_id
   where f.type = 'Veg');
   
    -- =================================================================================================================================

-- 16. Find Minimum and Maximum value for all customers
select u.user_id,u.name,min(o.amount) as mininum_amount, max(o.amount) as maximum_amount
from users u
inner join orders o
on u.user_id = o.user_id
group by u.user_id, u.name;