DEFINE m_country_cursor_prepared BOOLEAN
DEFINE m_airport_cursor_prepared BOOLEAN
CONSTANT COMPLETER_LIST_SIZE=50       -- maximum size of completer list
CONSTANT MINIMUM_COMPLETER_LENGTH=2   -- minimum characters to be entered

MAIN
DEFINE country STRING
DEFINE iata_code STRING -- NOT CHAR(3)???
DEFINE iata_code_c3 CHAR(3)
DEFINE airport RECORD
    code CHAR(3),
    name CHAR(40),
    city CHAR(40),
    country CHAR(40)
END RECORD
DEFINE autoset BOOLEAN

DEFINE i INTEGER
DEFINE filter STRING
DEFINE completer_list DYNAMIC ARRAY OF STRING
DEFINE w ui.Window
DEFINE f ui.Form

DEFINE country_name CHAR(50)

    OPTIONS INPUT WRAP

    CALL ui.Interface.LoadStyles("auto_completion")
    
    CONNECT TO ":memory:"
    LET m_country_cursor_prepared = FALSE
    LET m_airport_cursor_prepared = FALSE
    CALL init_database()
    
    CLOSE WINDOW SCREEN
    OPEN WINDOW w WITH FORM "auto_completion"
    LET w = ui.Window.getCurrent()
    LET f= w.getForm()

    INPUT BY NAME country, autoset, iata_code_c3, iata_code ATTRIBUTES(UNBUFFERED, WITHOUT DEFAULTS=TRUE)
        ON CHANGE country
        
            IF NOT m_country_cursor_prepared THEN
                DECLARE country_curs CURSOR FROM SFMT("SELECT name FROM country WHERE UPPER(name) LIKE UPPER(?) ORDER BY name LIMIT %1",COMPLETER_LIST_SIZE)
                LET m_country_cursor_prepared = TRUE
            END IF
          
            -- What user is currently typing is in the buffer, add % for LIKE 
            CALL completer_list.clear()
            LET filter = FGL_DIALOG_GETBUFFER()
            IF filter.getLength() >= MINIMUM_COMPLETER_LENGTH THEN
                LET filter = filter,"%"
                OPEN country_curs USING filter
                FOR i = 1 TO COMPLETER_LIST_SIZE
                    FETCH country_curs INTO country_name
                    IF status = NOTFOUND THEN
                        EXIT FOR
                    END IF
                    LET completer_list[i] = country_name CLIPPED
                END FOR
                
                IF autoset AND completer_list.getLength() = 1 THEN
                    -- If autoset enabled and there is one value, set the value and move to next field
                    LET country = completer_list[1]
                    CALL DIALOG.setCompleterItems(NULL)
                    CALL f.setfieldstyle("country","green")
                    NEXT FIELD NEXT
                ELSE
                    -- Display the list
                    CALL DIALOG.setCompleterItems(completer_list)
                END IF
                
                -- Change background colour based on number of matching entries
                CASE completer_list.getLength()
                    WHEN 1 CALL f.setfieldstyle("country","green")
                    WHEN 0 CALL f.setfieldstyle("country","red")
                    OTHERWISE CALL f.setfieldstyle("country","")
                END CASE
            ELSE
                CALL DIALOG.setCompleterItems(NULL)
                CALL f.setfieldstyle("country","")
            END IF
            
        ON CHANGE iata_code
            IF NOT m_airport_cursor_prepared THEN
                DECLARE airport_curs CURSOR FROM SFMT("SELECT iata_code, name, city, country FROM airport WHERE iata_code IS NOT NULL AND (iata_code LIKE ? OR UPPER(name) LIKE ? OR UPPER(city) LIKE ? OR UPPER(country) LIKE ?) ORDER BY iata_code LIMIT %1",COMPLETER_LIST_SIZE)
                LET m_airport_cursor_prepared = TRUE
            END IF
          
            -- What user is currently typing is in the buffer, add % for LIKE 
            CALL completer_list.clear()
            LET filter = FGL_DIALOG_GETBUFFER()
            IF filter.getLength() >= MINIMUM_COMPLETER_LENGTH THEN
                LET filter = filter,"%"
                OPEN airport_curs USING filter, filter, filter, filter
                FOR i = 1 TO COMPLETER_LIST_SIZE
                    FETCH airport_curs INTO airport.code, airport.name, airport.city, airport.country 
                    IF status = NOTFOUND THEN
                        EXIT FOR
                    END IF
                    -- If code is going into the database, important that it is first
                    LET completer_list[i] = SFMT("%1 (%2, %3, %4)", airport.code, airport.name CLIPPED, airport.city CLIPPED, airport.country CLIPPED)
                END FOR
                
                CALL DIALOG.setCompleterItems(completer_list)
            ELSE
                CALL DIALOG.setCompleterItems(NULL)
            END IF

            --Save current value to working copy
            LET iata_code_c3 = iata_code.subString(1,3)
            
        ON ACTION current_value ATTRIBUTES(TEXT="Current Value")
            CALL FGL_WINMESSAGE("Info",SFMT("Current country value = %1\nCurrent IATA code value = %2\nCurrent IATA Code value truncated to CHAR(3) = %3",country, iata_code, iata_code_c3),"info")
    END INPUT
END MAIN



FUNCTION init_database()

    CREATE TABLE country (name CHAR(50))

    CREATE TABLE airport
    (airport_id INTEGER,
     name VARCHAR(255),
     city VARCHAR(255),
     country VARCHAR(255),
     iata_code CHAR(3),
     icao_code CHAR(4),
     lat DECIMAL(9,4),
     lng DECIMAL(9,4),
     alt SMALLINT,
     tz SMALLINT,
     dst CHAR(1),
     tz_olson VARCHAR(255));

    LOAD FROM "country.dat" DELIMITER "," INSERT INTO country
    LOAD FROM "airports.dat" DELIMITER "," INSERT INTO airport 
END FUNCTION