USE Sakila;  

-- 1a. Display the first and last names of all actors from the table actor. 
SELECT first_name, last_name
FROM actor
;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name. 
SELECT concat(first_name, '_', last_name) as 'Actor Name'
FROM actor
;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe"
;

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE "%GEN%"
;

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name
FROM actor
WHERE last_name LIKE "%LI%"
;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM COUNTRY
WHERE country IN ('Afghanistan', 'Bangladesh', 'China')
;

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. 
-- Hint: you will need to specify the data type.
ALTER TABLE actor
ADD middle_name VARCHAR(45) AFTER first_name
;

-- 3b. You realize that some of these actors have tremendously long last names. 
-- Change the data type of the middle_name column to blobs.
ALTER TABLE actor
MODIFY COLUMN middle_name BLOB
;

-- 3c. Now delete the middle_name column.
ALTER TABLE actor
DROP COLUMN middle_name
;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) as count
FROM actor
GROUP BY last_name
;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) as count
FROM actor
GROUP BY last_name
HAVING COUNT >= 2
;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, 
-- the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" and last_name = "WILLIAMS"
;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
-- Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! 
-- (Hint: update the record using a unique identifier.)
UPDATE actor
SET first_name =
(CASE
    WHEN first_name = "HARPO" THEN "GROUCHO"
    ELSE "MUCHO GROUCHO"
END)
WHERE actor_id = 172
;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?  
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:
SELECT first_name, last_name, address
FROM staff as s
JOIN address as a
ON s.address_id = a.address_id
;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT first_name, last_name, SUM(amount) as 'total amount'
from payment as p
JOIN staff as s
ON s.staff_id = p.staff_id
WHERE payment_date between '2005-08-01 12:00:00 AM' and '2005-08-31 11:59:59 PM'
GROUP BY s.staff_id
;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title, COUNT(actor_id) as 'number of actors'
FROM film as f
INNER JOIN film_actor as fa
ON f.film_id = fa.film_id
GROUP BY title
;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select title, COUNT(inventory_id) as 'number of copies'
from film as f
JOIN inventory as i
ON f.film_id = i.film_id
where title = 'Hunchback Impossible'
;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT first_name, last_name, SUM(amount) as 'total payment'
FROM payment as p
JOIN customer as c
ON p.customer_id = c.customer_id
GROUP BY p.customer_id
ORDER BY last_name ASC
;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English. 
SELECT title, name
FROM film as f, language as l
WHERE f.language_id = l.language_id
AND l.name IN ('english')
AND (f.title IN
		(SELECT f.title
         FROM film as f
         WHERE title LIKE 'K%' or title LIKE 'Q%')
	);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN(
	SELECT actor_id
	FROM film_actor
	WHERE film_id IN(
	SELECT film_id
	FROM film
	WHERE title = 'Alone Trip'
    )
);

-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT first_name, last_name, email, country
FROM customer as c
JOIN address as a
ON c.address_id = a.address_id
JOIN city as cy
ON a.city_id = cy.city_id
JOIN country as ct
ON cy.country_id = ct.country_id
WHERE country = 'canada'
;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
select title, name
FROM film as f
JOIN film_category as fc
ON f.film_id = fc.film_id
JOIN category as c
ON fc.category_id = c.category_id
WHERE name = 'family'
;

-- 7e. Display the most frequently rented movies in descending order.
SELECT title
FROM film as f
JOIN inventory as i
ON f.film_id = i.film_id
JOIN rental as r
ON i.inventory_id = r.inventory_id
GROUP BY title
ORDER BY COUNT(title) desc
;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store_id, CONCAT('$', FORMAT(SUM(amount), 2)) as amount
FROM payment as p
JOIN staff as s
ON p.staff_id = s.staff_id
GROUP BY s.store_id
;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country
FROM store as s
JOIN address as a
ON s.address_id = a.address_id
JOIN city as cy
ON a.city_id = cy.city_id
JOIN country as ct
ON cy.country_id = ct.country_id
;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT name, SUM(amount) as gross_revenue
FROM category as c
JOIN film_category as fc
ON c.category_id = fc.category_id
JOIN inventory as i
ON fc.film_id = i.film_id
JOIN rental as r
ON i.inventory_id = r.rental_id
JOIN payment as p
ON p.customer_id = r.customer_id
GROUP BY c.name
ORDER BY gross_revenue desc
LIMIT 5
;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW topfivegenresbygrossrevenue AS 
SELECT name, SUM(amount) as gross_revenue
FROM category as c
JOIN film_category as fc
ON c.category_id = fc.category_id
JOIN inventory as i
ON fc.film_id = i.film_id
JOIN rental as r
ON i.inventory_id = r.rental_id
JOIN payment as p
ON p.customer_id = r.customer_id
GROUP BY c.name
ORDER BY gross_revenue desc
LIMIT 5
;

-- How would you display the view that you created in 8a?
SELECT * FROM topfivegenresbygrossrevenue
;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW topfivegenresbygrossrevenue
;