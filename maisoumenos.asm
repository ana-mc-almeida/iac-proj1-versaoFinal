	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; * IST - UL
	; * Modulo: lab7 - processos - quatro - bonecos - displays - teclado.asm
	; * Descrição: Este programa ilustra a utilização de várias instâncias de um
	; * processo cooperativo (extensão do lab7 - processos - boneco - displays - teclado.asm), 
	; * com quatro bonecos que se movimentam de forma independente no ecrã.
	; * O movimento dos boneco é temporizado por quatro interrupções
	; * e os displays sobem ou descem pelo meio do teclado.
	; * Há 6 processos:
	; * - Programa principal, que trata dos displays
	; * - Teclado, que deteta uma tecla na 4ª linha do teclado
	; * - 4 instâncias do processo boneco, cada um tratando do movimento
	; * de um dos quatro bonecos, sempre que a interrupção respetiva ocorre.
	; * As 4 instâncias têm o mesmo código, variando apenas os dados
	; * (a definição dos 4 bonecos é a mesma, mas poderiam ser diferentes
	; * com uma tabela com os endereços das 4 tabelas de definição de boneco)
	; * 
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; * Constantes
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	DEFINE_LINHA EQU 600AH       ; endereço do comando para definir a linha
	DEFINE_COLUNA EQU 600CH      ; endereço do comando para definir a coluna
	DEFINE_PIXEL EQU 6012H       ; endereço do comando para escrever um pixel
	APAGA_AVISO EQU 6040H        ; endereço do comando para apagar o aviso de nenhum cenário selecionado
	APAGA_ECRÃ EQU 6002H         ; endereço do comando para apagar todos os pixels já desenhados
	SELECIONA_CENARIO_FUNDO EQU 6042H ; endereço do comando para selecionar uma imagem de fundo
	SEL_ECRA EQU 6004H           ; para selecionar o ecrã onde vai ser desenhado o objeto
	
	DISPLAYS EQU 0A000H          ; endereço do periférico que liga aos displays
	TEC_LIN EQU 0C000H           ; endereço das linhas do teclado (periférico POUT - 2)
	TEC_COL EQU 0E000H           ; endereço das colunas do teclado (periférico PIN)
	LINHA_TECLADO EQU 16         ; linha a testar (4ª linha, 1000b)
	MASCARA EQU 0FH              ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	
	INICIO_DISPLAY EQU 0100H     ; valor inicial do display
	
	N_BONECOS EQU 4              ; número de bonecos (até 4)

    MODO EQU 0
	
	LINHA_BONECO_0 EQU 4         ; linha do boneco 0
	LINHA_BONECO_1 EQU 12        ; linha do boneco 1
	LINHA_BONECO_2 EQU 20        ; linha do boneco 2
	LINHA_BONECO_3 EQU 28        ; linha do boneco 3
	COLUNA EQU 30                ; coluna do boneco (a meio do ecrã)
	
	LINHA_INICIAL_ROVER EQU 27   ; linha do rover
	COLUNA_INICIAL_ROVER EQU 30  ; coluna do rover
	
	LINHA_INICIAL_METEORO EQU 0  ; linha do meteoro
	COLUNA_INICIAL_METEORO EQU 30 ; coluna do meteoro
	
	MIN_COLUNA EQU 0             ; número da coluna mais à esquerda que o objeto pode ocupar
	MAX_COLUNA EQU 63            ; número da coluna mais à direita que o objeto pode ocupar
	
	LARGURA_ROVER EQU 5          ; largura do rover
	ALTURA_ROVER EQU 4           ; altura do rover
	LARGURA_METEORO_1 EQU 1
	ALTURA_METEORO_1 EQU 1       ; altura do meteoro nível 5
	LARGURA_METEORO_2 EQU 2
	ALTURA_METEORO_2 EQU 2       ; altura do meteoro nível 5
	LARGURA_METEORO_3 EQU 3
	ALTURA_METEORO_3 EQU 3       ; altura do meteoro nível 5
	LARGURA_METEORO_4 EQU 4
	ALTURA_METEORO_4 EQU 4       ; altura do meteoro nível 5
	LARGURA_METEORO_5 EQU 5      ; largura do meteoro nível 5
	ALTURA_METEORO_5 EQU 5       ; altura do meteoro nível 5
	LARGURA_DISPARO EQU 5
	ALTURA_DISPARO EQU 5
	
	ECRA_ROVER EQU 0             ; ecrã especificado para o Rover
	ECRA_METEORO EQU 1           ; ecrã especificado para o Meteoro
	ECRA_DISPARO EQU 2
	
	ATRASO_ROVER EQU 7
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; * Cores
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	COR_AMARELA EQU 0FFF0H       ; amarelo em ARGB (opaco, amarelo no máximo, verde no máximo e azul a 0)
	COR_VERMELHA EQU 0FF00H      ; vermelho em ARGB (opaco, vermelho no máximo, verde e azul a 0)
	COR_CINZENTO EQU 0F99AH      ; cinzento em ARGB
	COR_VERDE EQU 0F0B3H         ; verde em ARGB
	COR_VERDE_AGUA EQU 0F2FBH    ; verde_agua em ARGB
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; * Teclas com Funções
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	TECLA_0 EQU 01H              ; tecla 0
	TECLA_2 EQU 03H              ; tecla 2
	TECLA_3 EQU 04H              ; tecla 3
	TECLA_5 EQU 06H              ; tecla 5
	TECLA_9 EQU 0AH              ; tecla 9
	TECLA_D EQU 0EH              ; tecla D
	TECLA_C EQU 0DH              ; tecla C
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; * Dados
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	PLACE 1000H
	
	; Reserva do espaço para as pilhas dos processos
	STACK 100H                   ; espaço reservado para a pilha do processo "programa principal"
SP_inicial_prog_princ:        ; este é o endereço com que o SP deste processo deve ser inicializado
	
	STACK 100H                   ; espaço reservado para a pilha do processo "teclado"
SP_inicial_teclado:           ; este é o endereço com que o SP deste processo deve ser inicializado
	
	; SP inicial de cada processo "boneco"
	STACK 100H                   ; espaço reservado para a pilha do processo "boneco", instância 0
SP_inicial_rover:             ; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 100H
SP_inicial_display_diminuir:
	
	STACK 100H
SP_inicial_display_aumentar:
	
DEF_ROVER:                    ; tabela que define o Rover (cor, largura, pixels)
	WORD ECRA_ROVER              ; ecrã do Rover
	WORD LARGURA_ROVER           ; largura do Rover
	WORD ALTURA_ROVER            ; altura do Rover
	WORD 0, 0, COR_AMARELA, 0, 0
	WORD COR_AMARELA, 0, COR_AMARELA, 0, COR_AMARELA
	WORD COR_AMARELA, COR_AMARELA, COR_AMARELA, COR_AMARELA, COR_AMARELA
	WORD 0, COR_AMARELA, 0, COR_AMARELA, 0
	
DEF_METEORO_INICIO_1:
	WORD ECRA_METEORO            ; ecrã do meteoro
	WORD LARGURA_METEORO_1       ; largura do Meteoro Mau
	WORD ALTURA_METEORO_1        ; altura do Meteoro Mau
	WORD COR_CINZENTO
	WORD COR_CINZENTO
	
DEF_METEORO_INICIO_2:
	WORD ECRA_METEORO            ; ecrã do meteoro
	WORD LARGURA_METEORO_2       ; largura do Meteoro Mau
	WORD ALTURA_METEORO_2        ; altura do Meteoro Mau
	WORD COR_CINZENTO, COR_CINZENTO
	WORD COR_CINZENTO, COR_CINZENTO
	
	
DEF_METEORO_BOM_3:
	WORD ECRA_METEORO            ; ecrã do meteoro
	WORD LARGURA_METEORO_3       ; largura do Meteoro Mau
	WORD ALTURA_METEORO_3        ; altura do Meteoro Mau
	WORD 0, COR_VERDE, 0
	WORD COR_VERDE, COR_VERDE, COR_VERDE
	WORD 0, COR_VERDE, 0
	
DEF_METEORO_BOM_4:
	WORD ECRA_METEORO            ; ecrã do meteoro
	WORD LARGURA_METEORO_4       ; largura do Meteoro Mau
	WORD ALTURA_METEORO_4        ; altura do Meteoro Mau
	WORD 0, COR_VERDE, COR_VERDE, 0
	WORD COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE
	WORD COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE
	WORD 0, COR_VERDE, COR_VERDE, 0
	
DEF_METEORO_BOM_5:            ; tabela que define o meteoro mau (cor, largura, pixels)
	WORD ECRA_METEORO            ; ecrã do meteoro
	WORD LARGURA_METEORO_5       ; largura do Meteoro Mau
	WORD ALTURA_METEORO_5
	WORD 0, COR_VERDE, COR_VERDE, COR_VERDE, 0
	WORD COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE ; altura do Meteoro Mau
	WORD COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE
	WORD COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE
	WORD 0, COR_VERDE, COR_VERDE, COR_VERDE, 0
	
DEF_METEORO_MAU_3:
	WORD ECRA_METEORO            ; ecrã do meteoro
	WORD LARGURA_METEORO_3       ; largura do Meteoro Mau
	WORD ALTURA_METEORO_3        ; altura do Meteoro Mau
	WORD COR_VERMELHA, 0, COR_VERMELHA
	WORD 0, COR_VERMELHA, 0
	WORD COR_VERMELHA, 0, COR_VERMELHA
	
DEF_METEORO_MAU_4:
	WORD ECRA_METEORO            ; ecrã do meteoro
	WORD LARGURA_METEORO_4       ; largura do Meteoro Mau
	WORD ALTURA_METEORO_4        ; altura do Meteoro Mau
	WORD COR_VERMELHA, 0, 0, COR_VERMELHA
	WORD COR_VERMELHA, 0, 0, COR_VERMELHA
	WORD 0, COR_VERMELHA, COR_VERMELHA, 0
	WORD COR_VERMELHA, 0, 0, COR_VERMELHA
	
DEF_METEORO_MAU_5:            ; tabela que define o meteoro mau (cor, largura, pixels)
	WORD ECRA_METEORO            ; ecrã do meteoro
	WORD LARGURA_METEORO_5       ; largura do Meteoro Mau
	WORD ALTURA_METEORO_5        ; altura do Meteoro Mau
	WORD COR_VERMELHA, 0, 0, 0, COR_VERMELHA
	WORD COR_VERMELHA, 0, COR_VERMELHA, 0, COR_VERMELHA
	WORD 0, COR_VERMELHA, COR_VERMELHA, COR_VERMELHA, 0
	WORD COR_VERMELHA, 0, COR_VERMELHA, 0, COR_VERMELHA
	WORD COR_VERMELHA, 0, 0, 0, COR_VERMELHA
	
DEF_DISPARO:
	WORD ECRA_DISPARO
	WORD LARGURA_DISPARO
	WORD ALTURA_DISPARO
	WORD 0, COR_VERDE_AGUA, 0, COR_VERDE_AGUA, 0
	WORD COR_VERDE_AGUA, 0, COR_VERDE_AGUA, 0, COR_VERDE_AGUA
	WORD 0, COR_VERDE_AGUA, 0, COR_VERDE_AGUA, 0
	WORD COR_VERDE_AGUA, 0, COR_VERDE_AGUA, 0, COR_VERDE_AGUA
	WORD 0, COR_VERDE_AGUA, 0, COR_VERDE_AGUA, 0
	
COLUNA_ROVER: WORD COLUNA_INICIAL_ROVER ; variável que indica a coluna do Rover
LINHA_ROVER: WORD LINHA_INICIAL_ROVER ; variável que indica a linha do Rover
	
COLUNA_METEORO: WORD COLUNA_INICIAL_METEORO ; variável que indica a coluna do Meteoro
LINHA_METEORO: WORD LINHA_INICIAL_METEORO ; variável que indica a linha do Meteoro
	
DISPLAY: WORD INICIO_DISPLAY  ; variável que indica o valor do display

JOGO: WORD MODO
	
linha_boneco:                 ; linha em que cada boneco está (inicializada com a linha inicial)
	WORD LINHA_BONECO_0
	WORD LINHA_BONECO_1
	WORD LINHA_BONECO_2
	WORD LINHA_BONECO_3
	
coluna_boneco:                ; coluna em que cada boneco está (inicializada com a coluna inicial)
	WORD COLUNA
	WORD COLUNA
	WORD COLUNA
	WORD COLUNA
	
sentido_movimento:            ; sentido movimento de cada boneco ( + 1 para a direita, - 1 para a esquerda)
	WORD 1
	WORD - 1
	WORD 1
	WORD - 1
	
	; Tabela das rotinas de interrupção
tab:
	WORD rot_meteoro             ; rotina de atendimento da interrupção 0
	WORD rot_missil              ; rotina de atendimento da interrupção 1
	WORD rot_energia             ; rotina de atendimento da interrupção 2
	
inicio_do_jogo:
	LOCK 0

dimui_energia_a_jogar:
	LOCK 0
	
aumenta_energia_clicar:
	LOCK 0
	
tecla_carregada:
	LOCK 0                       ; LOCK para o teclado comunicar aos restantes processos que tecla detetou
	
tecla_continuo:
	LOCK 0                       ; LOCK para o teclado comunicar aos restantes processos que tecla detetou, 
	                             ; enquanto a tecla estiver carregada
modo_jogo:
    LOCK 0

modo_pausa:
	LOCK 0
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; * Código
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	PLACE 0                      ; o código tem de começar em 0000H
inicio:
	MOV SP, SP_inicial_prog_princ ; inicializa SP do programa principal
	
	MOV BTE, tab                 ; inicializa BTE (registo de Base da Tabela de Exceções)
	
	MOV [APAGA_AVISO], R1        ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
	MOV [APAGA_ECRÃ], R1         ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	;MOV R1, 0 ; cenário de fundo número 0
	;MOV [SELECIONA_CENARIO_FUNDO], R1 ; seleciona o cenário de fundo
	MOV R7, 1                    ; valor a somar à coluna do boneco, para o movimentar
	
	EI0                          ; permite interrupções 0
	EI1                          ; permite interrupções 1
	EI2                          ; permite interrupções 2
	EI                           ; permite interrupções (geral)
	; a partir daqui, qualquer interrupção que ocorra usa
	; a pilha do processo que estiver a correr nessa altura
	
	; cria processos. O CALL não invoca a rotina, apenas cria um processo executável
	
	CALL teclado                 ; cria o processo teclado
	
	CALL rover

	CALL display_aumentar
	
	CALL display_inicia
	
	CALL gera_aleatorio

recomeca_jogo:

	MOV R0, DISPLAYS             ; endereço do periférico que liga aos displays
	MOV R2, INICIO_DISPLAY
    MOV [DISPLAY], R2
    MOV [R0], R2

    MOV [APAGA_AVISO], R1        ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
	MOV [APAGA_ECRÃ], R1         ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)

    MOV R0, MODO
    MOV [JOGO], R0

obtem_tecla:
	MOV R1, [tecla_carregada]    ; bloqueia neste LOCK até uma tecla ser carregada
	
	MOV R6, TECLA_C
	CMP R1, R6                   ; é a coluna da tecla 0?
	JZ testa_C
	
	MOV R6, TECLA_D
	CMP R1, R6                   ; é a coluna da tecla D?
	JZ testa_D

	JMP obtem_tecla
	
testa_D:
    MOV R2, 1
    MOV R0, [JOGO]
    CMP R2, R0
    JNZ testa_C
    MOV R2, 2
    MOV [JOGO], R2
	JMP obtem_tecla         ; processo do programa principal nunca termina

testa_C:
    MOV R2, 1
    MOV [JOGO], R2
    MOV [modo_jogo], R1
	JMP obtem_tecla         ; processo do programa principal nunca termina


	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; Processo
	;
	; TECLADO - Processo que deteta quando se carrega numa tecla na 4ª linha
	; do teclado e escreve o valor da coluna num LOCK.
	;
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	
	PROCESS SP_inicial_teclado   ; indicação de que a rotina que se segue é um processo, 
	; com indicação do valor para inicializar o SP
teclado:                      ; processo que implementa o comportamento do teclado
	MOV R2, TEC_LIN              ; endereço do periférico das linhas
	MOV R3, TEC_COL              ; endereço do periférico das colunas
	MOV R6, MASCARA              ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	
inicia_linhas:
	MOV R1, LINHA_TECLADO        ; linha a testar no teclado
espera_tecla:                 ; neste ciclo espera - se até uma tecla ser premida
	
	WAIT                         ; este ciclo é potencialmente bloqueante, pelo que tem de
	; ter um ponto de fuga (aqui pode comutar para outro processo)
	
	SHR R1, 1                    ; divide por 2 para passar para a linha anterior
	JZ inicia_linhas             ; se for 0 volta para a linha final
	MOVB [R2], R1                ; escrever no periférico de saída (linhas)
	MOVB R0, [R3]                ; ler do periférico de entrada (colunas)
	AND R0, R6                   ; elimina bits para além dos bits 0 - 3
	CMP R0, 0                    ; há tecla premida?
	JZ espera_tecla              ; se nenhuma tecla premida, repete
	
	MOV R10, R1                  ; memoriza a linha pressionada
	MOV R5, R1
	CALL converte_1248_to_0123   ; converter linha de 1, 2, 4 e 8 para 0, 1, 2, 3
	MOV R1, R8
	
	MOV R5, R0
	CALL converte_1248_to_0123   ; converter coluna de 1, 2, 4 e 8 para 0, 1, 2, 3
	MOV R0, R8
	
	ADD R1, R1                   ; R6 = 2 * R6
	ADD R1, R1                   ; R6 = 2 * R6 <=> R6 = 4 * R6
	ADD R0, R1                   ; R0 = 4 * R6 + R0 - > exata tecla pressionada
	
	ADD R0, 1                    ; adicionar mais um por causa do lock
	
	MOV [tecla_carregada], R0    ; informa quem estiver bloqueado neste LOCK que uma tecla foi carregada
	; (o valor escrito é o número da coluna da tecla no teclado)
	
ha_tecla:                     ; neste ciclo espera - se até NENHUMA tecla estar premida
	
	YIELD                        ; este ciclo é potencialmente bloqueante, pelo que tem de
	; ter um ponto de fuga (aqui pode comutar para outro processo)
	
	
	MOV [tecla_continuo], R0     ; informa quem estiver bloqueado neste LOCK que uma tecla está a ser carregada
	; (o valor escrito é o número da coluna da tecla no teclado)
	
	MOV R1, R10                  ; testar a linha pressionada anteriormente
	MOVB [R2], R1                ; escrever no periférico de saída (linhas)
	MOVB R0, [R3]                ; ler do periférico de entrada (colunas)
	AND R0, R6                   ; elimina bits para além dos bits 0 - 3
	CMP R0, 0                    ; há tecla premida?
	JZ espera_tecla
	
	MOV R5, R1
	CALL converte_1248_to_0123   ; converter linha de 1, 2, 4 e 8 para 0, 1, 2, 3
	MOV R1, R8
	
	MOV R5, R0
	CALL converte_1248_to_0123   ; converter coluna de 1, 2, 4 e 8 para 0, 1, 2, 3
	MOV R0, R8
	
	ADD R1, R1                   ; R6 = 2 * R6
	ADD R1, R1                   ; R6 = 2 * R6 <=> R6 = 4 * R6
	ADD R0, R1                   ; R0 = 4 * R6 + R0 - > exata tecla pressionada
	
	ADD R0, 1                    ; adicionar mais um por causa do lock
	
	JNZ ha_tecla                 ; se ainda houver uma tecla premida, espera até não haver
	
	;JMP espera_tecla ; esta "rotina" nunca retorna porque nunca termina
	; Se se quisesse terminar o processo, era deixar o processo chegar a um RET
	
	
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; Processo
	;
	; BONECO - Processo que desenha um boneco e o move horizontalmente, com
	; temporização marcada pela interrupção 0
	;
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	
	PROCESS SP_inicial_rover     ; indicação de que a rotina que se segue é um processo, 
	; com indicação do valor para inicializar o SP
rover:                        ; processo que implementa o comportamento do boneco
	; desenha o boneco na sua posição inicial
	MOV R1, LINHA_INICIAL_ROVER  ; linha do boneco
	MOV R2, COLUNA_INICIAL_ROVER
	MOV R5, 0                    ; inicializa o contador
    MOV R6, [modo_jogo]
	
ciclo_boneco:
	MOV R4, DEF_ROVER            ; endereço da tabela que define o boneco
	CALL desenha_objeto          ; desenha o boneco a partir da tabela
espera_movimento:
	MOV R3, [tecla_continuo]     ; lê o LOCK e bloqueia até o teclado escrever nele novamente
	
	ADD R5, 1                    ; incrementa o contador
	CMP R5, ATRASO_ROVER
	JNZ espera_movimento         ; não se vai mover enquanto não acabar o atraso
	
	MOV R5, 0                    ; reiniciar o contador
	
	MOV R6, TECLA_0
	CMP R3, R6                   ; é a coluna da tecla 0?
	JZ move_rover_esquerda
	
	
	MOV R6, TECLA_2
	CMP R3, R6                   ; é a coluna da tecla 2?
	JZ move_rover_direita
	
	JMP espera_movimento         ; se não é, ignora e continua à espera
	
move_rover_esquerda:          ; neste ciclo vê se é possível movimentar o obejto para a esquerda
	MOV R7, - 1                  ; desloca o objeto para a esquerda
	JMP move_rover               ; testa se está dentro dos limites do ecrã
move_rover_direita:
	MOV R7, + 1                  ; desloca o objeto para a direita, se estiver dentro dos limites do ecrã
	JMP move_rover               ; testa se está dentro dos limites do ecrã
move_rover:
	CALL apaga_objeto            ; apaga o boneco na sua posição corrente
	ADD R4, 2                    ; endereço da largura do objeto
	MOV R6, [R4]                 ; obtém a largura do boneco
	CALL testa_limites           ; vê se chegou aos limites do ecrã e nesse caso inverte o sentido
	ADD R2, R7                   ; para desenhar objeto na coluna seguinte (direita ou esquerda)
	JMP ciclo_boneco             ; esta "rotina" nunca retorna porque nunca termina
	; Se se quisesse terminar o processo, era deixar o processo chegar a um RET


	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; Processo Diminui Energia de 3 em 3 segundos
	;
	; DISPLAY
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	PROCESS SP_inicial_display_diminuir	

display_inicia:
    MOV R1, [modo_jogo]
display_diminuir:
    MOV R1, [dimui_energia_a_jogar]
    MOV R1, 1
    MOV R11, [JOGO]
    CMP R1, R11
    JNZ display_inicia
	JMP diminui_em_decimal
	MOV R1, 0
	MOV [dimui_energia_a_jogar], R1
	JMP display_diminuir
	
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
	; Processo Energia Aumenta ao Clicar
	;
	; DISPLAY
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	PROCESS SP_inicial_display_aumentar
	
display_aumentar:
	MOV R1, [aumenta_energia_clicar]
	JNZ aumenta_em_decimal
	MOV [aumenta_energia_clicar], R1
	RET
	
aumenta_em_decimal:
	MOV R11, [DISPLAY]           ; guarda o valor atual do display
	CALL testa_para_100_aumentar
	ADD R11, 5                   ; aumenta o registo do valor do display
	ADD R11, 5                   ; aumenta o registo do valor do display
	ADD R11, 5                   ; aumenta o registo do valor do display
	ADD R11, 1                   ; aumenta o registo do valor do display
	JMP altera_display
	
testa_para_100_aumentar:
	MOV R1, R11
	SHR R1, 4
	MOV R6, 09H
	CMP R1, R6
	JZ vai_aumentar
    MOV R6, 010H
    CMP R1, R6
	JZ vai_aumentar
	RET
vai_aumentar:
	MOV R11, 0100H
	JMP altera_display
	
altera_display:
	MOV [DISPLAYS], R11          ; altera o valor apresentado nos displays
	MOV [DISPLAY], R11           ; grava na memória o novo valor do display
	JMP display_aumentar         ; espera até a tecla deixar de ser pressionada
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; desenha_objeto - > desenha um objeto na linha e coluna indicadas com a
	; forma e cor definidas na tabela indicada.
	; Argumentos:
	; R1 - linha
	; R2 - coluna
	; R4 - tabela que define o objeto
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
	MOV R9, [R4]                 ; obtém a largura do objeto
	ADD R4, 2                    ; endereço da altura do objeto
	MOV [APAGA_AVISO], R1        ; apaga o aviso de nenhum cenário selecionado
	MOV [SEL_ECRA], R9           ; seleção do ecrã onde o objeto vai ser desenhado
	MOV R8, [R4]                 ; obtém a largura do objeto
	ADD R4, 2                    ; endereço da altura do objeto
	MOV R6, [R4]                 ; obtém a altura do objeto
	ADD R4, 2                    ; endereço da cor do próximo pixel
	MOV R7, R2                   ; guarda a coluna em que o objeto esta
obtem_largura_desenha:        ; neste ciclo é obtida a largura do objeto
	MOV R2, R7
	MOV R5, R8                   ; obtém a largura do objeto
desenha_pixels:               ; desenha os pixels do objeto a partir da tabela
	MOV R3, [R4]                 ; obtém a cor do próximo pixel do objeto
	CALL escreve_pixel           ; escreve cada pixel do objeto
	ADD R4, 2                    ; endereço da cor do próximo pixel
	ADD R2, 1                    ; próxima coluna
	SUB R5, 1                    ; menos uma coluna para tratar
	JNZ desenha_pixels           ; continua até percorrer toda a largura do objeto
	ADD R1, 1
	SUB R6, 1                    ; menos uma linha para percorrer
	JNZ obtem_largura_desenha    ; continua até percorrer toda a altura do objeto
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
	; apaga_objeto - > Apaga um boneco na linha e coluna indicadas com a forma
	; definida na tabela indicada.
	; Argumentos:
	; R1 - linha
	; R2 - coluna
	; R4 - tabela que define o boneco
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
	PUSH R9
obtem_altura_apaga:
	MOV R9, [R4]
	ADD R4, 2
	MOV [SEL_ECRA], R9
	MOV R8, [R4]                 ; obtém a largura do objeto
	ADD R4, 2                    ; endereço da altura do objeto
	MOV R6, [R4]                 ; obtém a altura do objeto
	ADD R4, 2                    ; endereço da altura do objeto
	MOV R7, R2
obtem_largura_apaga:
	MOV R2, R7
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
	; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
	; Argumentos: R1 - linha
	; R2 - coluna
	; R3 - cor do pixel (em formato ARGB de 16 bits)
	;
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
escreve_pixel:
	MOV [DEFINE_LINHA], R1       ; seleciona a linha
	MOV [DEFINE_COLUNA], R2      ; seleciona a coluna
	MOV [DEFINE_PIXEL], R3       ; altera a cor do pixel na linha e coluna já selecionadas
	RET
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; converte_1248_to_0123 - > Converte o valor entre (1, 2, 4 ou 8) para um valor entre (0, 1, 2, 3)
	; Argumentos:
	; R5 - valor (em formato 1, 2, 4 ou 8)
	;
	; Retorna: R8 - valor (em formato 0, 1, 2, 3)
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
converte_1248_to_0123:        ; neste ciclo os valores (1, 2, 4 e 8) são convertidos em (0, 1, 2, 3)
	PUSH R5
	MOV R8, - 1                  ; inicializa o counter
	CMP R5, 0                    ; verifica que o counter não é zero
	JZ fim_1248_to_0123          ; vai para o fim do ciclo
ciclo_1248_to_0123:           ; ciclo que converte os números
	SHR R5, 1                    ; dividir por dois
	ADD R8, 1                    ; incrementa o contador
	CMP R5, 0                    ; verifica se o valor é zero
	JNZ ciclo_1248_to_0123       ; repete o ciclo enquanto R5 = / = 0
fim_1248_to_0123:             ; ciclo que termina os ciclos anteriores
	POP R5
	RET
	
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; testa_limites - Testa se o objeto chegou aos limites do ecrã e nesse caso
	; impede o movimento (força R7 a 0)
	; Argumentos:
	; R2 - coluna em que o objeto está
	; R6 - largura do objeto
	; R7 - sentido de movimento do objeto (valor a somar à coluna em cada
	; movimento: + 1 para a direita, - 1 para a esquerda)
	;
	; Retorna: R7 - 0 se já tiver chegado ao limite, inalterado caso contrário
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
testa_limites:
	PUSH R5
	PUSH R6
testa_limite_esquerdo:        ; neste ciclo vê - se se o objeto chegou ao limite esquerdo
	MOV R5, MIN_COLUNA
	CMP R2, R5                   ; verifica se chegou ao lado esquerdo
	JGT testa_limite_direito     ; se não tiver chegado ao lado esquerdo, testa o direito
	CMP R7, 0                    ; passa a deslocar - se para a direita
	JGE sai_testa_limites        ; já verificou todos os limites, e por isso sai
	JMP impede_movimento         ; entre limites. Mantém o valor do R7
testa_limite_direito:         ; neste ciclo vê - se se o objeto chegou ao limite direito
	ADD R6, R2                   ; posição a seguir ao extremo direito do objeto
	MOV R5, MAX_COLUNA
	CMP R6, R5                   ; vê se chegou ao limite direito do ecrã
	JLE sai_testa_limites        ; entre limites. Mantém o valor do R7
	CMP R7, 0                    ; passa a deslocar - se para a direita
	JGT impede_movimento         ; se tiver chegado ao limite, impede o movimento
	JMP sai_testa_limites        ; já verificou todos os limites, e por isso sai
impede_movimento:             ; neste ciclo, o movimento do rover é impedido
	MOV R7, 0                    ; impede o movimento, forçando R7 a 0
sai_testa_limites:            ; neste ciclo, para - se de testar se o rover chegou aos limites laterais do ecrã
	POP R6
	POP R5
	RET
	
	
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	; gera_aleatorio - Gera um número "aleatório" entre 0 e 7
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
	;
	; ROTINAS DAS INTERRUPÇÕES
	;
	; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	
rot_meteoro:
	RFE
	
rot_missil:
	RFE
	
rot_energia:
	PUSH R1
	MOV R1, 5
	MOV [dimui_energia_a_jogar], R1 ; desbloqueia processo display (qualquer registo serve)
	POP R1
	RFE
