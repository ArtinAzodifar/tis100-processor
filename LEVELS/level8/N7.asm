MOV UP, ACC
SUB LEFT   
JLZ P      
JMP D      
P: NEG     
D: SUB 10  
JLZ W      
MOV 1, DOWN
JMP END    
W: MOV 0, DOWN
END: NOP 