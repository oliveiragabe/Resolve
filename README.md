# Resolve

Aplicativo de gerenciamento de ocorrências e bugs de projetos de software. O Resolve permite registrar problemas, acompanhar seu status e severidade, consultar detalhes, editar informações e excluir ocorrências.

## Informações acadêmicas

- **Aluno:** Gabriel
- **Back-end escolhido:** Opção A — API Laravel
- **Aplicativo:** Flutter e Dart
- **Back-end:** Laravel e PHP
- **Banco de dados:** SQLite

## Sobre o projeto

O Resolve foi desenvolvido como trabalho final integrado das disciplinas de Programação para Dispositivos Móveis, Programação Orientada a Objetos para Web e Paradigmas de Linguagem de Programação.

O aplicativo Flutter consome uma API REST desenvolvida em Laravel. Os dados das ocorrências são persistidos no banco SQLite e carregados pela aplicação por meio de requisições HTTP.

## Funcionalidades

- Cadastro de ocorrências.
- Listagem de ocorrências.
- Consulta dos detalhes de uma ocorrência.
- Edição de título, descrição, projeto, severidade e status.
- Exclusão de ocorrências.
- Atualização do status diretamente na tela de detalhes.
- Pesquisa por título ou projeto.
- Filtros por status e severidade.
- Dashboard com indicadores e ocorrências recentes.
- Validação dos formulários.
- Tratamento dos estados de carregamento, erro e lista vazia.

### Status disponíveis

- Aberto
- Em resolução
- Fechado

### Níveis de severidade

- Baixa
- Média
- Crítica

## Tecnologias utilizadas

### Aplicativo Flutter

- **Flutter e Dart:** desenvolvimento da aplicação.
- **go_router:** navegação por rotas nomeadas.
- **http:** comunicação HTTP com a API.
- **Material Design:** componentes e interface.

### API Laravel

- **PHP e Laravel:** implementação do back-end.
- **SQLite:** persistência dos dados.
- **API REST:** comunicação em JSON.

## Estrutura do projeto

O código está organizado dentro de `tads-es-2026-poo-web/apps/`:

```text
Resolve/
└── tads-es-2026-poo-web/
    └── apps/
        ├── api/       # API Laravel
        └── mobile/    # Aplicativo Flutter
```

### Estrutura do Flutter

```text
apps/mobile/lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── routes/
│   ├── theme/
│   └── utils/
├── models/
├── services/
├── screens/
└── widgets/
```

### Organização em camadas

No aplicativo Flutter:

- **Models:** representam as entidades e realizam a conversão dos dados JSON.
- **Services:** centralizam a comunicação com a API e retornam os models.
- **Screens:** apresentam as telas e controlam a interação do usuário por meio dos services.
- **Widgets:** concentram componentes reutilizáveis.
- **Core:** reúne constantes, rotas, tema e validações.

No back-end Laravel:

- **Models:** representam as entidades e os dados persistidos.
- **Repositories:** concentram as operações de acesso ao banco de dados.
- **Services:** organizam as operações e regras da aplicação.
- **Controllers:** recebem as requisições HTTP, validam os dados e retornam respostas JSON.

## Telas e rotas

| Tela | Rota | Descrição |
|---|---|---|
| Dashboard | `/` | Indicadores gerais e ocorrências recentes |
| Ocorrências | `/issues` | Listagem, pesquisa e filtros |
| Detalhes | `/issues/:id` | Informações, alteração de status e exclusão |
| Nova ocorrência | `/issues/new` | Cadastro de uma ocorrência |
| Editar ocorrência | `/issues/:id/edit` | Edição de uma ocorrência existente |

A navegação utiliza o pacote `go_router`, com nomes de rotas definidos em `core/routes/`.

## Como executar o projeto

Os passos abaixo consideram um ambiente com Flutter, Dart, PHP, Composer e as dependências do Laravel instaladas.

### 1. Clonar o repositório

```bash
git clone https://github.com/oliveiragabe/Resolve.git
cd Resolve
```

### 2. Configurar e executar a API Laravel

Acesse a pasta da API:

```bash
cd tads-es-2026-poo-web/apps/api
composer install
```

Se ainda não existir um arquivo `.env`, crie-o a partir do exemplo:

```bash
cp .env.example .env
php artisan key:generate
```

No arquivo `.env`, confirme a configuração do SQLite:

```env
DB_CONNECTION=sqlite
```

O Laravel utiliza por padrão o arquivo `database/database.sqlite`. Crie-o caso ainda não exista e execute as migrations:

```bash
touch database/database.sqlite
php artisan migrate
```

Inicie o servidor:

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

A API ficará disponível na porta **8000**.

### 3. Configurar a URL da API no Flutter

No GitHub Codespaces, abra a aba **Ports** e copie a URL encaminhada para a porta 8000.

No arquivo:

`tads-es-2026-poo-web/apps/mobile/lib/core/constants/api_constants.dart`

Atualize o valor de `baseUrl` com a URL do seu ambiente. Informe somente a URL base, sem acrescentar `/api/issues`, pois o endpoint é montado pela constante `ApiConstants.issues`.

A URL encaminhada pelo Codespaces pode mudar entre ambientes.

### 4. Executar o aplicativo Flutter

Em outro terminal, acesse a pasta mobile:

```bash
cd tads-es-2026-poo-web/apps/mobile
flutter pub get
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080
```

Encaminhe também a porta **8080** na aba **Ports** do Codespaces e abra a URL disponibilizada para visualizar o aplicativo no navegador.

> Mantenha o servidor Laravel em execução enquanto utiliza o aplicativo, pois o Flutter consome os dados diretamente da API.

## API REST

A API disponibiliza as operações CRUD para a entidade `issues`:

| Método | Endpoint | Operação |
|---|---|---|
| GET | `/api/issues` | Listar ocorrências |
| GET | `/api/issues/{id}` | Consultar uma ocorrência |
| POST | `/api/issues` | Criar ocorrência |
| PUT | `/api/issues/{id}` | Atualizar ocorrência |
| DELETE | `/api/issues/{id}` | Excluir ocorrência |

Os dados são enviados e recebidos em JSON.

### Campos da ocorrência

- `title`: título.
- `description`: descrição.
- `project`: projeto relacionado.
- `severity`: gravidade (`baixa`, `media` ou `critica`).
- `status`: situação (`aberto`, `em_resolucao` ou `fechado`).

## Testes e análise

Na pasta `tads-es-2026-poo-web/apps/mobile`, execute:

Formatar o código:

```bash
dart format .
```

Executar a análise estática:

```bash
flutter analyze
```

Executar os testes:

```bash
flutter test
```

A suíte de testes contempla testes de unidade e de widgets para models, validações, services e telas.

**Última execução registrada durante o desenvolvimento: 43 testes aprovados.**

## Capturas de tela

As capturas de tela da aplicação serão adicionadas aqui:

- Dashboard
- Listagem de ocorrências
- Detalhes da ocorrência
- Formulário de cadastro e edição

## Repositório

[GitHub — oliveiragabe/Resolve](https://github.com/oliveiragabe/Resolve)
