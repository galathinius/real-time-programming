# Problem

So you have a stream of data. Data continuously comes and you have
to analize it. Multiple points need attention in this context.

## [Point-in-time vs continuous queries](https://materialize.com/streaming-sql-intro/)

Running a SQL query on a traditional database returns a static set
of results from a single point in time.

Take this query:

    SELECT SUM(amount) as total_amount FROM invoices;

When you run it, the database engine scans all invoices that existed at the time of the query and returns the sum of their amounts.

But with streaming data the querries have run continuously, in order
to provide updates ans show the latest state.

## Time widows

Let's say you need to transform data and send
it onward as a new stream.
For this, joins are usually needed.

For a join, let's say, one piece of data comes first, then the
processing engine has to wait for the other pieces for the join
while keeping the first one in memory. this can lead to memory
overload as the process accumulates a lot of information and
waiting for the necessary bit.

## not all

Of course there are more pieces to the problem, but these were the most obvious ones
