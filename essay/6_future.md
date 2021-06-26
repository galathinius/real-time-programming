# Existing challenges and future directions

1. Machine Learning.

At the moment of writing, ML mod-els are used as consumers of 
data streams, but are typically trained offline and need to be 
periodically updated. One future direction would be to implement 
continuous training of models on those streams.

2. Transactions.

Streaming systems lack transactional facilities to support 
advanced business logic. Another future direction would be transaction operators in tools.

3. Elasticity & Reconfiguration.

Streaming systems providelimited means for elasticity and 
reconfiguration actions, suchas changing resource allocations and 
updating operator logicamidst a job execution. Typically a stream 
processing job hasto save its state, terminate its execution, and 
restart it withthe refreshed operators. For Cloud applications that 
haveto be constantly online, this support is inadequate. Instead,
applications need to apply code updates and hot fixes seam-lessly to 
their operation without affecting the state or theprocessing of user 
requests.


[source](https://dcatkth.github.io/papers/SIGMOD-streams.pdf
)







