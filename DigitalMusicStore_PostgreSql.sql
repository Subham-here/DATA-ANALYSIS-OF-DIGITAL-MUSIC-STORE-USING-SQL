--THE COUNTRIES WHICH HAVE THE MOST NUMBER OF INVOICES

SELECT billing_country,COUNT(billing_country) AS Invoice_Number
FROM invoice
GROUP BY billing_country
ORDER BY Invoice_Number DESC;


/* TO CHECK WHICH COUNTRY HAS THE BEST CUSTOMER SO THAT THE COMPANY COULD THROW
A PROMOTION MUSIC FESTIVAL IN THE CITY IN WHICH THEY MADE THE MOST REVENUE*/

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;

--The customer who has spent the most money will be declared the best customer

SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY (customer.customer_id)
ORDER BY total_spending DESC
LIMIT 1;


/*FINDING OUT THE ROCK MUSIC LISTENERS TO TARGET THEM WITH PERSONALIZED PROMOTIONS.*/

SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;


SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;


/*Now that we know that our customers love rock music, we can decide which musicians to invite to play at the concert.
Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands.*/

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;



/*finding out which artist has earned the most according to the InvoiceLines
and to find out which customer spent the most on this artist..*/

WITH tbl_best_selling_artist 
AS(
	SELECT artist.artist_id AS artist_id,
	artist.name AS artist_name,
	SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1,2
	ORDER BY 3 DESC
	LIMIT 1
   )
SELECT * FROM tbl_best_selling_artist;


SELECT bsa.artist_name,SUM(il.unit_price*il.quantity) AS amount_spent,c.customer_id,c.first_name,c.last_name
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN tbl_best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,3,4,5
ORDER BY 2 DESC;

/*Finding out all the track names that have a song length longer than the average song length. 
The query will be updated based on when new data is put in the database. 
*/

SELECT name,milliseconds
FROM track
WHERE milliseconds > 
(
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track)
ORDER BY milliseconds DESC;


