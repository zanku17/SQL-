USE sakila;
-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name 
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT upper(concat(first_name," ",last_name)) as "Actor Name" from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
Select actor_id,first_name,last_name from actor WHERE first_name="Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
SElect * from actor where last_name like "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
Select * from actor WHere last_name like "%LI%"
Order By last_name,first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
Where country IN ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB(Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
Alter table actor 
ADD COlumn description BLOB;

Select * from actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
Alter table actor
Drop Column description;

select * from actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.
Select last_name, count(last_name) actor_count 
FROM actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
Select last_name, count(last_name) actor_count 
FROM actor
group by last_name
HAVING actor_count>=2
Order by actor_count dESC;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
Update actor
set first_name = "HARPO", last_name="WILLIAMS"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query,  if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor 
set first_name = 'GROUCHO', last_name = 'WILLIAMS' 
where first_name = 'HARPO' and last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

select * from address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, a.address, a.address2, a.district, a.city_id, a.postal_code
FROM staff s INNER JOIN address a
ON s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.staff_id, s.first_name, s.last_name, sum(amount) , p.payment_date
from staff s INNER JOIN payment p
ON s.staff_id = p.staff_id
WHERE month(payment_date)="8" AND year(payment_date)="2005"
group by s.staff_id,s.first_name, s.last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.film_id, f.title, COUNT(fa.actor_id) as actor_count
from film f Inner Join film_actor fa
ON f. film_id = fa.film_id
group by f.film_id, f.title
order by actor_count DESC;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.title, count(*) as number_of_inventory
FROM film f INNER JOIN inventory i
ON f.film_id = i.film_id
WHERE f.title="Hunchback Impossible"
GROUP BY f.title;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.  List the customers alphabetically by last name:
SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) as Total_amount
FROM customer c
INNER JOIN payment p
ON c.customer_id = p.customer_id
group by c.customer_id, c.first_name, c.last_name
ORDER BY c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

-- USING JOIN
SELECT title 
FROM film f INNER JOIN language l
ON f.language_id = l.language_id
WHERE title LIKE "K%" OR title LIKE "Q%"
AND name="English";

-- USING SUBQuey
SELECT title from film where title LIKE "K%" OR title LIKE "Q%" AND language_id = 
(select language_id from language WHERE name="English");

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT actor_id, first_name,last_name FROM actor 
WHERE actor_id in 
(
	SELECT actor_id from film_actor WHERE film_id in
    (
		SELECT film_id from film WHERE title = "Alone Trip"
	)	
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email
FROM customer c INNER JOIN address a
ON c.address_id = a.address_id
INNER JOIN city ct
ON a.city_id = ct.city_id
INNER JOIN country cont
on ct.country_id = cont.country_id	
WHERE cont.country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT f.film_id, f.title, f.release_year
FROM film f INNER JOIN film_category ft
ON f.film_id = ft.film_id
INNER JOIN category cat
ON ft.category_id = cat.category_id
WHERE cat.name = "Family";

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.film_id, f.title, COUNT(rnt.rental_id) as no_of_times_rented
FROM film f INNER JOIN inventory inv
ON f.film_id = inv.film_id
INNER JOIN rental rnt
ON inv.inventory_id = rnt.inventory_id 
GROUP BY f.film_id, f.title
ORDER BY no_of_times_rented DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
Select cst.store_id, SUM(pmt.amount) as "Total Business in $"
from customer cst INNER JOIN payment pmt
ON cst.customer_id = pmt.customer_id
GRoup By cst.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT str.store_id, c.city, cnt.country 
FROm store str INNER JOIN address addr
ON str.address_id = addr.address_id
INNER JOIN city c
ON addr.city_id = c.city_id
INNER JOIN country cnt
ON c.country_id = cnt.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT cat.name, SUM(pmt.amount) as "Gross_Revenue"
from category cat INNER JOIN film_category fcat
ON cat.category_id = fcat.category_id
INNER JOIN film f
ON fcat.film_id = f.film_id
INNER JOIN inventory inv
ON f.film_id = inv.film_id
INNER JOIN rental r
ON inv.inventory_id = r.inventory_id
INNER JOIN payment pmt
ON r.rental_id = pmt.rental_id
GROUP By cat.name
ORDER BY Gross_Revenue DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_genres 
AS
SELECT cat.name, SUM(pmt.amount) as "Gross_Revenue"
from category cat INNER JOIN film_category fcat
ON cat.category_id = fcat.category_id
INNER JOIN film f
ON fcat.film_id = f.film_id
INNER JOIN inventory inv
ON f.film_id = inv.film_id
INNER JOIN rental r
ON inv.inventory_id = r.inventory_id
INNER JOIN payment pmt
ON r.rental_id = pmt.rental_id
GROUP By cat.name
ORDER BY Gross_Revenue DESC
LIMIT 5;

SELECT * from top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;

-- Retrieve the actor_id, first name, last name for all the actors whose last name equal to "WILLIAMS" or "DAVIS"
SELECT actor_id, first_name, last_name from actor WHERE last_name IN ("WILLIAMS", "DAVIS");

-- INEquality Condition - Selecting email id whose rental date is not equal to 2005-06-14
SELECT distinct email from customer c
INNER join rental r
ON c.customer_id = r.customer_id
WHERE r.rental_date<>DATE("2005-06-14");

-- Write a query that returns the title of every film in which an actor with the first name 'JOHN' appered
SELECT title, a.first_name
FROM film f INNER JOIN film_actor fa
ON f.film_id = fa.film_id
INNER JOIN actor a
ON fa.actor_id = a.actor_id
WHERE a.first_name="JOHN";
