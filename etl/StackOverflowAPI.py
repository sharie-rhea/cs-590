# Author: Sharie Rhea
# Date: 06.16.26
# Course: SNHU CS590

"""
This file holds the StackOverflowAPI helper class, which handles querying
the Stack Overflow API in batches and bundling responses.
"""

import logging
import requests
import time

logger = logging.getLogger("StackOverflowAPI")


class StackOverflowAPI:
    """
    Utility methods for querying info for Questions, Answers, and Comments
    from the Stack Overflow API.
    """

    BASE_URL = "https://api.stackexchange.com/2.3"

    def __init__(self, log_level: str) -> None:
        logging.basicConfig(level=log_level)

    def chunk_ids(self, id_list: list[int], chunk_size: int = 100) -> list[list[int]]:
        """
        Split a list of IDs into chunks of a maximum size.

        Parameters:
            id_list: list[int] - the IDs to split
            chunk_size: int - the maximum chunk size allowed
        Returns:
            list[list[int]] - the IDs segmented into multiple lists according to the max size
        """
        return [id_list[i : i + chunk_size] for i in range(0, len(id_list), chunk_size)]

    def query_items_batch(self, endpoint: str, id_chunk: list[int], params: dict) -> list[dict]:
        """
        Sends a single batched vector request for a list of up to 100 IDs.

        Parameters:
            endpoint: str - the API endpoint to use
            id_chunk: list[int] - list of IDs to query
            params: dict - API parameters
        Returns: list[dict] - JSON responses for each query
        """
        if not id_chunk:
            return []

        # join the IDs with semicolons for a batch query "69272967;69272968;69272969"
        id_string = ";".join(map(str, id_chunk))
        url = f"{self.BASE_URL}/{endpoint}/{id_string}"

        # explicitly enforce pagesize
        params["pagesize"] = max(100, len(id_chunk))

        response = requests.get(url, params=params)
        if response.status_code != 200:
            logger.error(f"Error fetching response for batch, status code: {response.status_code}")
            return []

        data = response.json()
        items = data.get("items", [])
        if not items:
            logger.warning(f"No items found for requested batch IDs: {id_chunk}")
            return []

        return items

    def get_questions_info(self, question_ids: list[int]) -> dict[int, dict]:
        """
        Queries a list of questions and returns a dictionary of information.

        Params:
            question_ids: list[int] - the IDs of the questions to query
        Returns:
            dict[int, dict] - {question_id: {"owner_id": int | None, "tags": str}}
        """
        results = {}
        chunks = self.chunk_ids(question_ids)

        for index, chunk in enumerate(chunks):
            if index > 0:
                time.sleep(0.2)  # throttle between API batch calls

            params = {"site": "stackoverflow", "filter": "default"}
            items = self.query_items_batch("questions", chunk, params)

            for item in items:
                question_id = item.get("question_id")
                owner = item.get("owner", {})
                owner_id = owner.get("user_id")
                tags = item.get("tags", [])

                logger.debug(f"--- Question {question_id} Details ---")
                logger.debug(f"Title: {item.get('title')}")
                logger.debug(f"Posted By: {owner.get('display_name')} (User ID: {owner_id})")
                logger.debug(f"Tags: {'|'.join(tags)}\n")

                results[question_id] = {"owner_id": owner_id, "tags": "|".join(tags)}

        return results

    def get_answers_info(self, answer_ids: list[int]) -> dict[int, dict]:
        """
        Queries a list of answers and returns a dictionary of information.

        Params:
            answer_ids: list[int] - the IDs of the answers to query
        Returns:
            dict[int, dict] - {answer_id: {"owner_id": int | None, "question_uuid": int | None, "creation_date": int}}
        """
        results = {}
        chunks = self.chunk_ids(answer_ids)

        for index, chunk in enumerate(chunks):
            if index > 0:
                time.sleep(0.2)  # throttle

            params = {"site": "stackoverflow"}
            items = self.query_items_batch("answers", chunk, params)

            for item in items:
                answer_id = item.get("answer_id")
                owner = item.get("owner", {})
                owner_id = owner.get("user_id")
                question_uuid = item.get("question_id")
                raw_timestamp = item.get("creation_date")

                logger.debug(f"--- Answer {answer_id} Details ---")
                logger.debug(f"Posted By: {owner.get('display_name')} (User ID: {owner_id})")
                logger.debug(f"Score: {item.get('score')}\n")

                results[answer_id] = {
                    "owner_id": owner_id,
                    "question_uuid": question_uuid,
                    "creation_date": raw_timestamp,
                }

        return results

    def get_comments_info(self, comment_ids: list[int]) -> dict[int, dict]:
        """
        Queries a list of comments and returns a dictionary of information.

        Params:
            comment_ids: list[int] - the IDs of the comments to query
        Returns:
            dict[int, dict] - {comment_id: {"owner_id": int | None, "post_id": int, "post_type": str}}
        """
        results = {}
        chunks = self.chunk_ids(comment_ids)

        for index, chunk in enumerate(chunks):
            if index > 0:
                time.sleep(1)  # throttle

            params = {"site": "stackoverflow"}
            items = self.query_items_batch("comments", chunk, params)

            for item in items:
                comment_id = item.get("comment_id")
                owner = item.get("owner", {})
                owner_id = owner.get("user_id")
                raw_timestamp = item.get("creation_date")

                logger.debug(f"--- Comment {comment_id} Details ---")
                logger.debug(f"Posted By: {owner.get('display_name')} (User ID: {owner_id})")
                logger.debug(f"Score: {item.get('score')}\n")

                results[comment_id] = {"owner_id": owner_id, "creation_date": raw_timestamp}

        return results


if __name__ == "__main__":
    # example for testing functionality
    sample_question_id = [65697972]
    sample_answer_id = [69272967]
    sample_comment_id = [122336972]

    stackoverflowAPI = StackOverflowAPI("DEBUG")
    stackoverflowAPI.get_questions_info(sample_question_id)
    stackoverflowAPI.get_answers_info(sample_answer_id)
    stackoverflowAPI.get_comments_info(sample_comment_id)
