# Servicos Corporativos Team OS

Sistema web para apoiar o pilar **Align Structure** no plano de 100 dias da nova Gerencia de Suprimentos de Servicos Corporativos.

O objetivo e dar uma visao executiva da estrutura atual, simular redistribuicao de carteiras, mapear competencias do time e apoiar avaliacoes de candidatos sem misturar dados com outros sistemas existentes no Supabase.

## Stack

- React + TypeScript + Vite
- Recharts para graficos
- Supabase JS com schema isolado `team_os`
- GitHub Pages no repositorio `Servi-os_Corporativos_Team`

## Como rodar localmente

```bash
pnpm install
pnpm run dev
```

O app funciona em modo demo/localStorage quando as variaveis Supabase nao existem.

## Variaveis de ambiente

Copie `.env.example` para `.env.local` e preencha:

```bash
VITE_SUPABASE_URL=https://seu-projeto.supabase.co
VITE_SUPABASE_ANON_KEY=sua-chave-publishable-ou-anon
VITE_SUPABASE_SCHEMA=team_os
```

Nunca coloque `SERVICE_ROLE_KEY` ou secret key no front-end. A secret key deve ficar apenas em ambiente seguro/server-side e nunca deve ser commitada.

## Supabase

Projeto alvo: `wagner-performance-os`.

Antes de aplicar a migration, rode o bloco de preflight no arquivo SQL para listar tabelas existentes e confirmar que nada sera sobrescrito.

A migration cria o schema `team_os` e tabelas `team_os_*` com RLS e policies por `auth.uid()`.

## Importar planilhas

Na aba **Estrutura Atual e Simulacoes**, use **Carregar Excel/CSV**.

O importador procura a guia equivalente a `Base Final Sistema`, aceitando variacoes de espaco como `Base Final  Sistema`, e identifica a linha que contem `CATEGORIAS`.

## Publicar no GitHub Pages

O `vite.config.ts` usa `base: "/Servi-os_Corporativos_Team/"`.

O workflow `.github/workflows/deploy-pages.yml` builda o app e publica `dist` no GitHub Pages.
