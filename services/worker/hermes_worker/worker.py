from redis import Redis
from rq import Connection, Worker

from app.core.config import get_settings
from app.core.logging import configure_logging
from app.worker.queue import QUEUE_NAME


configure_logging()
settings = get_settings()


def main() -> None:
    redis_conn = Redis.from_url(settings.redis_url)
    with Connection(redis_conn):
        worker = Worker([QUEUE_NAME])
        worker.work(with_scheduler=False)


if __name__ == "__main__":
    main()
