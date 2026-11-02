# ppg

Protótipo para testar leitura de batimentos (PPG) pela câmera do iPhone. Na traseira, o flash é ligado quando o aparelho permite; na frontal, a tela branca ilumina o dedo. Uma página só (`index.html`), sem build, sem backend.

Para receber ao vivo a frequência de um relógio Garmin (Configurações › Sensores e acessórios › FC no pulso › Transmitir FC), abra a página no navegador **Bluefy**, que tem Bluetooth, e toque em "Conectar Garmin". No Safari a câmera funciona, mas o Bluetooth não.

## Servir

A câmera só funciona em HTTPS.

### a) GitHub Pages

Publique o repo `bragarafaellr/ppg` com GitHub Pages (Settings › Pages › branch `main`, pasta `/`) e abra no iPhone:

https://bragarafaellr.github.io/ppg/

### b) HTTPS local (`serve.sh`)

Requer [mkcert](https://github.com/FiloSottile/mkcert) e Python 3. iPhone e computador na mesma rede Wi-Fi.

```bash
./serve.sh
```

O script cria um certificado para o IP local (arquivos `*.pem`, fora do git), mostra o caminho do `rootCA.pem` e a URL `https://<ip>:8443/`. Se o IP detectado estiver errado: `IP=192.168.0.10 ./serve.sh`.

Para o iPhone confiar no certificado:

1. Envie o `rootCA.pem` (caminho mostrado pelo script) para o iPhone (AirDrop ou e-mail) e abra o arquivo; ele vira um perfil baixado.
2. Ajustes › Geral › VPN e Gerenciamento de Dispositivo › selecione o perfil do mkcert › Instalar (confiar).
3. Ajustes › Geral › Sobre › Ajustes de Confiança de Certificado › ative a confiança total para o certificado raiz do mkcert.

## Protocolo de teste

Antes: desative o Modo Baixa Energia e não troque de aba durante a gravação. Inicie uma atividade Cardio no Garmin e conecte-o na página.

Faça 4 gravações, dedo cobrindo a lente sem apertar:

1. **A — Traseira**, respiração normal, "Gravar 60 s".
2. **B — Frontal**, respiração normal, "Gravar 60 s".
3. **C — Traseira**, respirando a 6/min (inspira 4 s, expira 6 s), "Gravar 2 min".
4. **D — Frontal**, respirando a 6/min, "Gravar 2 min".

C e D duram 2 min para ter ~12 respirações, como pede o protocolo de Lehrer et al. (2000) para analisar cada ritmo.

Ao fim de cada gravação, baixe o CSV ou copie o texto da caixa. Colunas:

| Coluna | Conteúdo |
| --- | --- |
| `ts_unix_ms` | Horário UTC do iPhone, para alinhar com outros arquivos |
| `t_rel_ms` | Tempo desde o início da gravação |
| `bruto`, `filtrado` | Média do canal de cor e sinal filtrado |
| `pico`, `rr_ms` | 1 na linha de cada batimento; RR válido nessa linha |
| `garmin_bpm` | Último BPM recebido do relógio (vazio sem conexão) |
| `garmin_rr_ms` | RR enviado pelo relógio, se ele enviar |
| `pacer` | 1 inspira, 0 expira, vazio sem pacer |
| `movimento` | 1 enquanto os batimentos são descartados por movimento do dedo |

São ~1800 linhas por minuto a 30 fps. RR fora de 300–2000 ms, ou longe demais da mediana recente (abaixo de 70% ou acima de 150%), fica em branco.

## Tela de respiração

- **Pacer:** a barra enche na inspiração e esvazia na expiração. A inspiração dura 40% do ciclo (a 6/min: 4 s inspira, 6 s expira). Ritmos de 6,5 a 4,5/min para achar a frequência ressonante, ou "sem pacer".
- **Curva da FC:** a FC de cada batimento (60000 / RR) nos últimos 30 s. As faixas azuis são as inspirações do pacer: com a respiração na frequência certa, a FC sobe na faixa azul e desce fora dela.
- **Variação/resp:** FC máxima − mínima em cada ciclo do pacer (janelas de 10 s sem pacer), média dos últimos 3 ciclos.
- **Detecção:** passa-baixa de 3 Hz (tira o entalhe dicrótico, que virava batimento falso), pico confirmado em ±200 ms, período refratário de 60% do RR típico. Se a amplitude dos últimos 2 s passar de 2,5× a típica, aparece "Movimento: deixe o dedo parado" e os batimentos são descartados por 1 s. Na gravação de 02/11 (`dados/`), os RR aceitos foram de 30 para 46 em 60 s. Nas de 30/10, sem movimento, o resultado não mudou.
- Para um sinal limpo: dedo **apoiado de leve** sobre a câmera, mão apoiada na mesa, sem apertar.
