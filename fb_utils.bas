screen 19

'APPEND TO the STRING array the STRING item
SUB sAppend(arr() AS STRING , Item AS STRING)
	REDIM PRESERVE arr(LBOUND(arr) TO UBOUND(arr) + 1) AS STRING
	arr(UBOUND(arr)) = Item
END SUB
'APPEND TO the INTEGER array the INTEGER item
SUB nAppend(arr() AS INTEGER , Item AS INTEGER)
	REDIM PRESERVE arr(LBOUND(arr) TO UBOUND(arr) + 1) AS INTEGER
	arr(UBOUND(arr)) = Item
END SUB

'1 getkeys function

FUNCTION _
	getKeys(_
	BYREF keysToCatch AS CONST STRING) _
	AS STRING
	
	DIM AS STRING _
	k
	
	DO
        k = > INKEY()
        
        SLEEP(1 , 1)
    LOOP UNTIL (INSTR(keysToCatch , k))
	
	'CLEAR keyboard buffer
	DO WHILE (LEN(INKEY()) > 0)
        SLEEP(1 , 1)
    LOOP
	
	RETURN(k)
END FUNCTION

'4 print whole text file on screen
SUB txtfile(f AS STRING)
	CLS
	DIM AS STRING buffer
	DIM h AS LONG = FREEFILE()
	OPEN f FOR BINARY AS #h
	buffer = SPACE(LOF(h))
	GET #h ,  , buffer
	CLOSE #h
	PRINT buffer
	SLEEP
End SUB

sub center(row as integer, s as string)
	locate row , (loword(width) - len(s)) shr 1 : print s 
End Sub

SUB calculate()
	cls
	DIM as double years, packs, cost
	dim as double totalCigarettes, lost, lostTime, lostMoney
	INPUT "HOW MANY YEARS DID YOU SMOKE?: ", years
	INPUT "HOW MANY PACKS OF CIGARETTES IN A DAY DID YOU SMOKE?: ", packs
	INPUT "HOW MUCH DOES A PACK OF CIGARETTES COSTS YOU?: ", cost
	
	CLS
	center 4, "PRESS ANY KEY TO GET CALCULATIONS"
	SLEEP
	totalCigarettes = years * 365 * packs * 20
	lost = totalCigarettes * 5
	lostTime = lost / 60 / 24 / 365
	lostMoney = years * 365 * packs * cost
	CLS
	center 4, "YOU SMOKED " + STR(totalCigarettes) + " CIGARETTES IN YOUR LIFE TIME SO FAR"
	center 6, "YOU LOST " + STR(lostTime) + " YEARS FROM YOUR LIFE CAUSE OF SMOKING"
	center 8, "YOU SPENDED " + STR(lostMoney) + "$ ON SMOKING IN YOUR LIFE SO FAR"
	center 10, "SMOKING IS BAD FOR YOU PLEASE CONSIDER QUITTING FOR GOOD"
	center 12, "PRESS ANY KEY TO END AND EXIT CALCULATOR..."
	SLEEP
END SUB

