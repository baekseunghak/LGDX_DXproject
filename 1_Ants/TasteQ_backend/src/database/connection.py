# src/database/connection.py
import pymysql
import os
from dotenv import load_dotenv

load_dotenv()

print("[DEBUG] MYSQL_HOST:", os.getenv("MYSQL_HOST"))  # 이 줄 추가

def get_connection():
    return pymysql.connect(
        host=os.getenv("MYSQL_HOST"),
        port=int(os.getenv("MYSQL_PORT", 3307)),
        user=os.getenv("MYSQL_USER"),
        password=os.getenv("MYSQL_PW"),
        database=os.getenv("MYSQL_DB"),
        cursorclass=pymysql.cursors.DictCursor
    )