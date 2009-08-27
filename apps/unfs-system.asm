;UnFS-Unlimited FileSystem-rethink the modern filesystem. Eventually this will have support for so much shit, you can't even imagine.
;UnFS uses unodes instead of inodes-you can just call them nodes or descriptors
;What follows is a sample filesystem to help me figure out how to code this stuff.
;I think I will make a java program which can create and extract this filesystem from the solleros image
;by default everything is owned by and readable by root, therefore this does not need to be stated
;the structure of the system should be as follows:
	;/bin/time
	;/etc/tutorial
	;/home/user/
filesys:
	db 2		;version size is in two bytes-this may not even be necessary, the ext filesystem only has 4 versions
	dw 1		;version 1
	db 6		;filesystem block pointer size in bytes
	db 4		;filesystem memory pointer size in bytes			
	db 2		;size of user/group id's
	db 9		;filesystem allocation block size in exponent of 2(2^9=512 bytes)
	db 0		;character encoding(0=ASCII), this will probably be removed or changed to unicode version when everything goes unicode
			;the filesystem node collection will act like one big file as will the index, what follows is their nodes
	dd nodecollectionnode
	dd indexcollectionnode
nodecollectionnode:	dd nodecollectionend
	db 0,0
	dd (fsstart-filesys)/512
	db 0,0
	dd (fsend-filesys)/512
nodecollectionend:	dd 0
indexcollectionnode: dd indexcollectionend
	db 0,0
	dd (indexstart-filesys)/512
	db 0,0
	dd (indexend-filesys)/512
indexcollectionend: dd 0
			;now the fun part: figuring out where everything goes
					;what follows is the root Unode, it acts like every folder's unode
align 512, db 0
fsstart:
superroootnodes:	dd superrootnodesend - fsstart		;next part of superroot unode-this can be used in windows-like systems for C:,D:,etc. like addressing with multiple roots
	rootnode:
		dd rootindexname - indexstart	;location of name in index, the root directories name does not change its location '/' and can be safely omitted(must be zero terminated even if empty)
		db 0		;this is a folder
		dd 0		;location of properties for root directory, zero specifies default-full control by root and nothing else-if other properties are added a list will be created
		dd rootnodes - fsstart	;location of node collection for root directory's children
		dd 0
superrootnodesend:	dd 0		;there is no next unode
		
	rootnodes:	dd rootnodesend - fsstart		;location of last part of this portion of rootnodes, none if zero	
		binnode:
			dd binindexname - indexstart
			db 0
			dd 0
			dd binnodes - fsstart
			dd rootnode - fsstart	;location of parent's node
			
		etcnode:
			dd etcindexname - indexstart
			db 0
			dd 0
			dd etcnodes - fsstart
			dd rootnode - fsstart
			
		homenode:
			dd homeindexname - indexstart
			db 0
			dd 0
			dd homenodes - fsstart
			dd rootnode - fsstart
			
	rootnodesend:	dd 0	;there is no next unode
	
		binnodes:	dd binnodesend - fsstart
			bin1node:
				dd bin1indexname - indexstart
				db 1		;this is a file
				dd 0
				dd bin1nodes - fsstart	;location of file section nodes
				dd binnode - fsstart
				
		binnodesend:	dd 0
				
					bin1nodes:	dd bin1nodesend - fsstart
							db 0,0
							dd (bin1p1start-filesys)/512	;remember, this is 6 bytes
							db 0,0
							dd (bin1p1end-filesys)/512	;remember, this is 6 bytes
					bin1nodesend:	dd 0
					
		etcnodes:	dd etcnodesend - fsstart
			etc1node:
				dd etc1indexname - indexstart
				db 1
				dd 0
				dd etc1nodes - fsstart
				dd etcnode - fsstart
		etcnodesend:	dd 0
				
					etc1nodes:	dd etc1nodesend - fsstart
							db 0,0
							dd (etc1p1start-filesys)/512	;remember, this is 6 bytes
							db 0,0
							dd (etc1p1end-filesys)/512	;remember, this is 6 bytes
					etc1nodesend:	dd 0
		homenodes:	dd homenodesend - fsstart
			usernode:
				dd userindexname - indexstart
				db 0
				dd useraccess - fsstart
				dd usernodes - fsstart
				dd homenode - fsstart
		homenodesend: dd 0
		
		usernodes: dd usernodesend - fsstart
			user1node:
				dd user1indexname - indexstart
				db 1
				dd 0
				dd user1nodes - fsstart
				dd usernode - fsstart
		usernodesend: dd 0
		
		user1nodes: dd user1nodesend - fsstart
				db 0,0
				dd (user1p1start-filesys)/512
				db 0,0
				dd (user1p1end-filesys)/512
		user1nodesend: dd 0
		
		useraccess:
			dw 2	;owned by uid 2-user-full control is automatically given
		
align 512, db 0
fsend:	
					
indexstart:		;this will basically contain all of the names/metadata/dates/other stuff needed to search properly and quickly

				;now we can talk about time. time will be done with a 48-bit number compiled as such:
				;4 bits-month
				;5 bits-day
				;1 bit-a sign bit for the year
				;9 bits-an offset up to 512 from 2000CE
				;5 bits-hour
				;6 bits-minute
				;6 bits-second
				;10 bits-millisecond
				;2 bit denoting if another package exists(0=none, 1=precision, 2=length, 3=overkill)
				
				;24 bits-add these to address 100 picosecond (1/10 nanosecond) intervals
				
				;24 bits-add these to the year to address time back or forward 8 billion years
				
				;the overkill package is major overkill
				;20 bits-add these to address 100 attosecond intervals (the interval ever measured is 100 attoseconds)
				;4 bits-add these to address time back or forward 137.44 billion years-all the way forward to the big rip
				

		rootindexname:	dd rootnode - fsstart		;points back to the root node
				db "UnFS Test Filesystem",0		;this is not necessary but is nice to have
						
		binindexname:	dd binnode - fsstart
				db "bin",0
						
		etcindexname:	dd etcnode - fsstart
				db "etc",0
				
		homeindexname:  dd homenode - fsstart
				db "home",0
		
		bin1indexname:	dd bin1node - fsstart
				db "time.exe",0
		
		etc1indexname:	dd etc1node - fsstart
				db "tutorial.bat",0

		userindexname:	dd usernode - fsstart
				db "user",0
		
		user1indexname: dd user1node - fsstart
				db "solleros.txt",0
align 512, db 0				
indexend:

bin1p1start:
incbin "included/time"
align 512, db 0
bin1p1end:

etc1p1start:
incbin "included/tutorial.bat"
align 512, db 0
etc1p1end:

user1p1start:
incbin "included/solleros.txt"
align 512, db 0
user1p1end: