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

São ~1800 linhas por minuto a 30 fps. RR fora de 300–2000 ms, ou longe demais da mediana recente (abaixo de 70% ou acima de 150%), fica em branco.
