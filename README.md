# ppg

Protótipo para testar leitura de batimentos (PPG) pela câmera do iPhone, sem flash. Uma página só (`index.html`), sem build, sem backend.

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

Antes: desative o Modo Baixa Energia e não troque de aba durante a gravação. Inicie uma atividade no Garmin em paralelo para comparar.

Faça 3 gravações de 60 s (botão "Gravar 60 s"), dedo cobrindo a lente sem apertar:

1. **Traseira, perto da janela** (luz natural forte).
2. **Traseira, ambiente normal** (luz interna).
3. **Frontal, tela branca** (modo "Frontal": a tela fica branca para iluminar o dedo).

Ao fim de cada gravação, baixe o CSV ou copie o texto da caixa. Colunas: `ts_unix_ms, t_rel_ms, bruto, filtrado, pico, rr_ms` (~1800 linhas a 30 fps; `rr_ms` preenchido nas linhas de pico com RR válido). Use `ts_unix_ms` para alinhar com o Garmin.
