# dms-desk-widgets

Widgets de desktop animados para o [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) (DMS), feitos em QML e rodando dentro do próprio processo do DMS.

| Widget | O que mostra |
|---|---|
| **deskSystem** | Relógio, data, clima desenhado (sol, nuvem, chuva, lua), CPU, memória, disco, bateria, rede e top processos |
| **deskDev** | Containers Docker, VPN, branch e alterações pendentes dos seus repos, uso do Claude Code — com uma baleia do Docker boiando |
| **deskOps** | Erros em produção (SigNoz), issues do Linear, seus PRs e o CI — com uma raposa que dorme quando está tudo bem e acorda quando algo quebra |
| **deskAquario** | Um aquário com peixes, bolhas e algas. Só pela graça. |

## Requisitos

- DMS ≥ 1.5 (Quickshell)
- `jq`, `curl`, `git`, `gh` (autenticado), `docker`, `nmcli`
- Fontes **Inter** e **JetBrains Mono**
- Uso do Claude Code (opcional): o plugin [`claudeCodeUsage`](https://github.com/titeya/dms-claudecode) instalado no DMS

## Instalação

```sh
git clone https://github.com/giusepperodo/dms-desk-widgets ~/Projetos/dms-desk-widgets
~/Projetos/dms-desk-widgets/install.sh
```

O script cria links dos plugins em `~/.config/DankMaterialShell/plugins/` e copia os arquivos de configuração de exemplo para `~/.config/desk-widgets/`. Depois:

1. Reinicie o DMS (`dms restart`).
2. Adicione os widgets pelo modo de edição de widgets de desktop do DMS e posicione onde quiser.

## Configuração

`~/.config/desk-widgets/config.env`

| Variável | Uso |
|---|---|
| `PROJECTS_DIR` | Pasta onde ficam seus repos (padrão `~/Projetos`) |
| `GIT_REPOS` | Repos mostrados no deskDev, separados por espaço |
| `CI_REPO` | Repo usado para PRs e CI no deskOps |

`~/.config/desk-widgets/secrets.env` (fica só na sua máquina, `chmod 600`)

| Variável | Onde gerar |
|---|---|
| `LINEAR_API_KEY` | Linear → Settings → Account → Security & access → Personal API keys |
| `SIGNOZ_API_KEY` | SigNoz → Settings → API Keys |
| `SIGNOZ_URL` | Endereço da sua instância do SigNoz |

Sem as chaves, as seções de Linear e SigNoz mostram uma dica de configuração no lugar dos dados.

## Desempenho

As animações usam Animators do Qt. Com os quatro widgets ativos o DMS redesenha as janelas continuamente, o que custa CPU — se pesar na sua máquina, deixe só os que mais usa.
