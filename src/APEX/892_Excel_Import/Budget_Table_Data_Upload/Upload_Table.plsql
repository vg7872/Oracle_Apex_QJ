-- SELECT
--     seq_id AS seq,
--     APEX_ITEM.CHECKBOX(1, seq_id) AS "SELECT",

--     C001 AS BRAND,
--     C002 AS BUDGETED_EXP_NATURE,
--     C003 AS BUD_AMOUNT

-- FROM APEX_COLLECTIONS
-- WHERE COLLECTION_NAME = 'XL'
-- ORDER BY seq_id;

-------------------------------------------------------------------------------------------


SELECT
    seq_id AS SEQ,

    APEX_ITEM.CHECKBOX(1, seq_id, 'CHECKED') AS "SELECT",

    C001 AS BRAND,
    C002 AS BUDGETED_EXP_NATURE,
    TO_NUMBER(C003 DEFAULT 0 ON CONVERSION ERROR) AS BUD_AMOUNT

FROM APEX_COLLECTIONS
WHERE COLLECTION_NAME = 'XL'
ORDER BY seq_id;