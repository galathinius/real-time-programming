# twitter_stream
<br/><br/>
This is an Erlang OTP Application that:
- continues from the [first part](https://github.com/galathinius/real-time-programming/tree/part1/twitter_stream)
- solves the following task:<br/>
Without further ado, the second laboratory task: <br/>
Loading streaming data into a database. <br/>
A backpressure story.<br/>
1. You will have to reuse the first Lab, with some additions.
2. You will be required to copy the Dynamic Supervisor + Workers that compute the sentiment score <br/>
and adapt this copy of the system to compute the Engagement Ratio per Tweet. Notice that some tweets <br/>
 are actually retweets and contain a special field retweet_status​ . You will have to extract it and treat it as<br/>
  a separate tweet. The Engagement Ratio will be computed as: (#favorites + #retweets) / #followers​ . <br/>
3. Your workers now print sentiment scores, but for this lab, they will have to send it to a dedicated aggregator <br/>
actor where the sentiment score, the engagement ratio, and the original tweet will be merged together. <br/>
Hint: <br/>
you will need special ids to recombine everything properly because synchronous communication is forbidden.
4. Finally, you will have to load everything into a database, for example Mongo, and given that writing messages<br/>
 one by one is not efficient, you will have to implement a backpressure mechanism called adaptive batching​​. <br/>
 Adaptive batching means that you write/send data in batches if the maximum batch size is reached, for <br/>
 example 128 elements, or the time is up, for example a window of 200ms is provided, whichever occurs first. <br/>
 This will be the responsibility of the sink actor(s).
5. To make things interesting, you will have to split the tweet JSON into users and tweets and keep them <br/>
in separate collections/tables in the DB.
6. Of course, don't forget about using actors and supervisors for your system to keep it running.
<br/>
    <br/>
What was done:<br/>

![project structure](../assets/lab2_shema.png)<br/>
\* with blue lines are the subscriber relations<br/>
they are neccesary for the worker pool described below
<br/><br/>

- This app calculates engagement according to the formula:<br/>
_(#favorites + #retweets) / (#followers +1)_<br/>
in order to mittigate division by 0<br/>
<br/>
- Besides the retweets, the workers also separate the quote tweets. <br/>
These are retweets with a comment added by the retweeter.<br/>
<br/>
- In order for the aggregator not to get flooded by empty or panic events from the server, <br/>
the events go through a filter which also separates the retweets and quote tweets.<br/>
*Update: the filter is also a pool<br/> 

<br/>
- As the tweets from the aggregator need to be rearranged before getting to the sink, <br/>
they had to go through an _information_transformer_ <br/>
<br/>
 - Because the _information_transformer_ part can be considered resource intensive, <br/>
 it was also given a worker pool<br/>
 <br/>

 Worker pool structure:<br/>

 ![worker pool structure](../assets/worker_pool.png)<br/>

On starting the pool superior supervisor, 2 parameters are given:<br/>
1. the publisher of information that the pool will get information from<br/>
2. the worker file name<br/>
<br/>
Next:<br/>
- the pool router subscribes to the given information publisher, and on updates, distributes the work<br/>
- the pool minion scaler subscribes to the main scaler for hiring updates and scales the number of workers accordingly<br/>
 <br/>

 Now, PubSub:<br/>

  ![pub sub meme](../assets/khajiit_pubsub.jpg)
  <br/>

  The PubSub pattern was implemented when it was observed that an actor needed to update <br/>
  multiple other actors of something:

  <br/>
  First is the event source:<br/>
As a lot of actors need the events, it was decided that a single router can be easily <br/>
overwhelmed, so an event publisher was created.<br/>
Its subscribers are:<br/>
1. the information actor (just counts them)<br/>
2. the filter (for the aggregator)<br/>
3. the emotional router (from the pool)<br/>
4. the engagement router (from the pool)<br/>
<br/>
Second is the main scaler:<br/>
As there are multiple worker pools (three), and more could be added, it would be redundant to <br/>
add the code for each one to one scaler, so it was made into a publisher.<br/>
<br/> 
Third is a victim of the worker pool API:<br/>
As the information transformer pool needs a publisher to subscribe to, the aggregator had to <br/>aquire a publisher.