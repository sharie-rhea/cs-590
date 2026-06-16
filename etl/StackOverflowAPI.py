# Author: Sharie Rhea
# Date: 06.16.26
# Course: SNHU CS590

import logging
import requests
import time

logger = logging.getLogger("StackOverflowAPI")
logging.basicConfig(level=logging.DEBUG)


class StackOverflowAPI:
    """
    Utility methods for querying info for Questions, Answers, and Comments
    from the Stack Overflow API.
    """

    BASE_URL = "https://api.stackexchange.com/2.3"

    def query_item(self, url, params, id) -> dict | None:
        response = requests.get(url, params=params)
        if response.status_code != 200:
            logger.error(f"Error fetching response, status code: {response.status_code}")
            return None
        data = response.json()
        if not data.get("items"):
            logger.warning(f"id {id} not found in response")
            return None

        return data.get("items")[0]

    def get_question_info(self, question_id) -> tuple[int, list[str]] | None:
        """
        Queries a specific question and returns the posting user's ID and
        any tags on the question.

        Params:
            question_id: int - the ID of the question to query
        Returns: user_id: int, tags: list[str]
        """

        # build the url for the query
        url = f"{self.BASE_URL}/questions/{question_id}"
        params = {"site": "stackoverflow", "filter": "default"}

        item = self.query_item(url, params, question_id)
        if not item:
            return None
        owner = item.get("owner", {})
        owner_id = owner.get("user_id")
        tags = item.get("tags", [])

        logger.debug(f"--- Question {question_id} Details ---")
        logger.debug(f"Title: {item.get('title')}")
        logger.debug(f"Posted By: {owner.get('display_name')} (User ID: {owner.get('user_id')})")
        logger.debug(f"Tags: {', '.join(tags)}\n")
        return owner_id, tags

    def get_answer_info(self, answer_id):
        """Queries a specific answer and returns the posting user's ID.

        Params:
            answer_id: int - the ID of the answer to query
        Returns: user_id: int, creation_date: int - UNIX timestamp
        """

        # build the url for the query
        url = f"{self.BASE_URL}/answers/{answer_id}"
        params = {"site": "stackoverflow"}

        item = self.query_item(url, params, answer_id)
        if not item:
            return None
        owner = item.get("owner", {})
        owner_id = owner.get("user_id")
        raw_timestamp = item.get("creation_date")

        logger.debug(f"--- Answer {answer_id} Details ---")
        logger.debug(f"Posted By: {owner.get('display_name')} (User ID: {owner_id})")
        logger.debug(f"Score: {item.get('score')}\n")
        return owner_id, raw_timestamp

    def get_comment_info(self, comment_id):
        """
        Queries a specific comment and returns the posting user's ID.

        Params:
            comment_id: int - the ID of the comment to query
        Returns: user_id: int
        """

        # build the url for the query
        url = f"{self.BASE_URL}/comments/{comment_id}"
        params = {"site": "stackoverflow"}

        item = self.query_item(url, params, comment_id)
        if not item:
            return None
        owner = item.get("owner", {})
        owner_id = owner.get("user_id")

        logger.debug(f"--- Comment {comment_id} Details ---")
        logger.debug(f"Posted By: {owner.get('display_name')} (User ID: {owner_id})")
        logger.debug(f"Score: {item.get('score')}\n")
        return owner_id


if __name__ == "__main__":
    # example for testing functionality
    sample_question_id = 65697972
    sample_answer_id = 69272967
    sample_comment_id = 122336972

    stackoverflowAPI = StackOverflowAPI()
    stackoverflowAPI.get_question_info(sample_question_id)
    time.sleep(1)  # throttle to avoid rate limiting
    stackoverflowAPI.get_answer_info(sample_answer_id)
    time.sleep(1)
    stackoverflowAPI.get_comment_info(sample_comment_id)
