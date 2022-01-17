'ORIGINAL CODE BY BPLUS FROM QB64 FORUM!

'_TITLE "RACHEL CHATBOT V1.2R" ' B+ started 2019-05-26  post loadArrays test on Script Eliza.txt file
'2019-05-29 post basic getReply$ function of Eliza / Script Player
'2019-05-30 LINE INPUT to allow commas, try isolatePunctuation$ and joinPunction, look like it's working.
'2019-05-31 OK it all seems to be working without all caps and with punctuation.
'2019-06-21 mod by ron77 for Rachel chatbot prototype added TTS with voice.exe TTS command line
'2020-04-01 mod and converted by ron77 to FB #lang"qb"
'2020-04-03 converted to standard FB DIalect - Imortis

CONST punctuation = "?!,.:;<>(){}[]"
DIM SHARED Greeting AS STRING, You AS STRING, Script AS String
DIM SHARED kCnt AS INTEGER, rCnt AS INTEGER, wCnt AS INTEGER, NoKeyFoundIndex AS INTEGER
REDIM SHARED keywords(0) AS STRING, replies(0) AS STRING, wordIn(0) AS STRING, wordOut(0) AS STRING
REDIM SHARED rStarts(0) AS INTEGER, rEnds(0) AS INTEGER, rIndex(0) AS INTEGER
DIM SHARED TTSvoice as String



'append to the string array the string item
SUB sAppend (arr() AS STRING, item AS STRING)
    REDIM Preserve arr(LBOUND(arr) TO UBOUND(arr) + 1) AS STRING
    arr(UBOUND(arr)) = item
END SUB

'append to the integer array the integer item
SUB nAppend (arr() AS INTEGER, item AS INTEGER)
    REDIM Preserve arr(LBOUND(arr) TO UBOUND(arr) + 1) AS INTEGER
    arr(UBOUND(arr)) = item
END SUB

' pull data out of some script file
SUB LoadArrays (scriptFile AS STRING)
    DIM startR AS INTEGER, endR AS INTEGER, ReadingR AS INTEGER, temp AS INTEGER
    DIM fline AS STRING, kWord AS STRING
    OPEN scriptFile FOR INPUT AS #1
    WHILE Not EOF(1)
        LINE INPUT #1, fline
        SELECT CASE LEFT(fline, 2)
           CASE "g:": Greeting = Trim(MID(fline, 3))
           CASE "y:": You = Trim(MID(fline, 3))
           CASE "c:": Script = Trim(MID(fline, 3))
            CASE "s:"
                wCnt = wCnt + 1: temp = INSTR(fline, ">")
                IF temp THEN
                    sAppend wordIn(), " " + Trim(MID(fline, 3, temp - 3)) + " "
                    sAppend wordOut(), " " + Trim(MID(fline, temp + 1)) + " "
                END IF
            CASE "r:"
                rCnt = rCnt + 1
                sAppend replies(), Trim(MID(fline, 3))
                IF NOT ReadingR THEN
                    ReadingR = -1
                    startR = rCnt
                END IF
            CASE "k:"
                IF ReadingR THEN
                    endR = rCnt
                    ReadingR = 0
                END IF
                IF rCnt THEN
                    kCnt = kCnt + 1
                    kWord = Trim(MID(fline, 3))
                    sAppend keywords(), " " + kWord + " "
                    nAppend rStarts(), startR
                    nAppend rIndex(), startR
                    nAppend rEnds(), endR
                    IF kWord = "nokeyfound" THEN NoKeyFoundIndex = kCnt
                END IF
            CASE "e:": EXIT WHILE
        END SELECT
    WEND
    CLOSE #1
    IF ReadingR THEN 'handle last bits
        endR = rCnt
        kCnt = kCnt + 1
        sAppend keywords(), "nokeyfound"
        nAppend rStarts(), startR
        nAppend rIndex(), startR
        nAppend rEnds(), endR
        NoKeyFoundIndex = kCnt
    END IF
END SUB


FUNCTION isolatePunctuation (s AS STRING) as string
    'isolate punctuation so when we look for key words they don't interfere
    DIM b AS STRING, i AS INTEGER
    b = ""
    FOR i = 1 TO LEN(s)
        IF INSTR(punctuation, MID(s, i, 1)) > 0 THEN b = b + " " + MID(s, i, 1) + " " ELSE b = b + MID(s, i, 1)
    NEXT
    isolatePunctuation = b
END FUNCTION

FUNCTION joinPunctuation (s AS STRING) as String
    'undo isolatePuntuation$
    DIM b AS STRING, find AS STRING, i AS INTEGER, place AS INTEGER
    b = s
    FOR i = 1 TO LEN(punctuation)
        find = " " + MID(punctuation, i, 1) + " "
        place = INSTR(b, find)
        WHILE place > 0
            IF place = 1 THEN
                b = MID(punctuation, i, 1) + MID(b, place + 3)
            ELSE
                b = MID(b, 1, place - 1) + MID(punctuation, i, 1) + MID(b, place + 3)
            END IF
            place = INSTR(b, find)
        WEND
    NEXT
    joinPunctuation = b
END Function

' =============================== here is the heart of ELIZA / Player function
FUNCTION GetReply () as string
    DIM inpt AS STRING, tail AS STRING, answ AS STRING
    DIM kFlag AS INTEGER, k AS INTEGER, kFound AS INTEGER, l AS INTEGER, w AS INTEGER

    ' USER INPUT SECTION
    PRINT You + ": ";: LINE INPUT "", inpt
    IF LCASE(inpt) = "q" OR LCASE(inpt) = "x" OR LCASE(inpt) = "goodbye" OR LCASE(inpt) = "good night" OR LCASE(inpt) = "bye" THEN
        GetReply = "Goodbye!": EXIT FUNCTION
    END IF
    inpt = " " + inpt + " " '<< need this because keywords embedded in spaces to ID whole words only
    inpt = isolatePunctuation(inpt)
    FOR k = 1 TO kCnt 'loop through key words until we find a match
        kFound = INSTR(LCASE(inpt), LCASE(keywords(k)))
        IF kFound > 0 THEN '>>> need the following for * in some replies
            tail = " " + MID(inpt, kFound + LEN(keywords(k)))
            FOR l = 1 TO LEN(tail) 'DO NOT USE INSTR
                FOR w = 1 TO wCnt 'swap words in tail if used there
                    IF LCASE(MID(tail, l, LEN(wordIn(w)))) = LCASE(wordIn(w)) THEN 'swap words exit for
                        tail = MID(tail, 1, l - 1) + wordOut(w) + MID(tail, l + LEN(wordIn(w)))
                        EXIT FOR
                    END IF
                NEXT w
            NEXT l
            kFlag = -1
            EXIT FOR
        END IF
    NEXT
    IF kFlag = 0 THEN k = NoKeyFoundIndex
    answ = replies(INT((rEnds(k) - rStarts(k) + 1) * RND) + rStarts(k))
    'set pointer to next reply in rIndex array
    IF k = NoKeyFoundIndex THEN 'let's not get too predictable for most used set of replies
        rIndex(k) = INT((rEnds(k) - rStarts(k) + 1) * RND) + rStarts(k)
        'ELSE
        '    rIndex(k) = rIndex(k) + 1 'set next reply index then check it
        '    IF rIndex(k) > rEnds(k) THEN rIndex(k) = rStarts(k)
    END IF
    IF RIGHT(answ, 1) <> "*" THEN GetReply = answ: EXIT FUNCTION 'oh so the * signal an append to reply!
    If Trim(tail) = "" THEN
        GetReply = "Please elaborate on, " + keywords(k)
    ELSE
        tail = joinPunctuation(tail)
        GetReply = MID(answ, 1, LEN(answ) - 1) + tail
    END IF
END FUNCTION



'SUB speakTotext (lines as string) 'uses voice command line voice.exe
    'PRINT Script + ": " + slow(lines): PRINT
'END Sub


'DIM rply AS STRING '              for main loop
'LoadArrays "Rachel Chatbot v3.txt" '   check file load, OK checks out
'PRINT Greeting: PRINT '           start testing main Eliza code
'DO
    'rply = GetReply
    'PRINT: speakTotext rply
'LOOP UNTIL rply = "Goodbye!"


'slow printing sub
SUB slow(Text AS STRING)
	'writefile("You: " + Text)
	DIM AS INTEGER speed(0 TO 4) = > {50 , 100 , 20 , 300 , 250}
	FOR i AS INTEGER = 1 TO LEN(Text)
        PRINT MID(Text , i , 1) ;
        SLEEP speed(INT(RND * UBOUND(speed)))
    NEXT
END SUB

SUB speakTotext (lines as string) 'uses voice command line voice.exe
    PRINT Script & ": "; : slow(lines): PRINT : print
END Sub

'DIM rply AS STRING '              for main loop
'
'LoadArrays("eliza_script.txt") '   check file load, OK checks out
'slow(Greeting)
''start testing main Eliza code
'DO
	'
	'rply = GetReply
	'PRINT: slow(rply)
'LOOP UNTIL rply = "Goodbye!"