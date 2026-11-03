# Pacer (Forerunner 965)

Watch app de respiração guiada, só visual: o círculo cresce na inspiração (azul) e encolhe na expiração (verde), com os segundos que faltam na fase. Não usa sensor; decisão em [`../rr-spike/README.md`](../rr-spike/README.md) (o pulso do 965 não entrega RR).

| Onde | Botão | Faz |
| --- | --- | --- |
| Tela inicial | UP / DOWN | ritmo: 6,5 · 6 · 5,5 · 5 · 4,5 /min |
| Tela inicial | segurar UP | proporção inspira/expira: 50/50 · 40/60 · 33/67 |
| Tela inicial | START | começa |
| Sessão | START | para (mostra o tempo) |
| Fim | START | volta à tela inicial |
| Qualquer | BACK | sai |

Sessão sem limite de tempo; o toque na tela não faz nada.

## Compilar e instalar

```bash
"$APPDATA/Garmin/ConnectIQ/Sdks/connectiq-sdk-win-9.3.0-2026-10-20-95888f262/bin/monkeyc.bat" -f monkey.jungle -d fr965 -o bin/PACER.prg -y ~/.garmin/developer_key.der
```

Copie `bin/PACER.prg` para `GARMIN/APPS/` no relógio (USB) e desconecte. O app aparece como **Pacer** na lista de apps.

## A validar

- Se a tela fica acesa durante a sessão (AMOLED pode apagar pelo tempo limite da luz de fundo).
- Uso durante a corrida: um watch app ocupa a tela e não roda junto com a atividade nativa.
