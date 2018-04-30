
;*********************************** Project Macros ***********************************
               
Delay       macro Num
    
            PUSHA 
            mov di,1
            mov si,1
            LOCAL L5
            L5:
            	LOCAL L4		
   	            L4:	inc di			
    		        cmp di,10000		
    	            jnz L4
    			    inc si
    			    mov di,1
    			    cmp si,Num
    			    jnz L5
    		POPA
endm Delay 

;*************************************************************************************

DrawRectangle   macro X1 Y1 X2 Y2 Color
                
                PUSHA
                mov cx,X1          
                mov dx,Y1         
                mov al,Color        
                mov ah,0ch
                LOCAL back1        
                back1:
                        LOCAL back11
                        back11:
                                int 10h   
                                inc cx    
                                cmp cx,X2
                                jnz back11
      
                inc dx
                cmp dx,Y2 
                mov cx,X1
                jnz back1 
                POPA

endm DrawRectangle

;**************************************************************************************

HorizontalLine  macro x1 y1 x2 y2 color
                 
                PUSHA
                mov cx,x1          
                mov dx,y1         
                mov al,Color        
                mov ah,0ch
                LOCAL back1        
                back1:
                      int 10h   
                      inc cx    
                      cmp cx,x2
                      jnz back1
                POPA 
                
endm HorizontalLine

;**************************************************************************************

VerticalLine    macro x1 y1 x2 y2 color
                
                PUSHA
                mov cx,x1          
                mov dx,y1         
                mov al,Color        
                mov ah,0ch
                LOCAL back1        
                back1:
                      int 10h   
                      inc dx    
                      cmp dx,y2
                      jnz back1
                POPA

endm VerticalLine

;**************************************************************************************

KeyPressed  macro 
                 
                 MOV AH, 01         ;jz hyjump if no key pressed
                 INT 16H     ; ZF =0 if key pressed, else ZF=1 AL: ASCII Code, AH: Scancode
                 
                 
endm KeyPressed

;**************************************************************************************

CheckKeyPressed    macro  
                 
                 MOV AH, 00 
                 INT 16H
                
                 
endm CheckKeyPressed

;**************************************************************************************

DisplayString       Macro Output
                    PUSHA
                    mov ah,09h
                    mov dx,offset Output
                    int 21h
                    POPA
endm DisplayString

;*************************************************************************************

MoveCursor          Macro row col
                    
                    PUSHA
                    MOV AH, 02                               
                    MOV BH, 00                       
                    MOV DL, col                        
                    MOV DH, row                        
                    INT 10H
                    POPA
                    
endm MoveCursor                    

;*************************************************************************************

increment        macro var
                 
                 PUSHA 
                 mov cx,var
                 inc cx
                 mov var,cx 
                 POPA
                 
                 
endm increment   

;**************************************************************************************

decrement        macro var
                 
                 PUSHA 
                 mov cx,var
                 dec cx
                 mov var,cx
                 POPA
endm decrement   

;*************************************************************************************

DrawFirstMan    Macro
                
                DrawRectangle 00 20 16 32 0
                DrawRectangle 16 28 32 32 0
                DrawRectangle 4 32 24 48 7
                DrawRectangle 4 48 16 52 7  
                DrawRectangle 24 36 32 40 7
                DrawRectangle 16 36 20 40 00
                DrawRectangle 4 52 12 56 7
                DrawRectangle 00 56 16 92 4
                DrawRectangle 8 92 32 96 6
                DrawRectangle 12 96 24 100 6
                DrawRectangle 16 84 36 92 6
                DrawRectangle 28 80 36 84 6
                DrawRectangle 36 76 48 84 6 
                DrawRectangle 48 72 56 100 6
                DrawRectangle 56 96 68 100 6
                DrawRectangle 16 64 24 68 4
                DrawRectangle 24 60 32 64 4
                DrawRectangle 32 56 40 60 4
                DrawRectangle 36 52 44 56 7 
                HorizontalLine 16 44 24 44 0
                
endm DrawFirstMan

;*************************************************************************************

 
DrawSecondMan    Macro
                
                DrawRectangle 624 20 640 32 0
                DrawRectangle 608 28 624 32 0
                DrawRectangle 616 32 636 48 7
                DrawRectangle 624 48 636 52 7 
                DrawRectangle 608 36 616 40 7
                DrawRectangle 620 36 624 40 0
                DrawRectangle 628 52 636 56 7
                DrawRectangle 624 56 640 92 8
                DrawRectangle 616 64 624 68 8
                DrawRectangle 608 60 616 64 8
                DrawRectangle 600 56 608 60 8
                DrawRectangle 596 52 604 56 7
                DrawRectangle 608 92 632 96 15
                DrawRectangle 616 96 628 100 15
                DrawRectangle 604 84 624 92 15
                DrawRectangle 604 80 612 84 15
                DrawRectangle 592 76 604 84 15 
                DrawRectangle 584 72 592 100 15
                DrawRectangle 572 96 584 100 15
                HorizontalLine 616 44 624 44 0
                
endm DrawSecondMan

;*************************************************************************************
SerialConfig Macro
    
        mov dx,3fbh 			; Line Control Register
        mov al,10000000b		;Set Divisor Latch Access Bit
        out dx,al				;Out it       
        
        mov dx,3f8h			
        mov al,0ch;60h			
        out dx,al
        
        mov dx,3f9h
        mov al,00h
        out dx,al  
        
        mov dx,3fbh
        mov al,00011011b ;  the same in both pcs
        out dx,al
        
endm  SerialConfig
    
;*************************************************************************************

Scrollline Macro  from to
       
       pusha
       mov ax,0601h;al =lines to scroll
       mov bh,07
       mov cx,from
       mov dx,to
       int 10h
       popa
       
endm Scrollline            

;************************************************************************************
DisplayChar Macro value
        pusha
        mov ah,2
        mov dl,value
        int 21h
        popa
endm DisplayChar  

;***********************************************************************************
GetCursor Macro cursor
        
        pusha
        mov ah,3h
        mov bh,0h
        int 10h
        mov cursor,dx 
        popa
        
endm GetCursor 

;***********************************************************************************
Send Macro value 
    
        mov dx , 3FDH		; Line Status Register 
        LOCAL AGAIN   
        AGAIN:  	                                  
        In al , dx 			;Read Line Status         
  		AND al , 00100000b                            
  		JZ AGAIN                                      
                                                      
        mov dx , 3F8H		; Transmit data register  
  		mov al,value                                  
  		out dx , al 
   
    
endm Send
                  
;***********************************************************************************
Recieve Macro  
    
        mov dx , 3FDH		; Line Status Register
	    LOCAL CHK
	    CHK:	
	    in al , dx 
  		AND al , 1
  		JZ CHK  ;if no 
  		
  		; if yes
  		mov dx , 03F8H
  		in al , dx 
  		;mov value , al    
  		
endm Recieve

;**********************************************************************************
Line Macro
        pusha
        mov cx,80 
        LOCAL line1
        line1:
        mov ah,2
        mov dl,'-'
        int 21h
        loop line1
        popa
    
endm Line          
;************************************************************************************
ClearScreen Macro 
       
       pusha
       mov ax,0600h;al =lines to scroll
       mov bh,07
       mov cx,0
       mov dx,184Fh
       int 10h
       popa
       
endm ClearScreen            

;************************************************************************************

        