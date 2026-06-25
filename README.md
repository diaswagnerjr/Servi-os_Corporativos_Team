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

Antes de aplicar a migration, rode o bloco de preflight no arquivo SQL para listar tabelas existentes e confirmar que nada sera sobrescrito:

```sql
select table_schema, table_name
from information_schema.tables
where table_schema not in ('pg_catalog', 'information_schema')
order by table_schema, table_name;
```

Depois aplique as migrations nesta ordem:

```sql
supabase/migrations/20260624150000_team_os_schema.sql
supabase/migrations/20260625122444_team_os_security_performance_indexes.sql
```

A migration cria o schema `team_os` e as tabelas:

- `team_os_roles`
- `team_os_people`
- `team_os_wallets`
- `team_os_structure_baseline`
- `team_os_structure_scenarios`
- `team_os_competencies`
- `team_os_expected_competency_matrix`
- `team_os_people_assessments`
- `team_os_sommos_assessments`
- `team_os_candidate_vacancies`
- `team_os_candidates`
- `team_os_candidate_assessments`
- `team_os_comments`
- `team_os_import_logs`

Todas ficam em `team_os`, com prefixo `team_os_`, RLS habilitado e escopo por `auth.uid()` nos dados de usuario.

## Importar planilhas

Na aba **Estrutura Atual e Simulacoes**, use **Carregar Excel/CSV**.

O importador procura a guia equivalente a `Base Final Sistema`, aceitando variacoes de espaco como `Base Final  Sistema`, e identifica a linha que contem `CATEGORIAS`. Apos o upload, os dados aparecem em uma area de revisao antes de substituir a base ativa.

Planilhas de origem usadas na primeira versao:

- `Analise de Carteiras.xlsx`, guia `Base Final  Sistema`
- `FERRAMENTA_MATRIZ COMPETENCIAS_COMPRAS - SERV ADM..xlsx`, guias `Avaliacao`, `Matriz_Media` e `Descritivos_Detalhamento`

## Publicar no GitHub Pages

O `vite.config.ts` ja usa:

```ts
base: "/Servi-os_Corporativos_Team/"
```

O workflow `.github/workflows/deploy-pages.yml` builda o app e publica `dist` no GitHub Pages.

## Modulos entregues

- Dashboard executivo com indicadores, graficos e alertas de risco organizacional.
- Estrutura atual e simulacoes com tabela editavel, importacao, duplicacao de baseline e comparativo.
- Raio X do Time com radar, heatmap editavel, gaps por pessoa/competencia e dados SOMMOS.
- Avaliacao de Candidatos com matriz esperada, radar, aderencia, gaps e comentarios.
- Supabase isolado no schema `team_os`, com RLS, policies por usuario, seed de competencias e indices de apoio.
