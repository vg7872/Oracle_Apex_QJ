DECLARE
    vId             NUMBER;
    vFileName       VARCHAR2(255);
    vRowCount       NUMBER := 0;
    vUser_Name      VARCHAR2(255);
    vCateGory       VARCHAR2(5);
    v_new_id        NUMBER;

    v_err_num       VARCHAR2(50);
    v_err_msg       VARCHAR2(150);

    -- Error Log
    PROCEDURE log_error(p_num VARCHAR2, p_msg VARCHAR2) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO XX_APEX_ERROR_LOG (
            LOG_ID,
            PACKAGE_NAME,
            DETAILS,
            CREATED_BY,
            CREATED_DT,
            ERROR_NUM,
            ERROR_MSG
        ) VALUES (
            (SELECT NVL(MAX(LOG_ID), 0) + 1 FROM XX_APEX_ERROR_LOG),
            'BUDGET_FORM',
            'Excel Import: ' || vFileName,
            :APP_USER,
            SYSDATE,
            p_num,
            p_msg
        );
        COMMIT;
    END;

BEGIN
    APEX_DEBUG.MESSAGE('SAVE PROCESS START');

    -- Init
    vFileName  := :P892_BROWS;
    vCateGory  := :P892_CATEGORY;
    vUser_Name := UPPER(:P0_USER_NAME);

    -- Validation
    IF vCateGory IS NULL THEN
        APEX_ERROR.ADD_ERROR (
            p_message => 'Please Select Category',
            p_display_location => apex_error.c_inline_in_notification
        );
        RETURN;
    END IF;

    -- 👉 Debug
    :P892_MESSAGE := 'Selected rows: ' || apex_application.g_f01.COUNT;

    -- 👉 If nothing selected
    IF apex_application.g_f01.COUNT = 0 THEN
        APEX_ERROR.ADD_ERROR (
            p_message => 'Please select at least one row',
            p_display_location => apex_error.c_inline_in_notification
        );
        RETURN;
    END IF;

    -- 👉 Lock table
    LOCK TABLE XXREN_MKT_EXPENSE_BUDGET IN EXCLUSIVE MODE;

    -- 👉 Get current max ID
    SELECT NVL(MAX(BUDGET_ID),0)
    INTO v_new_id
    FROM XXREN_MKT_EXPENSE_BUDGET;

    -- 👉 LOOP FIXED (IMPORTANT)
    FOR i IN 1 .. apex_application.g_f01.COUNT LOOP

        vId := TO_NUMBER(apex_application.g_f01(i));

        FOR rec IN (
            SELECT
                C001 AS BRAND,
                C002 AS BUDGETED_EXP_NATURE,
                C003 AS BUD_AMOUNT
            FROM APEX_COLLECTIONS
            WHERE COLLECTION_NAME = 'XL'
            AND SEQ_ID = vId
        )
        LOOP
            BEGIN
                v_new_id := v_new_id + 1;

                INSERT INTO XXREN_MKT_EXPENSE_BUDGET (
                    BRAND,
                    BUDGETED_EXP_NATURE,
                    BUD_AMOUNT,
                    BUSINESS_CODE,
                    DEPARTMENT_CODE,
                    DEPARTMENT,
                    BUSINESS_TAG,
                    BUDGET_ID
                ) VALUES (
                    rec.BRAND,
                    rec.BUDGETED_EXP_NATURE,
                    TO_NUMBER(rec.BUD_AMOUNT DEFAULT 0 ON CONVERSION ERROR),
                    '1101',
                    '351',
                    'Marketing',
                    'Pharmaceutical Business',
                    v_new_id
                );

                vRowCount := vRowCount + 1;

            EXCEPTION
                WHEN OTHERS THEN
                    log_error(SQLCODE, 'SEQ_ID='||vId||' -> '||SQLERRM);
            END;
        END LOOP;

    END LOOP;

    COMMIT;

    :P892_MESSAGE := '✔ Total rows inserted: ' || vRowCount;

    -- Clear collection
    IF APEX_COLLECTION.COLLECTION_EXISTS('XL') THEN
        APEX_COLLECTION.TRUNCATE_COLLECTION('XL');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        v_err_num := SQLCODE;
        v_err_msg := SUBSTR(SQLERRM, 1, 150);

        ROLLBACK;
        log_error(v_err_num, v_err_msg);

        :P892_MESSAGE := 'Error: ' || v_err_msg;
END;