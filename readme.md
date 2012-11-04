
Educated Guess
===================

What:
	
	Takes a seed list things you know about target. 
	E.g. name, school, address, birthdate and then 
	crosses it with a list of other passwords. I have 
	provided some lists of common terrible passwords.
	It will then output a customized password attempt 
	list to a location of your choosing.
	
	
Example Usage:

	There are two modes:
		1. common - does not not do the full pin number list / full
			substring combinations of the seed list
		2. full - does a lot more. 
		
		
	All params:
	
	ruby educated_guess.rb common -o outputfile.txt -p 500_worst_passwords.txt -s seeds.txt
	
	
	No output specified ( goes to ./guess_output.txt )
	
	ruby educated_guess.rb full -p twitter-banned.txt -s seeds.txt
	

Notes:
	
	Will be improved in future. Possible improvements:
		-more options
		-more common password types.
		-ouput mode so you can pipe results into other programs.
		-dynamically read the seed files instead of reading into memory
		
		
		
		
		
		
		
		
		
	
	
