CREATE TABLE LOG_TABLE (
    USERID NUMBER,
    TIMESTAMP DATE,
    MESSAGE VARCHAR2(200),
    CONSTRAINT FK_LOG_USERS FOREIGN KEY (USERID) REFERENCES USERS(USERID)
);