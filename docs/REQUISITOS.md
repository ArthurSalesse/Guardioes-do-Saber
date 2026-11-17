# Documentação de Requisitos e Conteúdo Pedagógico

**Projeto:** Guardiões do Saber

**Versão:** 1.0 — MVP

**Status:** Planejamento inicial

**Público-alvo:** Crianças de 7 a 10 anos

**Plataforma:** Web (computadores)

**Gênero:** Aventura 2D top-down com desafios educativos

Este documento registra os requisitos planejados para o MVP, conforme o
conteúdo fornecido para a issue #4. A presença de um requisito neste documento
não significa que ele já foi implementado. As validações externas pendentes
estão registradas na seção 10.

## 1. Visão Geral do Projeto

O **Guardiões do Saber** é um jogo educativo de aventura desenvolvido para auxiliar o aprendizado de crianças entre 7 e 10 anos, integrando conteúdos escolares a mecânicas de exploração, resolução de problemas e interação com personagens.

O jogador assume o papel de um guardião responsável por restaurar o equilíbrio do mundo fictício de Luméria, que foi afetado pela fragmentação dos Cristais do Conhecimento.

Durante a aventura, o jogador precisa explorar ambientes, interagir com personagens e resolver desafios matemáticos para avançar.

O projeto tem como objetivo oferecer uma ferramenta complementar ao ensino tradicional, permitindo que professores acompanhem o desempenho dos estudantes por meio de indicadores de aprendizagem.

### 1.1 Objetivo Geral

Desenvolver um protótipo funcional de jogo educativo que utilize mecânicas de aventura e resolução de problemas para estimular habilidades matemáticas de alunos do Ensino Fundamental.

### 1.2 Objetivos Específicos

- Desenvolver um ambiente de exploração 2D top-down.
- Integrar operações matemáticas às mecânicas do jogo.
- Estimular raciocínio lógico e resolução de problemas.
- Fornecer feedback educativo durante os desafios.
- Registrar informações sobre o desempenho dos jogadores.
- Disponibilizar indicadores de acompanhamento para professores.
- Avaliar a usabilidade e a aceitação do jogo em ambiente escolar.

## 2. Escopo do MVP

O MVP será limitado à primeira região do jogo, denominada **Floresta dos Números**, com foco em operações de adição e subtração.

### 2.1 Funcionalidades incluídas

- Um personagem jogável.
- Movimentação em quatro direções.
- Um mapa explorável com áreas desbloqueáveis.
- Interação com personagens e objetos.
- Sistema de diálogos e instruções.
- Três missões educativas.
- Sistema de dicas e feedback.
- Registro de tentativas, acertos e erros.
- Persistência de resultados no backend.
- Painel básico de acompanhamento para professores.
- Execução em navegadores compatíveis.

### 2.2 Funcionalidades fora do escopo

- Multiplayer.
- Rankings competitivos entre alunos.
- Personalização avançada de personagens.
- Inteligência artificial adaptativa.
- Aplicativos nativos para dispositivos móveis.
- Conteúdos de outras disciplinas.
- Geração automática de atividades.
- Sistemas de compras internas.

Essas funcionalidades poderão ser consideradas em versões futuras.

## 3. Requisitos Funcionais

| ID | Requisito | Prioridade |
|---|---|---|
| RF01 | O sistema deve permitir movimentação do personagem em quatro direções. | Alta |
| RF02 | O jogador deve conseguir interagir com personagens e objetos do cenário. | Alta |
| RF03 | O sistema deve apresentar diálogos e instruções para orientar o jogador. | Alta |
| RF04 | O jogo deve disponibilizar três missões matemáticas. | Alta |
| RF05 | O sistema deve verificar as respostas dos desafios matemáticos. | Alta |
| RF06 | O jogo deve apresentar feedback após cada tentativa. | Alta |
| RF07 | O jogador deve conseguir solicitar dicas durante os desafios. | Alta |
| RF08 | O sistema deve desbloquear novas áreas conforme a conclusão das missões. | Alta |
| RF09 | O sistema deve registrar tentativas, acertos, erros e dicas utilizadas. | Alta |
| RF10 | O sistema deve permitir iniciar sessões por meio de códigos individuais de acesso. | Alta |
| RF11 | O backend deve armazenar os resultados das sessões. | Alta |
| RF12 | O professor deve conseguir visualizar resultados dos alunos de suas turmas. | Alta |
| RF13 | O jogo deve apresentar uma tela de conclusão da aventura. | Média |
| RF14 | O jogador deve conseguir pausar a aventura. | Média |
| RF15 | O professor deve conseguir visualizar resultados agrupados por habilidade matemática. | Média |

## 4. Requisitos Não Funcionais

| ID | Requisito | Categoria |
|---|---|---|
| RNF01 | O jogo deve funcionar em navegadores modernos compatíveis com a exportação web do Godot. | Compatibilidade |
| RNF02 | A interface deve utilizar linguagem adequada à faixa etária de 7 a 10 anos. | Usabilidade |
| RNF03 | As interações devem ser simples, evitando exigência de reflexos rápidos. | Acessibilidade |
| RNF04 | Os elementos visuais devem possuir tamanho e contraste adequados. | Interface |
| RNF05 | O sistema deve proteger os dados dos alunos contra acessos não autorizados. | Segurança |
| RNF06 | A comunicação entre jogo e backend deve utilizar HTTPS em produção. | Segurança |
| RNF07 | O sistema deve minimizar a coleta de informações pessoais de crianças. | Privacidade |
| RNF08 | O jogo não deve apresentar anúncios ou compras internas. | Experiência |
| RNF09 | O sistema deve registrar falhas técnicas relevantes sem expor dados pessoais em logs. | Manutenção |
| RNF10 | A arquitetura deve permitir a inclusão de novas missões futuramente. | Escalabilidade |
| RNF11 | O jogo deve apresentar feedback visual e textual, sem depender exclusivamente de cores. | Acessibilidade |
| RNF12 | O acesso aos resultados deve ser restrito aos profissionais autorizados. | Segurança |

## 5. Conteúdo Pedagógico

### 5.1 Área de conhecimento

**Matemática — Ensino Fundamental, anos iniciais.**

O MVP trabalhará principalmente:

- Adição de números naturais.
- Subtração de números naturais.
- Composição e decomposição de quantidades.
- Resolução de problemas matemáticos.
- Raciocínio lógico e planejamento.

### 5.2 Alinhamento à BNCC

O conteúdo pedagógico deverá ser relacionado às habilidades da Base Nacional Comum Curricular (BNCC).

A seleção definitiva dos códigos de habilidades será realizada após análise dos desafios e validação com um profissional da área pedagógica.

Como o público contempla diferentes anos escolares, os desafios deverão considerar a progressão de dificuldade conforme o nível da turma.

O MVP não pretende contemplar integralmente o currículo de Matemática do 2º ao 5º ano, mas trabalhar um conjunto específico de habilidades.

## 6. Descrição das Missões Educativas

### Missão 1 — A Ponte Quebrada

**Contexto narrativo:** Uma ponte foi destruída durante a tempestade que atingiu Luméria. O construtor Tobi solicita ajuda ao jogador para reconstruí-la.

**Objetivo pedagógico:** Desenvolver habilidades de adição e composição de quantidades.

**Mecânica:**

O jogador encontra diferentes pilhas de madeira contendo quantidades específicas de tábuas.

A ponte necessita de exatamente 12 tábuas para ser reconstruída.

O jogador deve selecionar uma combinação de pilhas cuja soma seja igual a 12.

**Exemplo:**

Pilhas disponíveis: 4, 5, 7 e 8 tábuas.

Soluções possíveis incluem:

- 4 + 8 = 12
- 5 + 7 = 12

**Feedback:**

- Soma inferior a 12: informar que ainda faltam tábuas.
- Soma superior a 12: informar que a quantidade ultrapassou o necessário.
- Soma igual a 12: reconstruir a ponte e liberar a passagem.

**Indicadores registrados:**

- Quantidade de tentativas.
- Quantidade de respostas incorretas.
- Dicas utilizadas.
- Tempo de resolução.
- Conclusão do desafio.

### Missão 2 — O Moinho Encantado

**Contexto narrativo:** O moinho responsável por distribuir energia para a floresta parou de funcionar.

A guardiã Flora solicita ajuda para redistribuir a energia disponível.

**Objetivo pedagógico:** Trabalhar adição, subtração e planejamento de recursos.

**Mecânica:**

O jogador possui 20 unidades de energia e precisa ativar mecanismos do moinho, respeitando uma reserva mínima.

Para a configuração inicial, serão utilizados:

- Mecanismo A: 6 unidades.
- Mecanismo B: 8 unidades.
- Reserva mínima: 6 unidades.

**Exemplo:**

20 - 6 - 8 = 6

O jogador deve identificar uma distribuição válida, sem ultrapassar a energia disponível ou comprometer a reserva.

**Feedback:**

- Distribuição inválida: indicar que falta energia ou que a reserva foi comprometida.
- Distribuição válida: ativar o moinho.

**Indicadores registrados:**

- Quantidade de tentativas.
- Erros na distribuição.
- Dicas utilizadas.
- Tempo de resolução.
- Conclusão do desafio.

### Missão 3 — O Cristal Perdido

**Contexto narrativo:** Após restaurar a ponte e o moinho, o jogador chega à caverna onde está localizado o primeiro Cristal do Conhecimento.

Para recuperá-lo, será necessário ativar três pedestais mágicos.

**Objetivo pedagógico:** Consolidar habilidades de adição, subtração e resolução de problemas.

**Mecânica:**

Cada pedestal apresenta um desafio matemático contextualizado.

Exemplos iniciais:

**Pedestal 1 — Adição**

O jogador possui 7 cristais e encontra mais 5. Quantos cristais possui ao todo?

Resposta: 12.

**Pedestal 2 — Subtração**

Um mecanismo possui 18 unidades de energia e consome 9. Quantas unidades restam?

Resposta: 9.

**Pedestal 3 — Combinação**

O jogador deve selecionar cristais de valores diferentes para atingir uma quantidade-alvo.

Ao resolver os três desafios, o Cristal do Conhecimento é restaurado.

**Indicadores registrados:**

- Tentativas por pedestal.
- Acertos e erros.
- Dicas utilizadas.
- Tempo de resolução.
- Conclusão da missão.

## 7. Eventos e Indicadores de Aprendizagem

O sistema deverá registrar eventos associados à interação dos alunos com os desafios.

### 7.1 Eventos

| Evento | Descrição |
|---|---|
| SESSION_STARTED | Início de uma sessão de jogo. |
| MISSION_STARTED | Início de uma missão. |
| PUZZLE_ATTEMPTED | Registro de uma tentativa de resolução. |
| PUZZLE_CORRECT | Tentativa respondida corretamente. |
| PUZZLE_INCORRECT | Tentativa respondida incorretamente. |
| HINT_REQUESTED | Solicitação de uma dica. |
| MISSION_COMPLETED | Conclusão de uma missão. |
| SESSION_COMPLETED | Conclusão da aventura. |

Cada evento deverá possuir identificador, sessão associada e momento de ocorrência.

Eventos relacionados a desafios também deverão identificar a missão, o puzzle e a habilidade pedagógica correspondente.

### 7.2 Indicadores

**Taxa de acerto**

Percentual de tentativas corretas em relação ao total de tentativas registradas.

Taxa de acerto = (tentativas corretas / total de tentativas) × 100.

**Quantidade de tentativas**

Número de tentativas realizadas para resolver cada desafio.

**Utilização de dicas**

Quantidade de dicas solicitadas durante cada missão.

**Tempo de resolução**

Tempo transcorrido entre o início do desafio e sua conclusão.

**Taxa de conclusão**

Percentual de missões concluídas em relação às missões iniciadas.

### 7.3 Apresentação dos resultados

O professor deverá conseguir consultar:

- Quantidade de alunos que iniciaram e concluíram a aventura.
- Resultados individuais por missão.
- Quantidade média de tentativas por desafio.
- Desafios com maior frequência de erros.
- Dicas utilizadas.
- Resultados agrupados por habilidade matemática.

Os indicadores devem servir como apoio à observação pedagógica, não como diagnóstico definitivo de aprendizagem.

O sistema não deverá classificar automaticamente uma criança como incapaz ou com deficiência de aprendizagem a partir dos resultados.

## 8. Requisitos de Acessibilidade

O projeto deverá considerar as necessidades do público infantil, incluindo crianças com diferentes níveis de leitura e habilidades motoras.

### 8.1 Interface

- Utilizar fontes legíveis.
- Manter contraste adequado entre textos e fundos.
- Utilizar botões de tamanho apropriado.
- Evitar excesso de informações simultâneas.
- Utilizar ícones acompanhados de textos quando necessário.
- Não depender exclusivamente de cores para indicar respostas.

### 8.2 Interação

- Permitir movimentação por teclado.
- Evitar desafios que dependam de reflexos rápidos.
- Não estabelecer limite de tempo obrigatório para resolver puzzles.
- Permitir repetir instruções.
- Oferecer dicas progressivas.
- Permitir pausar o jogo.

### 8.3 Linguagem

- Utilizar frases curtas e objetivas.
- Evitar termos excessivamente técnicos.
- Apresentar instruções adequadas à faixa etária.
- Oferecer feedback construtivo.
- Evitar mensagens que constranjam a criança por respostas incorretas.

A inclusão de narração de instruções e suporte a diferentes necessidades de acessibilidade deverá ser avaliada durante o desenvolvimento e os testes.

## 9. Privacidade e Segurança

Como o produto é destinado a crianças, o tratamento de dados deverá observar a Lei Geral de Proteção de Dados Pessoais (LGPD) e os requisitos aplicáveis à proteção de dados infantis.

### 9.1 Minimização de dados

O MVP deverá evitar a coleta de informações pessoais desnecessárias.

Dados inicialmente previstos:

- Identificador interno do aluno.
- Apelido ou identificador utilizado pela turma.
- Turma associada.
- Sessões realizadas.
- Resultados dos desafios.
- Indicadores de desempenho.

Não será necessário coletar fotografias, endereços residenciais ou documentos pessoais das crianças.

### 9.2 Controle de acesso

- Professores deverão utilizar autenticação para acessar o painel.
- Alunos deverão iniciar sessões por códigos individuais e temporários.
- Professores somente poderão visualizar turmas autorizadas.
- A API deverá validar permissões de acesso.
- As informações deverão ser transmitidas por HTTPS em produção.

### 9.3 Proteção e retenção

O projeto deverá definir uma política de retenção, exclusão e proteção dos dados antes de sua utilização em escolas.

Também será necessário estabelecer responsabilidades pelo tratamento dos dados, medidas de segurança e procedimentos de autorização e transparência aplicáveis ao contexto escolar.

## 10. Critérios de Aceitação da Documentação

A Issue #4 será considerada concluída quando:

- [x] O escopo funcional e não funcional estiver documentado.
- [x] As três missões e seus objetivos pedagógicos estiverem descritos.
- [x] As habilidades matemáticas a validar com pedagogo estiverem identificadas.
- [x] Os eventos e indicadores de aprendizagem estiverem especificados.
- [x] Os requisitos iniciais de acessibilidade e privacidade estiverem definidos.
- [ ] O mapeamento definitivo das habilidades da BNCC estiver validado por profissional pedagógico.
- [ ] Os requisitos forem revisados e aprovados pela equipe.

## 11. Considerações Finais

A documentação estabelece os requisitos iniciais para o desenvolvimento do MVP do **Guardiões do Saber**.

O projeto prioriza uma experiência de aprendizagem integrada à aventura, utilizando desafios matemáticos contextualizados e oferecendo ferramentas de acompanhamento para professores.

A primeira versão será utilizada para validar a viabilidade técnica, a experiência dos jogadores e a utilidade pedagógica da solução.

Os requisitos poderão ser revisados conforme os resultados dos testes e as necessidades identificadas durante o desenvolvimento.
