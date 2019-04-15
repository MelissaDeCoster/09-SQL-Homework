USE sakila;

#1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor;
#----------------------------------------------------------------------------

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UPPER(CONCAT(first_name," ",last_name)) as "Actor Name"
FROM actor;
#------------------------------------------------------------------------------------

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, 
#"Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";
#--------------------------------------------------------------------------

#2b. Find all actors whose last name contain the letters GEN:
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%';
#----------------------------------------------------------------------------

#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, 
#in that order:
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;
#-----------------------------------------------------------------------------

#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');
#---------------------------------------------------------------------------------

#3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
#so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, 
#as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD COLUMN actor_desc BLOB;
#-------------------------------------------------------------------------

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN actor_desc;
#-------------------------------------------------------------------------

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name) as 'LastName Count'
FROM actor
GROUP BY last_name;
#---------------------------------------------------------------------------

#4b. List last names of actors and the number of actors who have that last name, 
but only for names that are shared by at least two actors
SELECT last_name, count(last_name) as 'LastNameCount'
FROM actor
GROUP BY last_name
HAVING LastNameCount >=2;
#-----------------------------------------------------------------------------

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
SELECT *
FROM actor
WHERE last_name = "WILLIAMS" AND first_name = "GROUCHO";

UPDATE actor
SET first_name = "HARPO" 
WHERE last_name = "WILLIAMS" AND first_name = "GROUCHO";
#------------------------------------------------------------------------------------------

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
#In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = "GROUCHO" 
WHERE first_name = "HARPO";
#--------------------------------------------------------------------------------------------

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
#Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address;
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;
#--------------------------------------------------------------------------------------------------

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
#Use the tables staff and address:
SELECT 
staff.first_name as "EE First Name" , 
staff.last_name as "EE Last Name" ,
address.address,
address.address2,
address.postal_code
FROM staff
LEFT JOIN address ON staff.address_id = address.address_id;
#-----------------------------------------------------------------------

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
	SELECT 
	staff.first_name as "EE First Name" , 
	staff.last_name as "EE Last Name" , 
	sum(payment.amount) as "Total Amount"
	FROM Payment
	LEFT JOIN staff ON staff.staff_id = payment.staff_id
	WHERE payment_date BETWEEN '2005-08-01' AND '2005-08-30'
    GROUP BY payment.staff_id;
#-----------------------------------------------------------------------------

#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT 
film.title as 'Film',
count(film_actor.actor_id) as 'Actor Count'
FROM film
INNER JOIN film_actor ON
	film.film_id = film_actor.film_id
GROUP BY film.title;
#-------------------------------------------------------------------------

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT count(film_id)
FROM inventory
WHERE film_id = (
	SELECT film_id
	FROM film
	WHERE title = 'Hunchback Impossible');
#----------------------------------------------------------------------------------------------

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
#List the customers alphabetically by last name:
SELECT
customer.first_name, 
customer.last_name,
sum(payment.amount)
FROM payment
INNER JOIN customer ON
	payment.customer_id = customer.customer_id
GROUP BY customer.customer_id
ORDER BY customer.last_name;
#---------------------------------------------------------------------------

#7a The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
#films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles 
#of movies starting with the letters K and Q whose language is English.
SELECT title
  FROM film
  WHERE language_id = '1' AND title IN
     (
      SELECT title
      FROM film
      WHERE title LIKE 'K%' OR title LIKE 'Q%'
        );
#---------------------------------------------------------------------------------

#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_id IN (
	SELECT actor_id
	FROM film_actor
	WHERE film_id = (
		SELECT film_id
		FROM film
		WHERE title = 'Alone Trip'));
#--------------------------------------------------------------------------

#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses 
#of all Canadian customers. Use joins to retrieve this information.
SELECT
customer.first_name,
customer.last_name,
customer.email,
country.country
FROM customer
INNER JOIN address
        ON customer.address_id = address.address_id
INNER JOIN city
        ON address.city_id = city.city_id 
INNER JOIN country
        ON city.country_id = country.country_id
WHERE country.country = 'Canada';
#------------------------------------------------------------------------
        
#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
#Identify all movies categorized as family films.
SELECT 
film.title,
FROM film
INNER JOIN film_category ON
	film.film_id = film_category.film_id
INNER JOIN category ON
	film_category.category_id = category.category_id
WHERE category.name = 'Family';
#------------------------------------------------------------------------------------

#7e. Display the most frequently rented movies in descending order.
SELECT 
film.title,
count(rental.inventory_id) as 'RentalCount'
FROM rental
INNER JOIN inventory ON
	rental.inventory_id = inventory.inventory_id
INNER JOIN film ON
	inventory.film_id = film.film_id
GROUP BY film.title
ORDER BY RentalCount DESC;
#------------------------------------------------------------------------

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT 
staff.store_id as 'Store',
SUM(payment.amount) as 'BusinessInDollars'
FROM payment
INNER JOIN staff ON
	payment.staff_id = staff.staff_id
GROUP BY staff.store_id;
#-----------------------------------------------------------------

#7g. Write a query to display for each store its store ID, city, and country.
SELECT 
store.store_id,
city.city,
country.country
FROM store
INNER JOIN address ON
	store.address_id = address.address_id
INNER JOIN city ON
	address.city_id = city.city_id
INNER JOIN country ON
	city.country_id = country.country_id;
#---------------------------------------------------------------------------------


#7h. List the top five genres in gross revenue in descending order. 
#(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT 
category.name,
sum(payment.amount) as 'GrossRevenue'
FROM payment
INNER JOIN rental ON
	payment.rental_id = rental.rental_id
INNER JOIN inventory ON
	rental.inventory_id = inventory.inventory_id
INNER JOIN film ON
	inventory.film_id = film.film_id
INNER JOIN film_category ON
	film.film_id = film_category.film_id
INNER JOIN category ON
	film_category.category_id = category.category_id
GROUP BY category.name
ORDER BY GrossRevenue DESC
LIMIT 5;
#-----------------------------------------------------------------------

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
# Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query 
#to create a view.
CREATE VIEW Top_5_Genre AS 
SELECT 
category.name,
sum(payment.amount) as 'GrossRevenue'
FROM payment
INNER JOIN rental ON
	payment.rental_id = rental.rental_id
INNER JOIN inventory ON
	rental.inventory_id = inventory.inventory_id
INNER JOIN film ON
	inventory.film_id = film.film_id
INNER JOIN film_category ON
	film.film_id = film_category.film_id
INNER JOIN category ON
	film_category.category_id = category.category_id
GROUP BY category.name
ORDER BY GrossRevenue DESC
LIMIT 5;
#---------------------------------------------------------------------

#8b. How would you display the view that you created in 8a?
SELECT * from top_5_genre;
#----------------------------------------------------------------------------

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_5_genre;
#--------------------------------------------------------------------------