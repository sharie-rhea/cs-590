# Author: Sharie Rhea
# Date: 06.16.26
# Course: CS590

"""
This file serves to clean and enrich the original provided CSV dataset.
The main tasks involve cleaning raw text fields (removing /r characters and
html escaped characters) and enriching data connections by querying the
Stack Overflow API.
"""

import html
import logging
import pandas as pd
from StackOverflowAPI import StackOverflowAPI

logger = logging.getLogger("cleaner")
logging.basicConfig(level=logging.INFO)

# utility functions


def html_unescape(dataframe, column_name):
    """
    Modify a dataframe column in-place and fix characters such as &quot; -> "
    Parameters:
        dataframe: pandas dataframe - the frame to modify
        column_name: str - the name of the column to process
    Returns:
        dataframe: pandas dataframe - the dataframe with the cleaned column
    """
    dataframe[column_name] = dataframe[column_name].apply(lambda x: html.unescape(x))
    return dataframe


def clean_answers():
    path = "../data/stackoverflow.nodes.Answer.csv"
    try:
        logger.info(f"Loading dataset {path}...")
        data = pd.read_csv(path)
        logger.info("Dataset loaded!")
    except Exception as exception:
        logger.error(f"Unable to load dataset: {exception}")
        raise

    for column in ["title", "body_markdown"]:
        # deal with special characters
        data = html_unescape(data, column)
        # remove /r line endings
        data[column] = data[column].str.replace("\r", "", regex=False)

    # prepare to enrich data using Stack Overflow's API
    answer_ids = data["uuid"].astype(int).unique().tolist()
    logger.info(f"Starting batch fetch for {len(answer_ids)} unique answer IDs...")

    # query
    answers_info_dict = api_client.get_answers_info(answer_ids)
    # add to existing data, matching on uuid
    data["user_uuid"] = data["uuid"].map(lambda x: answers_info_dict.get(x, {}).get("owner_id"))
    data["creation_date"] = data["uuid"].map(lambda x: answers_info_dict.get(x, {}).get("creation_date"))
    # convert timestamp into a readable format
    data["creation_date_formatted"] = pd.to_datetime(data["creation_date"], unit="s", errors="coerce")

    # check our work
    logger.info(f"\nDataFrame update complete! {len(answer_ids)} records updated.")
    logger.debug(data[["uuid", "user_uuid", "creation_date", "creation_date_formatted"]].head())

    # write out cleaned and enriched data
    data.to_csv("../data/cleaned/answer.csv", index=False)


def clean_comments():
    path = "../data/stackoverflow.nodes.Comment.csv"
    try:
        logger.info(f"Loading dataset {path}...")
        data = pd.read_csv(path)
        logger.info("Dataset loaded!")
    except Exception as exception:
        logger.error(f"Unable to load dataset: {exception}")
        raise

    # enrich data by linking comment to the question it is tied to
    # get the question uuid from the comment URL
    regex_pattern = r"/questions/(\d+)"
    # Int64 for nullable integer type in pandas
    data["question_uuid"] = data["link"].str.extract(regex_pattern).astype("Int64")

    # prepare to enrich data using Stack Overflow's API
    comment_ids = data["uuid"].astype(int).unique().tolist()
    logger.info(f"Starting batch fetch for {len(comment_ids)} unique comment IDs...")

    # query
    comment_info_dict = api_client.get_comments_info(comment_ids)
    # add to existing data, matching on uuid
    data["user_uuid"] = data["uuid"].map(lambda x: comment_info_dict.get(x, {}).get("owner_id"))
    data["creation_date"] = data["uuid"].map(lambda x: comment_info_dict.get(x, {}).get("creation_date"))
    # convert timestamp into a readable format
    data["creation_date_formatted"] = pd.to_datetime(data["creation_date"], unit="s", errors="coerce")

    # check our work
    logger.info(f"\nDataFrame update complete! {len(comment_ids)} records updated.")
    logger.debug(data[["uuid", "user_uuid", "question_uuid", "creation_date", "creation_date_formatted"]].head())

    # write out cleaned and enriched data
    data.to_csv("../data/cleaned/comment.csv", index=False)


def clean_questions():
    path = "../data/stackoverflow.nodes.Question.csv"
    try:
        logger.info(f"Loading dataset {path}...")
        data = pd.read_csv(path)
        logger.info("Dataset loaded!")
    except Exception as exception:
        logger.error(f"Unable to load dataset: {exception}")
        raise

    for column in ["title", "body_markdown"]:
        # deal with special characters
        data = html_unescape(data, column)
        # remove /r line endings
        data[column] = data[column].str.replace("\r", "", regex=False)

    # clean accepted answer ids Int64 (nullable) not floats like pandas wants to
    data["accepted_answer_id"] = data["accepted_answer_id"].astype("Int64")

    # prepare to enrich data using Stack Overflow's API
    question_ids = data["uuid"].astype(int).unique().tolist()
    logger.info(f"Starting batch fetch for {len(question_ids)} unique question IDs...")

    # query
    question_info_dict = api_client.get_questions_info(question_ids)
    # add to existing data, matching on uuid
    data["user_uuid"] = data["uuid"].map(lambda x: question_info_dict.get(x, {}).get("owner_id"))
    data["tags"] = data["uuid"].map(lambda x: question_info_dict.get(x, {}).get("tags"))
    # convert timestamp into a readable format
    data["creation_date_formatted"] = pd.to_datetime(data["creation_date"], unit="s", errors="coerce")

    # check our work
    logger.info(f"\nDataFrame update complete! {len(question_ids)} records updated.")
    logger.debug(data[["uuid", "user_uuid", "tags", "creation_date", "creation_date_formatted"]].head())

    # write out cleaned and enriched data
    data.to_csv("../data/cleaned/question.csv", index=False)


def clean_tags():
    path = "../data/stackoverflow.nodes.Tag.csv"
    try:
        logger.info(f"Loading dataset {path}...")
        data = pd.read_csv(path)
        logger.info("Dataset loaded!")
    except Exception as exception:
        logger.error(f"Unable to load dataset: {exception}")
        raise

    # NOTE: no cleaning or enrichment needed for tags
    # placeholder for future work if desired

    # write out
    data.to_csv("../data/cleaned/tag.csv", index=False)


def clean_users():
    path = "../data/stackoverflow.nodes.User.csv"
    try:
        logger.info(f"Loading dataset {path}...")
        data = pd.read_csv(path)
        logger.info("Dataset loaded!")
    except Exception as exception:
        logger.error(f"Unable to load dataset: {exception}")
        raise

    # NOTE: no cleaning or enrichment needed for users
    # placeholder for future work if desired

    # write out
    data.to_csv("../data/cleaned/user.csv", index=False)


if __name__ == "__main__":
    api_client = StackOverflowAPI()
    if input("Clean and enrich Answers? [y/N]: ").strip().lower() in ("y", "yes"):
        clean_answers()
    if input("Clean and enrich Comments? [y/N]: ").strip().lower() in ("y", "yes"):
        clean_comments()
    if input("Clean and enrich Questions? [y/N]: ").strip().lower() in ("y", "yes"):
        clean_questions()
    if input("Clean and enrich Tags? [y/N]: ").strip().lower() in ("y", "yes"):
        clean_tags()
    if input("Clean and enrich Users? [y/N]: ").strip().lower() in ("y", "yes"):
        clean_users()
