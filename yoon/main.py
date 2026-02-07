from __future__ import annotations

from datetime import datetime, timezone
from typing import Dict, List, Optional, Any
from uuid import uuid4

import httpx
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

from config import settings

app = FastAPI(title="SensorSquad Main Server (MVP)", version="0.2.0")

# -----------------------------
# Config (from .env via config.py)
# -----------------------------
ALLOWED_LEVELS = settings.allowed_levels
TOP_LEVEL = settings.top_level

PUSH_SERVER_URL = settings.push_server_url
PUSH_TIMEOUT_SEC = settings.push_timeout_sec
PUSH_COOLDOWN_SEC = settings.push_cooldown_sec

# -----------------------------
# In-memory "DB" (DB 붙기 전 MVP)
# -----------------------------
BIN_STATUS: Dict[str, Dict[str, Any]] = {}
BIN_EVENTS: List[Dict[str, Any]] = []

# -----------------------------
# Schemas
# -----------------------------
class ReportRequest(BaseModel):
    bin_id: str = Field(..., min_length=1, max_length=64)
    level: str = Field(..., min_length=1, max_length=32)
    ts: Optional[str] = None  # 라즈베리파이에서 보내면 저장, 없어도 됨


class ReportResponse(BaseModel):
    ok: bool
    bin_id: str
    level: str
    prev_level: Optional[str]
    notified: bool
    updated_at: str


class BinStatusItem(BaseModel):
    bin_id: str
    level: str
    last_seen_at: str
    updated_at: str


class BinDetailResponse(BaseModel):
    bin_id: str
    level: str
    last_seen_at: str
    updated_at: str
    recent_events: List[dict]


# -----------------------------
# Helpers
# -----------------------------
def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def normalize_level(level: str) -> str:
    return (level or "").strip().lower()


def validate_level(level: str) -> None:
    if level not in ALLOWED_LEVELS:
        raise HTTPException(
            status_code=400,
            detail=f"level must be one of {sorted(ALLOWED_LEVELS)}"
        )


def should_notify(prev_level: Optional[str], new_level: str, last_push_at_iso: Optional[str]) -> bool:
    # 규칙: 최상단 진입할 때만 푸시
    entered_top = (new_level == TOP_LEVEL) and (prev_level != TOP_LEVEL)
    if not entered_top:
        return False

    # 쿨다운(옵션): 최상단 재진입이 매우 잦은 환경에서 안전장치
    if last_push_at_iso:
        try:
            last_push_at = datetime.fromisoformat(last_push_at_iso)
            elapsed = (datetime.now(timezone.utc) - last_push_at).total_seconds()
            if elapsed < PUSH_COOLDOWN_SEC:
                return False
        except Exception:
            # last_push_at 파싱이 실패하면 보수적으로 푸시를 막지 않고 진행할 수도 있는데,
            # 여기서는 "쿨다운 판단 실패"는 무시(푸시 허용)로 둠.
            pass

    return True


async def call_push_server(bin_id: str, level: str) -> None:
    payload = {"bin_id": bin_id, "level": level}

    async with httpx.AsyncClient(timeout=PUSH_TIMEOUT_SEC) as client:
        r = await client.post(PUSH_SERVER_URL, json=payload)
        if r.status_code >= 400:
            raise HTTPException(status_code=502, detail=f"push server error: {r.text}")


def add_event(bin_id: str, event_type: str, payload: dict) -> None:
    BIN_EVENTS.append({
        "id": str(uuid4()),
        "bin_id": bin_id,
        "event_type": event_type,
        "payload": payload,
        "created_at": now_iso()
    })


# -----------------------------
# Routes
# -----------------------------
@app.get("/health")
def health():
    return {
        "ok": True,
        "allowed_levels": sorted(ALLOWED_LEVELS),
        "top_level": TOP_LEVEL,
        "push_server_url": PUSH_SERVER_URL
    }


@app.post("/api/v1/report", response_model=ReportResponse)
async def report(req: ReportRequest):
    level = normalize_level(req.level)
    validate_level(level)

    bin_id = req.bin_id.strip()
    received_at = now_iso()

    prev = BIN_STATUS.get(bin_id)
    prev_level = prev["level"] if prev else None

    # 수신 이벤트 기록
    add_event(bin_id, "report_received", {"level": level, "ts": req.ts, "received_at": received_at})

    # 최신 상태 갱신 준비
    last_seen_at = req.ts or received_at
    updated_at = received_at

    # 푸시 조건 판단
    last_push_at = prev.get("last_push_at") if prev else None
    notified = should_notify(prev_level, level, last_push_at)

    # 먼저 상태 저장(푸시 실패해도 상태는 반영되게)
    BIN_STATUS[bin_id] = {
        "bin_id": bin_id,
        "level": level,
        "last_seen_at": last_seen_at,
        "updated_at": updated_at,
        "last_push_at": last_push_at,
    }

    # 푸시 발송 (최상단 진입일 때만)
    if notified:
        await call_push_server(bin_id, level)
        BIN_STATUS[bin_id]["last_push_at"] = now_iso()
        add_event(bin_id, "push_sent", {"level": level})

    return ReportResponse(
        ok=True,
        bin_id=bin_id,
        level=level,
        prev_level=prev_level,
        notified=notified,
        updated_at=updated_at
    )


@app.get("/api/v1/bins", response_model=List[BinStatusItem])
def list_bins():
    items: List[BinStatusItem] = []
    for bin_id, st in BIN_STATUS.items():
        items.append(BinStatusItem(
            bin_id=bin_id,
            level=st["level"],
            last_seen_at=st["last_seen_at"],
            updated_at=st["updated_at"]
        ))

    # 최근 업데이트 순 정렬(선택)
    items.sort(key=lambda x: x.updated_at, reverse=True)
    return items


@app.get("/api/v1/bins/{bin_id}", response_model=BinDetailResponse)
def get_bin(bin_id: str, limit_events: int = 20):
    st = BIN_STATUS.get(bin_id)
    if not st:
        raise HTTPException(status_code=404, detail="bin not found")

    # 최근 이벤트 N개
    limit_events = max(0, min(limit_events, 200))
    recent = [e for e in reversed(BIN_EVENTS) if e["bin_id"] == bin_id][:limit_events]

    return BinDetailResponse(
        bin_id=bin_id,
        level=st["level"],
        last_seen_at=st["last_seen_at"],
        updated_at=st["updated_at"],
        recent_events=recent
    )


@app.get("/api/v1/events")
def list_events(limit: int = 200):
    limit = max(1, min(limit, 1000))
    return list(reversed(BIN_EVENTS))[:limit]
