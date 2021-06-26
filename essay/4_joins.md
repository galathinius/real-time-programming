what if we need to combine data from multtiple sources and send it off as a new stream?<br/>
Most stream processing products have an operation for that!<br/>
Its callled a _streaming join_<br/>

Streaming joins can be of two types:
1. stream-static join<br/>
This is when data from a stream is combine with data from a static 
source if information, for example an sql database or a dataframe.
<br/>
This is a relatively simple opperation so more tools have it.<br/>

2. stream-stream join<br/>
This is the complex one, where data from two streams needs to be combined.