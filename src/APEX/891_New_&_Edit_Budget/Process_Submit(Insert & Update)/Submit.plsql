DECLARE
BEGIN

    --  NEW INSERT
    IF :P891_BUDGET_ID IS NULL THEN

        SELECT NVL(MAX(BUDGET_ID),0) + 1
        INTO :P891_BUDGET_ID
        FROM XXREN_MKT_EXPENSE_BUDGET;

        INSERT INTO XXREN_MKT_EXPENSE_BUDGET (
            BUDGET_ID,
            BRAND,
            BUDGETED_EXP_NATURE,
            BUD_AMOUNT,
            BUSINESS_CODE,
            DEPARTMENT_CODE,
            DEPARTMENT,
            BUSINESS_TAG
        ) VALUES (
            :P891_BUDGET_ID,
            :P891_BRAND,
            :P891_BUDGETED_EXP_NATURE,
            :P891_BUD_AMOUNT,
            :P891_BUSINESS_CODE,
            :P891_DEPARTMENT_CODE,
            :P891_DEPARTMENT,
            :P891_BUSINESS_TAG
        );

        apex_application.g_print_success_message := 'New Budget Saved Successfully...';

    ELSE
        --  UPDATE
        UPDATE XXREN_MKT_EXPENSE_BUDGET
        SET
            BRAND = :P891_BRAND,
            BUDGETED_EXP_NATURE = :P891_BUDGETED_EXP_NATURE,
            BUD_AMOUNT = :P891_BUD_AMOUNT
        WHERE BUDGET_ID = :P891_BUDGET_ID;

        apex_application.g_print_success_message := 'Budget Updated Successfully...';
    END IF;

END;