"""
title: Limit Max Tokens Filter Pipeline
author: parzival-space
date: 2026-01-22
version: 1.0
license: MIT
description: A filter pipeline that limits the max tokens in the request body.
requirements: requests
"""

from typing import List, Optional
from pydantic import BaseModel
from schemas import OpenAIChatMessage
import os

class Pipeline:
    class Valves(BaseModel):
        # List target pipeline ids (models) that this filter will be connected to.
        # If you want to connect this filter to all pipelines, you can set pipelines to ["*"]
        pipelines: List[str] = []

        # Assign a priority level to the filter pipeline.
        # The priority level determines the order in which the filter pipelines are executed.
        # The lower the number, the higher the priority.
        priority: int = 0

        # The maximum allowed tokens to be set in the request body.
        # Users that set a higher value will be capped to this value.
        max_allowed_tokens: int = 128
        pass

    def __init__(self):
        self.type = "filter"
        self.name = "Filter"

        self.valves = self.Valves(**{
            "pipelines": os.getenv("TOKEN_LIMIT_PIPELINES", "*").split(","),
            "max_allowed_tokens":  int(
                os.getenv("TOKEN_LIMIT_MAX_TOKENS", 128)
            ),
        })
        pass

    async def on_startup(self):
        pass

    async def on_shutdown(self):
        pass

    async def inlet(self, body: dict, user: Optional[dict] = None) -> dict:
        # If max_tokens is not provided or is None, set it to the max_allowed_tokens.
        if "max_tokens" not in body or body.get("max_tokens") is None:
            body["max_tokens"] = self.valves.max_allowed_tokens
        else:
            # Try to coerce to int; if that fails, default to max_allowed_tokens.
            try:
                current = int(body.get("max_tokens"))
            except (TypeError, ValueError):
                current = self.valves.max_allowed_tokens
                body["max_tokens"] = current

            # If the provided value exceeds the maximum, cap it.
            if current > self.valves.max_allowed_tokens:
                body["max_tokens"] = self.valves.max_allowed_tokens

        return body
