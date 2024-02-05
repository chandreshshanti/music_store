-- Who is the Senior most employee based on job title?

select 
e.employee_id,
e.first_name,
e.last_name,
levels
from employees e
order by levels desc
limit 1 ;

-- Which countries have the most invoices ?

select billing_country,
count(billing_country) as most_invoice
from invoice_final
group by billing_country
order by most_invoice desc;

-- What are top 3 values of total invoice

select invoice_id,
round(sum(unit_price * quantity ))as sales
from invoice_line
join invoice_final
using(invoice_id)
group by invoice_id
order by sales desc
limit 3 ;

-- Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name & sum of all invoice totals

select 
city,
sum(total) as most_sales
from customers c
join invoice_final i
using(customer_id)
group by city
order by most_sales desc
limit 1 ;

-- Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money

select customer_id,
first_name,last_name,
sum(total) as ts,
country
from customers c
join invoice_final i
using(customer_id)
group by customer_id
order by ts desc 
limit 1 ;

--  Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A

select 
first_name,
last_name,
g.name as genre,
email
from customers c
join invoice_final i
using(customer_id)
join invoice_line il
using(invoice_id)
join tracks t
using(track_id)
join genre g 
using(genre_id)
where g.name = 'Rock'
group by first_name,last_name,g.name,email
order by email;

-- Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands

select 
a.name,
g.name,
count(t.track_id) as most_tracks
from artist a
join album al
using(artist_id)
join tracks t
using(album_id)
join genre g
using(genre_id)
where g.name = 'rock'
group by a.name,g.name
order by most_tracks desc
limit 10 ;

-- Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.

select 
t.name,
t.milliseconds
from tracks t
where t.milliseconds >
(
select 
avg(t.milliseconds)
from tracks t
)
order by t.milliseconds desc;

-- Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent
with cte as (
select
sum(il.unit_price*il.quantity) as g, 
aa.artist_id,
c.first_name,
-- c.last_name,
-- sum(i.total) as t,
aa.name
-- rank() over (partition by sum(il.unit_price*il.quantity))as k
from customers c
join invoice_final i
using(customer_id)
join invoice_line il
using(invoice_id)
join tracks t
using(track_id)
join album a
using(album_id)
join artist aa
using(artist_id)
-- where aa.name='queen'
group by aa.name,aa.artist_id,c.first_name
order by g desc
-- limit 1
)
select g,
artist_id,
first_name,name
from cte
where name ='queen';

-- We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
-- with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
-- the maximum number of purchases is shared return all Genres.

with cte as 
(
select 
c.country,
round(sum(il.unit_price * il.quantity)) as sales,
g.name,
row_number() over(partition by c.country order by sum(il.unit_price * il.quantity)desc ) as ranks
from customers c
join invoice_final i
using(customer_id)
join invoice_line il
using(invoice_id)
join tracks t
using(track_id)
join genre g 
using(genre_id)
group by c.country,g.name
)
select *
from cte 
where ranks = 1 ;

-- Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount.

with cte as (
select c.first_name,
c.last_name,
c.country,
sum(unit_price * quantity) as sales,
row_number() over (partition by c.country order by sum(unit_price * quantity) desc ) as ranks
from customers c
join invoice_final i
using(customer_id)
join invoice_line il
using(invoice_id)
group by c.first_name,
c.last_name,
c.country
)
select *
from cte 
where ranks = 1 