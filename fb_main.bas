#INCLUDE "vbcompat.bi"
#include "fb_utils.bas"

const filelog = "log.txt"
dim shared quit_date as double
dim shared quitting_counter as LONG
DIM SHARED AS STRING reason_for_quitting, message_to_self

screen 20

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


sub quitting()
	cls
	if NOT CBool(FILEEXISTS(filelog)) then
		write_to_file()
		center 2, "YOU STARTED TO QUIT NOW! AT " & DATE & " GOOD LUCK!"
		print
		input "PLEASE ENTER YOUR REASON FOR QUITTING SMOKING: ", reason_for_quitting
		print
		input "ENTER PERSONAL MESSAGE FOR YOURSELF WHEN YOU HAVE CRAVINGS FOR SMOKING: ", message_to_self
		append_to_file()
	ELSE
		read_to_file()
		dim d1 as double
		d1 = now()
		quitting_counter = datediff("d", quit_date, d1)
		if quitting_counter = 0 then
			center 2, "YOU JUST STARTED QUITTING SMOKING! THIS IS THE FIRST DAY! STAY STRONG!"
		ELSE
			center 2, "YOU ARE: " & quitting_counter & " DAYS NOT SMOKING! STAY STRONG! :)"
		EndIf
		
	EndIf
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
	
	center 34, "PRESS S KEY IF YOU STARTED SMOKING AGAIN :("
	center 35, "PRESS KEY 1 TO RETURN TO MAIN MENU"
	k = getkeys("s1")
	if k = "s" then
		dim h as string
		kill(filelog)
		cls
		center 5 , "WE ARE SO SORRY YOU'RE BACK SMOKING :( PLEASE CONIDER TRYING AGAIN :-/"
		center 7, "PRESS KEY H FOR INFO ABOUT N.R.T. (NICOTINE REPLACMENT THERAPY) - OPENS URL IN BROWSER"
		center 9, "PRESS ESC TO RERUN TO MAIN MANU"
		h = getkeys("h" & chr(27))
		if h = "h" then
			#ifdef __FB_LINUX__
				SHELL("xdg-open https://en.wikipedia.org/wiki/Nicotine_replacement_therapy")
			#else
				shell("start https://en.wikipedia.org/wiki/Nicotine_replacement_therapy")
			#EndIf
		elseif h = chr(27) then
			exit sub
		EndIf
	ELSEIF k = "1" then
		exit sub
	EndIf
	
	
	
End Sub	




sub main1()
	do
		dim k as string
		CLS
		center(2, "MAIN MANU - QUIT SMOKING APP V.1.0")
		center(4, "----------------------------------")
		center(6, "1. SMOKING CALCULATURE")
		center(8, "2. INFO ABOUT QUITTING SMOKING (OPEN URLS IN BROWSER)")
		center(10, "3. START OR CHECK QUITTING COUNTER")
		center(12, "4. EXIT")
		k = getkeys("1234")
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
		EndIf
	loop
End Sub












txtfile("opening.txt")
main1()
sleep