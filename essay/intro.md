<h1> Lets understand the topic first.</h1>
</br>
<h2>SQL</h2>

[SQL (Structured Query Language) is a descriptive computer language designed for updating, retrieving, and calculating data in table-based databases.](https://developer.mozilla.org/en-US/docs/Glossary/SQL)</br></br>



<h2>Semantics</h2>
/sɪˈmantɪks/

noun: semantics;</br>
 noun: logical semantics; </br>
 noun: lexical semantics</br>

    the branch of linguistics and logic concerned with meaning. The two main areas are logical semantics, concerned with matters such as sense and reference and presupposition and implication, and lexical semantics, concerned with the analysis of word meanings and relations between them.
        the meaning of a word, phrase, or text.
        plural noun: semantics
        "such quibbling over semantics may seem petty stuff"

*by google in colaboration with oxford languages*</br>

</br></br>

Kinda abstract and doesn't clear up what 'sql semantics' could possibly mean</br>
Searching for 'SQL semantincs' isn't really helpful as the only close result is this</br>

    The semantics of SQL queries is formally defined by stating a set of rules that determine a syntax-driven translation of an SQL query to a formal model. The target model, called Extended Three Valued Predicate Calculus (E3VPC), is largely based on a set of well-known mathematical concepts. The rules which allow the transformation of a general E3VPC expression to a Canonical Form, which can be manipulated using traditional, two-valued predicate calculus are also given; in this way, problems like equivalence analysis of SQL queries are completely solved.

[*Formal semantics of SQL queries*](https://dl.acm.org/doi/abs/10.1145/111197.111212)

</br>

Lets look for something in more familiar teritory</br>

[*Python semantics*](https://jakevdp.github.io/WhirlwindTourOfPython/03-semantics-variables.html)

The above article explains, that for example, all python variables are pointers. </br>
Everything is an object. </br>
And numerical types have a real and imag attribute that returns the real and imaginary part of the value, if viewed as a complex number:</br>

    x = 4.5
    print(x.real, "+", x.imag, 'i')

    4.5 + 0.0 i

Okay, until now it is understood that this essay will be about how sql works behind the curtains. but in what situations?</br>

The *streaming data* part comes now.

<h2>Streaming data</h2>
