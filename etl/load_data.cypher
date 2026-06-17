// Author: Sharie Rhea
// Date: 06.16.26
// Course: SNHU CS590

// This file outlines the graph schema for a neo4j database
// to house the Stack Overflow data and loads it from the 
// cleaned CSV files.

// create unique constraints so future MATCHes are faster
CREATE CONSTRAINT FOR (a:Answer) REQUIRE a.uuid IS UNIQUE;
CREATE CONSTRAINT FOR (c:Comment) REQUIRE c.uuid IS UNIQUE;
CREATE CONSTRAINT FOR (q:Question) REQUIRE q.uuid IS UNIQUE;
CREATE CONSTRAINT FOR (t:Tag) REQUIRE t.tag_id IS UNIQUE;
CREATE CONSTRAINT FOR (u:User) REQUIRE u.uuid IS UNIQUE;

// create tags and users first as they are "independent" nodes
// --- create tag nodes
LOAD CSV WITH HEADERS from "file:///../data/cleaned/tag.csv" AS tag_row
CREATE (t:Tag)
SET t.tag_id = toInteger(tag_row.`tag_id`),
	t.name = tag_row.`name`,
	t.link = tag_row.`link`;

// --- create user nodes
LOAD CSV WITH HEADERS from "file:///../data/cleaned/user.csv" AS user_row
CREATE (u:User)
SET u.user_id = toInteger(user_row.`user_id`),
	u.uuid = toInteger(user_row.`uuid`),
	u.display_name = user_row.`display_name`;

// now creation question nodes
// --- create question nodes
LOAD CSV WITH HEADERS from "file:///../data/cleaned/question.csv" AS question_row
CREATE (q:Question)
SET q.question_id = toInteger(question_row.`question_id`),
	q.link = question_row.`link`,
	q.view_count = toInteger(question_row.`view_count`),
	q.body_markdown = question_row.`body_markdown`,
	q.uuid = toInteger(question_row.`uuid`);
	q.title = question_row.`title`;
// and link them to the user who posted them
MATCH (user:User {uuid: toInteger(question_row.`user_uuid`)})
CREATE (user)-[:POSTS {
	creation_date: date(question_row.`creation_date_formatted`)
}]->(q);
// and link tags to this question
WITH q, split(question_row.`tags`, ",") AS tag_list
UNWIND tag_list AS tag_name
MATCH (tag:Tag {name: tag_name})
CREATE (q)-[:TAGGED_WITH]->(tag)

// --- create answer nodes
LOAD CSV WITH HEADERS from "file:///../data/cleaned/answer.csv" AS answer_row
CREATE (a:Answer)
SET a.answer_id = toInteger(answer_row.`answer_id`),
	a.link = answer_row.`link`,
	a.title = answer_row.`title`,
	a.body_markdown = answer_row.`body_markdown`,
	a.score = toInteger(answer_row.`score`),
	a.uuid = toInteger(answer_row.`uuid`);
// and link them to the user who posted them
MATCH (user:User {uuid: toInteger(answer_row.`user_uuid`)})
CREATE (user)-[:POSTS {
	creation_date: date(answer_row.`creation_date_formatted`)
}]->(a);
// and to the question they are answering
MATCH (question:Question {uuid: toInteger(answer_row.`question_uuid`)})
CREATE (a)-[:ANSWERS {
	accepted: toBoolean(toLower(answer_row.`is_accepted`))
}]->(question);

// --- create comment nodes
LOAD CSV WITH HEADERS from "file:///../data/cleaned/comment.csv" AS comment_row
CREATE (c:Comment)
SET c.comment_id = toInteger(comment_row.`comment_id`),
	c.score = toInteger(comment_row.`score`),
	c.uuid = toInteger(comment_row.`uuid`);
	c.link = comment_row.`link`;
// and link them to the user who posted them
MATCH (user:User {uuid: toInteger(comment_row.`user_uuid`)})
CREATE (user)-[:POSTS {
	creation_date: date(comment_row.`creation_date_formatted`)
}]->(c);
// and to the question they are commenting on
MATCH (question:Question {uuid: toInteger(comment_row.`question_uuid`)})
CREATE (c)-[:RESPONDS_TO]->(question);
