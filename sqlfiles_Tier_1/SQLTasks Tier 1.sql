/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name AS list_of_facilities_with_membercost
FROM Facilities
WHERE membercost > 0;


/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(*) AS number_of_facilities_with_no_membercost
FROM Facilities
WHERE membercost = 0 OR membercost IS NULL;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost < (0.2* monthlymaintenance) AND membercost > 0;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid IN (1, 5);

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance > 100 THEN 'expensive'
ELSE 'cheap'
END AS label_cost_as
FROM Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname, joindate
FROM Members
WHERE joindate = (
SELECT MAX(joindate)
FROM Members);

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT CONCAT (firstname, '  ', surname) AS customer_name, name AS court_name
FROM Bookings AS b
LEFT JOIN Members AS m
           ON b.memid = m.memid
LEFT JOIN Facilities AS f
ON b.facid = f.facid
WHERE name LIKE 'Tennis%'
ORDER BY customer_name;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT CONCAT (firstname, '  ', surname) AS customer_name, name AS facility_name,
CASE WHEN b.memid = 0 THEN guestcost * slots 
ELSE membercost * slots
END AS total_cost
FROM Bookings AS b
INNER JOIN Members AS m ON b.memid = m.memid
INNER JOIN Facilities AS f ON b.facid = f.facid
WHERE starttime LIKE '2012-09-14%' AND ((b.memid = 0 AND guestcost * slots > 30) OR (b.memid != 0 AND membercost * slots > 30))
ORDER BY total_cost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT customer_name, facility_name, total_cost, starttime
FROM (SELECT CONCAT (firstname, '  ', surname) AS customer_name, name AS facility_name, starttime, 
      CASE WHEN b.memid = 0 THEN guestcost * slots 
      ELSE membercost * slots 
      END AS total_cost 
      FROM Members AS m
      INNER JOIN Bookings AS b ON m.memid = b.memid
      INNER JOIN Facilities AS f ON b.facid = f.facid
      WHERE starttime LIKE '2012-09-14%') AS bookings
WHERE total_cost > 30
ORDER BY total_cost DESC;

/* PART 2: SQLite
We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.*/
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

import sqlite3
from sqlite3 import Error

 
def create_connection(db_file):
    """ create a database connection to the SQLite database
        specified by the db_file
    :param db_file: database file
    :return: Connection object or None
    """
    conn = None
    try:
        conn = sqlite3.connect(db_file)
        print(sqlite3.version)
    except Error as e:
        print(e)
 
    return conn

 
def select_all_tasks(conn):
    """
    Query all rows in the tasks table
    :param conn: the Connection object
    :return:
    """
    cur = conn.cursor()
    
    query1 = """
        SELECT name AS facility_name, SUM(CASE WHEN b.memid = 0 THEN slots * guestcost
        ELSE slots * membercost
        END) AS total_revenue
        FROM Bookings AS b
        INNER JOIN Members AS m ON b.memid = m.memid
        INNER JOIN Facilities AS f ON b.facid = f.facid
        GROUP BY name
        HAVING total_revenue < 1000
        ORDER BY total_revenue DESC;
        """
    cur.execute(query1)
 
    rows = cur.fetchall()
 
    for row in rows:
        print(row)


def main():
    database = "sqlite_db_pythonsqlite.db"
 
    # create a database connection
    conn = create_connection(database)
    with conn: 
        print("2. Query all tasks")
        select_all_tasks(conn)
 
 
if __name__ == '__main__':
    main()

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

import sqlite3
from sqlite3 import Error

 
def create_connection(db_file):
    """ create a database connection to the SQLite database
        specified by the db_file
    :param db_file: database file
    :return: Connection object or None
    """
    conn = None
    try:
        conn = sqlite3.connect(db_file)
        print(sqlite3.version)
    except Error as e:
        print(e)
 
    return conn

 
def select_all_tasks(conn):
    """
    Query all rows in the tasks table
    :param conn: the Connection object
    :return:
    """
    cur = conn.cursor()
    
    query1 = """
        SELECT m.memid AS member_id, m.surname||'  '|| m.firstname AS member_name, 
        sub.surname||'  '||sub.firstname AS recommender_name
        FROM Members AS m, (SELECT surname, firstname, memid FROM Members) AS sub
        WHERE recommendedby != '' 
        AND recommendedby = sub.memid 
        ORDER BY recommender_name ASC;
        """
    cur.execute(query1)
 
    rows = cur.fetchall()
 
    for row in rows:
        print(row)


def main():
    database = "sqlite_db_pythonsqlite.db"
 
    # create a database connection
    conn = create_connection(database)
    with conn: 
        print("2. Query all tasks")
        select_all_tasks(conn)
 
 
if __name__ == '__main__':
    main()


/* Q12: Find the facilities with their usage by member, but not guests */

import sqlite3
from sqlite3 import Error

 
def create_connection(db_file):
    """ create a database connection to the SQLite database
        specified by the db_file
    :param db_file: database file
    :return: Connection object or None
    """
    conn = None
    try:
        conn = sqlite3.connect(db_file)
        print(sqlite3.version)
    except Error as e:
        print(e)
 
    return conn

 
def select_all_tasks(conn):
    """
    Query all rows in the tasks table
    :param conn: the Connection object
    :return:
    """
    cur = conn.cursor()
    
    query1 = """
        SELECT firstname, surname, name, b.memid, b.facid 
        FROM Bookings AS b
        INNER JOIN Facilities AS f ON b.facid = f.facid
        INNER JOIN Members AS m ON b.memid = m.memid
        WHERE b.memid != 0
        GROUP BY firstname;
        """
    cur.execute(query1)
 
    rows = cur.fetchall()
 
    for row in rows:
        print(row)


def main():
    database = "sqlite_db_pythonsqlite.db"
 
    # create a database connection
    conn = create_connection(database)
    with conn: 
        print("2. Query all tasks")
        select_all_tasks(conn)
 
 
if __name__ == '__main__':
    main()


/* Q13: Find the facilities usage by month, but not guests */

import sqlite3
from sqlite3 import Error

 
def create_connection(db_file):
    """ create a database connection to the SQLite database
        specified by the db_file
    :param db_file: database file
    :return: Connection object or None
    """
    conn = None
    try:
        conn = sqlite3.connect(db_file)
        print(sqlite3.version)
    except Error as e:
        print(e)
 
    return conn

 
def select_all_tasks(conn):
    """
    Query all rows in the tasks table
    :param conn: the Connection object
    :return:
    """
    cur = conn.cursor()
    
    query1 = """
        SELECT strftime('%m', starttime) AS month, f.facid, firstname, surname, SUM(slots) AS facility_usage_total, name
        FROM Bookings AS b
        INNER JOIN Facilities AS f ON b.facid = f.facid
        INNER JOIN Members AS m ON b.memid = m.memid
        WHERE b.memid <> 0
        GROUP BY month, f.facid;
        """
    cur.execute(query1)
 
    rows = cur.fetchall()
 
    for row in rows:
        print(row)


def main():
    database = "sqlite_db_pythonsqlite.db"
 
    # create a database connection
    conn = create_connection(database)
    with conn: 
        print("2. Query all tasks")
        select_all_tasks(conn)
 
 
if __name__ == '__main__':
    main()
