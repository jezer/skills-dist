# PostgreSQL Windows Reference

## Configuracao alvo

- IP fixo principal: `192.168.1.10`.
- Subnet LAN esperada: `192.168.1.0/24`.
- Porta: `5432`.
- Banco: `ai_platform`.
- Usuario administrativo: `ai_admin`.
- Schemas: `core`, `rag`, `chat`, `logs`, `config`, `monitoring`, `automation`.
- Backup fora do repositorio: `C:\backup\postgresql`.

## Validacoes uteis

```powershell
Get-NetTCPConnection -LocalPort 5432
Get-NetIPAddress -IPAddress 192.168.1.10
Test-NetConnection -ComputerName 192.168.1.10 -Port 5432
psql --version
pg_isready
```

## SQL base

```sql
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS rag;
CREATE SCHEMA IF NOT EXISTS chat;
CREATE SCHEMA IF NOT EXISTS logs;
CREATE SCHEMA IF NOT EXISTS config;
CREATE SCHEMA IF NOT EXISTS monitoring;
CREATE SCHEMA IF NOT EXISTS automation;

CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS rag.documents (
    id UUID PRIMARY KEY,
    titulo TEXT,
    conteudo TEXT,
    criado_em TIMESTAMP
);

CREATE TABLE IF NOT EXISTS rag.embeddings (
    id UUID PRIMARY KEY,
    document_id UUID,
    embedding vector(1536),
    metadata JSONB
);
```

## Acesso LAN

- `postgresql.conf`: `listen_addresses = '*'` para escuta em todas as interfaces.
- `pg_hba.conf`: entrada obrigatoria para a subnet — sem ela toda conexao remota e rejeitada.
- Firewall do Windows: regra TCP `5432` com `Profile: Private`.
- **Perfil de rede**: a interface Wi-Fi/Ethernet deve estar como `Private`, nao `Public`.

### Sequencia minima para habilitar acesso remoto (Admin)

```powershell
# 1. Diagnostico inicial
.\scripts\diagnose-network.ps1

# 2. Configurar tudo de uma vez
.\scripts\configure-remote-access.ps1 -Subnet "192.168.1.0/24"

# 3. Confirmar
.\scripts\diagnose-network.ps1
```

### pg_hba.conf — entrada para subnet local

```
host    all    all    192.168.1.0/24    scram-sha-256
```

Localizado em: `C:\Program Files\PostgreSQL\{versao}\data\pg_hba.conf`

### Firewall — criar regra manualmente

```powershell
New-NetFirewallRule -DisplayName "PostgreSQL-TCP-5432-Privado" `
    -Direction Inbound -Protocol TCP -LocalPort 5432 `
    -Profile Private -Action Allow
Set-NetFirewallRule -DisplayName "PostgreSQL-TCP-5432-Privado" -RemoteAddress "192.168.1.0/24"
```

### Perfil de rede — corrigir interface Public para Private

```powershell
Get-NetConnectionProfile                                            # ver estado atual
Set-NetConnectionProfile -InterfaceAlias "Wi-Fi" -NetworkCategory Private
```

### Erro common: FATAL pg_hba.conf

```
FATAL: nenhuma entrada em pg_hba.conf para o hospedeiro "192.168.1.x", sem encriptacao
```

Causa: subnet nao esta no pg_hba.conf.
Solucao: adicionar `host all all 192.168.1.0/24 scram-sha-256` e reiniciar o servico.

### Erro comum: TCP connect failed (porta 5432 fechada remotamente)

Verificar em ordem:
1. `netstat -ano | findstr 5432` — PostgreSQL esta escutando em `0.0.0.0:5432`?
2. `Get-NetConnectionProfile` — interface e Private?
3. Regras de firewall para porta 5432 existem e estao ativas?

### Validacoes uteis

```powershell
netstat -ano | findstr 5432
Get-NetConnectionProfile
Get-NetFirewallRule -DisplayName "PostgreSQL-TCP-5432-Privado"
Get-NetTCPConnection -LocalPort 5432
Get-NetIPAddress -IPAddress 192.168.1.10
Test-NetConnection -ComputerName 192.168.1.10 -Port 5432
Test-NetConnection -ComputerName PE0FC2KX -Port 5432
psql --version
pg_isready
```
