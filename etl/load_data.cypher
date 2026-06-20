// Author: Sharie Rhea
// Date: 06.16.26
// Course: SNHU CS590

// This file outlines the graph schema for a neo4j database
// to house the Stack Overflow data and loads it from the 
// cleaned CSV files.

// drop everything and start fresh
MATCH (n)
DETACH DELETE n;
DROP CONSTRAINT u_a_id IF EXISTS;
DROP CONSTRAINT u_c_id IF EXISTS;
DROP CONSTRAINT u_q_id IF EXISTS;
DROP CONSTRAINT u_t_id IF EXISTS;
DROP CONSTRAINT u_u_id IF EXISTS;

DROP INDEX user_name_idx IF EXISTS;
DROP INDEX tag_name_idx IF EXISTS;
DROP INDEX post_content_idx IF EXISTS;

// create unique constraints so future MATCHes are faster
CREATE CONSTRAINT u_a_id FOR (a:Answer) REQUIRE a.uuid IS UNIQUE;
CREATE CONSTRAINT u_c_id FOR (c:Comment) REQUIRE c.uuid IS UNIQUE;
CREATE CONSTRAINT u_q_id FOR (q:Question) REQUIRE q.uuid IS UNIQUE;
CREATE CONSTRAINT u_t_id FOR (t:Tag) REQUIRE t.tag_id IS UNIQUE;
CREATE CONSTRAINT u_u_id FOR (u:User) REQUIRE u.uuid IS UNIQUE;

// create indexes for faster searches on text fields
CREATE INDEX user_name_idx FOR (u:User) ON (u.display_name);
CREATE INDEX tag_name_idx FOR (t:Tag) ON (t.name);

CREATE FULLTEXT INDEX post_content_idx FOR (n:Question|Answer) 
ON EACH [n.title, n.body_markdown];

// create tags and users first as they are "independent" nodes
// --- create tag nodes
LOAD CSV WITH HEADERS from "file:///cleaned/tag.csv" AS tag_row
CREATE (t:Tag)
SET t.tag_id = toInteger(tag_row.`tag_id`),
	t.name = tag_row.`name`,
	t.link = tag_row.`link`;

// --- create user nodes
LOAD CSV WITH HEADERS from "file:///cleaned/user.csv" AS user_row
CREATE (u:User)
SET u.user_id = toInteger(user_row.`user_id`),
	u.uuid = toInteger(user_row.`uuid`),
	u.display_name = user_row.`display_name`;

// --- create question nodes
LOAD CSV WITH HEADERS from "file:///cleaned/question.csv" AS question_row
CREATE (q:Question)
SET q.question_id = toInteger(question_row.`question_id`),
	q.link = question_row.`link`,
	q.view_count = toInteger(question_row.`view_count`),
	q.body_markdown = question_row.`body_markdown`,
	q.uuid = toInteger(question_row.`uuid`),
	q.title = question_row.`title`;

// and link them to the user who posted them
LOAD CSV WITH HEADERS from "file:///cleaned/question.csv" AS question_row
MATCH (q:Question {uuid: toInteger(question_row.`uuid`)})
OPTIONAL MATCH (user:User {uuid: toInteger(question_row.`user_uuid`)})
FOREACH (ignore IN CASE WHEN user IS NOT NULL THEN [1] ELSE [] END |
    CREATE (user)-[:POSTS {
        creation_date: datetime(question_row.`creation_date_formatted`)
    }]->(q)
);

// and link tags to this question
LOAD CSV WITH HEADERS from "file:///cleaned/question.csv" AS question_row
MATCH (q:Question {uuid: toInteger(question_row.`uuid`)})
UNWIND split(question_row.`tags`, "|") AS tag_name
OPTIONAL MATCH (tag:Tag) WHERE tag.name = tag_name
FOREACH (ignoreMe IN CASE WHEN tag IS NOT NULL THEN [1] ELSE [] END |
    CREATE (q)-[:TAGGED_WITH]->(tag)
);

// --- create answer nodes
LOAD CSV WITH HEADERS from "file:///cleaned/answer.csv" AS answer_row
CREATE (a:Answer)
SET a.answer_id = toInteger(answer_row.`answer_id`),
	a.link = answer_row.`link`,
	a.title = answer_row.`title`,
	a.body_markdown = answer_row.`body_markdown`,
	a.score = toInteger(answer_row.`score`),
	a.uuid = toInteger(answer_row.`uuid`);

// and link them to the user who posted them
LOAD CSV WITH HEADERS from "file:///cleaned/answer.csv" AS answer_row
MATCH (a:Answer {uuid: toInteger(answer_row.`uuid`)})
OPTIONAL MATCH (user:User {uuid: toInteger(answer_row.`user_uuid`)})
FOREACH (ignore IN CASE WHEN user IS NOT NULL THEN [1] ELSE [] END |
    CREATE (user)-[:POSTS {
        creation_date: datetime(answer_row.`creation_date_formatted`)
    }]->(a)
);

// and to the question they are answering
LOAD CSV WITH HEADERS from "file:///cleaned/answer.csv" AS answer_row
MATCH (a:Answer {uuid: toInteger(answer_row.`uuid`)})
OPTIONAL MATCH (question:Question) 
WHERE question.uuid = toInteger(split(answer_row.`question_uuid`, ".")[0])
// for each to ignore "orphan" answers -> we don't know the question they're responding to
FOREACH (match_found IN CASE WHEN question IS NOT NULL THEN [1] ELSE [] END |
	// always create an answers relationship if found
    CREATE (a)-[:ANSWERS]->(question)

	// if this answer was accepted, also create edge from q->a
	FOREACH (accepted_answer IN CASE WHEN toBoolean(toLower(answer_row.`is_accepted`)) THEN [1] ELSE [] END |
		// wish there was a way to restrict so that only ONE edge of this type may exist for each question...
        CREATE (question)-[:ACCEPTS_ANSWER]->(a)
    )
);

// --- create comment nodes
LOAD CSV WITH HEADERS from "file:///cleaned/comment.csv" AS comment_row
CREATE (c:Comment)
SET c.comment_id = toInteger(comment_row.`comment_id`),
	c.score = toInteger(comment_row.`score`),
	c.uuid = toInteger(comment_row.`uuid`),
	c.link = comment_row.`link`;

// and link them to the user who posted them
LOAD CSV WITH HEADERS from "file:///cleaned/comment.csv" AS comment_row
MATCH (c:Comment {uuid: toInteger(comment_row.`uuid`)})
OPTIONAL MATCH (user:User {uuid: toInteger(comment_row.`user_uuid`)})
FOREACH (ignore IN CASE WHEN user IS NOT NULL THEN [1] ELSE [] END |
    CREATE (user)-[:POSTS {
        creation_date: datetime(comment_row.`creation_date_formatted`)
    }]->(c)
);

// and to the question they are commenting on
LOAD CSV WITH HEADERS from "file:///cleaned/comment.csv" AS comment_row
MATCH (c:Comment {uuid: toInteger(comment_row.`uuid`)})
OPTIONAL MATCH (question:Question) 
WHERE question.uuid = toInteger(split(comment_row.`question_uuid`, ".")[0])
FOREACH (ignore IN CASE WHEN question IS NOT NULL THEN [1] ELSE [] END |
    CREATE (c)-[:RESPONDS_TO]->(question)
);
