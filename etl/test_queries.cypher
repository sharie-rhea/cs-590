// Author: Sharie Rhea
// Date: 06.17.26
// Course: SNHU CS590

// This file holds test/validation queries for
// the stackoverflow data model.

// verify number of nodes for each type
MATCH (n)
RETURN labels(n)[0] AS node_type, count(n) AS count 
ORDER BY count DESC;

// verify number of edges for each type
MATCH ()-[r]->()
RETURN type(r) AS relationship_type, count(r) AS count;

// check for questions/answers/comments without a POSTED relationship
// we don't know the author
MATCH (p) 
WHERE (p:Question OR p:Answer OR p:Comment) 
  AND NOT (:User)-[:POSTS]->(p)
RETURN labels(p)[0] AS unknown_author_type, count(p) AS count;

// check for answers that do not have an associated question
MATCH (a:Answer) WHERE NOT (a)-[:ANSWERS]->(:Question)
WITH count(a) AS orphan_answers
// and comments that do not have an associated question
MATCH (c:Comment) WHERE NOT (c)-[:RESPONDS_TO]->(:Question)
RETURN orphan_answers, count(c) AS orphan_comments;

// test connections by building a full thread
MATCH (q:Question)
WHERE q.uuid = 66979866  // grab a single question (chosen because it has multiple comments and answers)
// find its author
MATCH (author:User)-[:POSTS]->(q)
// find its tag(s)
OPTIONAL MATCH (q)-[:TAGGED_WITH]->(t:Tag)
// find any answers and their authors
OPTIONAL MATCH (:User)-[:POSTS]->(a:Answer)-[:ANSWERS]->(q)
// find any comments and their authors
OPTIONAL MATCH (:User)-[:POSTS]->(c:Comment)-[:RESPONDS_TO]->(q)
RETURN 
    author.display_name AS question_author, 
    collect(DISTINCT t.name) AS tags,
	count(DISTINCT a) as answers,
	count(DISTINCT c) as comments;

// test user "profile" by getting their name, number of posts, and activity info
MATCH (u:User)-[p:POSTS]->(post)
RETURN 
    u.display_name AS username,
    count(post) AS total_posts,
	count(CASE WHEN post:Answer THEN 1 END) as total_answers,
	count(CASE WHEN post:Question THEN 1 END) as total_questions,
	count(CASE WHEN post:Comment THEN 1 END) as total_comments,
    min(p.creation_date) AS first_post_date,
    max(p.creation_date) AS latest_post_date
ORDER BY total_posts DESC 
LIMIT 5;

// find 5 questions that have accepted answers
MATCH (q:Question)-[accepted:ACCEPTS_ANSWER]->(a:Answer)
RETURN
	q.uuid AS question_uuid,
	q.view_count AS view_count,
	a.uuid AS answer_uuid
LIMIT 5;
