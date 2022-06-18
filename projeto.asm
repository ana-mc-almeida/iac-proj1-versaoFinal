; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
; * IST - UL
; * IAC
; * Grupo: 76
; * Constituição do Grupo: 
; * 	Alice Mota 			102500 
; * 	Mafalda Matias 		103756 
; * 	Ana Almeida			102618
; * Descrição: Versão final de um jogo de simulação de um rover a 
; * defender o planeta X, que obtém energia de meteoros bons e 
; * destrói meteoros maus.
; * Funções das teclas:
; *		Tecla 0 -> Move o Rover de forma contínua para a esquerda
; *		Tecla 1 -> Dispara o míssil
; * 	Tecla 2 -> Move o Rover de forma contínua para a direita
; * 	Tecla C -> Começa o jogo, reiniciando a energia do rover a 100%
; * 	Tecla D -> Suspende/ continua o jogo
; * 	Tecla E -> Termina o jogo (mantendo visível a energia final do Rover)
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
; * Constantes
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
DEFINE_LINHA EQU 600AH       	; endereço do comando para definir a linha
DEFINE_COLUNA EQU 600CH     	; endereço do comando para definir a coluna
DEFINE_PIXEL EQU 6012H       	; endereço do comando para escrever um pixel

APAGA_AVISO EQU 6040H        				; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRA EQU 6002H         				; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO EQU 6042H 			; endereço do comando para selecionar uma imagem de fundo
SEL_ECRA EQU 6004H           				; endereço do comando para selecionar o ecrã onde vai ser desenhado o objeto
SELECIONA_SOM EQU 605AH      				; endereço do comando para selecionar um som de fundo
APAGA_PIXEIS EQU 6000H      				; apaga todos os pixels do ecrã especificado
SELECIONA_ECRA_VISUALIZADO EQU 6006H 		; mostra o ecrã selecionado


DISPLAYS EQU 0A000H          ; endereço do periférico que liga aos displays
TEC_LIN EQU 0C000H           ; endereço das linhas do teclado (periférico POUT - 2)
TEC_COL EQU 0E000H           ; endereço das colunas do teclado (periférico PIN)
LINHA_TECLADO EQU 16         ; linha a testar
MASCARA EQU 0FH              ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

INICIO_DISPLAY EQU 0100H     ; valor inicial do display

MODO EQU 0					 ; constante inicial para o modo de jogo
ATIVO EQU 0

LINHA_INICIAL_ROVER EQU 27   		; linha inicial do rover
COLUNA_INICIAL_ROVER EQU 30  		; coluna inicial do rover

LINHA_INICIAL_METEORO EQU 0 		; linha inicial do meteoro
COLUNA_INICIAL_METEORO EQU 30 		; coluna inicial do meteoro

MIN_LINHA EQU 0              ; número da linha superior do ecrã
MAX_LINHA EQU 32             ; número da linha inferior do ecrã

MIN_COLUNA EQU 0             ; número da coluna lateral esquerda do ecrã
MAX_COLUNA EQU 63            ; número da coluna lateral direita do ecrã

N_METEOROS EQU 4             ; número máximo de meteoros

ATRASO_ROVER EQU 70			 		; atraso para limitar a velocidade de movimento do Rover
ATRASO_EXPLOSAO EQU 4				; atraso para limitar a velocidade de execução da explosão
MAX_ALCANCE_MISSIL EQU 07H   		; alcance máximo do míssil (7 linhas até desaparecer)


NIVEIS_METEORO EQU 08H       ; diferentes niveis dos meteoros
DIVISAO_MAU_OU_BOM EQU 2     ; valor entre 0 e 7: indica a probabilidade de o meteoro ser bom ou mau

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
; * Sons
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
SOM_INICIO EQU 0             	; som produzido quando o ecrã inicial aparece
SOM_DISPARO_MISSIL EQU 1     	; som produzido quando um míssil é disparado
SOM_MENU EQU 2               	; som produzido quando surge o ecrã com o menu
SOM_DESTROI_INIMIGO EQU 3    	; maybe
SOM_EXPLOSAO EQU 4           	; som produzido quando ocorre uma explosão
SOM_APROVEITA_ENERGIA EQU 5  	; maybe
SOM_SEM_ENERGIA EQU 6        	; falta parte Mafalda
SOM_PERDE_COLISAO EQU 7      	; maybe

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
; * Fundos
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
FUNDO_INICIO EQU 0					; fundo apresentado quando o programa começa
FUNDO_A_JOGAR EQU 1					; fundo apresentado durante o jogo
FUNDO_PAUSA EQU 2					; fundo apresentado quando o jogo está em pausa
FUNDO_GAME_OVER_ENERGIA EQU 3		; fundo apresentado quando se perde o jogo por fim de energia
FUNDO_GAME_OVER_COLISAO EQU 4		; fundo apresentado quando se perde o jogo devido a uma colisão com um meteoro mau
FUNDO_JOGO_TERMINADO EQU 5			; fundo produzido quando se termina o jogo (ao pressionar a tecla E)

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
; * Dimensões
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
LARGURA_ROVER EQU 5          ; largura do rover
ALTURA_ROVER EQU 4           ; altura do rover

LARGURA_METEORO_1 EQU 1      ; largura do meteoro nível 1
ALTURA_METEORO_1 EQU 1       ; altura do meteoro nível 1

LARGURA_METEORO_2 EQU 2      ; largura do meteoro nível 2
ALTURA_METEORO_2 EQU 2       ; altura do meteoro nível 2

LARGURA_METEORO_3 EQU 3      ; largura do meteoro nível 3
ALTURA_METEORO_3 EQU 3       ; altura do meteoro nível 3

LARGURA_METEORO_4 EQU 4      ; largura do meteoro nível 4
ALTURA_METEORO_4 EQU 4       ; altura do meteoro nível 4

LARGURA_METEORO_5 EQU 5      ; largura do meteoro nível 5
ALTURA_METEORO_5 EQU 5       ; altura do meteoro nível 5

LARGURA_EXPLOSAO EQU 5       ; largura da explosão
ALTURA_EXPLOSAO EQU 5        ; altura da explosão

LARGURA_MISSIL EQU 1         ; largura do missil
ALTURA_MISSIL EQU 1          ; altura do missil

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
; * Ecrãs
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
ECRA_ROVER EQU 0             ; ecrã especificado para o Rover
ECRA_METEORO_MAU EQU 1       ; ecrã especificado para os Meteoros Maus
ECRA_METEORO_BOM EQU 2       ; ecrã especificado para os Meteoros Bons
ECRA_MISSIL EQU 3			 ; ecrã especificado para o Míssil
ECRA_EXPLOSAO EQU 4			 ; ecrã especificado para a explosão (após colisão)

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
; * Cores
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
COR_AMARELA EQU 0FFF0H       	; amarelo em ARGB (opaco, amarelo no máximo, verde no máximo e azul a 0) -> Rover
COR_VERMELHA EQU 0FF00H      	; vermelho em ARGB (opaco, vermelho no máximo, verde e azul a 0) -> meteoros maus
COR_VERDE EQU 0F0B3H         	; verde em ARGB -> meteoros bons
COR_CINZENTO EQU 0799AH      	; cinzento em ARGB (com alguma transparência, dando ilusão de distância) -> meteoros inicialmente
COR_VERDE_AGUA EQU 0F2FBH    	; verde-água em ARGB -> explosão
COR_ROXA EQU 0FC3FH          	; roxo em ARGB -> míssil

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
; * Teclas com Funções
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
TECLA_0 EQU 01H              ; tecla 0 -> move o Rover para a esquerda
TECLA_1 EQU 02H              ; tecla 1 -> dispara o míssil
TECLA_2 EQU 03H              ; tecla 2 -> move o Rover para a direita
TECLA_C EQU 0DH              ; tecla C -> começa o jogo
TECLA_D EQU 0EH              ; tecla D -> suspende/ continua o jogo
TECLA_E EQU 0FH              ; tecla E -> termina o jogo

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
; * Dados
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	PLACE 1000H

; Reserva do espaço para as pilhas dos processos
	STACK 100H                   ; espaço reservado para a pilha do processo "programa principal"
SP_inicial_prog_princ:        	 ; endereço com que o SP deste processo deve ser inicializado
	
	STACK 100H                   ; espaço reservado para a pilha do processo "teclado"
SP_inicial_teclado:            	 ; endereço com que o SP deste processo deve ser inicializado
	
	STACK 100H                   ; espaço reservado para a pilha do processo "rover"
SP_inicial_rover:              	 ; endereço com que o SP deste processo deve ser inicializado
	
	STACK 100H                   ; espaço reservado para a pilha do processo "missil"
SP_inicial_missil:             	 ; endereço com que o SP deste processo deve ser inicializado
	
	STACK 100H                   			 ; espaço reservado para a pilha do processo "display_inicia"
SP_inicial_display_diminuir_tempo:  	 	 ; endereço com que o SP deste processo deve ser inicializado
	
	STACK 100H                   			 ; espaço reservado para a pilha do processo "colisao_boa_display"
SP_inicial_display_aumentar_colisao_boa:  	 ; endereço com que o SP deste processo deve ser inicializado
	
	STACK 100H                   			 ; espaço reservado para a pilha do processo "disparo_nave_ma_display"
SP_inicial_display_aumentar_acertar_nave:  	 ; endereço com que o SP deste processo deve ser inicializado
	
	STACK 100H                  			 ; espaço reservado para a pilha do processo "missil_display"
SP_inicial_display_diminuir_missil:  		 ; endereço com que o SP deste processo deve ser inicializado
	
	STACK 100H                   ; espaço reservado para a pilha do processo "explosao"
SP_inicial_explosao:           	 ; endereço com que o SP deste processo deve ser inicializado
	
	STACK 100H                   ; espaço reservado para a pilha do processo "meteoro", instância 0
SP_inicial_meteoro_0:          	 ; endereço com que o SP deste processo deve ser inicializado
	
	STACK 100H                   ; espaço reservado para a pilha do processo "meteoro", instância 1
SP_inicial_meteoro_1:          	 ; endereço com que o SP deste processo deve ser inicializado
	
	STACK 100H                   ; espaço reservado para a pilha do processo "meteoro", instância 2
SP_inicial_meteoro_2:          	 ; endereço com que o SP deste processo deve ser inicializado
	
	STACK 100H                   ; espaço reservado para a pilha do processo "meteoro", instância 3
SP_inicial_meteoro_3:          	 ; endereço com que o SP deste processo deve ser inicializado
	

DEF_ROVER:                						; tabela que define o Rover (cor, largura, pixels)
	WORD ECRA_ROVER              											; ecrã do Rover
	WORD LARGURA_ROVER           											; largura do Rover
	WORD ALTURA_ROVER            											; altura do Rover
	WORD 0, 0, COR_AMARELA, 0, 0 											; cores da linha 1
	WORD COR_AMARELA, 0, COR_AMARELA, 0, COR_AMARELA 						; cores da linha 2
	WORD COR_AMARELA, COR_AMARELA, COR_AMARELA, COR_AMARELA, COR_AMARELA 	; cores da linha 3
	WORD 0, COR_AMARELA, 0, COR_AMARELA, 0 									; cores da linha 4
	
DEF_METEORO_INICIO_1:         	 ; tabela que define o meteoro nivel 1 (cor, largura, pixels)
	WORD ECRA_METEORO_MAU        ; ecrã do meteoro nível 1
	WORD LARGURA_METEORO_1       ; largura do meteoro nível 1
	WORD ALTURA_METEORO_1        ; altura do meteoro nível 1
	WORD COR_CINZENTO            ; cor da linha 1
	
DEF_METEORO_INICIO_2:         				; tabela que define o meteoro nível 2 (cor, largura, pixels)
	WORD ECRA_METEORO_MAU        			; ecrã do meteoro
	WORD LARGURA_METEORO_2       			; largura do meteoro nível 2
	WORD ALTURA_METEORO_2        			; altura do meteoro nível 2
	WORD COR_CINZENTO, COR_CINZENTO 		; cor da linha 1
	WORD COR_CINZENTO, COR_CINZENTO 		; cor da linha 2
	
DEF_METEORO_BOM_3:            						; tabela que define o meteoro bom nível 3 (cor, largura, pixels)
	WORD ECRA_METEORO_BOM        					; ecrã do meteoro bom
	WORD LARGURA_METEORO_3       					; largura do meteoro Bom nível 3
	WORD ALTURA_METEORO_3        					; altura do meteoro Bom nível 3
	WORD 0, COR_VERDE, 0         					; cores da linha 1
	WORD COR_VERDE, COR_VERDE, COR_VERDE			; cores da linha 2
	WORD 0, COR_VERDE, 0         					; cores da linha 3
	
DEF_METEORO_BOM_4:            							 ; tabela que define o meteoro bom nível 4 (cor, largura, pixels)
	WORD ECRA_METEORO_BOM       						 ; ecrã do meteoro bom
	WORD LARGURA_METEORO_4       						 ; largura do meteoro bom nível 4
	WORD ALTURA_METEORO_4        						 ; altura do meteoro bom nível 4
	WORD 0, COR_VERDE, COR_VERDE, 0 					 ; cores da linha 1
	WORD COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE 	 ; cores da linha 2
	WORD COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE 	 ; cores da linha 3
	WORD 0, COR_VERDE, COR_VERDE, 0						 ; cores da linha 4
	
DEF_METEORO_BOM_5:            							; tabela que define o meteoro bom nível 5 (cor, largura, pixels)
	WORD ECRA_METEORO_BOM        									; ecrã do meteoro bom
	WORD LARGURA_METEORO_5      							  		; largura do meteoro bom nível 5
	WORD ALTURA_METEORO_5        									; altura do meteoro bom nível 5
	WORD 0, COR_VERDE, COR_VERDE, COR_VERDE, 0						; cores da linha 1
	WORD COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE 		; cores da linha 2
	WORD COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE		; cores da linha 3
	WORD COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE 		; cores da linha 4
	WORD 0, COR_VERDE, COR_VERDE, COR_VERDE, 0 						; cores da linha 5
	
DEF_METEORO_MAU_3:            				; tabela que define o meteoro mau nível 3 (cor, largura, pixels)
	WORD ECRA_METEORO_MAU      					; ecrã do meteoro mau
	WORD LARGURA_METEORO_3       				; largura do meteoro mau nível 3
	WORD ALTURA_METEORO_3        				; altura do meteoro mau nível 3
	WORD COR_VERMELHA, 0, COR_VERMELHA 			; cores da linha 1
	WORD 0, COR_VERMELHA, 0      				; cores da linha 2
	WORD COR_VERMELHA, 0, COR_VERMELHA 			; cores da linha 3
	
DEF_METEORO_MAU_4:            			; tabela que define o meteoro mau nível 4 (cor, largura, pixels)
	WORD ECRA_METEORO_MAU        				; ecrã do meteoro mau
	WORD LARGURA_METEORO_4       				; largura do meteoro mau nível 4
	WORD ALTURA_METEORO_4        				; altura do meteoro mau nível 4
	WORD COR_VERMELHA, 0, 0, COR_VERMELHA 		; cores da linha 1
	WORD COR_VERMELHA, 0, 0, COR_VERMELHA 		; cores da linha 2
	WORD 0, COR_VERMELHA, COR_VERMELHA, 0 		; cores da linha 3
	WORD COR_VERMELHA, 0, 0, COR_VERMELHA 		; cores da linha 4
	
DEF_METEORO_MAU_5:           		; tabela que define o meteoro mau nível 5 (cor, largura, pixels)
	WORD ECRA_METEORO_MAU        							; ecrã do meteoro mau
	WORD LARGURA_METEORO_5       							; largura do meteoro mau nível 5
	WORD ALTURA_METEORO_5       						  	; altura do meteoro mau nível 5
	WORD COR_VERMELHA, 0, 0, 0, COR_VERMELHA				; cores da linha 1
	WORD COR_VERMELHA, 0, COR_VERMELHA, 0, COR_VERMELHA 	; cores da linha 2
	WORD 0, COR_VERMELHA, COR_VERMELHA, COR_VERMELHA, 0 	; cores da linha 3
	WORD COR_VERMELHA, 0, COR_VERMELHA, 0, COR_VERMELHA 	; cores da linha 4
	WORD COR_VERMELHA, 0, 0, 0, COR_VERMELHA 				; cores da linha 5
	
DEF_METEOROS_MAUS:            		; tabela com os niveis do meteoro mau
	WORD DEF_METEORO_INICIO_1		; meteoro nível 1
	WORD DEF_METEORO_INICIO_2		; meteoro nível 2
	WORD DEF_METEORO_MAU_3			; meteoro mau nível 3
	WORD DEF_METEORO_MAU_4			; meteoro mau nível 4
	WORD DEF_METEORO_MAU_5			; meteoro mau nível 5
	
DEF_METEOROS_BONS:            		; tabela com os niveis do meteoro bom
	WORD DEF_METEORO_INICIO_1		; meteoro nível 1
	WORD DEF_METEORO_INICIO_2		; meteoro nível 2
	WORD DEF_METEORO_BOM_3			; meteoro bom nível 3
	WORD DEF_METEORO_BOM_4			; meteoro bom nível 4
	WORD DEF_METEORO_BOM_5			; meteoro bom nível 5
	
DEF_EXPLOSAO:                 		; tabela que define a explosão (cor, largura, pixels)
	WORD ECRA_EXPLOSAO           									; ecrã da explosão
	WORD LARGURA_EXPLOSAO        									; largura da explosão
	WORD ALTURA_EXPLOSAO         									; altura da explosão
	WORD 0, COR_VERDE_AGUA, 0, COR_VERDE_AGUA, 0 					; cores da linha 1
	WORD COR_VERDE_AGUA, 0, COR_VERDE_AGUA, 0, COR_VERDE_AGUA 		; cores da linha 2
	WORD 0, COR_VERDE_AGUA, 0, COR_VERDE_AGUA, 0 					; cores da linha 3
	WORD COR_VERDE_AGUA, 0, COR_VERDE_AGUA, 0, COR_VERDE_AGUA 		; cores da linha 4
	WORD 0, COR_VERDE_AGUA, 0, COR_VERDE_AGUA, 0 					; cores da linha 5
	
DEF_MISSIL:                   ; tabela que define o míssil (cor, largura, pixels)
	WORD ECRA_MISSIL          ; ecrã do missil
	WORD LARGURA_MISSIL       ; largura do missil
	WORD ALTURA_MISSIL        ; altura do missil
	WORD COR_ROXA             ; cor da linha 1
	
COLUNA_ROVER: WORD COLUNA_INICIAL_ROVER 		; variável que indica a coluna do Rover
LINHA_ROVER: WORD LINHA_INICIAL_ROVER 			; variável que indica a linha do Rover
	
COLUNA_MISSIL: WORD COLUNA_INICIAL_ROVER 		; variável que indica a coluna do míssil
LINHA_MISSIL: WORD LINHA_INICIAL_ROVER 			; variável que indica a linha do míssil
	
HOUVE_EXPLOSAO: WORD 0        ; flag que indica se ocorreu uma explosao
	
DISPLAY: WORD INICIO_DISPLAY  ; variável que indica o valor do display
	
JOGO: WORD MODO				  ; variável que guarda o modo de jogo atual 
	
; indica quando o jogo está a ser recomeçado
RECOMECAR_ROVER: WORD ATIVO			; recomeça o rover
RECOMECAR_MISSIL: WORD ATIVO		; recomeça o míssil
RECOMECAR_METEOROS:					; tabela para recomeçar todos os meteoros
	WORD ATIVO
	WORD ATIVO
	WORD ATIVO
	WORD ATIVO
	
meteoro_SP_tab:               		; tabela com os SP iniciais de cada processo "meteoro"
	WORD SP_inicial_meteoro_0		; SP inicial do meteoro 0
	WORD SP_inicial_meteoro_1		; SP inicial do meteoro 1
	WORD SP_inicial_meteoro_2		; SP inicial do meteoro 2
	WORD SP_inicial_meteoro_3		; SP inicial do meteoro 3
	
linhas_meteoros:               		; linha em que cada meteoro está (inicializada com a linha inicial para todos)
	WORD LINHA_INICIAL_METEORO
	WORD LINHA_INICIAL_METEORO
	WORD LINHA_INICIAL_METEORO
	WORD LINHA_INICIAL_METEORO
	
colunas_meteoros:             		; coluna em que cada meteoro está (inicializada com a coluna inicial para todos)
	WORD COLUNA_INICIAL_METEORO
	WORD COLUNA_INICIAL_METEORO
	WORD COLUNA_INICIAL_METEORO
	WORD COLUNA_INICIAL_METEORO
	
defs_meteoros:                	; tipo de cada um dos meteoros (inicializada com DEF_METEORO_INICIO_1 para todos)
	WORD DEF_METEORO_INICIO_1
	WORD DEF_METEORO_INICIO_1
	WORD DEF_METEORO_INICIO_1
	WORD DEF_METEORO_INICIO_1
	
houve_colisao:         ; tabela com a indicação de que cada meteoro colidiu
	WORD 0
	WORD 0
	WORD 0
	WORD 0
	
tab:							 ; tabela das rotinas de interrupção
	WORD rot_int_meteoros        ; rotina de atendimento da interrupção dos meteoros
	WORD rot_int_missil          ; rotina de atendimento da interrupção dos mísseis
	WORD rot_int_energia         ; rotina de atendimento da interrupção da energia
	
evento_int_meteoros:
	LOCK 0                       ; LOCK para a rotina de interrupção dos meteoros
	
tecla_carregada:
	LOCK 0                       ; LOCK para o teclado comunicar aos restantes processos que tecla detetou
	
tecla_continuo:
	LOCK 0                       ; LOCK para o teclado comunicar aos restantes processos que tecla detetou, 
								 ; enquanto a tecla estiver carregada
	
missil_disparado:
	LOCK 0                       ; LOCK para indicar diminuir em 5 a energia
	
missil_movimenta:
	LOCK 0                       ; LOCK para a rotina de interrupção do missil
	
dimui_energia_a_jogar:	
	LOCK 0						 ; LOCK para diminuir a energia do display
	
colisao_boa:
	LOCK 0						 ; LOCK para indicar se a colisão foi com um meteoro bom
	
modo_jogo:
	LOCK 0						 ; LOCK para indicar o modo de jogo 
	
acerta_nave_ma:
	LOCK 0						 ; LOCK para identificar quando uma nave má é atingida com o míssil
	
disparo_missil:
	LOCK 0						 ; LOCK para quando um míssil é disparado
	
aumenta_energia:
	LOCK 0						 ; LOCK para quando se colide com uma nave boa, ganhando-se energia
	
explodiu:
	LOCK 0                       ; LOCK para indicar se houve alguma explosão
	
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
; * Código
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	PLACE 0                      		; o código tem de começar em 0000H
inicio:
	MOV SP, SP_inicial_prog_princ 		; inicializa SP do programa principal
	
	MOV BTE, tab                 		; inicializa BTE (registo de Base da Tabela de Exceções)
	
	
	EI0                          ; permite interrupções 0
	EI1                          ; permite interrupções 1
	EI2                          ; permite interrupções 2
	EI                           ; permite interrupções (geral)
	; a partir daqui, qualquer interrupção que ocorra usa
	; a pilha do processo que estiver a correr nessa altura

	CALL teclado                 		; cria o processo teclado
	CALL colisao_boa_display			; cria o processo colisao_boa_display
	CALL display_inicia					; cria o processo display_inicia
	CALL disparo_nave_ma_display		; cria o processo disparo_nave_ma_display
	CALL missil_display					; cria o processo missil_display
	
	MOV R1, N_METEOROS           ; número de meteoros a usar (até 4)
loop_meteoros:					 ; cria o número de meteoros pretendido (no caso, 4)
	SUB R1, 1                    ; próximo meteoro
	CALL meteoro                 ; cria uma nova instância do processo meteoro (o valor de R1 distingue-as)
	; Cada processo fica com uma cópia independente dos registos
	CMP R1, 0                    ; já criou as instâncias todas?
	JNZ loop_meteoros            ; se não, continua
	
	CALL explosao                ; cria o processo explosao
	CALL rover                   ; cria o processo rover
	CALL missil                  ; cria o processo missil
	
	; o resto do programa principal é também um processo
	
	MOV [APAGA_AVISO], R1        ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
	MOV [APAGA_ECRA], R1         ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	
	MOV R0, DISPLAYS             ; endereço do periférico que liga aos displays
	MOV R2, INICIO_DISPLAY       ; valor a ser mostrado nos displays
	MOV [R0], R2                 ; mostra o valor do contador nos displays
	
	MOV R1, FUNDO_INICIO         			; cenário de fundo e som número 0 (mesmo valor para ambos)
	MOV [SELECIONA_CENARIO_FUNDO], R1 		; seleciona o cenário de fundo
	MOV [SELECIONA_SOM], R1      			; seleciona o som
	
obtem_tecla:						
	MOV R1, [tecla_carregada]    ; bloqueia neste LOCK até uma tecla ser carregada
	
	MOV R6, TECLA_1
	CMP R1, R6                   ; é a tecla 1?
	JZ clique_disparo			 ; se sim, dispara o míssil
	
	MOV R6, TECLA_C
	CMP R1, R6                   ; é a tecla C?
	JZ testa_C					 ; se sim, inicia um novo jogo
	
	MOV R6, TECLA_D
	CMP R1, R6                   ; é a tecla D?
	JZ testa_D				     ; se sim, termina o jogo atual
	
	JMP obtem_tecla              ; se não for nenhuma das anteriores, ignora a tecla e espera por outra
	
testa_D:
	MOV R2, 2
	MOV R0, [JOGO]
	CMP R2, R0
	JZ sai_de_pausa
	MOV R2, 1
	MOV R0, [JOGO]
	CMP R2, R0
	JNZ obtem_tecla
	MOV R1, FUNDO_PAUSA          			; cenário de fundo e som número 0 - o numero do ecra e do som é o mesmo
	MOV [SELECIONA_CENARIO_FUNDO], R1 		; seleciona o cenário de fundo
	MOV [SELECIONA_SOM], R1      			; seleciona o som
	MOV R2, 2
	MOV [JOGO], R2               			; desbloqueia processo ...............? (qualquer registo serve)
	JMP obtem_tecla              			; processo do programa principal nunca termina
sai_de_pausa:
	MOV R1, FUNDO_A_JOGAR        			; cenário de fundo número 0
	MOV [SELECIONA_CENARIO_FUNDO], R1 		; seleciona o cenário de fundo
	MOV R1, SOM_MENU
	MOV [SELECIONA_SOM], R1      			; seleciona o som
	MOV R2, 1
	MOV [JOGO], R2               			; desbloqueia processo ...............? (qualquer registo serve)
	JMP obtem_tecla              			; processo do programa principal nunca termina
	
testa_C:
	MOV R1, FUNDO_A_JOGAR        ; cenário de fundo número 0
	MOV [SELECIONA_CENARIO_FUNDO], R1 ; seleciona o cenário de fundo
	MOV R2, 2
	MOV R0, [JOGO]
	CMP R2, R0
	JNZ comeca_jogo
	CALL recomeca_jogo
	JMP obtem_tecla              ; processo do programa principal nunca termina
comeca_jogo:
	MOV R2, 1
	MOV [JOGO], R2               ; desbloqueia processo ...............? (qualquer registo serve)
	MOV [modo_jogo], R2          ; desbloqueia processo ...............? (qualquer registo serve)
	JMP obtem_tecla              ; processo do programa principal nunca termina
	
clique_disparo:
	MOV R2, 1
	MOV [missil_disparado], R2   ; desbloqueia processo missil (qualquer registo serve)
	JMP obtem_tecla              ; processo do programa principal nunca termina
	
	
recomeca_jogo:
	MOV R2, INICIO_DISPLAY
	MOV [DISPLAYS], R2
	MOV [DISPLAY], R2
	
	MOV [APAGA_ECRA], R1         ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	
	MOV R10, 1
	MOV [JOGO], R10              ; desbloqueia processo ...............? (qualquer registo serve)
	
	MOV R11, 1                   ; inicializa o contador
	MOV [RECOMECAR_ROVER], R11   ; flag que indica que o rover tem de ser reiniciado
	MOV [RECOMECAR_MISSIL], R11  ; flag que indica que o missil tem de ser reiniciado
	
	MOV R1, N_METEOROS				; número de meteoros a utilizar (máximo 4)
loop_reinicia_meteoros:       		; loop para alterar flag que indica que os meteoros tem de ser reiniciados
	SUB R1, 1						; próximo meteoro
	MOV R9, RECOMECAR_METEOROS		; tabela para recomeçar os meteoros
	MOV R8, R1
	SHL R8, 1
	MOV [R9 + R8], R11
	CMP R1, 0
	JNZ loop_reinicia_meteoros
	
	RET
	
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
; Processo
;
; TECLADO - Processo que deteta quando se carrega numa tecla do teclado
; e escreve o valor da tecla num LOCK.
;
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	PROCESS SP_inicial_teclado   ; indicação de que a rotina que se segue é um processo, 
	; com indicação do valor para inicializar o SP

teclado:                      ; processo que implementa o comportamento do teclado
	MOV R2, TEC_LIN              ; endereço do periférico das linhas
	MOV R3, TEC_COL              ; endereço do periférico das colunas
	MOV R6, MASCARA              ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	
inicia_linhas:
	MOV R1, LINHA_TECLADO        	; linha a testar no teclado
espera_tecla:                 		; neste ciclo espera-se até uma tecla ser premida
	
	WAIT                         	; este ciclo é potencialmente bloqueante, pelo que tem de
	; ter um ponto de fuga (aqui pode comutar para outro processo)
	
	SHR R1, 1                    	; divide por 2 para passar para a linha anterior
	JZ inicia_linhas             	; se for 0 volta para a linha final
	MOVB [R2], R1                	; escreve no periférico de saída (linhas)
	MOVB R0, [R3]                	; lê do periférico de entrada (colunas)
	AND R0, R6                   	; elimina bits para além dos bits 0 - 3
	CMP R0, 0                    	; há tecla premida?
	JZ espera_tecla              	; se nenhuma tecla está a ser premida, repete o ciclo
	
	MOV R10, R1                  	; memoriza a linha pressionada
	MOV R5, R1					 	; memoriza o valor da linha pressionada (em formato 1, 2, 4 ou 8)
	CALL converte_1248_to_0123   	; converter linha de 1, 2, 4 e 8 para 0, 1, 2, 3
	MOV R1, R8					 	; memoriza o valor atualizado da linha pressionada
	
	MOV R5, R0						; memoriza o valor da coluna pressionada (em formato 1, 2, 4 ou 8)
	CALL converte_1248_to_0123   	; converter coluna de 1, 2, 4 e 8 para 0, 1, 2, 3
	MOV R0, R8					 	; memoriza o valor atualizado da coluna pressionada
	
	ADD R1, R1                   	; R1 = 2 * R1
	ADD R1, R1                   	; R1 = 2 * R1 <=> R1 = 4 * R1
	ADD R0, R1                   	; R0 = 4 * R1 + R0 -> correspondente à tecla pressionada
	
	ADD R0, 1                    	; adicionar mais um, por causa do LOCK
	
	MOV [tecla_carregada], R0    	; informa quem estiver bloqueado neste LOCK que uma tecla foi carregada
	; (o valor escrito é o número da coluna da tecla no teclado)
	
ha_tecla:                     		; neste ciclo espera-se até NENHUMA tecla estar premida
	
	YIELD                       	; este ciclo é potencialmente bloqueante, pelo que tem de
	; ter um ponto de fuga (aqui pode comutar para outro processo)
	
	
	MOV [tecla_continuo], R0    	; informa quem estiver bloqueado neste LOCK que uma tecla está a ser carregada
	; (o valor escrito é o número da coluna da tecla no teclado)
	
	MOV R1, R10                 	; testa a linha pressionada anteriormente
	MOVB [R2], R1                	; escreve no periférico de saída (linhas)
	MOVB R0, [R3]               	; lê do periférico de entrada (colunas)
	AND R0, R6                   	; elimina bits para além dos bits 0 - 3
	CMP R0, 0                    	; há tecla premida?
	JZ espera_tecla					; se não houver, espera-se até uma tecla estar a ser premida
	
	MOV R5, R1						; memoriza o valor da linha pressionada (em formato 1, 2, 4 ou 8)
	CALL converte_1248_to_0123   	; converter linha de 1, 2, 4 e 8 para 0, 1, 2, 3
	MOV R1, R8						; memoriza o valor atualizado da linha pressionada
	
	MOV R5, R0						; memoriza o valor da coluna pressionada (em formato 1, 2, 4 ou 8)
	CALL converte_1248_to_0123   	; converter coluna de 1, 2, 4 e 8 para 0, 1, 2, 3
	MOV R0, R8						; memoriza o valor atualizado da coluna pressionada
	
	ADD R1, R1             ; R1 = 2 * R1
	ADD R1, R1             ; R1 = 2 * R1 <=> R1 = 4 * R1
	ADD R0, R1             ; R0 = 4 * R1 + R0 -> correspondente à tecla pressionada
	
	ADD R0, 1              ; adicionar mais um por causa do lock
	
	JNZ ha_tecla           ; se ainda houver uma tecla a ser premida, espera até deixar de existir
	
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
; Processo
;
; ROVER - Processo que desenha o rover e o move horizontalmente, 
; dependendo das teclas pressionadas pelo utilizador
;
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	
	PROCESS SP_inicial_rover     		; indicação de que a rotina que se segue é um processo, 
	; com indicação do valor para inicializar o SP
rover:                        			; processo que implementa o comportamento do objeto
	; desenha o objeto na sua posição inicial
	MOV R1, LINHA_INICIAL_ROVER  		; linha do Rover
	MOV R2, COLUNA_INICIAL_ROVER 		; coluna do Rover
	MOV R5, 0                    		; inicializa o contador
	MOV R6, [modo_jogo]					; lê o LOCK e bloqueia até estar no modo de jogo correto
	
ciclo_rover:					 	; ciclo onde é feito o movimento do Rover
	MOV R4, DEF_ROVER           	; endereço da tabela que define o rover
	MOV [COLUNA_ROVER], R2       	; atualiza a coluna atual do rover
	CALL desenha_objeto          	; desenha o rover a partir da tabela
espera_movimento_rover:				
	MOV R3, [tecla_continuo]     	; lê o LOCK e bloqueia até o teclado escrever nele novamente
	
	MOV R10, 2
	MOV R11, [JOGO]					; lê o modo de jogo atual
	CMP R10, R11				
	JZ espera_movimento_rover		; O Rover não se vai mover se não estiver no modo de jogo "pausa"
	
	MOV R11, [RECOMECAR_ROVER]		; lê o valor que reinicia o Rover
	MOV R10, 1						 
	CMP R11, R10					
	JZ reinicia_rover				; se tiverem o mesmo valor, o Rover é reiniciado
	
	ADD R5, 1                    	; incrementa o contador
	MOV R6, ATRASO_ROVER			; atraso do Rover
	CMP R5, R6						
	JNZ espera_movimento_rover   	; o Rover não se vai move enquanto não acabar o atraso
	
	MOV R5, 0                    	; reinicia o contador
	
	MOV R6, TECLA_0
	CMP R3, R6                  	; é a tecla 0?
	JZ move_rover_esquerda		 	; se for, o Rover move-se de forma contínua para a esquerda
	
	MOV R6, TECLA_2
	CMP R3, R6                   	; é a tecla 2?
	JZ move_rover_direita			; se for, o Rover move-se de forma contínua para a direita
	
	JMP espera_movimento_rover   ; se não é nenhuma das duas, ignora e continua à espera
	
move_rover_esquerda:          	 ; neste ciclo vê se é possível movimentar o rover para a esquerda
	MOV R7, - 1                  ; desloca o rover para a esquerda
	JMP move_rover               ; testa se está dentro dos limites do ecrã
move_rover_direita:				 ; vê se é possível movimentar o Rover para a direita
	MOV R7, + 1                  ; desloca o rover para a direita, se estiver dentro dos limites do ecrã
	JMP move_rover               ; testa se está dentro dos limites do ecrã
move_rover:
	CALL apaga_objeto            ; apaga o rover na sua posição corrente
	ADD R4, 2                    ; endereço da largura do rover
	MOV R6, [R4]                 ; obtém a largura do rover
	CALL testa_limites           ; vê se chegou aos limites do ecrã e nesse caso não o deixa movimentar se
	ADD R2, R7                   ; desenha o Rover na coluna seguinte (direita ou esquerda, ou fica parado caso esteja num limite)
	JMP ciclo_rover              ; esta "rotina" nunca retorna porque nunca termina
	; Se se quisesse terminar o processo, era deixar o processo chegar a um RET
	
reinicia_rover:
	MOV R1, LINHA_INICIAL_ROVER  	; linha do rover
	MOV R2, COLUNA_INICIAL_ROVER 	; coluna do rover
	MOV R4, DEF_ROVER            	; endereço da tabela que define o rover
	MOV [COLUNA_ROVER], R2       	; atualiza a coluna atual do rover
	CALL desenha_objeto          	; desenha o rover a partir da tabela
	MOV R11, 0
	MOV [RECOMECAR_ROVER], R11		; recomeça o Rover
	JMP espera_movimento_rover		; o Rover não mexe até ser pressionada uma das teclas definidas para tal
	
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
; Processo
;
; METEORO - Processo que desenha um meteoro e o move verticalmente, com
; temporização marcada pela interrupção do meteoro (interrupção 0)
;
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	PROCESS SP_inicial_meteoro_0 			; indicação de que a rotina que se segue é um processo, 
	; com indicação do valor para inicializar o SP
meteoro:                     		 ; processo que implementa o comportamento do meteoro
	
	MOV R8, R1                   	; cópia do nº de instância do processo
	SHL R8, 1                    	; multiplica por 2 porque as tabelas são de WORDS
	
	MOV R9, meteoro_SP_tab       	; tabela com os SPs iniciais das várias instâncias deste processo
	MOV SP, [R9 + R8]            	; re-inicializa o SP deste processo, de acordo com o nº de instância
	; NOTA - Cada processo tem a sua cópia própria do SP
	
	MOV R9, houve_colisao        	; tabela com a indicação de que cada meteoro colidiu
	MOV R1, 0                    	; ao entrar pela primeira vez neste processo é impossivel o meteoro já ter colidido
	MOV [R9 + R8], R1			 	; escreve na tabela a indicação de que o meteoro não colidiu
	
	MOV R6, [modo_jogo]				; lê o modo de jogo atual
inicializa_meteoro:				
	
	MOV R1, LINHA_INICIAL_METEORO	; linha inicial do meteoro 
	MOV R9, linhas_meteoros      	; tabela com a linha de cada meteoro
	MOV [R9 + R8], R1            	; linha inicial do meteoro
	
	MOV R9, colunas_meteoros     	; tabela com a coluna de cada meteoro
	CALL gera_aleatorio         	; Gera um número "aleatório" entre 0 e 7
	SHL R2, 3                    	; transforma o valor entre 0 e 7 para valores de 8 em 8, de 0 até 64
	; (divide o ecrã em blocos de 8 colunas)
	MOV [R9 + R8], R2            	; coluna inicial do meteoro
	
	MOV R3, - 2                  	; contador para ler o tamanho do meteoro
	MOV R7, 0                    	; contador para ver se é linha múltipla de 3
	CALL define_tipo_meteoro		; define aleatoriamente o tipo de meteoro
	MOV R9, defs_meteoros        	; tabela com o tipo de cada meteoro
	MOV [R9 + R8], R10           	; define o tipo de meteoro (bom ou mau)
	
	
	MOV R9, RECOMECAR_METEOROS		; tabela para recomeçar os meteoros
	MOV R11, 0						 
	MOV [R9 + R8], R11				; recomeça os meteoros
	
aumenta_meteoro:
	ADD R3, 2                    	; aumenta o nivel do meteoro
ciclo_meteoro:
	
	YIELD                        	; este ciclo é potencialmente bloqueante, pelo que tem de
	; ter um ponto de fuga (aqui pode comutar para outro processo)
	
	MOV R9, RECOMECAR_METEOROS		; tabela para recomeçar os meteoros	
	MOV R11, [R9 + R8] 				; lê o valor correspondente ao meteoro na tabela
	MOV R6, 1
	CMP R11, R6						
	JZ inicializa_meteoro			; se o valor associado ao meteoro estiver ativo, é inicializado um novo meteoro
	
	MOV R5, R10                  	; obtém o tipo de meteoro
	MOV R4, [R5 + R3]            	; endereço da tabela com o tipo de meteoro no nível atual
	CALL desenha_objeto          	; desenha o objeto a partir da tabela
	
move_meteoro:                 			; neste ciclo o meteoro muda de posição
	MOV R6, [evento_int_meteoros] 		; lê o LOCK deste processo (bloqueia até a rotina de interrupção
	; respetiva escrever neste LOCK)
	; Quando bloqueia, passa o controlo para outro processo
	; Como não há valor a transmitir, o registo pode ser um qualquer
	
	MOV R6, 2					
	MOV R11, [JOGO]				 ; lê o modo de jogo atual
	CMP R6, R11						
	JZ move_meteoro				 ; se estiver no menu "pausa", entra num loop, até sair deste modo
	
	ADD R7, 1                    ; incrementa o contador
	CALL desce_meteoro			 ; o meteoro desce uma linha 
	MOV R9, 3                    ; de 3 em 3 linhas o meteoro aumenta o nivel
	MOD R7, R9                   ; resto da divisão do contador por 3
	CMP R7, 0					 ; vê se o contador (ou seja, se a linha onde o meteoro se encontra) é múltipla de 3
	JNZ ciclo_meteoro            ; se não for para subir o nível, volta a movimentar o meteoro
	MOV R9, NIVEIS_METEORO       ; número maximo de niveis
	CMP R3, R9
	JNZ aumenta_meteoro          ; só aumenta o meteoro caso ainda não tenha alcançado o nível máximo
	JMP ciclo_meteoro			 ; volta ao início do ciclo
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; DESCE_METEORO: Faz o meteoro descer uma linha no ecrã, detetando se colide com o Rover, 
	; ou se é atingido por um míssil quando se movimenta.
	; Argumentos:
	;
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
desce_meteoro:
	PUSH R6
	PUSH R9
	CALL deteta_colisao				; deteta se o meteoro colide com o Rover, ou o míssil
	MOV R11, DEF_EXPLOSAO			; tabela que define a explosão
	CMP R10, R11					 
	JZ meteoro_explodiu
	MOV R9, houve_colisao
	MOV R11, [R9 + R8]
	CMP R11, 1
	JZ meteoro_colidiu
	CALL apaga_objeto
	MOV R6, [R5 + R3]				; endereço da tabela com o tipo de meteoro no nível atual
	ADD R6, 2
	MOV R9, [R6]
	CALL testa_limite_inferior		; testa se o meteoro chegou ao limite inferior do ecrã
	JMP fim_desce_meteoro			; vai para o fim da rotina
meteoro_colidiu:
	CALL apaga_objeto
	;MOV R5, SOM_DESTROI_INIMIGO
	;MOV [SELECIONA_SOM], R5
	CALL reinicia_meteoro
	MOV R9, houve_colisao
	MOV R11, 0
	MOV [R9 + R8], R11
	JMP fim_desce_meteoro			; vai para o fim da rotina
meteoro_explodiu:
	CALL reinicia_meteoro			; se um meteoro explode, deve ser reiniciado, de forma a que possa aparecer um novo
	MOV [explodiu], R10
	MOV R5, SOM_EXPLOSAO
	MOV [SELECIONA_SOM], R5
	JMP fim_desce_meteoro			; vai para o fim da rotina
fim_desce_meteoro:					; termina a rotina "desce_meteoro"
	POP R9
	POP R6
	RET
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; TESTA_LIMITE_INFERIOR: Testa se o meteoro já atingiu o limite inferior do ecrã
	; (de cima para baixo)
	; 
	; Argumentos:
	;	R1 - linha do meteoro
	; 	R9 - altura do meteoro
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
testa_limite_inferior:        ; vê - se se o objeto chegou o limite inferior
	PUSH R9                      ; altura do meteoro
	MOV R5, MAX_LINHA					; valor do limite inferior do ecrã
	ADD R9, R1							; limite inferior do objeto (linha inicial (R1) mais altura)
	CMP R9, R5							; se não estiver na última linha
	JNZ proxima_linha					; vai para a linha seguinte
	CALL reinicia_meteoro				; se estiver na última linha, faz iniciar-se um novo meteoro
	JMP fim_testa_limites_inferior
proxima_linha:
	ADD R1, 1							; incrementa em uma unidade a linha onde o meteoro tem inicio
fim_testa_limites_inferior:
	MOV R9, linhas_meteoros      ; tabela com a linha de cada meteoro
	MOV [R9 + R8], R1
	POP R9
	RET
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; REINICIA_METEORO: Define, "aleatoriamente", o tipo de meteoro
	;
	; Retorna: R10 - tipo de meteoro
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
define_tipo_meteoro:
	PUSH R2
	CALL gera_aleatorio				; gera número aleatorio entre 0 e 7
	CMP R2, DIVISAO_MAU_OU_BOM
	JGE meteoro_mau					; se o valor gerado for maior que o valor da DIVISAO_MAU_BOM, o meteoro é mau
meteoro_bom:
	MOV R10, DEF_METEOROS_BONS   	; tabela com os niveis dos meteoros bons
	JMP fim_tipo_meteoros
meteoro_mau:
	MOV R10, DEF_METEOROS_MAUS   	; tabela com os niveis dos meteoros maus
fim_tipo_meteoros:
	POP R2
	RET
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; REINICIA_METEORO: Inicia um novo meteoro de forma aleatoria, no inicio do ecrã
	; Argumentos:
	;
	; Retorna:
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
reinicia_meteoro:
	MOV R1, LINHA_INICIAL_METEORO 		; linha do meteoro
	MOV R9, linhas_meteoros      		; tabela com a linha de cada meteoro
	MOV [R9 + R8], R1
	CALL gera_aleatorio         	 	; gera número aleatorio entre 0 e 7
	SHL R2, 3                    		; coluna do meteoro dependendo do numero gerado anteriormente
	MOV R9, colunas_meteoros     		; tabela com a coluna de cada meteoro
	MOV [R9 + R8], R2            		; guarda o valor da coluna do meteoro
	MOV R3, - 2                  		; count para ler o tamanho do meteoro
	MOV R7, 0                    		; count para ver se é linha múltipla de 3
	CALL define_tipo_meteoro			; vê se o meteoro é bom ou mau
	MOV R9, defs_meteoros				; tabela com o tipo de cada um dos meteoros
	MOV [R9 + R8], R10					; guarda o valor do tipo de meteoro
	RET
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; Processo
	;
	; EXPLOSAO: Processo que APAGA A EXPLOSAO. Dependente do número de clocks
	; do missil
	;
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	PROCESS SP_inicial_explosao  ; indicação de que a rotina que se segue é um processo, 
	; com indicação do valor para inicializar o SP
explosao:                     ; processo que implementa o comportamento da explosão
	MOV R3, [explodiu]           ; lê o LOCK e bloqueia até haver uma explosão
	MOV R5, 0                    ; inicializa o contador
	MOV R2, ATRASO_EXPLOSAO      ; obtém o tempo até a explosão apagar
ciclo_explosao:
	MOV R3, [missil_movimenta]   ; lê o LOCK do processo míssil
	ADD R5, 1                    ; incrementa o contador
	CMP R5, R2                   ; só vai apagar a explosão quando chegar ao mesmo número do atraso
	JNZ ciclo_explosao
	MOV R2, ECRA_EXPLOSAO
	MOV [APAGA_PIXEIS], R2       ; apaga todos os pixels do ecrã
	JMP explosao
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; DETETA_COLISAO: Deteta se existe colisão entre o rover e um meteoro (bom )
	; Argumentos:
	;
	;
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	
deteta_colisao:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	PUSH R11
	
nao_colisao_cima:
	MOV R9, linhas_meteoros      	; tabela com a linha de cada meteoro
	MOV R1, [R9 + R8]            	; número da linha superior do meteoro
	MOV R2, ALTURA_METEORO_5     	; altura do meteoro
	SUB R2, 1                    	; retira 1 porque a prmeira linha já conta (ficava 1 bloco a mais)
	ADD R2, R1                   	; linha inferior do meteoro
	MOV R3, [LINHA_ROVER]        	; linha superior do rover
	MOV R4, ALTURA_ROVER         	; altura do Rover
	CMP R2, R3                   	; se a linha inferior do meteoro for superior à linha mais acima do Rover, 
	JLT deteta_colisao_disparo   	; não colidem nesta situação
nao_colisao_lados:
	MOV R9, colunas_meteoros     	; tabela com a coluna de cada meteoro
	MOV R1, [R9 + R8]            	; número da coluna esquerda do meteoro
	MOV R2, LARGURA_METEORO_5    	; largura do meteoro
	SUB R2, 1                    	; retira 1 porque a lateral já conta (ficava 1 bloco a mais)
	ADD R2, R1                   	; coluna da lateral direita do meteoro
	MOV R3, [COLUNA_ROVER]       	; coluna onde o rover se encontra
	MOV R4, LARGURA_ROVER        	; largura do Rover
	SUB R4, 1                    	; retira 1 porque a lateral já conta (ficava 1 bloco a mais)
	ADD R4, R3                   	; coluna da lateral direita do rover
nao_colisao_direita:
	CMP R1, R4                   	; se a lateral direita do rover estiver à esquerda da lateral esquerda do meteoro, 
	JGT deteta_colisao_disparo   	; não colidem nesta situação
nao_colisao_esquerda:
	CMP R3, R2                   	; se a lateral esquerda do rover estiver à direita da lateral direita do meteoro, 
	JGT deteta_colisao_disparo   	; não colidem nesta situação
	JMP colisao_rover            	; se passar em todos estes casos, há colisão com o rover
deteta_colisao_disparo:
	MOV R9, colunas_meteoros     	; tabela com a coluna de cada meteoro
	MOV R1, [R9 + R8]            	; número da lateral esquerda do meteoro
	MOV R7, [COLUNA_MISSIL]      	; coluna onde o missil está a ser disparado
	CMP R1, R7                   	; se a coluna mais a esquerda do meteoro estiver depois da do missil, 
	JGT fim_deteta_colisao       	; não há colisão
	MOV R9, colunas_meteoros     	; tabela com a coluna de cada meteoro
	MOV R1, [R9 + R8]            	; número da coluna esquerda do meteoro
	MOV R2, LARGURA_METEORO_5    	; largura do meteoro
	SUB R2, 1                    	; retira 1 porque a lateral já conta (ficava 1 bloco a mais)
	ADD R2, R1                   	; coluna direita (onde o meteoro termina)
	CMP R2, R7                   	; se a coluna mais a direita onde o meteoro está estiver antes da do missil, não há colisão
	JLT fim_deteta_colisao
	MOV R7, [LINHA_MISSIL]       	; linha do míssil
	MOV R9, linhas_meteoros      	; tabela com a linha de cada meteoro
	MOV R1, [R9 + R8]            	; numero da linha superior do meteoro
	MOV R2, ALTURA_METEORO_5     	; altura do meteoro
	SUB R2, 1                    	; retira 1 porque a lateral já conta (ficava 1 bloco a mais)
	ADD R2, R1                   	; linha inferior do meteoro
	CMP R2, R7
	JLT fim_deteta_colisao
	JMP colisao_disparo          	; se passar em todos estes casos, há colisão com o missil
fim_deteta_colisao:
	POP R11
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET
	
	
colisao_rover:                	 ; o que fazer quando o objeto colide
	MOV R9, houve_colisao		 ; tabela com a indicação de que cada meteoro colidiu
	MOV R11, 1
	MOV [R9 + R8], R11			 ; indica que o meteoro no endereço indicado colidiu
	
	MOV R9, linhas_meteoros      ; tabela com a linha de cada meteoro
	MOV R1, [R9 + R8]            ; linha do meteoro
	MOV R9, colunas_meteoros     ; tabela com a coluna de cada meteoro
	MOV R2, [R9 + R8]            ; coluna do meteoro
	MOV R4, DEF_METEORO_MAU_5    ; para apagar apenas importa a altura e o ecrã, não é necessário distinguir entre meteoros
	CALL apaga_objeto            ; apaga meteoro
	
	MOV R11, DEF_METEOROS_BONS   ; tabela com os níveis dos meteoros bons
	CMP R10, R11                 ; verifica qual é o tipo de meteoro
	JZ colisao_meteoro_bom       ; colidiu com um meteoro bom
	JMP colisao_meteoro_mau      ; colidiu com um meteoro mau
colisao_meteoro_bom:
	MOV [colisao_boa], R11       ; desbloqueia o processo colisao_boa_display (qualquer registo serve)
	
colisao_meteoro_mau:   
	
fim_colisao_rover:
	MOV R9, colunas_meteoros     ; tabela com a coluna de cada meteoro
	MOV R2, [R9 + R8]            ; coluna do meteoro
	JMP fim_deteta_colisao
	
colisao_disparo:
	MOV R3, 1
	MOV [HOUVE_EXPLOSAO], R3     		; avisa o procedimento míssil que houve uma explosão
	MOV R9, linhas_meteoros      		; tabela com a linha de cada meteoro
	MOV R1, [R9 + R8]            		; linha do meteoro
	MOV R9, colunas_meteoros     		; tabela com a coluna de cada meteoro
	MOV R2, [R9 + R8]            		; coluna do meteoro
	
	MOV R11, DEF_METEOROS_MAUS   		; tabela com os níveis dos meteoros bons
	CMP R10, R11                 		; verifica qual é o tipo de meteoro
	JNZ obtem_altura_meteoro_bom 		; colidiu com um meteoro bom
obtem_altura_meteoro_mau:     			; colidiu com um meteoro mau
	MOV R4, DEF_METEORO_MAU_5    		; endereço da tabela que define o meteoro mau
	JMP apagar_objetos_apos_colisao		
obtem_altura_meteoro_bom:
	MOV R4, DEF_METEORO_BOM_5    ; endereço da tabela que define o meteoro bom
apagar_objetos_apos_colisao:
	CALL apaga_objeto            		; apaga o meteoro
	MOV R1, [LINHA_MISSIL]       		; linha do míssil
	MOV R2, [COLUNA_MISSIL]      		; coluna do míssil
	MOV R4, DEF_MISSIL           		; endereço da tabela que define o míssil
	CALL apaga_objeto            		; apaga o míssil
	MOV R1, MAX_LINHA
	MOV [LINHA_MISSIL], R1
	
	MOV R9, linhas_meteoros      		; tabela com a linha de cada meteoro
	MOV R1, [R9 + R8]            		; linha do meteoro
	MOV R9, colunas_meteoros     		; tabela com a coluna de cada meteoro
	MOV R2, [R9 + R8]            		; coluna do meteoro
	MOV R4, DEF_EXPLOSAO         		; endereço da tabela que define a explosão
	CALL desenha_objeto          		; desenha a explosão
	MOV R11, DEF_METEOROS_MAUS   		; tabela com os níveis dos meteoros bons
	CMP R10, R11                 		; verifica qual é o tipo de meteoro
	JZ colisao_disparo_meteoro_mau
	MOV R10, DEF_EXPLOSAO        		; para o código saber que houve explosão
	JMP fim_deteta_colisao
colisao_disparo_meteoro_mau:
	; diminuir energia
	MOV R10, DEF_EXPLOSAO        		; para o código saber que houve explosão
	JMP fim_deteta_colisao		 
	
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; Processo
	;
	; MISSIL - Processo que desenha o missil e o move verticalmente com
	; temporização marcada pela interrupção 2 (missil)
	;
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	
	PROCESS SP_inicial_missil    	; indicação de que a rotina que se segue é um processo, 
	; com indicação do valor para inicializar o SP
missil:                       	 ; processo que implementa o comportamento do míssil
	MOV R3, 0
	MOV [HOUVE_EXPLOSAO], R3     	; flag que indica se ocorreu uma explosão
	MOV R1, MAX_LINHA            	; linha inicial do míssil
	MOV [LINHA_MISSIL], R1       	; atualiza a variável LINHA_MISSIL
	MOV R3, [missil_disparado]   	; lê o LOCK e bloqueia até o missil ser disparado
	MOV R2, SOM_DISPARO_MISSIL
	MOV [SELECIONA_SOM], R2      	; seleciona o som a ser produzido
	
	MOV R1, LINHA_INICIAL_ROVER  	; linha do míssil
	SUB R1, 1                    	; para começar em cima do Rover
	MOV [LINHA_MISSIL], R1      	; atualiza a variável linha míssil
	
	MOV R2, [COLUNA_ROVER]       	; coluna inicial do míssil
	ADD R2, 2                    	; para começar no meio do rover
	MOV [COLUNA_MISSIL], R2      	; atualiza a variável COLUNA_MISSIL
	
	MOV [disparo_missil], R2	 	; desbloqueia o disparo do míssil
	
	MOV R5, - 1                  	; inicializa o contador
	
	MOV R3, 0
	MOV [HOUVE_EXPLOSAO], R3     	; flag que indica se ocorreu uma explosão
	
	MOV R11, 0
	MOV [RECOMECAR_MISSIL], R11		; recomeça o míssil
	
ciclo_missil:
	MOV R11, [RECOMECAR_MISSIL]
	MOV R10, 1
	CMP R11, R10
	JZ missil
	
	MOV R3, [HOUVE_EXPLOSAO]
	CMP R3, 1
	JZ missil                    	; testa se houve explusao
	MOV R6, MAX_ALCANCE_MISSIL   	; alcance máximo do míssil
	CMP R5, R6
	JZ missil                    	; se já estiver no alcance máximo, o míssil só desaparece
	MOV R4, DEF_MISSIL           	; endereço da tabela que define o míssil
	CALL desenha_objeto          	; desenha o objeto a partir da tabela
espera_movimento_missil:
	MOV R3, [missil_movimenta]   	; lê o LOCK e bloqueia até o míssil ser movimentado
	
	MOV R10, 2
	MOV R11, [JOGO]
	CMP R10, R11				
	JZ espera_movimento_missil	 	; se estiver no modo "pausa", o míssil não se vai mover
	
	ADD R5, 1                    	; incrementa o contador
	
move_missil:                  	; neste ciclo vê se é possível movimentar o míssil para cima
	MOV R7, - 1                  	; desloca o missil para cima
	CALL apaga_objeto            	; apaga o míssil na sua posição corrente
	ADD R4, 4                    	; endereço da altura do míssil
	MOV R6, [R4]                 	; obtém a altura do míssil
	ADD R1, R7                   	; para desenhar o objeto na coluna de cima
	MOV [LINHA_MISSIL], R1       	; atualiza a coluna atual do rover
	JMP ciclo_missil             	; esta "rotina" nunca retorna porque nunca termina
	; Se se quisesse terminar o processo, era deixar o processo chegar a um RET
	
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; Processo Diminui Energia de 3 em 3 segundos
	;
	; DISPLAY
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	PROCESS SP_inicial_display_diminuir_tempo
	
display_inicia:
	MOV R1, [modo_jogo]          ; bloqueia neste LOCK até .........?
	
display_diminuir:
	MOV R1, [dimui_energia_a_jogar]
	MOV R1, 2
	MOV R11, [JOGO]
	CMP R1, R11
	JZ display_diminuir
	JMP diminui_em_decimal
	
diminui_em_decimal:
	MOV R11, [DISPLAY]           ; guarda o valor atual do display
	MOV R1, MASCARA
	MOV R2, R11
	AND R2, R1
	CMP R2, 0
	JZ diminui_11
	SUB R11, 5                   ; aumenta o registo do valor do display
	JMP muda_display
diminui_11:
	CALL testa_para_100_diminuir
	SUB R11, 5                   ; aumenta o registo do valor do display
	SUB R11, 5                   ; aumenta o registo do valor do display
	SUB R11, 1                   ; aumenta o registo do valor do display
	JMP muda_display
	
muda_display:
	MOV [DISPLAYS], R11          ; altera o valor apresentado nos displays
	MOV [DISPLAY], R11           ; grava na memória o novo valor do display
	JMP display_diminuir         ; espera até a tecla deixar de ser pressionada
	
testa_para_100_diminuir:
	MOV R1, R11
	SHR R1, 4
	MOV R6, 010H
	CMP R1, R6
	JZ vai_diminuir
	RET
vai_diminuir:
	MOV R6, 09H                  ; aumenta o registo do valor do display
	SHL R6, 4
	ADD R6, 5
	MOV R11, R6
	JMP muda_display
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; Processo Energia Aumenta 10 ao Colidir com uma nave boa
	;
	; DISPLAY
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	PROCESS SP_inicial_display_aumentar_colisao_boa
	
colisao_boa_display:
	MOV R1, [colisao_boa]        ; bloqueia neste LOCK até ...........?
	MOV R11, [DISPLAY]           ; guarda o valor atual do display
	CALL testa_para_100_aumentar
	ADD R11, 5                   ; aumenta o registo do valor do display
	ADD R11, 5                   ; aumenta o registo do valor do display
	ADD R11, 5                   ; aumenta o registo do valor do display
	ADD R11, 1                   ; aumenta o registo do valor do display
	JMP aumenta_10_display
	
testa_para_100_aumentar:
	MOV R1, R11
	SHR R1, 4
	MOV R6, 09H
	CMP R1, R6
	JZ vai_para_100
	MOV R6, 010H
	CMP R1, R6
	JZ vai_para_100
	RET
vai_para_100:
	MOV R11, 0100H
	JMP aumenta_10_display
	
aumenta_10_display:
	MOV [DISPLAYS], R11          ; altera o valor apresentado nos displays
	MOV [DISPLAY], R11           ; grava na memória o novo valor do display
	JMP colisao_boa_display      ; espera até a tecla deixar de ser pressionada
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; Processo Energia Aumenta ao disparar contra uma nave má
	;
	; DISPLAY
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	PROCESS SP_inicial_display_aumentar_acertar_nave
	
disparo_nave_ma_display:
	MOV R1, [acerta_nave_ma]     ; bloqueia neste LOCK até .........?
	MOV R11, [DISPLAY]           ; guarda o valor atual do display
	MOV R1, MASCARA
	MOV R2, R11
	AND R2, R1
	CALL testa_para_100
	CMP R2, 0
	JZ aumenta_5_registo
	ADD R11, 5                   ; aumenta o registo do valor do display
	ADD R11, 5                   ; aumenta o registo do valor do display
	ADD R11, 1                   ; aumenta o registo do valor do display
	JMP aumenta_5_display
	
aumenta_5_registo:
	CALL testa_para_100
	ADD R11, 5                   ; aumenta o registo do valor do display
	JMP aumenta_5_display
	
testa_para_100:
	MOV R6, [DISPLAY]            ; guarda o valor atual do display
	SHR R6, 4
	MOV R1, 09H
	CMP R6, R1
	JZ continua_testar
	JGE fica_a_100
	RET
continua_testar:
	MOV R1, 05H
	CMP R2, 5
	JGE fica_a_100
	RET
	
fica_a_100:
	MOV R11, 0100H
	JMP aumenta_5_display
	
aumenta_5_display:
	MOV [DISPLAYS], R11          ; altera o valor apresentado nos displays
	MOV [DISPLAY], R11           ; grava na memória o novo valor do display
	JMP disparo_nave_ma_display  ; espera até a tecla deixar de ser pressionada
	
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; Processo Energia Diminui 5 ao mandar um missil
	;
	; DISPLAY
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	PROCESS SP_inicial_display_diminuir_missil
	
missil_display:
	MOV R1, [disparo_missil]     ; bloqueia neste LOCK até .........?
	MOV R11, [DISPLAY]           ; guarda o valor atual do display
	MOV R6, R11
	SHR R6, 4
	MOV R1, 0
	CMP R6, R1
	JZ fica_a_0
	
	MOV R1, 010H
	CMP R6, R1
	JZ esta_a_100
	
	MOV R1, MASCARA
	MOV R2, R11
	AND R2, R1
	CMP R2, 0
	JNZ diminui_5_registo
	SUB R11, 5                   ; aumenta o registo do valor do display
	SUB R11, 5                   ; aumenta o registo do valor do display
	SUB R11, 1                   ; aumenta o registo do valor do display
	JMP diminui_5_display
	
diminui_5_registo:
	SUB R11, 5                   ; aumenta o registo do valor do display
	JMP diminui_5_display
	
fica_a_0:
	MOV R11, 0H
	JMP diminui_5_display
	
esta_a_100:
	MOV R11, 095H
	JMP diminui_5_display
	
diminui_5_display:
	MOV [DISPLAYS], R11          ; altera o valor apresentado nos displays
	MOV [DISPLAY], R11           ; grava na memória o novo valor do display
	JMP missil_display           ; espera até a tecla deixar de ser pressionada
	
	
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; DESENHA_OBJETO: Desenha um objeto na linha e coluna indicadas com a
	; forma e cor definidas na tabela indicada.
	; 
	; Argumentos:
	; 	R1 - linha
	; 	R2 - coluna
	; 	R4 - tabela que define o objeto
	;
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
desenha_objeto:               ; neste ciclo é desenhado um objeto na linha e coluna indicados
	PUSH R1
	PUSH R2                      ; indicador da coluna em que está a desenhar
	PUSH R3                      ; indicador da cor que está a desenhar
	PUSH R4                      ; endereço da tabela
	PUSH R5                      ; largura do objeto
	PUSH R6                      ; altura do objeto
	PUSH R7                      ; guarda a coluna inicial
	PUSH R8                      ; guarda a largura do objeto
	PUSH R9                      ; guarda o ecrã onde o objeto vai ser desenhado
obtem_altura_desenha:         ; neste ciclo é obtida a altura do objeto
	MOV R9, [R4]                 ; obtém o ecrã do objeto
	ADD R4, 2                    ; endereço da largura do objeto
	MOV [SEL_ECRA], R9           ; seleção do ecrã onde o objeto vai ser desenhado
	MOV R8, [R4]                 ; obtém a largura do objeto
	ADD R4, 2                    ; endereço da altura do objeto
	MOV R6, [R4]                 ; obtém a altura do objeto
	ADD R4, 2                    ; endereço da cor do próximo pixel
	MOV R7, R2                   ; guarda a coluna em que o objeto esta
obtem_largura_desenha:        ; neste ciclo é obtida a largura do objeto
	MOV R2, R7                   ; obtém a coluna do objeto
	MOV R5, R8                   ; obtém a largura do objeto
desenha_pixels:               ; desenha os pixels do objeto a partir da tabela
	MOV R3, [R4]                			; obtém a cor do próximo pixel do objeto
	CALL escreve_pixel           			; escreve cada pixel do objeto
	ADD R4, 2                    			; endereço da cor do próximo pixel
	ADD R2, 1                    			; próxima coluna
	SUB R5, 1                    			; menos uma coluna para tratar
	JNZ desenha_pixels           			; continua até percorrer toda a largura do objeto
	ADD R1, 1
	SUB R6, 1                    			; menos uma linha para percorrer
	JNZ obtem_largura_desenha    			; continua até percorrer toda a altura do objeto
	MOV R9, ECRA_METEORO_MAU
	MOV [SELECIONA_ECRA_VISUALIZADO], R9 	; os meteoros maus são sempre os primeiros a aparecer
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; APAGA_OBJETO: Apaga um objeto na linha e coluna indicadas com a forma
	; definida na tabela indicada.
	; Argumentos:
	; 	R1 - linha
	; 	R2 - coluna
	; 	R4 - tabela que define o objeto
	;
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
apaga_objeto:                 ; neste ciclo o objeto na posição indicada é apagado
	PUSH R1
	PUSH R2                      ; indicador da coluna em que está a desenhar
	PUSH R3                      ; indicador da cor com que está a desenhar
	PUSH R4                      ; enderaço da tabela
	PUSH R5                      ; largura do objeto
	PUSH R6                      ; altura do objeto
	PUSH R7                      ; guarda a coluna inicial
	PUSH R8                      ; guarda a largura do objeto
	PUSH R9                      ; guarda o ecrã onde o objeto vai ser desenhado
obtem_altura_apaga:
	MOV R9, [R4]                 ; obtém o ecrã do objeto
	ADD R4, 2                    ; endereço da largura do objeto
	MOV [SEL_ECRA], R9           ; seleção do ecrã onde o objeto vai ser desenhado
	MOV R8, [R4]                 ; obtém a largura do objeto
	ADD R4, 2                    ; endereço da altura do objeto
	MOV R6, [R4]                 ; obtém a altura do objeto
	ADD R4, 2                    ; endereço da altura do objeto
	MOV R7, R2                   ; guarda a coluna em que o objeto esta
obtem_largura_apaga:
	MOV R2, R7                   ; obtém a coluna do objeto
	MOV R5, R8                   ; obtém a largura do objeto
apaga_pixels:                 ; desenha os pixels do objeto a partir da tabela
	MOV R3, 0                    ; obtém a cor do próximo pixel do objeto
	CALL escreve_pixel           ; escreve cada pixel do objeto
	ADD R4, 2                    ; endereço da cor do próximo pixel
	ADD R2, 1                    ; próxima coluna
	SUB R5, 1                    ; menos uma coluna para tratar
	JNZ apaga_pixels             ; continua até percorrer toda a largura do objeto
	ADD R1, 1
	SUB R6, 1                    ; menos uma linha para tratar
	JNZ obtem_largura_apaga      ; continua até percorrer toda a altura do objeto
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; ESCREVE_PIXEL: Escreve um pixel na linha e coluna indicadas.
	; 
	; Argumentos: 
	; 	R1 - linha
	; 	R2 - coluna
	; 	R3 - cor do pixel (em formato ARGB de 16 bits)
	;
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
escreve_pixel:
	MOV [DEFINE_LINHA], R1       ; seleciona a linha
	MOV [DEFINE_COLUNA], R2      ; seleciona a coluna
	MOV [DEFINE_PIXEL], R3       ; altera a cor do pixel na linha e coluna já selecionadas
	RET
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; CONVERTE_1248_TO_0123: Converte o valor entre (1, 2, 4 ou 8) para um valor entre (0, 1, 2, 3)
	; 
	; Argumentos:
	; 	R5 - valor (em formato 1, 2, 4 ou 8)
	;
	; Retorna: 
	; 	R8 - valor (em formato 0, 1, 2, 3)
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
converte_1248_to_0123:        ; neste ciclo os valores (1, 2, 4 e 8) são convertidos em (0, 1, 2, 3)
	PUSH R5
	MOV R8, - 1                  ; inicializa o counter
	CMP R5, 0                    ; verifica que o counter não é zero
	JZ fim_1248_to_0123          ; vai para o fim do ciclo
ciclo_1248_to_0123:           ; ciclo que converte os números
	SHR R5, 1                    ; divide por dois
	ADD R8, 1                    ; incrementa o contador
	CMP R5, 0                    ; verifica se o valor é zero
	JNZ ciclo_1248_to_0123       ; repete o ciclo enquanto R5 =/= 0
fim_1248_to_0123:             ; ciclo que termina os ciclos anteriores
	POP R5
	RET
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; TESTA_LIMITES: Testa se o objeto chegou aos limites do ecrã e nesse caso
	; impede o movimento (força R7 a 0)
	; 
	; Argumentos:
	; 	R2 - coluna em que o objeto está
	; 	R6 - largura do objeto
	; 	R7 - sentido de movimento do objeto (valor a somar à coluna em cada
	; movimento: + 1 para a direita, - 1 para a esquerda)
	;
	; Retorna: 
	;	R7 - 0 se já tiver chegado ao limite, inalterado caso contrário
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
testa_limites:
	PUSH R5
	PUSH R6
testa_limite_esquerdo:       	; neste ciclo vê-se se o objeto chegou ao limite esquerdo
	MOV R5, MIN_COLUNA
	CMP R2, R5                   	; verifica se chegou ao lado esquerdo
	JGT testa_limite_direito     	; se não tiver chegado ao lado esquerdo, testa o direito
	CMP R7, 0                    	; passa a deslocar-se para a direita
	JGE sai_testa_limites        	; já verificou todos os limites, e por isso sai
	JMP impede_movimento         	; entre limites. Mantém o valor do R7
testa_limite_direito:         	; neste ciclo vê-se se o objeto chegou ao limite direito
	ADD R6, R2                   	; posição a seguir ao extremo direito do objeto
	MOV R5, MAX_COLUNA
	CMP R6, R5                   	; vê se chegou ao limite direito do ecrã
	JLE sai_testa_limites        	; entre limites. Mantém o valor do R7
	CMP R7, 0                    	; passa a deslocar-se para a direita
	JGT impede_movimento         	; se tiver chegado ao limite, impede o movimento
	JMP sai_testa_limites        	; já verificou todos os limites, e por isso sai
impede_movimento:             		; neste ciclo, o movimento do rover é impedido
	MOV R7, 0                    	; impede o movimento, forçando R7 a 0
sai_testa_limites:            		; neste ciclo, para de se de testar se o rover chegou aos limites laterais do ecrã
	POP R6
	POP R5
	RET

	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; GERA_ALEATORIO: Gera um número "aleatório" entre 0 e 7
	;
	; Retorna: R2 - número entre 0 e 7
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
gera_aleatorio:
	PUSH R3
	MOV R3, TEC_COL              ; endereço do periférico das colunas
	MOVB R2, [R3]                ; ler do periférico de entrada (colunas)
	SHR R2, 5                    ; FALTA TIRAR O TAMANHO MÁXIMO DO METEORO
	POP R3
	RET
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; rot_int_missil: Rotina de atendimento da interrupção míssil
	; Faz simplesmente uma escrita no LOCK que o processo míssil lê.
	; Como basta indicar que a interrupção ocorreu (não há mais
	; informação a transmitir), basta a escrita em si, pelo que
	; o registo usado, bem como o seu valor, é irrelevante
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
rot_int_missil:
	PUSH R1
	MOV R1, 1
	MOV [missil_movimenta], R1   		; desbloqueia o processo missil (qualquer registo serve)
	POP R1
	RFE
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; rot_int_meteoros: Rotina de atendimento da interrupção meteoros
	; Faz simplesmente uma escrita no LOCK que o processo meteoros lê.
	; Como basta indicar que a interrupção ocorreu (não há mais
	; informação a transmitir), basta a escrita em si, pelo que
	; o registo usado, bem como o seu valor, é irrelevante
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
rot_int_meteoros:
	PUSH R1
	MOV R1, 1
	MOV [evento_int_meteoros], R1 		; desbloqueia o processo meteoro (qualquer registo serve)
	POP R1
	RFE
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; rot_int_energia: Rotina de atendimento da interrupção de energia
	; Faz simplesmente uma escrita no LOCK que o processo energia lê.
	; Como basta indicar que a interrupção ocorreu (não há mais
	; informação a transmitir), basta a escrita em si, pelo que
	; o registo usado, bem como o seu valor, é irrelevante
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
rot_int_energia:
	PUSH R1
	MOV R1, 5
	MOV [dimui_energia_a_jogar], R1 	; desbloqueia  o processo display (qualquer registo serve)
	POP R1
	RFE
