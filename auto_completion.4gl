CONSTANT COMPLETER_LIST_SIZE = 50 -- maximum size of completer list

MAIN
    DEFINE rec RECORD
        country STRING,
        country2 STRING,
        minimum_completer_length INTEGER,
        autoset BOOLEAN,
        countries STRING,
        iata_code_c3 CHAR(3),
        iata_code STRING
    END RECORD

    DEFINE airport RECORD
        code CHAR(3),
        name CHAR(60),
        city CHAR(60),
        country CHAR(60)
    END RECORD

    DEFINE i INTEGER
    DEFINE prefix STRING
    DEFINE filter STRING
    DEFINE completer_list DYNAMIC ARRAY OF STRING
    DEFINE w ui.Window
    DEFINE f ui.Form

    DEFINE country_name CHAR(50)

    OPTIONS INPUT WRAP

    CALL ui.Interface.loadStyles("auto_completion")

    CONNECT TO ":memory:+driver='dbmsqt'"

    CALL init_database()
    DECLARE country_curs CURSOR FROM SFMT("SELECT name FROM country WHERE UPPER(name) LIKE UPPER(?) ORDER BY name LIMIT %1",
        COMPLETER_LIST_SIZE)
    DECLARE airport_curs CURSOR FROM SFMT("SELECT iata_code, name, city, country FROM airport WHERE iata_code IS NOT NULL AND (iata_code LIKE ? OR UPPER(name) LIKE ? OR UPPER(city) LIKE ? OR UPPER(country) LIKE ?) ORDER BY iata_code LIMIT %1",
        COMPLETER_LIST_SIZE)

    CLOSE WINDOW SCREEN
    OPEN WINDOW w WITH FORM "auto_completion"
    LET w = ui.Window.getCurrent()
    LET f = w.getForm()

    LET rec.autoset = TRUE
    LET rec.minimum_completer_length = 2

    INPUT BY NAME rec.country,
        rec.country2,
        rec.minimum_completer_length,
        rec.autoset,
        rec.countries,
        rec.iata_code_c3,
        rec.iata_code
        ATTRIBUTES(UNBUFFERED, WITHOUT DEFAULTS = TRUE)

        ON CHANGE country
            -- A bare bones simple example
            CALL completer_list.clear()
            LET filter = fgl_dialog_getbuffer()
            LET filter = filter, "%"
            OPEN country_curs USING filter
            FOR i = 1 TO COMPLETER_LIST_SIZE
                FETCH country_curs INTO country_name
                IF status = NOTFOUND THEN
                    EXIT FOR
                END IF
                LET completer_list[i] = country_name CLIPPED
            END FOR
            CALL DIALOG.setCompleterItems(completer_list)

        ON CHANGE country2
            -- A more complex examnple that includes ...
            --     a minimum number of characters entered before setting the value
            --     if list only has 1 item, select it
            --     change background color of field if value entered
            CALL completer_list.clear()
            LET filter = fgl_dialog_getbuffer()
            IF filter.getLength() >= rec.minimum_completer_length THEN
                LET filter = filter, "%" -- What user is currently typing is in the buffer, add % for LIKE
                OPEN country_curs USING filter
                FOR i = 1 TO COMPLETER_LIST_SIZE
                    FETCH country_curs INTO country_name
                    IF status = NOTFOUND THEN
                        EXIT FOR
                    END IF
                    LET completer_list[i] = country_name CLIPPED
                END FOR

                IF rec.autoset AND completer_list.getLength() = 1 THEN
                    -- If autoset enabled and there is one value, set the value and move to next field
                    LET rec.country2 = completer_list[1]
                    CALL DIALOG.setCompleterItems(NULL)
                    CALL f.setFieldStyle("country2", "green")
                    NEXT FIELD NEXT
                ELSE
                    -- Display the list
                    CALL DIALOG.setCompleterItems(completer_list)
                END IF

                -- Change background colour based on number of matching entries
                CASE completer_list.getLength()
                    WHEN 1
                        CALL f.setFieldStyle("country2", "green")
                    WHEN 0
                        CALL f.setFieldStyle("country2", "red")
                    OTHERWISE
                        CALL f.setFieldStyle("country2", "")
                END CASE
            ELSE
                CALL DIALOG.setCompleterItems(NULL)
                CALL f.setFieldStyle("country2", "")
            END IF

        ON CHANGE countries
            -- Example using tagedit widget available in late Genero 5 GBC for selecting multiple values from proposals
            CALL completer_list.clear()
            LET filter = fgl_dialog_getbuffer()

            CALL split_on_last_semi_colon(filter) RETURNING prefix, filter
            IF filter.getLength() >= 1 THEN
                LET filter = filter, "%"
                OPEN country_curs USING filter
                FOR i = 1 TO COMPLETER_LIST_SIZE
                    FETCH country_curs INTO country_name
                    IF status = NOTFOUND THEN
                        EXIT FOR
                    END IF
                    IF prefix.getLength() > 0 THEN
                        LET completer_list[i] = SFMT("%1;%2;", prefix, country_name CLIPPED)
                    ELSE
                        LET completer_list[i] = SFMT("%1;", country_name CLIPPED)
                    END IF
                END FOR

                CALL DIALOG.setCompleterItems(completer_list)
            ELSE
                CALL DIALOG.setCompleterItems(NULL)
            END IF

        ON CHANGE iata_code
            -- An example showing a way to code the key/label pattern
            CALL completer_list.clear()
            LET filter = fgl_dialog_getbuffer()
            LET filter = "%", filter, "%"
            OPEN airport_curs USING filter, filter, filter, filter
            FOR i = 1 TO COMPLETER_LIST_SIZE
                FETCH airport_curs INTO airport.code, airport.name, airport.city, airport.country
                IF status = NOTFOUND THEN
                    EXIT FOR
                END IF
                -- If code is going into the database, important that it is first
                LET completer_list[i] =
                    SFMT("%1 (%2, %3, %4)", airport.code, airport.name CLIPPED, airport.city CLIPPED, airport.country CLIPPED)
            END FOR

            CALL DIALOG.setCompleterItems(completer_list)

        AFTER FIELD iata_code
            --Save current value to working copy
            LET rec.iata_code_c3 = rec.iata_code.subString(1, 3)

        ON ACTION current_value ATTRIBUTES(TEXT = "Current Value")
            LET rec.iata_code_c3 = rec.iata_code.subString(1, 3)
            CALL FGL_WINMESSAGE(
                "Info",
                SFMT("Simple country value = %1\nCurrent country value = %2\nCountries value= %3\nCurrent IATA code value = %4\nCurrent IATA Code value truncated to CHAR(3) = %4",
                    rec.country, rec.country2, rec.countries, rec.iata_code, rec.iata_code_c3),
                "info")
    END INPUT
END MAIN

FUNCTION init_database()

    CREATE TABLE country(name CHAR(50))

    CREATE TABLE airport(
        airport_id INTEGER,
        name VARCHAR(255),
        city VARCHAR(255),
        country VARCHAR(255),
        iata_code CHAR(3),
        icao_code CHAR(4),
        lat DECIMAL(9, 4),
        lng DECIMAL(9, 4),
        alt SMALLINT,
        tz SMALLINT,
        dst CHAR(1),
        tz_olson VARCHAR(255));

    LOAD FROM "country.dat" DELIMITER "," INSERT INTO country
    LOAD FROM "airports.dat" DELIMITER "," INSERT INTO airport
END FUNCTION

FUNCTION split_on_last_semi_colon(s STRING) RETURNS(STRING, STRING)
    DEFINE l_pos, l_last_pos INTEGER
    DEFINE
        s1 STRING,
        s2 STRING

    LET l_pos = 0
    WHILE TRUE
        LET l_last_pos = l_pos
        LET l_pos = s.getIndexOf(";", l_pos + 1)
        IF l_pos > 0 THEN
            CONTINUE WHILE
        ELSE
            LET s1 = s.subString(1, l_last_pos - 1)
            LET s2 = s.subString(l_last_pos + 1, s.getLength())
            EXIT WHILE
        END IF
    END WHILE
    RETURN s1, s2
END FUNCTION
