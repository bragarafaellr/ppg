# RR Spike (Forerunner 965)

Watch app descartável que responde uma pergunta: **o sensor do pulso do 965 entrega intervalos RR reais pelo Connect IQ?**
Sem RR reais não há biofeedback batida a batida no relógio (ver decisões abaixo).

O app registra `heartBeatIntervals` via `Sensor.registerSensorDataListener` e a FC do relógio.

Botões: na tela inicial, **UP/DOWN** escolhe 1 ou 2 min e **START** grava. Gravando, **START** para. No fim (vibra e mostra `FIM`), **START** volta à tela inicial. **BACK** sai.
O toque na tela não faz nada, para não parar a gravação por acidente.

Tela:

| Linha | Significado |
| --- | --- |
| `45 / 60 s` | tempo / duração |
| `FC 52  cb 45` | FC do relógio · quantas vezes o callback do sensor foi chamado |
| `RR n=40` | quantos RR chegaram |
| `media` / `dp` | média e desvio padrão dos RR (ms) |
| penúltima linha | últimos 3 RR |

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

1. Sentado, relógio firme no pulso, **respirando a 6/min** (5 s inspira, 5 s expira).
2. **Ao mesmo tempo**, grave com a câmera do iPhone no app web (dedo da outra mão). O CSV da câmera tem `ts_unix_ms` e o log do relógio tem a hora de início, então dá para alinhar os batimentos e medir **quanto atraso** o RR do relógio tem.
3. Anote a tela final (foto).
4. Reconecte por USB e copie `GARMIN/APPS/LOGS/RRSPIKE.TXT` e o CSV da câmera para `C:\ppg-teste\dados\`.
   Log: `start,epoch_s` (hora de início, precisão de 1 s), `rr,t_ms,rr_ms` (cada RR, carimbado com o tempo do callback) e `hr,t_ms,bpm` (FC do relógio, 1/s).

## Como ler o resultado

| O que aparece | Conclusão |
| --- | --- |
| `cb 0` | o callback nem é chamado com o sensor do pulso |
| `cb` sobe, `RR n=0` | callback chamado, mas sem RR |
| RR chegam, `dp` baixo (< ~10 ms) ou valores repetidos | RR suavizados/sintéticos, não servem |
| RR chegam, ~1 por batimento (n ≈ FC × minutos), `dp` claramente alto (dezenas de ms) e a FC sobe e desce uma vez a cada respiração (~10 s a 6/min) | **RR reais** |
| RR reais e atraso em relação à câmera de até ~1–2 s | **biofeedback no relógio é viável** |
| RR reais, mas atraso de vários segundos (como os ~5 s do BPM por Bluetooth) | não serve para acompanhar a respiração em tempo real |

O app recebe os RR em lotes a cada 1 s (o mínimo do `:period`), então o atraso mínimo é ~1 s mais o processamento do sensor óptico, que só o teste mostra.

## Decisões (02/11/2026)

- **Objetivo da tela (produto):** acompanhar a respiração: pacer + gráfico da FC batida a batida subindo na inspiração e descendo na expiração. O spike só valida se o dado existe e chega rápido.
- **Dado o mais instantâneo possível:** atraso de vários segundos inviabiliza o exercício de respiração.
- **Tipo de app:** watch app. A doc oficial de `registerSensorDataListener` diz que ele "will cause an app crash if called from a data field app", então RR só existe em watch app.
- **Durante exercício:** começar pelo watch app e depois validar se faz sentido usar na corrida (talvez só um número fixo).
- **Fonte de RR:** só o pulso, sem cinta. Se o spike falhar, o relógio fica **só com o pacer**.
- **Código:** esta subpasta de `bragarafaellr/ppg`.
- **1º teste no relógio (02/11, `dados/garmin-rrspike-2026-11-02-travou.txt`):** o **relógio inteiro travou** por volta de 20 s (lista de atividades presa; foi preciso segurar LIGHT ~15 s para reiniciar). Não houve `CIQ_LOG` (não foi exceção do app). Até 20 s: FC 72–81 bpm chegando, **nenhum RR**; aos 20,0 s chegou um único RR (621 ms, incoerente com FC 80 ≈ 750 ms) e o log acaba. Suspeita: a gravação de atividade (`ActivityRecording`) junto com o sensor. A 2ª versão não grava atividade.
- **2º teste (02/11, sem `ActivityRecording`, 60 s, sentado):** não travou. `cb 59` (callback chamado todo segundo), FC 64, **`RR n=0`**: o sensor do pulso **não entrega nenhum RR** ao app. Câmera junto (`dados/ppg_rear_2026-11-02_junto-rrspike.csv`): FC média 64,7, igual ao relógio.
- **Decisão:** o FR965 **não serve para biofeedback batida a batida pelo pulso**. Pela escolha "só pulso, sem cinta", o relógio fica **só com o pacer** (respiração guiada por vibração/visual, sem dado de FC em tempo real). O biofeedback com RR segue no app web pela câmera.

## Se o relógio travar

Segure **LIGHT** por 15–30 s até a tela apagar e aperte LIGHT para ligar (não apaga dados). Para remover o app: `Configurações > Atividades e apps`, ou apague `GARMIN/APPS/RRSPIKE.prg` pelo USB.
