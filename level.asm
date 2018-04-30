                                    
    include fishing.inc 
    .model small
    .stack 64
    
    .data
         
         fish               DW        32 dup (0000)   ;x,y,direction,caught
         direction          DW        0,1,1,1,0,1,1,0,1,0,0,0,1,1,0,1,1,1,0,0
         xend1              DW        0        ;for the first hook
         yend1              DW        0
         xstart2            DW        0        ;for the second hook
         yend2              DW        0 
         xfish              DW        0        ;for the fish
         yfish              Dw        0   
         counter1           DW        0        ;counters for the two players
         counter2           DW        0
         y1caught           DW        0        ;the y coordinates of the caught fishes to put new ones in their position
         y2caught           DW        0
         catching1          DW        0        ;is the first man catching a fish?
         catching2          DW        0        ;is the second man catching a fish?
         1firstcaught       DB        1        ;is this the moment of catching for first player?
         2firstcaught       DB        1        ;is this the moment of catching for first player?
         Gameover           DB        " wins $" 
         str                DB        "  $"
         blackstr           DB        "                                                                                $"
         RestartGame        DB        "                     *  Press Enter To Start Fishing Again!! *                  $" 
         mes                DB        'Please enter your name and then press enter$'                        
         error              DB        "your name can't contain special characters or letters",10,13,'$'
         player1            Db        16,?,16 dup('$')
         player2            Db        16,?,16 dup('$') 
         cursor             DB        0
         chat               DB        '* To start chatting press F1 $'
         game               DB        '* To start the game press F2 $'
         esc                DB        '* To end the program press ESC $' 
         drx                DW        0     ;variables for drawing the fish
         dry                DW        0 
         drx2               DW        0
         dry2               DW        0
         dcolor             DB        0
         variable           DW        0     ;variables for randomization
         var2               DW        0
         mycursor           dw        0100h
         hiscursor          dw        0D00h  
         level              db        0
         f3                 db        " To return to main menu press f3$"
         value              db        ?  
         connection         db        " You are connected to $" 
         connect            db        " Connecting ...$"  
         chatsent           db        "you sent a chat invitation to $"
         gamesent           db        "you sent a game invitation to $"
         chatrecieved       db        "sent you a chat invitation.To accept it press F1$"
         gamerecieved       db        "sent you a game invitation.To accept it press F2$"
         chatting           db        0 ;1 if i sent invitation , 2 if i recieved an invitation
         gaming             db        0 ;1 if i sent invitation , 2 if i recieved an invitation 
         host               db        0 ;0 for guest , 1 for host 
         mycursorinline     dw        1A00h
         hiscursorinline    dw        1C00h 
         levelno            db        "To choose level 1 press 1",10,13,"To choose level 2 press 2",'$'
         
         
    .code         
        
        main proc far             
        mov ax,@data
        mov ds,ax

        ;serial configuration
        SerialConfig       
        
        ClearScreen
        
        ;change to graphics mode
        ;640*480  
        ;mov ax,4F02H    
;        mov bx,101H          
;        int 10h      
        
        ;get the name of the first player and check
        ;for its validity -------------------------;                                           
        getname:                                   ;
                                                   ;
        MoveCursor  0Ch  0Ah                       ;
        DisplayString mes                          ;
                                                   ;
        MoveCursor 0Dh  0Ah                        ;
        
        mov cx,15
        mov di,offset player1+2
        init:
        mov [di],'$'
        inc di
        loop init
                                                   ;
        mov ah,0AH                                 ;
        mov dx,offset player1                      ;
        int 21h                                    ;
                                                   ;
        mov cx,15                                  ;
                                                   ;
        mov di,offset player1+2                    ;
        lbl:                                       ;
        mov ax,[di]                                ;
        cmp al,0Dh                                 ;;we reached the end of the string
        jz Connecting                              ;
        cmp al,41h                                 ;
        jb err                                     ;
        cmp al,5Ah                                 ;
        jbe next                                   ;
        cmp al,61h                                 ;
        jb err                                     ;
        cmp al,7Ah                                 ;
        jbe next                                   ;
        jmp err                                    ;
                                                   ;
        next:                                      ;
        inc di                                     ;
        loop lbl                                   ;
                                                   ;
        jmp Connecting                             ;
                                                   ;
        err:                                       ;
        mov ax,4F02H                               ;
        mov bx,101H                                ;
        int 10h                                    ;
        MoveCursor  0Ah  0Ah                       ;
        DisplayString error                        ;
        jmp getname                                ;;go get the first name again
        ;------------------------------------------;
                   
        
        ;Extchanging Names-----------------------------;
        Connecting:
        ;momken hnaa ab2a abdl el enter b space eli f a5er el esm ;  
        mov [di],' '
        ClearScreen
        MoveCursor  0Ah  0Ah                       ;
        DisplayString Connect
        
        mov cx,15
        mov di,offset player1
        mov si,offset player2
        mov bx,0
        exchanging:
        ;mov value,player1[di] 
        send di[bx];value
        Recieve
        mov si[bx],al  
        inc bx
        loop exchanging
        ;----------------------------------------------;
        
        
        
        ; Main Menu--------------------------------;
        MainMenu:                                  ;
        ;mov ax,4F02H                               ;
;        mov bx,101H                                ;
;        int 10h                                    ;
        
        mov ax, 0002h
        mov bl, 0
        int 10h
         
        Clearscreen                                  
        
        MoveCursor 00h 0Ah                         ;
        DisplayString connection         
        DisplayString Player2+2        
                                                   ;
        MoveCursor 07h 0Ah                         ;
        DisplayString chat  ;f1 ah=3B              ;;start chating
        MoveCursor 0Ah 0Ah                         ;
        DisplayString game  ;f2 ah=3C              ;;start game
        MoveCursor 0Dh 0Ah                         ;
        DisplayString esc   ;esc ah=01             ;;end 
                                                   ;
        
        cmp chatting,1
        jnz check2
        
        MoveCursor 16h 00h
        DisplayString  chatsent
        DisplayString player2+2
        jmp again1
        
        check2:
        cmp chatting,2
        jnz check3:
        
        MoveCursor 16h 00h
        DisplayString player2+2
        DisplayString  chatrecieved
        jmp again1
        
        check3:
        cmp gaming,1
        jnz check4
        
        MoveCursor 18h 00h
        DisplayString  gamesent
        DisplayString player2+2 
        jmp again1
        
        check4:
        cmp gaming,2
        jnz again1
        
        MoveCursor 18h 00h
        DisplayString player2+2
        DisplayString  gamerecieved                                           
                                                   
        again1:                                    ;
        KeyPressed                                 ;
        jz rec1:                                 ; 
                                                   ;
        CheckKeyPressed                            ;;take the key pressed from the buffer  
        
        ch1:
        cmp ah,3Bh;f1
        jnz ga1    
        
        ;lw das f1
        cmp chatting,2
        jnz printchat1 ; lw el chat mafehash invitation yb2a ana bb3t invitation
        
        ;lw asln ana kan gayli invitation (chatting =2)
        mov value,ah
        send value ;keda bb3t eni acceptted el chat request
        mov chatting,0
        jmp startchat
            
        printchat1:
        MoveCursor 16h 00h
        DisplayString  chatsent
        DisplayString player2+2 
        mov value,ah
        send value ;keda bb3t chat request
        mov chatting,1
        jmp rec1 
            
        ga1:                                       ;
        cmp ah,3CH ;f2                             ;  
        jnz en1                              ;
        
        ;lw das f2
        cmp gaming,2
        jnz printgame1 ; lw el game mafehash invitation yb2a ana bb3t invitation
        
        ;lw asln ana kan gayli invitation (gamming =2)
        mov value,ah
        send value ;keda bb3t eni acceptted el game request
        mov gaming,0  
        mov host,0
        jmp startgame
            
        printgame1:
        MoveCursor 18h 00h
        DisplayString  gamesent
        DisplayString player2+2 
        mov value,ah
        send value ;keda bb3t game request
        mov gaming,1
        jmp rec1 
       
     
        en1:
        cmp ah,01h ;esc                            ;
        jz sendendding                                  ;  
        
        jmp rec1
        sendendding:
        send 01h
        jmp endall
        
        rec1:                                      ;r
        mov dx , 3FDH		; Line Status Register    ;r
	    CHK:	                                      ;r
	    in al , dx                                    ;r
  		AND al , 1                                    ;r
  		JZ again1;CHK  ;if no  ;;;;;;;;;;??????       ;r
  		                                              ;r
  		; if yes                                      ;r
  		mov dx , 03F8H                                ;r
  		in al , dx                                    ;r
  		mov value , al        
  		
  		
  		ch2:
  		cmp al,3Bh ; f1 recieved 
  		jnz ga2  
  		
  		;lw recieved f1
        cmp chatting,1
        jnz printchat2 ; lw ana msh ba3ta invitation yb2a hwa eli ba3tli invitation   
  		
  		;lw asln ana ba3ta 
        mov chatting,0
        jmp startchat
            
        printchat2:
        MoveCursor 16h 00h
        DisplayString player2+2
        DisplayString  chatrecieved 
        mov chatting,2
        jmp again1 
  		
  		
  		
  		ga2:
  		cmp al,3Ch ; f2 recieved
  		jnz en2  
  		
  		;lw recieved f2
        cmp gaming,1
        jnz printgame2 ; lw ana msh ba3ta invitation yb2a hwa eli ba3tli invitation   
  		
  		;lw asln ana ba3ta 
        mov gaming,0
        mov host,1
        jmp startgame
            
        printgame2:
        MoveCursor 18h 00h
        DisplayString player2+2
        DisplayString  gamerecieved 
        mov gaming,2
        jmp again1 
        
           
  		    
  		en2:
  		cmp al,01h ; esc recieved
  		jz endall 
        
        jmp again1
        ischat:
        mov value,ah
        send value
                                               ;
        jmp again1                                 ;
        ;------------------------------------------;  
        
                                                        
                                                        
        ;Chat Module ----------------------------------;                                                
        StartChat:                                     ;
                                                       ;
        ClearScreen                                    ; 
                                                       ;
        mov mycursor,0100h                             ;
        mov hiscursor,0D00h                            ;
                                                       ;
        MoveCursor 18h 00h                             ;
        DisplayString f3                               ;
        MoveCursor 17h 00h                             ;
        Line                                           ;
                                                       ;
                                                       ;
        MoveCursor 00h 00h                             ;
        Displaystring Player1+2                        ;
        Displaychar ':'                                ;
                                                       ;
        MoveCursor 0Ch 00h                             ;
        Displaystring Player2+2                        ;
        Displaychar ':'                                ;
                                                       ;
        ;screen division                               ;
        MoveCursor 0Bh 00h                             ;
        Line                                           ;
                                                       ;
        ChattingMod:                                   ;
        ;check key pressed                             ;
        Ckeckkp:                                       ;
        KeyPressed                                     ;
        jz Checkserial                                 ;
                                                       ;
        ;if a key is pressed                           ;
        CheckKeyPressed                                ;
                                                       ;
        cmp ah,3Dh ;f3 scancode                        ;
        jnz writting                                   ;
        mov al,0FFh ;; ay 7aga a3rf mnha eno das f3    ;
                                                       ;
                                                       ;
        writting:                                      ;
        mov value,al                                   ;
                                                       ;
        cmp al,0Dh ;(ascii enter)                      ;
        jnz cursor1                                    ;
        mov dx,mycursor                                ;
        inc dh                                         ;
        mov mycursor,dx                                ;
                                                       ;
         ;scrolling                                    ;
        cmp dh,0Bh                                     ;
        jne cursor1 ;jne                                   ;
                                                       ;
        Scrollline 0100h 0A4FH                         ;
                                                       ;
        mov dx,mycursor                                ;
        dec dh                                         ;
        mov mycursor,dx                                ;
                                                       ;
        ;move cursor                                   ;
        cursor1: 
        pusha                                          ;
        mov ah,2                                       ;
        mov dx,mycursor                                ;
        int 10h                                        ; 
        popa
                                                       ;
        DisplayChar value                              ;
        GetCursor  mycursor                            ;
                                                       ;
        sending:                                       ;
        Send value                                     ; 
        mov al,value
        cmp al,0FFh
        jz  MainMenu
  		                                               ;
  		Checkserial:                                   ;
  		                                               ;
        mov dx , 3FDH		; Line Status Register     ;
	    CHK2:	                                       ;
	    in al , dx                                     ;
  		AND al , 1                                     ;
  		JZ ChattingMod;CHK  ;if no  ;;;;;;;;;;??????   ;
  		                                               ;
  		; if yes                                       ;
  		mov dx , 03F8H                                 ;
  		in al , dx                                     ;
  		mov value , al                                 ; 
  		                                               ;
  		cmp al,0FFh                                    ;
  		jz MainMenu                                    ;
  		                                               ;
  		cmp al,0Dh ;(ascii enter)                      ;
        jnz cursor2                                    ;
        mov dx,hiscursor                               ;
        inc dh                                         ;
        mov hiscursor,dx                               ;
                                                       ;
         ;scrolling                                    ;
        cmp dh,17h;0Ch                                 ;
        jne cursor2                                    ;
                                                       ;
        Scrollline 0D00h 164Fh                         ;
                                                       ;
        mov dx,hiscursor                               ;
        dec dh                                         ;
        mov hiscursor,dx                               ;
  		                                               ;
  		;move cursor                                   ;
  		cursor2:                                       ;
        mov ah,2                                       ;
        mov dx,hiscursor                               ;
        int 10h                                        ;
                                                       ;
        DisplayChar value                              ;
        GetCursor hiscursor                            ;
                                                       ;
        jmp ChattingMod                                ;
                                                       ;
;------------------------------------------------------;        
        
        
        StartGame: 
        
        
        mov ax, 0002h
        mov bl, 0
        int 10h
          
        Clearscreen              
        pusha                    
        cmp host,0
        jz guest0       
        
        
        
        Displaystring levelno
        
        get:
        keypressed
        jz get
        
        checkkeypressed
        cmp ah,02;ascii 1
        jz send1
        
        cmp  ah,03;ascii 2
        jz send2  
        jmp get
        
        send1:
        mov al,1
        mov level,al
        send level
        jmp initialize
        
        send2: 
        mov al,2
        mov level,al
        send level
        jmp initialize  
        
        
        guest0:              
        MoveCursor  0Ah  0Ah                       ;
        DisplayString Connect
        Recieve
        mov level,al
              
        
        initialize:
        popa
        mov counter1,0        ;counters for the two players
        mov counter2,0
        mov y1caught,0        ;the y coordinates of the caught fishes to put new ones in their position
        mov y2caught, 0
        mov catching1, 0        ;is the first man catching a fish?
        mov catching2,0        ;is the second man catching a fish?
        mov 1firstcaught,1        ;is this the moment of catching for first player?
        mov 2firstcaught,1        ;is this the moment of catching for first player? 
        mov mycursorinline,1A00h
        mov hiscursorinline,1C00h      
        
        
               
        mov ax,4F02H    
        mov bx,101H     
        int 10h
        
        ;Draw the background ---------------------;
                                                  ;
        DrawRectangle 00d 00d 640d 100d 09h       ;;first part of the sky
        DrawRectangle 80d 100d 560d 140d 09h      ;;second part of the sky
        DrawRectangle 80d 140d 560d 400d 01h      ;;the sea
        DrawRectangle 00d 100d 80d 400d 00h       ;
        DrawRectangle 560d 100d 640d 400d 00h     ;        
        DrawFirstMan                              ;
        DrawSecondMan                             ;
                                                  ;
        mov mycursorinline,1A00h
        mov hiscursorinline,1C00h                                          
                                                  
        MoveCursor 0 0                            ;
        DisplayString blackstr                    ;
                                                  ; 
        cmp host,1 
        jnz guest1:
                                                  
        MoveCursor 0 1                            ;;displaying the players' names
        DisplayString player1+2                   ;
                                                  ;
        MoveCursor 0 60                           ;
        DisplayString player2+2                   ;
        
        jmp hookCoor
        guest1:
        MoveCursor 0 1                            ;;displaying the players' names
        DisplayString player2+2                   ;
                                                  ;
        MoveCursor 0 60                           ;
        DisplayString player1+2                   ;
        
        
                                                  ;
        ;Set Hooks Coordinates                    ;                            
        hookCoor:                                         ;
        PUSHA                                     ;
        mov cx,161                                ;;initial positions of the hooks
        mov xend1,cx                              ;
        mov cx,160                                ;
        mov yend1,cx                              ;
        mov yend2,cx                              ;
        mov cx,481                                ;
        mov xstart2,cx                            ;
        POPA                                      ;
                                                  ;
        ;-----------------------------------------;
        
       cmp host,1
       jnz guest2  
         
         
      ;Setting fishy     -------------------------;
        host2:                                          ;
        mov cx,8                                  ;
        mov di,offset fish                        ;
        mov bx,2                                  ;
        mov ax,176d                               ;;the first y posiotion
                                                  ;
                                                  ;
                                                  ;
        fish_y:                                   ;
        mov di[bx],ax                             ;
        add bx ,8                                 ;
        add ax,30d                                ;
        loop fish_y                               ;
        ;-----------------------------------------;                                          
                                                  
                                                  
        ;Randomize fishx--------------------------;
        mov cx,8                                  ;
        mov di,offset fish                        ;
        mov bx,0                                  ;                                       
                                                  ;
        push cx                                   ;
        mov ah,2Ch ;get system time               ;
        int 21h    ;ch:hrs,cl:min,dh:sec,dl:1/100 ;
        pop cx                                    ;
        mov dh,0                                  ;
        mov variable,dx                           ;
                                                  ;
                                                  ;
                                                  ;
        fish_x:                                   ;
                                                  ;
        add variable,263d  ;just a random number  ;
        modulus:                                  ;
        cmp variable,480d                         ;
        jb endx                                   ;
        sub variable,480d                         ;
        jmp modulus                               ;
                                                  ;
        endx:                                     ;
        add variable,80d                          ;
        mov dx,variable                           ;
        mov di[bx],dx                             ;
                                                  ;
                                                  ;
        add bl,8                                  ;
        loop fish_x                               ;
        ;-----------------------------------------;
         
         
        ;Randomize direction----------------------; 
                                                  ;  
        mov ah,2Ch ;get system time               ;
        int 21h ;ch:hrs,cl:min,dh:sec,dl:1/100    ;
                                                  ;
                                                  ;
        mov ah,0                                  ;
        mov al,dl                                 ;
        mov bh,12 ;cause direction contains 20 no.;
        div bh                                    ;
                                                  ;
        mov al,ah                                 ;
        mov ah,0                                  ;
        mov var2,ax                               ;
        mov bx,var2                               ;
                                                  ;
        mov cx,8                                  ;
        mov ax,var2                               ;
        mov bx,0                                  ;
        dirr:                                     ;
                                                  ;
        push bx                                   ;
        mov bx,ax                                 ;
        mov dx,direction[bx]                      ;
        pop bx                                    ;
        mov dl,dh                                 ;
        mov dh,00                                 ;
        mov fish[bx]+4,dx                         ;
                                                  ;
        inc ax                                    ;
        add bx,8                                  ;
                                                  ;
        loop dirr                                 ;
                                                  ;
        ;-----------------------------------------;  
                                                 
         ;Sending------------------------------------  
        mov cx,64 
        mov di,offset fish
        mov bx,0 
        sendingfish: 
        ;mov value,di[bx]
        send di[bx]
  		inc bx
  		loop sendingfish                                 
  		;------------------------------------------                                         
        
        jmp FishDrawing
        guest2:
        ;;Recieving-----------
        mov cx,64 
        mov di,offset fish
        mov bx,0
        recievingfish:
        Recieve
        mov di[bx] , al 
        inc bx
        loop recievingfish
        ;----------------------------
        
        
                                                 
        ;Drawing Fishes --------------------------;
        FishDrawing:                              ;
        mov cx,8                                  ;
        mov di ,offset fish                       ;
        mov bx,0                                  ;
                                                  ;
        drawfish1:                                ;
                                                  ;
        cmp [Di]+4,1 ;direction:1 left        ;
        jne fishright1                            ;
                                                  ;
        push bx                                   ;
        mov bx,[Di]                           ;
        mov drx,bx                                ; setting drx for the proc
        mov bx,[Di]+2                         ;                         
        mov dry,bx                                ; setting dry for the proc
        mov dcolor,03h                            ; setting dcolor with the fish color
        pop bx                                    ;
        cmp [di],528                          ;
        ja end1                                   ;
        call Drawfishleftp                        ;
        jmp end1                                  ;
                                                  ;
        fishright1:                               ;
        push bx                                   ;
        mov bx,[Di]                           ;
        mov drx,bx                                ; setting drx for the proc
        mov bx,[Di]+2                         ;                         
        mov dry,bx                                ; setting dry for the proc
        mov dcolor,03h                            ; setting dcolor with the fish color          
        pop bx                                    ;
        cmp [di],112                          ;
        jb end1                                   ;
        call Drawfishrightp                       ;
        end1:                                     ;    
        add di,8                                  ;
                                                  ;
        loop drawfish1                            ;
                                                  ;
        ;-----------------------------------------; 
        
        
            
         
        
        MainLoop: 
        
        
        
        ;Clear Hooks -----------------------------;
                                                  ;
        HorizontalLine 44 52 xend1 52 09h         ;
        VerticalLine xend1 52 xend1 140 09h       ; ;clear the upper part with sky color
        VerticalLine xend1 140 xend1 yend1 01h    ; ;clear the lower part with the sea color
        inc xend1                                 ;
        VerticalLine xend1 52 xend1 140 09h       ; 
        VerticalLine xend1 140 xend1 yend1 01h    ;                                         
        dec xend1                                 ;
                                                  ;
        HorizontalLine xstart2 52 596 52 09h      ;
        VerticalLine xstart2 52 xstart2 140 09h   ;
        VerticalLine xstart2 140 xstart2 yend2 01h;                                       
        inc xstart2                               ;
        VerticalLine xstart2 52 xstart2 140 09h   ;
        VerticalLine xstart2 140 xstart2 yend2 01h;                                         
        dec xstart2                               ;
        ;-----------------------------------------;
        
        
        
        ;Clear Fishes ----------------------------;
                                                  ;
        mov cx,8                                  ;
        mov di ,offset fish                       ;
        mov bx,0                                  ;
                                                  ;
        clearfish1:                               ;
                                                  ;
        cmp fish[Di]+4,1                          ;
        jne fishright11                           ;
                                                  ;
        push bx                                   ;
        mov bx,fish[Di]                           ;
        mov drx,bx                                ; ;setting drx for the proc
        mov bx,fish[Di]+2                         ;
        mov dry,bx                                ; ;setting dry for the proc
        mov dcolor,01h                            ; ;clear with the sea color
        pop bx                                    ;
        cmp fish[di],528                          ;
        ja end11                                  ;
        call Drawfishleftp                        ;
        jmp end11                                 ;
                                                  ;
        fishright11:                              ;
        push bx                                   ;
        mov bx,fish[Di]                           ;
        mov drx,bx                                ; ;setting drx for the proc 
        mov bx,fish[Di]+2                         ;                           
        mov dry,bx                                ; ;setting dry for the proc 
        mov dcolor,01h                            ; ;clear with the sea color
        pop bx                                    ;
        cmp fish[di],112                          ;
        jb end11                                  ;
        call Drawfishrightp                       ;
        end11:                                    ;    
        add di,8                                  ;
                                                  ;
        loop clearfish1                           ;
                                                  ;
        ;-----------------------------------------;
        
      ;***********************************************************************************************   
        
        ;Drawing Hooks ---------------------------;
                                                  ;
                                                  ;
        cmp host,1
        jz host3                                          
        jmp guest3                                          ;
        ;Reading input                            ;
        host3:                                          ;
        KeyPressed                                ;
        jz sendnull1 ;;meeen hna?                                 ;
                                                  ;
        CheckKeyPressed                           ;
                                                  ;
        cmp ah,4Bh ;left arrow                                ;; 
        jnz right1                              ;;player 1 left 
        
        
        mov value,0FCh ;ascii left encrypted XD
        send value
        jmp horiz1dec
        
        right1:                                          ;
        cmp ah,4DH                                ;;
        jnz down1                              ;;Player 1 right
        
        mov value,0FBh    ;ascii right encrypted
        send value
        jmp horiz1inc
        
        down1:                                          ;
        cmp ah,50H                                ;;
        jnz up1                           ;;player 1 down 
        
        
        mov value,0FDh    ;ascii down encrypted
        send value
        jmp vertical1inc
        
        up1:                                          ;
        cmp ah,48H                                ;;
        jnz f31                           ;;Player 1 up 
        
        mov value,0FEh    ;ascii up encrypted
        send value
        jmp vertical1dec
        
        f31:
        cmp ah,3Dh
        jnz char1 ; el mafrood eno inline chat b2a
        
        mov value,0FFh    ;ascii up encrypted
        send value
        jmp MainMenu
        
        char1:
        ;hna el inline chat w cursors b2a w bta3
        cmp mycursorinline,1A4Fh
        jnz adjustcursor
        
        ;lw a5er el satr
        MoveCursor 1Ah 00h
        Displaystring blackstr
        MoveCursor 1Ah 00h
        
        jmp printandsend1
        adjustcursor:
        MOV AH, 02                               
        MOV BH, 00                       
        MOV dx,mycursorinline                        
        INT 10H
        
        printandsend1:
        mov value,al
        Displaychar value
        getcursor mycursorinline
        send value
        
        
        jmp recieveguest
        sendnull1:
        send 0
        
        recieveguest:
        recieve    
  		mov value,al
  		         
        cmp al,0
        jz draw 
                                                  ;
        cmp al,0FCH  ;dah left                              ;;right arrow
        jz horiz2inc                              ;
                                                   ;
        cmp al,0FBH                                ;;left arrow
        jz horiz2dec                              ;
                                                  ;
        cmp al,0FDH                                ;;down arrow
        jz vertical2inc                           ;
                                                  ;
        cmp al,0FEH                                ;;up arrow
        jz vertical2dec                           ;
                                                  ;
        cmp al,0FFh                                 ;;escape key
        jz MainMenu                               ;;el mafrood mafeesh esc w f3 trag3ni main menu
                                                  ; 
        ;hna yrecieve el chat bta3 el guest
        cmp hiscursorinline,1C4Fh
        jnz adjustcursor2
        
        ;lw a5er el satr
        MoveCursor 1Ch 00h
        Displaystring blackstr
        MoveCursor 1Ch 00h
        
        jmp printandsend2
        adjustcursor2:
        MOV AH, 02                               
        MOV BH, 00                       
        MOV dx,hiscursorinline                        
        INT 10H
        
        printandsend2:
        mov value,al
        Displaychar value
        getcursor hiscursorinline                                                        
                                                  
        jmp Draw                                 ;
                                                  ;
                                                  ; 
        guest3:
        
        KeyPressed                                ;
        jz sendnull2                                  ;
                                                  ;
        CheckKeyPressed                           ;
                                                  ;
        cmp ah,4Bh ;left arrow                                ;; 
        jnz right2                              ;;player 1 left 
        
        
        mov value,0FCh ;ascii left encrypted XD
        send value
        jmp horiz2inc
        
        right2:                                          ;
        cmp ah,4DH                                ;;
        jnz down2                              ;;Player 1 right
        
        mov value,0FBh    ;ascii right encrypted
        send value
        jmp horiz2dec
        
        down2:                                          ;
        cmp ah,50H                                ;;
        jnz up2                           ;;player 1 down 
        
        
        mov value,0FDh    ;ascii down encrypted
        send value
        jmp vertical2inc
        
        up2:                                          ;
        cmp ah,48H                                ;;
        jnz f32                           ;;Player 1 up 
        
        mov value,0FEh    ;ascii up encrypted
        send value
        jmp vertical2dec
        
        f32:
        cmp ah,3Dh
        jnz char2 ; el mafrood eno inline chat b2a
        
        mov value,0FFh    ;ascii up encrypted
        send value
        jmp MainMenu
        
        char2:
        ;hna el inline chat w cursors b2a w bta3
        cmp mycursorinline,1A4Fh
        jnz adjustcursor3
        
        ;lw a5er el satr
        MoveCursor 1Ah 00h
        Displaystring blackstr
        MoveCursor 1Ah 00h
        
        jmp printandsend3
        adjustcursor3:
        MOV AH, 02                               
        MOV BH, 00                       
        MOV dx,mycursorinline                        
        INT 10H
        
        printandsend3:
        mov value,al
        Displaychar value
        getcursor mycursorinline
        send value
               
        jmp recievehost
        sendnull2:
        send 0       
         
        recievehost:
        recieve    
  		mov value,al
  		         
        cmp al,0
        jz draw
  		         
                                                  ;
        cmp al,0FCH                                ;;right arrow
        jz horiz1dec                              ;
                                                  ;
        cmp al,0FBH                                ;;left arrow
        jz horiz1inc                              ;
                                                  ;
        cmp al,0FDH                                ;;down arrow
        jz vertical1inc                           ;
                                                  ;
        cmp al,0FEH                                ;;up arrow
        jz vertical1dec                           ;
                                                  ;
        cmp al,0FFh                                 ;;escape key
        jz MainMenu                               ;;el mafrood mafeesh esc w f3 trag3ni main menu
        
        ;hna yrecieve el chat bta3 el host
        cmp hiscursorinline,1C4Fh
        jnz adjustcursor4
        
        ;lw a5er el satr
        MoveCursor 1Ch 00h
        Displaystring blackstr
        MoveCursor 1Ch 00h
        
        jmp printandsend4
        adjustcursor4:
        MOV AH, 02                               
        MOV BH, 00                       
        MOV dx,hiscursorinline                        
        INT 10H
        
        printandsend4:
        mov value,al
        Displaychar value
        getcursor hiscursorinline 
        
      ;*********************************************************************************************************;
        
        
                                                  
                                                  
        ;Performing Action                        ;
        jmp Draw
                                                  ;
        horiz1dec:                                ;
        cmp xend1,113d                            ;;if it reached its border just draw 
        jz Draw                                   ;
        decrement xend1                           ;
        decrement xend1                           ;
        jmp Draw                                  ;
                                                  ;
        horiz1inc:                                ;
        cmp xend1,315d                            ;
        jz Draw                                   ;
        increment xend1                           ;
        increment xend1                           ;
        jmp Draw                                  ;
                                                  ;
        vertical1inc:                             ;
        cmp yend1,400d                            ;
        jz Draw                                   ;
        increment yend1                           ;
        jmp Draw                                  ;
                                                  ;
        vertical1dec:                             ;
        cmp yend1,160d                            ;
        jz Draw                                   ;
        decrement yend1                           ;
        jmp Draw                                  ;
                                                  ;
        horiz2dec:                                ;
        cmp xstart2,527d                          ;
        jz Draw                                   ;
        increment xstart2                         ;
        increment xstart2                         ;
        jmp Draw                                  ;
                                                  ;
        horiz2inc:                                ;
        cmp xstart2,325                           ;
        jz Draw                                   ;
        decrement xstart2
        decrement xstart2                         ;
        jmp Draw                                  ;
                                                  ;
        vertical2inc:                             ;
        cmp yend2,400                             ;
        jz Draw                                   ;
        increment yend2                           ;
        jmp Draw                                  ;
                                                  ;
        vertical2dec:                             ;
        cmp yend2,160                             ;
        jz Draw                                   ;
        decrement yend2                           ;
        jmp Draw                                  ;
                                                  ;
                                                  ;
        Draw:                                     ;
                                                  ;
        HorizontalLine 44 52 xend1 52 0           ;;hook1
        VerticalLine xend1 52 xend1 yend1 0       ;
        inc xend1
        VerticalLine xend1 52 xend1 yend1 0 
        dec xend1 
                                                  ;
        HorizontalLine xstart2 52 596 52 0        ;;hook2
        VerticalLine xstart2 52 xstart2 yend2 0   ;
        inc xstart2
        VerticalLine xstart2 52 xstart2 yend2 0 
        dec xstart2
                                                  ;
        ;-----------------------------------------;
        
        ;Fishes Caught?---------------------------;                                          
        fishcaught:                                          ;
        mov cx,8                                  ;
        mov di ,offset fish                       ;
        MoveFish11:                               ;
                                                  ;
        cmp fish[di]+6,1                          ;;caught by first man?          
        jne endmov11                              ;;if no check if it is caught by second man
                                                  ;;if yes                         
        cmp xend1,113d                            ;;check if we reached the borders
        jne comp1                                 ;
        cmp yend1,160d                            ;
        jne comp1                                 ;
                                                  ;
        increment counter1                        ;;if we reached the border we inc counter       
        mov fish[di],113d                         ;;we add a new fish at this border               
        mov ax,y1caught                           ;;with the same y coordinate of the previous one
        mov fish[di]+2 ,ax                        ;                                               
        mov y1caught,0                            ;                                               
        mov fish[di]+4,0                          ;;set direction to right                         
        mov fish[di]+6,0                          ;;set caught to zero                            
        mov 1firstcaught,1                        ;;obviously sice the player is not catching now then it is not the first moment of catching                                               
        mov catching1,0                           ;; the first man is not catching now           
        jmp endmov111                             ;                                               
                                                  ;                                               
        comp1:                                    ;;if we didn't reach the border                 
        mov ax,xend1                              ;;set x,y of the fish with x,y hook             
        mov fish[di],ax                           ;
        mov ax,yend1                              ;
        mov fish[di]+2,ax                         ;
        jmp endmov111                             ;
                                                  ;
                                                  ;
                                                  ;
        endmov11:                                 ;
        cmp fish[di]+6,2                          ;;caught by second man?
        jne endmov111                             ;;if no continue to the next fish
                                                  ;;if yes 
        cmp xstart2,527d                          ;;check if we reached the borders
        jne comp2                                 ;
        cmp yend2,160d                            ;
        jne comp2                                 ;
                                                  ;
        increment counter2                        ;;if we reached the border we inc counter
        mov fish[di],527d                         ;;we add anew fish at this border
        mov ax,y2caught                           ;;with the same y coordinate of the previous one
        mov fish[di]+2 ,ax                        ;
        mov y2caught,0                            ;
        mov fish[di]+4,1                          ;;set direction to left
        mov fish[di]+6,0                          ;;set caught to zero
        mov 2firstcaught,1                        ;
        mov catching2,0                           ;; the second man is not catching now
        jmp endmov111                             ;
                                                  ;
        comp2:                                    ;;if we didn't reach the border 
        mov ax,xstart2                            ;;set x,y of the fish with x,y hook
        mov fish[di],ax                           ;
        mov ax,yend2                              ;
        mov fish[di]+2,ax                         ;
                                                  ;
        endmov111:                                ;
        add di,8                                  ;
                                                  ;
        loop MoveFish11                           ;
                                                  ;
                                                  ;
                                                  ;
        ;-----------------------------------------;                                         
                                                  
        
        ;Moving Fish    --------------------------;
                                                  ;
        mov cx,8                                  ;
        mov di ,offset fish                       ;
                                                  ;
        MoveFish:                                 ;
                                                  ;
                                                  ;
        cmp fish[di]+4,0                          ;
        jne leftmove                              ;
        ;Moving Right                             ;
                                                  ;
                                                  ;   
        ;hook1                                    ;
        mov ax,fish[di]                           ;
        mov xfish ,ax                             ;
        mov ax ,fish[di]+2                        ;
        mov yfish ,ax                             ;
                                                  ;
        mov ax,xfish                              ;
        cmp xend1, ax                             ;
        jne xminusone                             ;   
                                                  ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;        
        jmp moving                                ;
                                                  ;
        xminusone:                                ;
        dec xfish                                 ;
        mov ax,xfish                              ;
        cmp xend1, ax                             ;
        jne xminustwo                             ;
                                                  ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
                                                  ;
        dec yfish                                 ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
                                                  ;
        add yfish,2                               ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
        dec yfish                                 ;
        jmp moving                                ;
                                                  ;
        xminustwo:                                ;         
        dec xfish                                 ;
        mov ax,xfish                              ;
        cmp xend1, ax                             ;
        jne xminusthree                           ;     
                                                  ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
                                                  ;
        dec yfish                                 ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
                                                  ;
        add yfish,2                               ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
        jmp moving                                ;
                                                  ;
        xminusthree:                              ;           
        dec xfish                                 ;
        mov ax,xfish                              ;
        cmp xend1, ax                             ;
        jne hook2                                 ;
                                                  ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
                                                  ;
        dec yfish                                 ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
                                                  ;
        dec yfish                                 ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
                                                  ;
        add yfish,3                               ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
                                                  ;
        add yfish,1                               ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
        jmp moving                                ;
                                                  ;
                                                  ;
        hook2:                                    ;                             
        mov ax,fish[di]                           ;
        mov xfish ,ax                             ;
        mov ax ,fish[di]+2                        ;
        mov yfish ,ax                             ;
                                                  ;
                                                  ;
        mov ax,xfish                              ;
        cmp xstart2, ax                           ; 
        jne xminusone2                            ;    
                                                  ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;         
        jmp moving                                ;
                                                  ;
        xminusone2:                               ;          
        dec xfish                                 ;
        mov ax,xfish                              ;
        cmp xstart2, ax                           ; 
        jne xminustwo2                            ;    
                                                  ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
                                                  ;
        dec yfish                                 ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
                                                  ;
        add yfish,2                               ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
        dec yfish                                 ;
        jmp moving                                ;
                                                  ;
        xminustwo2:                               ;          
        dec xfish                                 ;
        mov ax,xfish                              ;
        cmp xstart2, ax                           ; 
        jne xminusthree2                          ;      
                                                  ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
                                                  ;
        dec yfish                                 ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
                                                  ;
        add yfish,2                               ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
        jmp moving                                ;
                                                  ;
        xminusthree2:                             ;            
        dec xfish                                 ;
        mov ax,xfish                              ;
        cmp xstart2, ax                           ; 
        jne moving                                ;
                                                  ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
                                                  ;
        dec yfish                                 ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
                                                  ;
        dec yfish                                 ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
                                                  ;
        add yfish,3                               ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
        jmp moving                                ;
                                                  ;
        add yfish,1                               ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
        jmp moving                                ;
                                                  ;
                                                  ;
        ;Moving Left                              ;
        Leftmove:                                 ;
                                                  ;
        mov ax,fish[di]                           ;
        mov xfish ,ax                             ;
        mov ax ,fish[di]+2                        ;
        mov yfish ,ax                             ;
                                                  ;
        mov ax,xfish                              ;
        cmp xend1, ax                             ;
        jne xplusone                              ;  
                                                  ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;        
        jmp moving                                ;
                                                  ;
        xplusone:                                 ;        
        inc xfish                                 ;
        mov ax,xfish                              ;
        cmp xend1, ax                             ;
        jne xplustwo                              ;  
                                                  ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
                                                  ;
        dec yfish                                 ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
                                                  ;
        add yfish,2                               ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
        dec yfish                                 ;
        jmp moving                                ;
                                                  ;
        xplustwo:                                 ;        
        inc xfish                                 ;
        mov ax,xfish                              ;
        cmp xend1, ax                             ;
        jne xplusthree                            ;    
                                                  ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
                                                  ;
        dec yfish                                 ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
                                                  ;
        add yfish,2                               ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
        jmp moving                                ;
                                                  ;
        xplusthree:                               ;          
        inc xfish                                 ;
        mov ax,xfish                              ;
        cmp xend1, ax                             ;
        jne hook22                                ;
                                                  ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
                                                  ;
        dec yfish                                 ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
                                                  ;
        dec yfish                                 ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
                                                  ;
        add yfish,3                               ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
        jmp moving                                ;
                                                  ;
        add yfish,1                               ;
        mov ax,yfish                              ;
        cmp yend1, ax                             ;
        je firsthookcaught                        ;
        jmp moving                                ;
                                                  ;
                                                  ;
        hook22:                                   ;                              
        mov ax,fish[di]                           ;
        mov xfish ,ax                             ;
        mov ax ,fish[di]+2                        ;
        mov yfish ,ax                             ;
                                                  ;
                                                  ;
        mov ax,xfish                              ;
        cmp xstart2, ax                           ; 
        jne xplusone2                             ;   
                                                  ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;         
        jmp moving                                ;
                                                  ;
        xplusone2:                                ;         
        inc xfish                                 ;
        mov ax,xfish                              ;
        cmp xstart2, ax                           ; 
        jne xplustwo2                             ;   
                                                  ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
                                                  ;
        dec yfish                                 ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
                                                  ;
        add yfish,2                               ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
        dec yfish                                 ;
        jmp moving                                ;
                                                  ;
        xplustwo2:                                ;         
        inc xfish                                 ;
        mov ax,xfish                              ;
        cmp xstart2, ax                           ; 
        jne xplusthree2                           ;     
                                                  ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
                                                  ;
        dec yfish                                 ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
                                                  ;
        add yfish,2                               ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
                                                  ;
        xplusthree2:                              ;           
        inc xfish                                 ;
        mov ax,xfish                              ;
        cmp xstart2, ax                           ; 
        jne moving                                ;
                                                  ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
                                                  ;
        dec yfish                                 ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
                                                  ;
        dec yfish                                 ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
                                                  ;
        add yfish,3                               ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
                                                  ;
        add yfish,1                               ;
        mov ax,yfish                              ;
        cmp yend2, ax                             ;
        je secondhookcaught                       ;
                                                  ;
        jmp moving                                ;
        firsthookcaught:                          ;
                                                  ;
        mov ax,fish[di]                           ;
        mov xfish ,ax                             ;
        mov ax ,fish[di]+2                        ;
        mov yfish ,ax                             ;
                                                  ;
        cmp catching1,1                           ;
        je moving                                 ;
        mov catching1,1                           ;
        mov fish[di]+6,1 ; caught                 ;
        cmp 1firstcaught,1                        ;
        jne moving                                ;
        mov ax,yend1                              ;
        mov y1caught ,ax                          ;
        mov 1firstcaught,0                        ;
                                                  ;
                                                  ;
        jmp moving                                ;
        secondhookcaught:                         ;
                                                  ;
        mov ax,fish[di]                           ;
        mov xfish ,ax                             ;
        mov ax ,fish[di]+2                        ;
        mov yfish ,ax                             ;
                                                  ;
        cmp catching2,1                           ;
        je moving                                 ;
        mov catching2,1                           ;
        mov fish[di]+6,2 ; caught                 ;
        cmp 2firstcaught,1                        ;
        jne moving                                ;
        mov ax,yend2                              ;
        mov y2caught ,ax                          ;
        mov 2firstcaught,0                        ;
                                                  ;
                                                  ;
                                                  ;
                                                  ;          
        moving:                                   ;
                                                  ;
        mov ax,fish[di]                           ;
        mov xfish ,ax                             ;
        mov ax ,fish[di]+2                        ;
        mov yfish ,ax                             ;
                                                  ;
                                                  ;
        cmp fish[di]+6,1                          ;
        je endmov                                 ;
                                                  ;
        cmp fish[di]+6,2                          ;
        je endmov                                 ;
                                                  ;
         ;moving horizontal                       ;
        cmp fish[di]+4,1                          ;
        je moveleft                               ;
                                                  ;
        ; move right                              ;
        ;increment xfish                          ;
                                                  ;
        mov ax, xfish                             ;
        cmp ax,560d                               ;
        jne lbl1                                  ;
                                                  ;
        mov fish[di]+4,1                          ;
        mov ax, xfish                             ;
        mov ax,528d                               ;
        mov fish[di],ax                           ;
        jmp endmov                                ;
                                                  ;
        lbl1:                                     ;
        inc ax                                    ;
        mov fish[di],ax                           ;
                                                  ;
        jmp endmov                                ;
                                                  ;
        moveleft:                                 ;
        ;decrement xfish                          ;
        mov ax,xfish                              ;
        cmp ax,80d                                ;
        jne lbl2                                  ;
                                                  ;
        mov fish[di]+4,0                          ;
        mov ax, xfish                             ;
        mov ax,112d                               ;
        mov fish[di],ax                           ;
        jmp endmov                                ;
                                                  ;
        lbl2:                                     ;
        dec ax                                    ;
        mov fish[di],ax                           ;
                                                  ;
        endmov:                                   ;
        add di,8                                  ;
                                                  ;
        loop MoveFish                             ;
                                                  ;
        ;-----------------------------------------;
                                                  
                                                 
         
        ;Drawing Fishes --------------------------;
                                                  ;
        mov cx,8                                  ;
        mov di ,offset fish                       ;
        mov bx,0                                  ;
                                                  ;
        drawfish:                                 ;
                                                  ;
        cmp fish[Di]+4,1;direction,0:right,1:left ;
        jne fishright                             ;
                                                  ;
        push bx                                   ;
        mov bx,fish[Di]                           ;
        mov drx,bx                                ;;setting drx for the proc (mouth x coordinate)
        mov bx,fish[Di]+2                         ;                                              
        mov dry,bx                                ;;setting dry for the proc (mouth y coordinate)
        mov dcolor,03h                            ;;color of the fish                            
        pop bx                                    ;
        cmp fish[di],528                          ;
        ja endloop1                               ;
        call Drawfishleftp                        ;
        jmp endloop1                              ;
                                                  ;
                                                  ;
        fishright:                                ;
        push bx                                   ;
        mov bx,fish[Di]                           ;
        mov drx,bx                                ;;setting drx for the proc (mouth x coordinate)
        mov bx,fish[Di]+2                         ;
        mov dry,bx                                ;;setting dry for the proc (mouth y coordinate)
        mov dcolor,03h                            ;;color of the fish
        pop bx                                    ;
        cmp fish[di],112                          ;
        jb endloop1                               ;      
        call Drawfishrightp                       ;
        endloop1:                                 ;    
        add di,8                                  ;
                                                  ;
        loop drawfish                             ;
                                                  ;
        ;-----------------------------------------; 
        
       
        
        ;MoveCursor 1Ah 0   
        ;DisplayString chat
        ;MoveCursor 1Ch 0   
        ;DisplayString game 
        ;MoveCursor 1Ch 0   
        ;DisplayString esc
        MoveCursor 19h 0
        DisplayString player1+2
        Displaychar ':'
        MoveCursor 1Bh 0
        DisplayString player2+2  
        Displaychar ':'
        MoveCursor 1Dh 0
        DisplayString f3
        
        
        ;UpdateResult ----------------------------;
                                                  ;
        MoveCursor 0 16                           ;
        mov bx,counter1                           ;
        add bx,'0'                                ;
        mov str[1],bl                             ;  
        DisplayString str                         ;
                                                  ;
        MoveCursor 0 76                           ;
        mov bx,counter2                           ;
        add bx,'0'                                ;
        mov str[1],bl                             ;  
        DisplayString str                         ;
                                                  ;
        ;-----------------------------------------;
        
        
        ;Checking if any player won---------------;
        cmp counter1,5;1                          ;
        je gameover11                             ;
        cmp counter2,5;1                          ;
        je gameover11                             ;
        ;-----------------------------------------;
        
        mov al,level
        cmp al,2
        jz level2                     
        Delay 5
        jmp MainLoop
        level2:
        Delay 4
        
        jmp MainLoop
         
        
        ;Ending Status ----------------------------;
        gameover11:                                ;
                                                   ;
        MoveCursor 14d 0                           ;
        DisplayString blackstr                     ;
        MoveCursor 15d 0                           ;
        DisplayString blackstr                     ;
        MoveCursor 16d 0                           ;
        DisplayString blackstr                     ;
                                                   ;
        cmp host,1
        jnz guest4                                           
                                                   ;
        cmp counter1,5;1                           ;
        jne player2win                             ;
        MoveCursor 15d 32d                         ;
        DisplayString player1+2                    ;
        mov al,player1                             ;
        ;mov al,ah                                  ;
        add al,32d                                 ;
        mov cursor,al                              ;
        jmp player1win                             ;
        player2win:                                ;
        MoveCursor 15d 32d                         ;
        DisplayString player2+2                    ;
        mov al,player2                             ;
        ;mov al,ah                                  ;
        add al,32d                                 ;
        mov cursor,al                              ;
        jmp player1win 
        
        guest4:
        cmp counter1,5;1                           ;
        jne player2win2                             ;
        MoveCursor 15d 32d                         ;
        DisplayString player2+2                    ;
        mov al,player1                             ;
        add al,32d                                 ;
        mov cursor,al                              ;
        jmp player1win                             ;
        player2win2:                                ;
        MoveCursor 15d 32d                         ;
        DisplayString player1+2                    ;
        mov al,player2                             ;
        add al,32d                                 ;
        mov cursor,al                              ;
        
      
        player1win:                                ;                                           ; 
        MoveCursor 15d cursor                      ;                     
        DisplayString Gameover                     ;
        Delay 300                                  ;
        ;MoveCursor 1Ah 0                           ;
        ;DisplayString RestartGame                  ;
        ;------------------------------------------;  
        
        
        ;Restarting Or Ending----------------------;
        mov counter1,0                             ;
        mov counter2,0                             ;
                                                   ;
        again:                                     ;
        KeyPressed                                 ;
        jz serialin                                 ;
                                                   ;
        CheckKeyPressed                            ;
        cmp ah,3Dh;f3
        jz sendmain
        
        jmp serialin
        sendmain:
        send 0FFh
        jmp MainMenu
        
         
        serialin:
        
         mov dx , 3FDH		; Line Status Register
         	
	    in al , dx 
  		AND al , 1
  		JZ again  ;if no 
  		
  		; if yes
  		mov dx , 03F8H
  		in al , dx 
  		
  		cmp al,0FFh
  		jz MainMenu    
        
        jmp again                                           ;
                                          ;
        ;------------------------------------------; 
        
        
        endall:
        mov ah,4Ch
        int 21h  
       
        main endp                          
       
       
;Drawing the fish in the Right direction----------; 
                                                  ;
Drawfishrightp proc  ; drx    dry   dcolor        ;
    PUSHA                                         ;
    mov ax,drx                                    ;
    mov bx,dry                                    ;
    ;mid                                          ;
    mov cx,ax                                     ;
    sub cx,22                                     ;
    mov drx2,cx                                   ;
    HorizontalLine drx2 dry drx dry dcolor        ;
                                                  ;
    ;y-1                                          ;
    mov dx,bx                                     ;
    sub dx,1                                      ;
    mov dry,dx                                    ;
                                                  ;
    mov cx,ax                                     ;
    sub cx,1                                      ;
    mov drx,cx                                    ;
    HorizontalLine drx2 dry drx dry dcolor        ;
                                                  ;
    ;y+1                                          ;
    mov dx,bx                                     ;
    add dx,1                                      ;
    mov dry,dx                                    ;
    HorizontalLine drx2 dry drx dry dcolor        ;
                                                  ;
    ;y-2                                          ;
    mov dx,bx                                     ;
    sub dx,2                                      ;
    mov dry,dx                                    ;
                                                  ;
    mov cx,ax                                     ;
    sub cx,2                                      ;
    mov drx,cx                                    ;
    HorizontalLine drx2 dry drx dry dcolor        ;
                                                  ;
    ;y+2                                          ;
    mov dx,bx                                     ;
    add dx,2                                      ;
    mov dry,dx                                    ;
    HorizontalLine drx2 dry drx dry dcolor        ;
                                                  ;
                                                  ;
     mov cx,ax                                    ;
    sub cx,18                                     ;
    mov drx2,cx                                   ;
                                                  ;
    ;y-3                                          ;
    mov dx,bx                                     ;
    sub dx,3                                      ;
    mov dry,dx                                    ;
                                                  ;
    mov cx,ax                                     ;
    sub cx,4                                      ;
    mov drx,cx                                    ;
    HorizontalLine drx2 dry drx dry dcolor        ;
                                                  ;
    ;y+3                                          ;
    mov dx,bx                                     ;
    add dx,3                                      ;
    mov dry,dx                                    ;
    HorizontalLine drx2 dry drx dry dcolor        ;
                                                  ;
    mov cx,ax                                     ;
    sub cx,17                                     ;
    mov drx2,cx                                   ;
                                                  ;
    ;y-4                                          ;
    mov dx,bx                                     ;
    sub dx,4                                      ;
    mov dry,dx                                    ;
                                                  ;
    mov cx,ax                                     ;
    sub cx,5                                      ;
    mov drx,cx                                    ;
    HorizontalLine drx2 dry drx dry dcolor        ;
                                                  ;
    ;y+4                                          ;
    mov dx,bx                                     ;
    add dx,4                                      ;
    mov dry,dx                                    ;
    HorizontalLine drx2 dry drx dry dcolor        ;
                                                  ;
                                                  ;
    mov cx,ax                                     ;
    sub cx,15                                     ;
    mov drx2,cx                                   ;
                                                  ;
    ;y-5                                          ;
    mov dx,bx                                     ;
    sub dx,5                                      ;
    mov dry,dx                                    ;
                                                  ;
    mov cx,ax                                     ;
    sub cx,7                                      ;
    mov drx,cx                                    ;
    HorizontalLine drx2 dry drx dry dcolor        ;
                                                  ;
    ;y+5                                          ;
    mov dx,bx                                     ;
    add dx,5                                      ;
    mov dry,dx                                    ;
    HorizontalLine drx2 dry drx dry dcolor        ;
                                                  ;
    mov cx,ax                                     ;
    sub cx,14                                     ;
    mov drx2,cx                                   ;
                                                  ;
    ;y-6                                          ;
    mov dx,bx                                     ;
    sub dx,6                                      ;
    mov dry,dx                                    ;
                                                  ;
    mov cx,ax                                     ;
    sub cx,8                                      ;
    mov drx,cx                                    ;
    HorizontalLine drx2 dry drx dry dcolor        ;
                                                  ;
    ;y+6                                          ;
    mov dx,bx                                     ;
    add dx,6                                      ;
    mov dry,dx                                    ;
    HorizontalLine drx2 dry drx dry dcolor        ;
                                                  ;
     mov cx,ax                                    ;
    sub cx,12                                     ;
    mov drx2,cx                                   ;
                                                  ;
    ;y-7                                          ;
    mov dx,bx                                     ;
    sub dx,7                                      ;
    mov dry,dx                                    ;
                                                  ;
    mov cx,ax                                     ;
    sub cx,10                                     ;
    mov drx,cx                                    ;
    HorizontalLine drx2 dry drx dry dcolor        ;
                                                  ;
    ;y+7                                          ;
    mov dx,bx                                     ;
    add dx,7                                      ;
    mov dry,dx                                    ;
    HorizontalLine drx2 dry drx dry dcolor        ;
                                                  ;
                                                  ;
    mov dx,bx                                     ;
    sub dx,11                                     ;
    mov dry2,dx                                   ;
                                                  ;
    mov dx,bx                                     ;
    sub dx,8                                      ;
    mov dry,dx                                    ;
                                                  ;
    mov cx,ax                                     ;
    sub cx,32                                     ;
    mov drx2,cx                                   ;
                                                  ;
    mov cx,ax                                     ;
    sub cx,28                                     ;
    mov drx,cx                                    ;
                                                  ;
    DrawRectangle  drx2 dry2 drx dry dcolor       ;
                                                  ;
    mov dx,bx                                     ;
    sub dx,8                                      ;
    mov dry2,dx                                   ;
                                                  ;
    mov dx,bx                                     ;
    sub dx,3                                      ;
    mov dry,dx                                    ;
                                                  ;
    mov cx,ax                                     ;
    sub cx,27                                     ;
    mov drx2,cx                                   ;
                                                  ;
    mov cx,ax                                     ;
    sub cx,23                                     ;
    mov drx,cx                                    ;
                                                  ;
    DrawRectangle  drx2 dry2 drx dry dcolor       ;
                                                  ;
     mov dx,bx                                    ;
    add dx,11                                     ;
    mov dry,dx                                    ;
                                                  ;
    mov dx,bx                                     ;
    add dx,8                                      ;
    mov dry2,dx                                   ;
                                                  ;
    mov cx,ax                                     ;
    sub cx,32                                     ;
    mov drx2,cx                                   ;
                                                  ;
    mov cx,ax                                     ;
    sub cx,28                                     ;
    mov drx,cx                                    ;
                                                  ;
    DrawRectangle  drx2 dry2 drx dry dcolor       ;
                                                  ;
     mov dx,bx                                    ;
    add dx,8                                      ;
    mov dry,dx                                    ;
                                                  ;
    mov dx,bx                                     ;
    add dx,3                                      ;
    mov dry2,dx                                   ;
                                                  ;
    mov cx,ax                                     ;
    sub cx,27                                     ;
    mov drx2,cx                                   ;
                                                  ;
    mov cx,ax                                     ;
    sub cx,23                                     ;
    mov drx,cx                                    ;
                                                  ;
    DrawRectangle  drx2 dry2 drx dry dcolor       ;
                                                  ;
    mov ch,dcolor                                 ;
    cmp ch,1                                      ;;if we are drawing the fish with the sea color
    jz eye1                                       ;;don't draw the eye
    mov cx,ax                                     ;
    mov dx,bx                                     ;
    sub cx,7                                      ;
    sub dx,4                                      ;
    mov al,00                                     ;
    mov ah,0ch                                    ;
    int 10H                                       ;
    add dx,1                                      ;
    int 10h                                       ;
    sub cx,1                                      ;
    int 10h                                       ;
    sub dx,1                                      ;
    int 10h                                       ;
    eye1:                                         ;
                                                  ;
	POPA	                                      ;
ret                                               ;
Drawfishrightp endp                               ;
                                                  ;
;-------------------------------------------------;                                                  
                                                   
                                                   
;Drawing The Fish in the left direction-----------;
                                                  ; 
Drawfishleftp proc  ; drx    dry   dcolor         ;
    PUSHA                                         ;
    mov ax,drx                                    ;
    mov bx,dry                                    ;
    ;mid                                          ;
    mov cx,ax                                     ;
    add cx,22                                     ;
    mov drx2,cx                                   ;
    HorizontalLine drx dry drx2 dry dcolor        ;
                                                  ;
    ;y-1                                          ;
    mov dx,bx                                     ;
    sub dx,1                                      ;
    mov dry,dx                                    ;
                                                  ;
    mov cx,ax                                     ;
    add cx,1                                      ;
    mov drx,cx                                    ;
    HorizontalLine drx dry drx2 dry dcolor        ;
                                                  ;
    ;y+1                                          ;
    mov dx,bx                                     ;
    add dx,1                                      ;
    mov dry,dx                                    ;
    HorizontalLine drx dry drx2 dry dcolor        ;
                                                  ;
    ;y-2                                          ;
    mov dx,bx                                     ;
    sub dx,2                                      ;
    mov dry,dx                                    ;
                                                  ;
    mov cx,ax                                     ;
    add cx,2                                      ;
    mov drx,cx                                    ;
    HorizontalLine drx dry drx2 dry dcolor        ;
                                                  ;
    ;y+2                                          ;
    mov dx,bx                                     ;
    add dx,2                                      ;
    mov dry,dx                                    ;
    HorizontalLine drx dry drx2 dry dcolor        ;
                                                  ;
                                                  ;
     mov cx,ax                                    ;
    add cx,18                                     ;
    mov drx2,cx                                   ;
                                                  ;
    ;y-3                                          ;
    mov dx,bx                                     ;
    sub dx,3                                      ;
    mov dry,dx                                    ;
                                                  ;
    mov cx,ax                                     ;
    add cx,4                                      ;
    mov drx,cx                                    ;
    HorizontalLine drx dry drx2 dry dcolor        ;
                                                  ;
    ;y+3                                          ;
    mov dx,bx                                     ;
    add dx,3                                      ;
    mov dry,dx                                    ;
    HorizontalLine drx dry drx2 dry dcolor        ;
                                                  ;
    mov cx,ax                                     ;
    add cx,17                                     ;
    mov drx2,cx                                   ;
                                                  ;
    ;y-4                                          ;
    mov dx,bx                                     ;
    sub dx,4                                      ;
    mov dry,dx                                    ;
                                                  ;
    mov cx,ax                                     ;
    add cx,5                                      ;
    mov drx,cx                                    ;
    HorizontalLine drx dry drx2 dry dcolor        ;
                                                  ;
    ;y+4                                          ;
    mov dx,bx                                     ;
    add dx,4                                      ;
    mov dry,dx                                    ;
    HorizontalLine drx dry drx2 dry dcolor        ;
                                                  ;
                                                  ;
    mov cx,ax                                     ;
    add cx,15                                     ;
    mov drx2,cx                                   ;
                                                  ;
    ;y-5                                          ;
    mov dx,bx                                     ;
    sub dx,5                                      ;
    mov dry,dx                                    ;
                                                  ;
    mov cx,ax                                     ;
    add cx,7                                      ;
    mov drx,cx                                    ;
    HorizontalLine drx dry drx2 dry dcolor        ;
                                                  ;
    ;y+5                                          ;
    mov dx,bx                                     ;
    add dx,5                                      ;
    mov dry,dx                                    ;
    HorizontalLine drx dry drx2 dry dcolor        ;
                                                  ;
    mov cx,ax                                     ;
    add cx,14                                     ;
    mov drx2,cx                                   ;
                                                  ;
    ;y-6                                          ;
    mov dx,bx                                     ;
    sub dx,6                                      ;
    mov dry,dx                                    ;
                                                  ;
    mov cx,ax                                     ;
    add cx,8                                      ;
    mov drx,cx                                    ;
    HorizontalLine drx dry drx2 dry dcolor        ;
                                                  ;
    ;y+6                                          ;
    mov dx,bx                                     ;
    add dx,6                                      ;
    mov dry,dx                                    ;
    HorizontalLine drx dry drx2 dry dcolor        ;
                                                  ;
    mov cx,ax                                     ;
    add cx,12                                     ;
    mov drx2,cx                                   ;
                                                  ;
    ;y-7                                          ;
    mov dx,bx                                     ;
    sub dx,7                                      ;
    mov dry,dx                                    ;
                                                  ;
    mov cx,ax                                     ;
    add cx,10                                     ;
    mov drx,cx                                    ;
    HorizontalLine drx dry drx2 dry dcolor        ;
                                                  ;
    ;y+7                                          ;
    mov dx,bx                                     ;
    add dx,7                                      ;
    mov dry,dx                                    ;
    HorizontalLine drx dry drx2 dry dcolor        ;
                                                  ;
                                                  ;
    mov dx,bx                                     ;
    sub dx,11                                     ;
    mov dry2,dx                                   ;
                                                  ;
    mov dx,bx                                     ;
    sub dx,8                                      ;
    mov dry,dx                                    ;
                                                  ;
    mov cx,ax                                     ;
    add cx,32                                     ;
    mov drx2,cx                                   ;
                                                  ;
    mov cx,ax                                     ;
    add cx,28                                     ;
    mov drx,cx                                    ;
                                                  ;
    DrawRectangle  drx dry2 drx2 dry dcolor       ;
                                                  ;
    mov dx,bx                                     ;
    sub dx,8                                      ;
    mov dry2,dx                                   ;
                                                  ;
    mov dx,bx                                     ;
    sub dx,3                                      ;
    mov dry,dx                                    ;
                                                  ;
    mov cx,ax                                     ;
    add cx,27                                     ;
    mov drx2,cx                                   ;
                                                  ;
    mov cx,ax                                     ;
    add cx,23                                     ;
    mov drx,cx                                    ;
                                                  ;
    DrawRectangle  drx dry2 drx2 dry dcolor       ;
                                                  ;
     mov dx,bx                                    ;
    add dx,11                                     ;
    mov dry,dx                                    ;
                                                  ;
    mov dx,bx                                     ;
    add dx,8                                      ;
    mov dry2,dx                                   ;
                                                  ;
    mov cx,ax                                     ;
    add cx,32                                     ;
    mov drx2,cx                                   ;
                                                  ;
    mov cx,ax                                     ;
    add cx,28                                     ;
    mov drx,cx                                    ;
                                                  ;
    DrawRectangle  drx dry2 drx2 dry dcolor       ;
                                                  ;
     mov dx,bx                                    ;
    add dx,8                                      ;
    mov dry,dx                                    ;
                                                  ;
    mov dx,bx                                     ;
    add dx,3                                      ;
    mov dry2,dx                                   ;
                                                  ;
    mov cx,ax                                     ;
    add cx,27                                     ;
    mov drx2,cx                                   ;
                                                  ;
    mov cx,ax                                     ;
    add cx,23                                     ;
    mov drx,cx                                    ;
                                                  ;
    DrawRectangle  drx dry2 drx2 dry dcolor       ;
                                                  ;
                                                  ;
    mov ch,dcolor                                 ;
    cmp ch,1                                      ;
    jz eye2                                       ;
                                                  ;
    mov cx,ax                                     ;
    mov dx,bx                                     ;
    add cx,7                                      ;
    sub dx,4                                      ;
    mov al,00                                     ;
    mov ah,0ch                                    ;
    int 10H                                       ;
    add dx,1                                      ;
    int 10h                                       ;
    add cx,1                                      ;
    int 10h                                       ;
    sub dx,1                                      ;
    int 10h                                       ;
    eye2:                                         ;
                                                  ;
	POPA	                                      ;
ret                                               ;
Drawfishleftp endp                                ;
;-------------------------------------------------;

end main 
