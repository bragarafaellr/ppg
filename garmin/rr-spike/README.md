# RR Spike (Forerunner 965)

Watch app descartável que responde uma pergunta: **o sensor do pulso do 965 entrega intervalos RR reais pelo Connect IQ?**
Sem RR reais não há biofeedback batida a batida no relógio (ver decisões abaixo).

O app grava 2 min: registra `heartBeatIntervals` via `Sensor.registerSensorDataListener` e grava uma atividade
(para comparar a FC no Garmin Connect). Ao fim, vibra e mostra `FIM`.

Tela:

| Linha | Significado |
| --- | --- |
| `45 / 120 s` | tempo |
| `FC 52  cb 45` | FC do relógio · quantas vezes o callback do sensor foi chamado |
| `RR n=40` | quantos RR chegaram |
| `media` / `dp` | média e desvio padrão dos RR (ms) |
| última linha | últimos 3 RR |

## Compilar

SDK 9.3.0 instalado pelo SDK Manager; chave de desenvolvedor em `~/.garmin/developer_key.der` (fora do repo).

```bash
"$APPDATA/Garmin/ConnectIQ/Sdks/connectiq-sdk-win-9.3.0-2026-10-20-95888f262/bin/monkeyc.bat" -f monkey.jungle -d fr965 -o bin/RRSPIKE.prg -y ~/.garmin/developer_key.der
```

## Instalar no relógio

1. Conecte o 965 por USB e abra no Explorador de Arquivos: `Forerunner 965 > Internal Storage > GARMIN`.
2. Copie `bin/RRSPIKE.prg` para `GARMIN/APPS/`.
3. Para ter o log: copie `RRSPIKE.TXT` (vazio) para `GARMIN/APPS/LOGS/` (crie a pasta `LOGS` se não existir).
4. Desconecte. O app aparece como **RR Spike** na lista de apps (botão START > rolar até o fim).

## Teste

1. Sentado, relógio firme no pulso, 2 min **respirando a 6/min** (5 s inspira, 5 s expira; pode usar o pacer do app web).
2. Anote a tela final (foto).
3. Reconecte por USB e copie `GARMIN/APPS/LOGS/RRSPIKE.TXT` para `C:\ppg-teste\dados\`.
   Linhas `rr,t_ms,rr_ms` (cada RR, carimbado com o tempo do callback) e `hr,t_ms,bpm` (FC do relógio, 1/s).

## Como ler o resultado

| O que aparece | Conclusão |
| --- | --- |
| `cb 0` | o callback nem é chamado com o sensor do pulso |
| `cb` sobe, `RR n=0` | callback chamado, mas sem RR |
| RR chegam, `dp` baixo (< ~10 ms) ou valores repetidos | RR suavizados/sintéticos, não servem |
| RR chegam, ~1 por batimento (n ≈ FC × 2), `dp` claramente alto (dezenas de ms) e oscilação a ~10 s no log | **RR reais** → biofeedback no relógio é viável |

## Decisões (02/11/2026)

- **Tipo de app:** watch app. A doc oficial de `registerSensorDataListener` diz que ele "will cause an app crash if called from a data field app", então RR só existe em watch app.
- **Durante exercício:** começar pelo watch app e depois validar se faz sentido usar na corrida (talvez só um número fixo).
- **Fonte de RR:** só o pulso, sem cinta. Se o spike falhar, o relógio fica **só com o pacer**.
- **Código:** esta subpasta de `bragarafaellr/ppg`.
- **Resultado do spike:** _pendente (teste no relógio)_.
