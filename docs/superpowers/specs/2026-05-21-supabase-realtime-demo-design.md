# Spec: Banco de Dados em Tempo Real com Supabase
**Data:** 2026-05-21  
**Slug:** supabase-realtime-demo  
**Contexto:** Seminário Lab Mobile CC7MA — demonstração prática do Supabase em Flutter

---

## Problema

Demonstrar para a banca como o Supabase fornece sincronização em tempo real entre clientes Flutter, usando PostgreSQL + WebSockets sem backend customizado.

## Escopo

### In-scope
- App Flutter com três telas: NameScreen, ChatScreen, TaskScreen
- Chat em tempo real (INSERT de mensagens via Supabase Realtime)
- Lista colaborativa de tarefas com checkbox (INSERT + UPDATE via Realtime)
- Identificação por apelido (sem autenticação)
- Demonstração com emulador Android + Supabase Table Editor no navegador

### Out-of-scope
- Autenticação / cadastro de usuários
- Delete de mensagens ou tarefas
- Notificações push
- Testes automatizados

---

## Arquitetura

```
Flutter App
  └── supabase_flutter client (WebSocket + REST)
        ├── messages table  → ChatScreen (stream INSERT)
        └── tasks table     → TaskScreen (stream INSERT + UPDATE)

Supabase Project
  ├── PostgreSQL Database
  └── Realtime (habilitado nas duas tabelas)
```

## Modelo de Dados

### Tabela `messages`
| Coluna | Tipo | Default |
|--------|------|---------|
| id | bigint (identity) | auto |
| username | text | — |
| content | text | — |
| created_at | timestamptz | now() |

### Tabela `tasks`
| Coluna | Tipo | Default |
|--------|------|---------|
| id | bigint (identity) | auto |
| username | text | — |
| title | text | — |
| is_done | boolean | false |
| created_at | timestamptz | now() |

Configuração: RLS desabilitado, Realtime habilitado (INSERT + UPDATE + DELETE) nas duas tabelas.

---

## Telas e Navegação

```
NameScreen → HomeScreen (BottomNavigationBar)
                ├── ChatScreen   (aba 0)
                └── TaskScreen   (aba 1)
```

**NameScreen:** campo de texto + botão Entrar. Bloqueia campo vazio. Salva apelido em memória.

**ChatScreen:** lista rolável de mensagens (mais recente embaixo), campo + botão Enviar. Cada item exibe username em negrito, conteúdo e horário. Stream do Supabase atualiza a lista automaticamente.

**TaskScreen:** lista de tarefas com `Checkbox`, campo + botão Adicionar no topo. Tarefa concluída exibe texto riscado. Toggle `is_done` via UPDATE no banco. Stream atualiza automaticamente.

---

## Critérios de Aceite (verificáveis)

1. App abre no emulador sem erros → tela de apelido visível
2. Após inserir apelido e tocar Entrar → navega para HomeScreen
3. Mensagem enviada no ChatScreen aparece na lista em < 2 segundos
4. Inserir linha diretamente no Supabase Table Editor → mensagem aparece no app sem refresh
5. Adicionar tarefa no TaskScreen → aparece na lista em < 2 segundos
6. Marcar tarefa como concluída → texto fica riscado e `is_done = true` no banco
7. Inserir task diretamente no Table Editor → aparece no app sem refresh
