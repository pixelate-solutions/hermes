from redis import Redis
from rq import Queue

from app.core.config import get_settings


QUEUE_NAME = "lead_jobs"


def get_queue() -> Queue:
    settings = get_settings()
    connection = Redis.from_url(settings.redis_url)
    return Queue(QUEUE_NAME, connection=connection)
