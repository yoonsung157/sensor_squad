from __future__ import annotations

import os
from dataclasses import dataclass, field
from pathlib import Path

from dotenv import load_dotenv

# 프로젝트 루트 기준으로 .env 로드
BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR / ".env")


def _get_env_str(name: str, default: str) -> str:
    return os.getenv(name, default).strip()


def _get_env_int(name: str, default: int) -> int:
    v = os.getenv(name, str(default)).strip()
    return int(v)


def _get_env_float(name: str, default: float) -> float:
    v = os.getenv(name, str(default)).strip()
    return float(v)


def _parse_levels(csv: str) -> set[str]:
    # "low,middle,high" -> {"low","middle","high"}
    return {x.strip().lower() for x in csv.split(",") if x.strip()}


def _get_levels(name: str, default_csv: str) -> set[str]:
    raw = _get_env_str(name, default_csv)
    return _parse_levels(raw)


@dataclass(frozen=True)
class Settings:
    # Main server
    main_host: str = field(default_factory=lambda: _get_env_str("MAIN_HOST", "0.0.0.0"))
    main_port: int = field(default_factory=lambda: _get_env_int("MAIN_PORT", 7000))

    # Level policy (⚠️ set은 default_factory로!)
    allowed_levels: set[str] = field(default_factory=lambda: _get_levels("ALLOWED_LEVELS", "low,middle,high"))
    top_level: str = field(default_factory=lambda: _get_env_str("TOP_LEVEL", "high").lower())

    # Push server
    push_server_url: str = field(default_factory=lambda: _get_env_str("PUSH_SERVER_URL", "http://127.0.0.1:6000/push"))
    push_timeout_sec: float = field(default_factory=lambda: _get_env_float("PUSH_TIMEOUT_SEC", 3.0))
    push_cooldown_sec: int = field(default_factory=lambda: _get_env_int("PUSH_COOLDOWN_SEC", 60))


settings = Settings()
