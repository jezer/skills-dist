---
name: postgresql-support
description: Apoio para instalar, configurar, validar e diagnosticar PostgreSQL no Windows dentro do workspace C:\codes. Use quando Codex precisar preparar PostgreSQL local, validar pre-requisitos, configurar acesso LAN no mesmo Wi-Fi, diagnosticar IP fixo/porta/servico, planejar pgvector, ou criar backup rotativo com arquivos fixos.
---

# PostgreSQL Support

## Objetivo

Apoiar instalacao e operacao local de PostgreSQL no Windows com foco em uso por projetos de IA, acesso por outra maquina no mesmo Wi-Fi e backup rotativo controlado.

## Uso

1. Usar antes de instalar PostgreSQL para validar pre-requisitos.
2. Usar para configurar ou revisar acesso local/LAN, `postgresql.conf`, `pg_hba.conf` e firewall.
3. Usar para validar o IP fixo `192.168.1.10`, porta `5432`, servico PostgreSQL e conectividade.
4. Usar para criar, revisar ou testar scripts de backup rotativo.
5. Usar junto com `powershell-specialist` quando alterar scripts PowerShell.
6. Usar `scripts/configure-remote-access.ps1` para habilitar acesso LAN de uma vez: pg_hba.conf + firewall + perfil de rede.

## Limites

1. Nao expor PostgreSQL para internet publica.
2. Nao armazenar senha, dump real, `.env` ou segredo no repositorio.
3. Nao instalar pacote, alterar firewall ou reiniciar servico sem aprovacao quando exigir privilegio administrativo.
4. Nao assumir que `pgvector` esta disponivel sem validar a extensao no PostgreSQL instalado.
5. Nao usar reserva DHCP ou configuracao do roteador como dependencia obrigatoria.
6. Nao executar backup real em pasta do repositorio.

## Fluxo

1. Confirmar chamado e plano ativos.
2. Executar `scripts/precheck-postgresql.ps1` para validar ambiente.
3. Resolver bloqueios de porta, instalador ou perfil de rede antes de instalar.
4. Instalar PostgreSQL somente apos aprovacao, preferindo Chocolatey e usando Winget como fallback.
5. Configurar banco `ai_platform`, usuario `ai_admin`, schemas e `pgvector`.
6. Configurar acesso LAN: executar `scripts/configure-remote-access.ps1 -Subnet 192.168.1.0/24` como Administrador.
7. Executar `scripts/diagnose-network.ps1` para evidenciar IP, porta, perfil de rede e firewall.
8. Criar backup rotativo com `scripts/run-rotating-backup.ps1`; testar primeiro com `-DryRun`.
9. Registrar evidencias no plano ou na sessao do chamado.

## Armadilhas conhecidas

1. **Perfil de rede Public bloqueia regras de firewall com `Profile: Private`.**
   Verificar com `Get-NetConnectionProfile` antes de criar a regra.
   Corrigir: `Set-NetConnectionProfile -InterfaceAlias "Wi-Fi" -NetworkCategory Private`

2. **pg_hba.conf sem entrada para subnet bloqueia toda conexao remota**, mesmo com `listen_addresses = '*'`.
   O erro e: `FATAL: nenhuma entrada em pg_hba.conf para o hospedeiro "x.x.x.x"`.
   Adicionar: `host all all 192.168.1.0/24 scram-sha-256`

3. **Conexao via nome da maquina usa o IP real da interface, nao 127.0.0.1.**
   Testes bem-sucedidos em localhost nao garantem acesso por hostname/IP externo.

## Scripts

1. `scripts/precheck-postgresql.ps1`: verifica Windows, PowerShell, Chocolatey, Winget, DBeaver, porta, perfil de rede e IP esperado.
2. `scripts/configure-remote-access.ps1`: configura pg_hba.conf, firewall e perfil de rede para acesso LAN. Requer Admin.
3. `scripts/diagnose-network.ps1`: mostra hostname, IPs, perfis de rede, firewall, servico PostgreSQL e teste de porta.
4. `scripts/get-backup-slot.ps1`: calcula os nomes fixos de backup para semanal, quinzenal e mensal.
5. `scripts/run-rotating-backup.ps1`: executa ou simula `pg_dump` para os slots de backup rotativo.

## Padrao De Backup

1. Semanal: `ai_platform_semana_1.dump` ate `ai_platform_semana_7.dump`.
2. Quinzenal: `ai_platform_quinzenal_dia_01.dump` e `ai_platform_quinzenal_dia_15.dump`.
3. Mensal: `ai_platform_mensal_dia_01.dump`.
4. `semana_1` representa segunda-feira e `semana_7` representa domingo.
5. No dia 01, o script deve gerar semanal, quinzenal do dia 01 e mensal do dia 01.
6. Cada ciclo sobrescreve o arquivo fixo correspondente.

## Referencias

1. `references/postgresql-windows.md`: comandos e contratos esperados para instalacao, LAN, pgvector e backup.
