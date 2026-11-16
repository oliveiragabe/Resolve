# Resolve

Aplicação para gerenciamento de ocorrências e bugs de projetos de software. O sistema permite registrar problemas, acompanhar seu status e severidade, consultar detalhes, editar informações e excluir ocorrências.

**Aluno:** Gabriel  
**Back-end escolhido:** Opção A — API Laravel  
**Front-end:** Flutter / Dart  
**Back-end:** Laravel / PHP  
**Banco de dados:** SQLite

---

## Funcionalidades

- Cadastro de ocorrências.
- Listagem de ocorrências registradas.
- Visualização dos detalhes de uma ocorrência.
- Edição de título, descrição, projeto, severidade e status.
- Exclusão de ocorrências.
- Atualização do status diretamente na tela de detalhes.
- Pesquisa por título ou projeto.
- Filtros por status e severidade.
- Dashboard com indicadores e ocorrências recentes.

### Status disponíveis

- Aberto
- Em resolução
- Fechado

### Níveis de severidade

- Baixa
- Média
- Crítica

---

## Tecnologias utilizadas

### Aplicativo Flutter

- Flutter e Dart
- go_router — navegação por rotas nomeadas
- http — comunicação HTTP com a API
- Material Design — componentes e interface

### API Laravel

- PHP
- Laravel
- SQLite
- API REST em JSON

---

## Estrutura do projeto

O código da aplicação está organizado dentro de `tads-es-2026-poo-web/apps/`.

```text
Resolve/
└── tads-es-2026-poo-web/
    └── apps/
        ├── api/       # API Laravel
        └── mobile/    # Aplicativo Flutter
```

### Flutter

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

### Laravel

A API utiliza separação de responsabilidades em camadas:

- **Models:** representam as entidades e os dados persistidos.
- **Repositories:** concentram as operações de acesso ao banco de dados.
- **Services:** organizam as operações e regras da aplicação.
- **Controllers:** recebem as requisições HTTP, validam os dados e retornam respostas JSON.

---

## Telas e rotas

| Tela | Rota | Descrição |
|---|---|---|
| Dashboard | `/` | Indicadores gerais e ocorrências recentes |
| Ocorrências | `/issues` | Listagem, pesquisa e filtros |
| Detalhes | `/issues/:id` | Informações, alteração de status e exclusão |
| Nova ocorrência | `/issues/new` | Cadastro de uma ocorrência |
| Editar ocorrência | `/issues/:id/edit` | Edição de uma ocorrência existente |

A navegação é gerenciada pelo pacote `go_router`, com nomes de rotas definidos em `core/routes/`.

---

## Como executar o projeto

Os comandos abaixo consideram a execução em um ambiente com Flutter, Dart, PHP, Composer e Laravel instalados. Em GitHub Codespaces, as portas da API e do aplicativo precisam estar encaminhadas.

### 1. Clonar o repositório

```bash
git clone https://github.com/oliveiragabe/Resolve.git
cd Resolve
```

### 2. Configurar a API Laravel

Abra um terminal e execute:

```bash
cd tads-es-2026-poo-web/apps/api
composer install
cp .env.example .env
php artisan key:generate
```

Configure o SQLite no arquivo `.env`:

```env
DB_CONNECTION=sqlite
DB_DATABASE=database/database.sqlite
```

Crie o arquivo do banco e execute as migrations:

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

Atualize o valor de `baseUrl` com a URL do seu ambiente, sem acrescentar `/api/issues`. O endpoint de ocorrências é montado pela constante `ApiConstants.issues`.

A URL encaminhada pelo Codespaces pode mudar entre ambientes.

### 4. Executar o aplicativo Flutter

Em outro terminal:

```bash
cd tads-es-2026-poo-web/apps/mobile
flutter pub get
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080
```

Encaminhe também a porta **8080** na aba **Ports** do Codespaces e abra a URL disponibilizada para visualizar o aplicativo.

> Mantenha o servidor Laravel em execução enquanto utiliza o aplicativo, pois o Flutter consome os dados diretamente da API.

---

## Testes e análise

Na pasta `tads-es-2026-poo-web/apps/mobile`, execute:

```bash
dart format .
flutter analyze
flutter test
```

A suíte de testes do projeto possui testes de unidade e de widgets para validações, model, service e telas.

**Última execução registrada:** 43 testes aprovados.

---

## Capturas de tela

Adicionar nesta seção as capturas das telas do aplicativo:

- Dashboard
- Listagem de ocorrências
- Detalhes da ocorrência
- Formulário de cadastro e edição

---

## API REST

A API disponibiliza as operações CRUD para a entidade `issues`:

| Método | Endpoint | Operação |
|---|---|---|
| GET | `/api/issues` | Listar ocorrências |
| GET | `/api/issues/{id}` | Consultar uma ocorrência |
| POST | `/api/issues` | Criar ocorrência |
| PUT | `/api/issues/{id}` | Atualizar ocorrência |
| DELETE | `/api/issues/{id}` | Excluir ocorrência |

As respostas são fornecidas em JSON. Os dados são persistidos no banco SQLite configurado na API.
