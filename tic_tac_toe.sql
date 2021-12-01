DROP TABLE tic_tac_toe;

CREATE TABLE tic_tac_toe (
    id   INTEGER CHECK ( id IN ( 1, 2, 3 ) ) NOT NULL,
    col1 CHAR(1) CHECK ( col1 IN ( 'Y', 'N' ) ),
    col2 CHAR(1) CHECK ( col2 IN ( 'Y', 'N' ) ),
    col3 CHAR(1) CHECK ( col3 IN ( 'Y', 'N' ) )
);

EXEC p_reset();

SET SERVEROUTPUT ON;
BEGIN
    -- @player - 1/2
    -- x - X coordinate
    -- y - Y coordinate
    p_my_turn(1, 3, 3);
   
END;
/

 -- to reset the game
 EXEC p_reset();
    
CREATE OR REPLACE PROCEDURE p_reset AS
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE tic_tac_toe';
    INSERT INTO tic_tac_toe (
        id,
        col1,
        col2,
        col3
    ) VALUES (
        1,
        NULL,
        NULL,
        NULL
    );

    INSERT INTO tic_tac_toe (
        id,
        col1,
        col2,
        col3
    ) VALUES (
        2,
        NULL,
        NULL,
        NULL
    );

    INSERT INTO tic_tac_toe (
        id,
        col1,
        col2,
        col3
    ) VALUES (
        3,
        NULL,
        NULL,
        NULL
    );

END;
/


CREATE OR REPLACE PROCEDURE p_my_turn (
    play          NUMBER,
    x             NUMBER,
    y             NUMBER
) AS
    if_already_exists NUMBER;
    player_symbol     CHAR;
    c_records sys_refcursor;
BEGIN
    IF play = 1 THEN
        player_symbol := 'Y';
    ELSE
        player_symbol := 'N';
    END IF;

    SELECT
        CASE
            WHEN (
                SELECT
                    CASE
                        WHEN y = 1 THEN
                            col1
                        WHEN y = 2 THEN
                            col2
                        ELSE
                            col3
                    END
                FROM
                    tic_tac_toe
                WHERE
                    id = x
            ) IS NULL THEN
                1
            ELSE
                0
        END
    INTO if_already_exists
    FROM
        dual;

    IF if_already_exists = 1 THEN
        IF y = 1 THEN
            UPDATE tic_tac_toe
            SET
                col1 = player_symbol
            WHERE
                id = x;

        ELSIF y = 2 THEN
            UPDATE tic_tac_toe
            SET
                col2 = player_symbol
            WHERE
                id = x;

        ELSIF y = 3 THEN
            UPDATE tic_tac_toe
            SET
                col3 = player_symbol
            WHERE
                id = x;

        ELSE
            raise_application_error(-20000, 'Invalid input!!');
        END IF;

        COMMIT;
        
        open c_records for SELECT * FROM tic_tac_toe;
        dbms_sql.return_result(c_records);
        p_check_valid(play);
        
    ELSE
        raise_application_error(-20001, 'The box is already played before!!');
    END IF;

END;
/

CREATE OR REPLACE PROCEDURE p_check_valid (
    play NUMBER
) AS

    row1   tic_tac_toe%rowtype;
    row2   tic_tac_toe%rowtype;
    row3   tic_tac_toe%rowtype;
    play11 CHAR;
    play12 CHAR;
    play13 CHAR;
    play21 CHAR;
    play22 CHAR;
    play23 CHAR;
    play31 CHAR;
    play32 CHAR;
    play33 CHAR;
BEGIN
    SELECT
        *
    INTO row1
    FROM
        tic_tac_toe
    WHERE
        id = 1;

    SELECT
        *
    INTO row2
    FROM
        tic_tac_toe
    WHERE
        id = 2;

    SELECT
        *
    INTO row3
    FROM
        tic_tac_toe
    WHERE
        id = 3;

    play11 := row1.col1;
    play12 := row1.col2;
    play13 := row1.col3;
    play21 := row2.col1;
    play22 := row2.col2;
    play23 := row2.col3;
    play31 := row3.col1;
    play32 := row3.col2;
    play33 := row3.col3;
    IF ( (
        play11 = play12
        AND play12 = play13
        AND play11 = play13
    ) OR (
        play21 = play22
        AND play22 = play23
        AND play21 = play23
    ) OR (
        play31 = play32
        AND play32 = play33
        AND play31 = play33
    ) OR (
        play11 = play21
        AND play21 = play31
        AND play11 = play31
    ) OR (
        play12 = play22
        AND play22 = play32
        AND play12 = play32
    ) OR (
        play13 = play23
        AND play23 = play33
        AND play13 = play33
    ) OR (
        play11 = play22
        AND play22 = play33
        AND play33 = play11
    ) OR (
        play13 = play22
        AND play22 = play31
        AND play13 = play31
    ) ) THEN
        dbms_output.put_line('Player '
                             || play
                             || ' won!');
        p_reset();
    END IF;

END;
/

