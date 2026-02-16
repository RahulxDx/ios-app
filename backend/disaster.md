# 🚨 Disaster Recovery Plan
Stellantis Dealer Hygiene Backend

---

## 1️⃣ Infrastructure Overview

### Primary Region
- Public IP: http://13.221.127.254
- Health Endpoint: http://13.221.127.254/health

### Secondary Region (Warm Standby)
- Public IP: http://13.201.56.162
- Health Endpoint: http://13.201.56.162/health

Both regions run:
- FastAPI backend
- Gunicorn service
- Nginx reverse proxy
- Identical application version

---

## 2️⃣ Health Monitoring (MANDATORY)

The following endpoints MUST be checked regularly:

Primary:
http://13.221.127.254/health

Secondary:
http://13.201.56.162/health

Expected Response:
{
"status": "ok"
}

If the endpoint does not return HTTP 200 with valid JSON,
the instance should be considered unhealthy.

---

## 3️⃣ Monitoring Procedure

Health checks should be performed:

- Daily (manual verification)
- Before major demo or release
- After any deployment
- If application behaves abnormally

Optional (Recommended):
Create a small monitoring script to ping /health every 5 minutes.

Example:

```bash
curl http://13.221.127.254/health
