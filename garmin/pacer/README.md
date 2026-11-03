# Pacer (Forerunner 965)

Data field de respiração guiada, só visual, para usar **dentro da corrida** (ou de qualquer atividade): o círculo cresce na inspiração (azul) e encolhe na expiração (verde), com os segundos que faltam na fase. Não usa sensor; decisão em [`../rr-spike/README.md`](../rr-spike/README.md) (o pulso do 965 não entrega RR).

- Anda com o **cronômetro da atividade**: começa quando você inicia a corrida e pausa junto. Antes de iniciar, mostra "Pacer" e o ritmo.
- **Ritmo e proporção fixos**: 6,0/min e 40/60 (4 s inspira, 6 s expira). Para mudar, altere `RATE_X10` e `INHALE` em `source/PacerApp.mc` e recompile.
- Data field não tem botões nem timer: o relógio redesenha o campo **1 vez por segundo**, então o círculo anda em degraus de 1 s; a contagem regressiva é exata.
- Em tela cheia (layout de 1 campo) mostra círculo grande e o ritmo; em campos menores, círculo e contagem com fonte menor.

A primeira versão era um watch app com botões (commit `600e13b`); virou data field porque um watch app não roda junto com a atividade de corrida.

## Compilar e instalar

```bash
"$APPDATA/Garmin/ConnectIQ/Sdks/connectiq-sdk-win-9.3.0-2026-10-20-95888f262/bin/monkeyc.bat" -f monkey.jungle -d fr965 -o bin/PACER.prg -y ~/.garmin/developer_key.der
```

1. Copie `bin/PACER.prg` para `GARMIN/APPS/` no relógio (USB) e desconecte.
2. No relógio: abra a atividade de corrida › segure UP (menu) › Configurações da corrida › Telas de dados › escolha ou adicione uma tela › layout de 1 campo › toque no campo › **Connect IQ › Pacer**.
