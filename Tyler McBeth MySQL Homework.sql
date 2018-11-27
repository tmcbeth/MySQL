USE sakila;

-- 1a. Display the first and last names of all actors from the table actor

SELECT first_name from actor;

SELECT last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name 

ALTER TABLE actor
ADD actor_name varchar (255) after last_update;
UPDATE actor SET actor_name = CONCAT(first_name,' ', last_name);

SELECT * FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

CREATE VIEW joe AS
SELECT actor_id, first_name, last_name from actor
WHERE first_name = "Joe";

SELECT * FROM joe;

-- 2b. Find all actors whose last name contain the letters GEN :

CREATE VIEW gen AS
SELECT actor_id, first_name, last_name from actor
WHERE last_name like "%gen%";

SELECT * FROM gen;

-- 2c. Find all actors whose last names contain the letters LI . This time, order the rows by last name and first name, in that order:

CREATE VIEW li AS
SELECT actor_id, last_name, first_name from actor
WHERE last_name LIKE "%li%";

SELECT * FROM li;

-- 2d. Using IN , display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country FROM country
WHERE country 
IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

ALTER TABLE actor
ADD description BLOB(255) AFTER last_name;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(*) AS "Count of Last Name"
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, COUNT(*) AS "Count_of_Last_Name"
FROM actor
GROUP BY last_name
HAVING Count_of_Last_Name >=2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS . Write a query to fix the record.

UPDATE actor SET first_name = 'HARPO' WHERE last_name = 'Williams' AND first_name = 'Groucho';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO . It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO , change it to GROUCHO .

UPDATE actor SET first_name = 'GROUCHO' WHERE last_name = 'Williams' AND first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address :

SELECT staff.first_name, staff.last_name, address.address 
FROM staff JOIN address ON (staff.address_id = address.address_id);

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment .

CREATE TABLE total_amount_staff AS
SELECT staff.first_name, staff.last_name, payment.amount, payment.payment_date
FROM staff JOIN payment ON (staff.staff_id = payment.staff_id);

SELECT first_name, last_name, SUM(amount) as "Total Amount"
FROM total_amount_staff WHERE payment_date LIKE "2005-08%"
GROUP BY first_name, last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film . Use inner join.

CREATE TABLE num_actors_film AS
SELECT film.title, film_actor.actor_id 
FROM film JOIN film_actor ON (film.film_id = film_actor.film_id);

SELECT title, count(title) AS "Number of Actors"
FROM num_actors_film
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
-- Join film name and inventory

CREATE TABLE film_inventory AS
SELECT film.title, inventory.film_id 
FROM film JOIN inventory ON (film.film_id = inventory.film_id);

SELECT title, COUNT(film_id) AS "Number of Copies"
FROM film_inventory
GROUP BY title
HAVING title= "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

CREATE TABLE customer_payment AS
SELECT customer.first_name, customer.last_name, payment.amount
FROM customer JOIN payment ON (customer.customer_id = payment.customer_id);

SELECT * FROM customer_payment;

SELECT first_name, last_name, SUM(amount) AS "Total Amount Paid"
FROM customer_payment
GROUP BY first_name, last_name
ORDER BY last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
	
SELECT title FROM film
WHERE 
title LIKE "K%" or title LIKE "Q%"
AND
language_id IN
	(SELECT language_id FROM language
    WHERE name = "English");
    
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip

SELECT actor_name FROM actor
WHERE actor_id IN
	(SELECT actor_id FROM film_actor
    WHERE film_id IN
		(SELECT film_id FROM film
        WHERE title = "ALONE TRIP"));
        
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information

SELECT customer.first_name, customer.last_name, customer.email, address.address, address.district, city.city, country.country
FROM customer, address, city, country
WHERE customer.address_id=address.address_id AND address.city_id = city.city_id AND city.country_id = country.country_id AND country.country="Canada";

-- 7d.  Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT film.title 
FROM film, film_category, category
WHERE film.film_id = film_category.film_id AND film_category.category_id = category.category_id AND category.name = "Family";

-- 7e. Display the most frequently rented movies in descending order.

SELECT film.title, COUNT(rental.rental_id) AS "Number_of_Rentals"
FROM film, inventory, rental
WHERE film.film_id = inventory.film_id AND inventory.inventory_id = rental.inventory_id
GROUP BY film.title
ORDER BY Number_of_Rentals DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT store.store_id, SUM(payment.amount) as "Total Revenue"
FROM staff, payment, store
WHERE payment.staff_id = staff.staff_id AND staff.staff_id = store.store_id
GROUP BY store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT store.store_id, address.address, city.city, country.country
FROM store, address, city, country
WHERE store.address_id = address.address_id AND address.city_id = city.city_id AND city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
-- 8a Create view

CREATE VIEW top_five_genres AS
SELECT category.name, SUM(payment.amount)
FROM category, film_category, inventory, rental, payment
WHERE category.category_id = film_category.category_id AND film_category.film_id=inventory.film_id AND inventory.inventory_id = rental.inventory_id AND rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY SUM(payment.amount) DESC
LIMIT 5 ;

-- 8b Show view

SELECT * FROM top_five_genres;

-- 8c

DROP VIEW top_five_genres;