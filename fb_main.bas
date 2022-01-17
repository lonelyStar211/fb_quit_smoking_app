
#INCLUDE "vbcompat.bi"
#include "chatbot_advisor.bas"
#include "fb_utils.bas"

const attemptslog = "attempts.txt"
const counterlog = "counter.txt"
const filelog = "log.txt"
dim shared quit_date as double
dim shared quitting_counter as LONG
DIM SHARED AS STRING reason_for_quitting, message_to_self
dim shared counter_of_attempts as LONG
redim shared as string attempts_array(any) 
dim shared as string reason_for_failure

screen 20

sub attempts_read()
	dim fline as string
	dim f as long = freefile()
	open attemptslog for input as #f
	while not eof(f)
		line input #f, fline
		sAppend(attempts_array(), fline)
	Wend
	close #f
End Sub


sub add_attempt()
	dim f as long = freefile()
	open attemptslog for append as #f
	print #f, reason_for_failure
	close #f
End Sub


sub counter_read()
	dim f as long = freefile()
	open counterlog for input as #f
	input #f, counter_of_attempts
	close #f
End Sub

sub counter_write()
	counter_of_attempts += 1
	dim f as long = freefile()
	open counterlog for output as #f
	write #f, counter_of_attempts
	close #f
End Sub

sub read_to_file()
	dim f as long = freefile()
	open filelog for input as #f
	input #f, quit_date
	input #f, reason_for_quitting
	input #f, message_to_self
	close #f
End Sub

sub write_to_file()
	dim f as long = freefile()
	dim d2 as double
	d2 = now()
	open filelog for output as #f
	write #f, d2
	close #f
End Sub

sub append_to_file()
	dim f as long = freefile()
	open filelog for append as #f
	print #f, reason_for_quitting
	print #f, message_to_self
	close #f
End Sub

sub quitty_advisor()
	cls	
	DIM rply AS STRING '              for main loop
	LoadArrays("chatbot_script.txt") '   check file load, OK checks out
	speakTotext(Greeting)
	'start testing main Eliza code
	DO
		
		rply = GetReply
		PRINT : speakTotext(rply)
	LOOP UNTIL rply = "Goodbye!"
End Sub

sub quitting()
	cls
	if fileexists(filelog) = false then 'INSTEAD OF 'if NOT CBool(FILEEXISTS(filelog)) then
		write_to_file()
		counter_read()
		counter_write()
		center 2, "YOU STARTED TO QUIT NOW! AT " & DATE & " GOOD LUCK!"
		print
		input "PLEASE ENTER YOUR REASON FOR QUITTING SMOKING: ", reason_for_quitting
		print
		input "ENTER PERSONAL MESSAGE FOR YOURSELF WHEN YOU HAVE CRAVINGS FOR SMOKING: ", message_to_self
		append_to_file()
	ELSE
		read_to_file()
		counter_read()
		dim d1 as double
		d1 = now()
		quitting_counter = datediff("d", quit_date, d1)
		center 1, "ATTENPT NUMBER: " & counter_of_attempts & " TO QUIT SMOKING!"
		if quitting_counter = 0 then
			center 2, "YOU JUST STARTED QUITTING SMOKING! THIS IS THE FIRST DAY! STAY STRONG!"
		ELSE
			center 2, "YOU ARE: " & quitting_counter & " DAYS NOT SMOKING! STAY STRONG! :)"
		EndIf
		
		'EndIf
		dim k as STRING
		print
		print
		center 4, "THE REASON YOU WANT TO QUIT IS:" 
		print
		print UCASE(reason_for_quitting)
		print
		center 15, "YOUR MESSAGE TO YOURSELF WHEN CRAVING STARTS IS:"
		print
		print UCASE(message_to_self)
		
		
		center 43, "PRESS S KEY IF YOU STARTED SMOKING AGAIN :("
		center 44, "PRESS KEY 1 TO RETURN TO MAIN MENU"
		center 45, "PRESS C KEY TO CHAT WITH QUITTY THE ADVISOR CHATBOT"
		k = getkeys("s1c")
		if k = "s" then
			txtfile("message.txt")
			sleepex()
			dim key as string
			kill(filelog)
			cls
			input "PLEASE ENTER WHY AND HOW YOU WERE TRIGGERED TO SMOKE AGAIN: ", reason_for_failure
			add_attempt()
			cls 
			center 5 , "WE ARE SO SORRY YOU'RE BACK SMOKING :( PLEASE CONIDER TRYING AGAIN :-/"
			center 7, "PRESS KEY H FOR INFO ABOUT N.R.T. (NICOTINE REPLACMENT THERAPY) - OPENS URL IN BROWSER"
			center 9, "PRESS ESC TO RERUN TO MAIN MANU"
			key = getkeys("h" & chr(27))
			if key = "h" then
				#ifdef __FB_LINUX__
					SHELL("xdg-open https://en.wikipedia.org/wiki/Nicotine_replacement_therapy")
				#else
					shell("start https://en.wikipedia.org/wiki/Nicotine_replacement_therapy")
				#EndIf
			elseif key = chr(27) then
				exit sub
			EndIf
		ELSEIF k = "1" then
			exit sub
		elseif k ="c" then
			quitty_advisor()
		EndIf
	endif
	
	
End Sub	

sub view_pass_attempts()
	for i as integer = 0 to ubound(attempts_array)
		cls
		print
		print "ATTEMPTS NUMBER " & i + 1 & " FAILED CAUSE OF:"
		print
		print attempts_array(i)
		sleep
	Next
End Sub

sub opening_page()
	if fileexists(filelog) then
		read_to_file()
		dim d1 as double
		d1 = now()
		quitting_counter = datediff("d", quit_date, d1)
		if quitting_counter >= 0 and quitting_counter < 8 then
			'center 1, "QUITTING SMOKING DAY NUMBER: " & quitting_counter
			txtfile("week1.txt")
		ELSEIF quitting_counter >= 8 and quitting_counter < 15 then
			txtfile("week2.txt")
		elseif quitting_counter >= 15 and quitting_counter < 22 then
			txtfile("week3.txt")
		elseif quitting_counter >= 22 and quitting_counter < 29 then
			txtfile("week4.txt")
		elseif quitting_counter >= 29 then
			txtfile("victory.txt")
		EndIf
	else
		txtfile("opening.txt")
	EndIf
End Sub




sub main1()
	if fileexists(attemptslog) = true then attempts_read()
	'txtfile("opening.txt")
	opening_page()
	do
		dim k as string
		CLS
		center(2, "MAIN MANU - QUIT SMOKING APP V.1")
		center(4, "----------------------------------")
		center(6, "1. SMOKING CALCULATURE")
		center(8, "2. INFO ABOUT QUITTING SMOKING (OPEN URLS IN BROWSER)")
		center(10, "3. START OR CHECK QUITTING COUNTER")
		if fileexists(attemptslog) = true then
			center(14, "5. VIEW PAST ATTEMPTS LOG")
		endif
		'center(12, "4. CHAT WITH QUITTY THE CHATBOT ADVISER")
		center(12, "4. EXIT")
		k = getkeys("12345")
		if k = "4" then
			end
		elseif k = "1" then
			calculate()
		elseif k = "2" then
			#ifdef __FB_LINUX__
				shell("xdg-open https://www.getaeris.app/blog/quit-smoking-timeline/")
				shell("xdg-open https://www.cancer.gov/about-cancer/causes-prevention/risk/tobacco/withdrawal-fact-sheet")
			#else
				shell("start https://www.getaeris.app/blog/quit-smoking-timeline/")
				shell("start https://www.cancer.gov/about-cancer/causes-prevention/risk/tobacco/withdrawal-fact-sheet")
			#EndIf
		elseif k = "3" then
			quitting()
		elseif k = "5" then
			view_pass_attempts()
		'elseif k = "4" then
			'quitty_advisor()
		EndIf
	loop
End Sub




main1()
sleep