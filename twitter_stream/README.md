# twitter_stream
<br/><br/>
This is an Erlang OTP Application that solves the following task:<br/>
Finally, the first laboratory task itself: Make a streaming Twitter sentiment analysis system<br/>
1. You will have to read 2 SSE streams of actual Twitter API tweets in JSON format. <br/>
    For Elixir use this project to read SSE: https://github.com/cwc/eventsource_ex<br/>
2. The streams are available from a Docker container, alexburlacu/rtp-server:faf18x, just like Lab 1 PR, only now it's on port 4000<br/>
3. To make things interesting, the rate of messages varies by up to an order of magnitude, from 100s to 1000s.<br/>
4. Then, you route the messages to a group of workers that need to be autoscaled, you will need to <br/>
    scale up the workers (have more) when the rate is high, and less actors when the rate is low<br/>
5. Route/load balance messages among worker actors in a round robin fashion<br/>
6. ccasionally you will receive "kill messages", on which you have to crash the workers.<br/>
7. To continue running the system you will have to have a supervisor/restart policy for the workers.<br/>
8. The worker actors also must have a random sleep, in the range of 50ms to 500ms, normally distributed. <br/>
    This is necessary to make the system behave more like a real one + give the router/load balancer a bit <br/>
    of a hard time + for the optional speculative execution. The output will be shown as log messages.<br/>
    <br/>

This App parses the tweets and prints the emotional score according to the mapping in [*emotional_score.erl*](https://github.com/galathinius/real-time-programming/blob/main/twitter_stream/src/components/emotional_score.erl)<br/>

Also, once every second the Scaler shows some statistics for the passed second:
 - Panics - panic messages received from the server, they kill workers
 - Actual scores - not every tweet has words with emotional scores, that's why this one shows how many tweets had scores different from 0
 - Events - how many events came from the server 
 - Workers - how many workers are now
 - To hire - how many workers need to be hired, if negative then fired

[Link to a video showing the running application](https://utm-my.sharepoint.com/:v:/g/personal/anisoara_plesca_isa_utm_md/ESBz-rR9wmxMoooHAHd-8vMB3cdO5qYRDF3uUeaYsDXCvA?e=xDmRiL)