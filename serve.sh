#!/usr/bin/env bash
# Servidor HTTPS local para testar no iPhone (câmera exige HTTPS).
# Uso: ./serve.sh            (ou IP=192.168.0.10 ./serve.sh para forçar o IP)
set -euo pipefail
cd "$(dirname "$0")"
PORT=8443

PY=python3
"$PY" -c '' 2>/dev/null || PY=python

# IP da rede local (nenhum pacote é enviado; só escolhe a interface de saída)
IP="${IP:-$("$PY" -c 'import socket; s=socket.socket(socket.AF_INET, socket.SOCK_DGRAM); s.connect(("10.255.255.255", 1)); print(s.getsockname()[0])')}"

CERT="cert-$IP.pem"
KEY="key-$IP.pem"
if [ ! -f "$CERT" ]; then
  mkcert -install
  mkcert -cert-file "$CERT" -key-file "$KEY" localhost 127.0.0.1 "$IP"
fi

echo "Certificado raiz (instalar no iPhone): $(mkcert -CAROOT)/rootCA.pem"
echo "Abra no iPhone: https://$IP:$PORT/"

"$PY" - "$PORT" "$CERT" "$KEY" <<'EOF'
import http.server, ssl, sys
port, cert, key = int(sys.argv[1]), sys.argv[2], sys.argv[3]
httpd = http.server.ThreadingHTTPServer(("0.0.0.0", port), http.server.SimpleHTTPRequestHandler)
ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ctx.load_cert_chain(cert, key)
httpd.socket = ctx.wrap_socket(httpd.socket, server_side=True)
httpd.serve_forever()
EOF
