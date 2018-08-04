/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

/* ANSWER: Facilities that charge members a cost are
Tennis court 1
Tennis court 2
Squash court
Massage Room 1
Massage Room 2 */

--select all columns
SELECT *
FROM  `Facilities`
--filter to only facilities with a cost to members
WHERE membercost >0


/* Q2: How many facilities do not charge a fee to members? */

--ANSWER: A total of four facilities do not charge fees for members

--count the facility names
SELECT COUNT(name)
FROM  `Facilities`
--filter to only facilities that are free for members
WHERE membercost =0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

--select relevant columns
SELECT facid, name, membercost, monthlymaintenance
FROM `Facilities`
--filter returned rows where member cost is more than 20% of maintenance cost
WHERE membercost < (monthlymaintenance * .2)

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

--select all columns
SELECT *
FROM `Facilities`
--filter to just facilities with ID 1 and 5
WHERE facid IN (1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

--select appropriate columns
SELECT name, monthlymaintenance,
--use if/then logic to categorize maintenance cost into new column
  CASE WHEN monthlymaintenance > 100 THEN 'expensive'
  ELSE 'cheap' END AS "cheap vs expensive"
FROM `Facilities`

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

--select appropriate columns from member table
SELECT firstname, surname, joindate
FROM `Members`
--filter out the guest entries as they did not sign up
WHERE firstname != 'GUEST'
--order by most recent date of sign up
ORDER BY joindate DESC

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

--select concatination of distinct member and court name pairs
SELECT DISTINCT concat(member.firstname, ' ', member.surname, ' ', facility.name) AS 'Name',
       member.memid,
       facility.facid,
       bookings.facid, bookings.memid
FROM `Bookings` AS bookings
  --use left joins on Bookings table to ensure all booking entries are preserved
  LEFT JOIN `Facilities` AS facility ON bookings.facid = facility.facid
  LEFT JOIN `Members` AS member ON bookings.memid  = member.memid
--filter to just tennis courts
WHERE bookings.facid IN (0, 1)
--order results by member name
ORDER BY 1


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

--use member ID to identify guests and calculate cost based on appropriate rate
SELECT CASE WHEN bookings.memid = 0 THEN facility.guestcost * bookings.slots
            ELSE facility.membercost * bookings.slots
            END AS total_cost,
--concatinate strings into name column
       CASE WHEN bookings.memid = 0 THEN concat(member.surname, ' ', facility.name)
            ELSE concat(member.firstname, ' ', member.surname, ' ', facility.name)
            END AS "Name"
--select from bookings table to preserve all bookings on 2012-09-14
FROM `Bookings` AS bookings
  LEFT JOIN `Facilities` AS facility ON bookings.facid = facility.facid
--filter to only 2012-09-14
  AND bookings.starttime LIKE '2012-09-14%'
  LEFT JOIN `Members` AS member ON bookings.memid  = member.memid
--filter to only 2012-09-14
  AND bookings.starttime LIKE '2012-09-14%'
--filter to only cases where total cost exceeds $30
WHERE CASE WHEN bookings.memid = 0 THEN facility.guestcost * bookings.slots > 30
ELSE facility.membercost * bookings.slots > 30 END
--order by descending total cost
ORDER BY total_cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

--Select all filtered results
SELECT *
--create subtable using conditionals and joins
FROM (
      SELECT CASE WHEN bookings.memid = 0 THEN concat(member.surname, ' ', facility.name)
                  ELSE concat(member.firstname, ' ', member.surname, ' ', facility.name)
                  END AS "Name",
             CASE WHEN bookings.memid = 0 THEN facility.guestcost * bookings.slots
                  ELSE facility.membercost * bookings.slots
                  END AS total_cost
            FROM `Bookings` AS bookings
            LEFT JOIN `Facilities` AS facility ON bookings.facid = facility.facid
            AND bookings.starttime LIKE '2012-09-14%'
            LEFT JOIN `Members` AS member ON bookings.memid  = member.memid
            AND bookings.starttime LIKE '2012-09-14%') subtable
--filter with alias created in subquery
WHERE subtable.total_cost > 30
--order by descending total cost
ORDER BY subtable.total_cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

--select facility name and the sum of total revenue
SELECT facility.name, SUM(CASE WHEN bookings.memid = 0 THEN facility.guestcost * bookings.slots
     ELSE facility.membercost * bookings.slots
     END) AS revenue
FROM `Bookings` AS bookings
LEFT JOIN `Facilities` AS facility ON bookings.facid = facility.facid
--group the facility entries
GROUP BY 1
--filter to revenus sums less than a thousand
HAVING revenue < 1000
--order by revenue
ORDER BY revenue
