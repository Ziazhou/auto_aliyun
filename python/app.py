from fastapi import FastAPI, HTTPException
import mysql.connector
from contextlib import contextmanager

app = FastAPI()

DB_CONFIG = {
    "host": "mysql",
    "user": "appuser",
    "password": "AppUser123@vue",
    "database": "vueapp"
}

@contextmanager
def get_db():
    conn = mysql.connector.connect(**DB_CONFIG)
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()

@app.get("/")
def root():
    return {"message": "Python API运行正常"}

@app.get("/api/health")
def health_check():
    try:
        with get_db() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT 1")
            cursor.fetchone()
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Database error: {str(e)}")

@app.get("/api/data")
def get_data():
    try:
        with get_db() as conn:
            cursor = conn.cursor(dictionary=True)
            cursor.execute("SHOW TABLES;")
            tables = cursor.fetchall()
        return {"tables": tables}
    except Exception as e:
        return {"error": str(e), "message": "请先在MySQL中创建表"}