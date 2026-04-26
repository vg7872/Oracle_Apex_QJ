DECLARE
BEGIN
    -- Clear collection
    IF APEX_COLLECTION.COLLECTION_EXISTS('XL') THEN
        APEX_COLLECTION.TRUNCATE_COLLECTION('XL');
    ELSE
        APEX_COLLECTION.CREATE_COLLECTION('XL');
    END IF;

    -- Parse Excel file
    FOR rec IN (
        SELECT *
        FROM TABLE(
            APEX_DATA_PARSER.PARSE(
                p_content => (SELECT blob_content
                              FROM apex_application_temp_files
                              WHERE name = :P892_BROWS),
                p_file_name => :P892_BROWS
            )
        )
    )
    LOOP
        -- Skip header row
        IF rec.line_number > 1 THEN
            APEX_COLLECTION.ADD_MEMBER(
                p_collection_name => 'XL',
                p_c001 => rec.col001,
                p_c002 => rec.col002,
                p_c003 => rec.col003
            );
        END IF;
    END LOOP;
END;