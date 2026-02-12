# Versão 18 - RESTAURAÇÃO DE EMERGÊNCIA (ESTÁVEL E SEM ERROS)
FROM ghcr.io/open-webui/open-webui:ollama

# 1. Configurações Oficiais (Garante que o app inicie)
ENV WEBUI_NAME="BenemaxGPT"
ENV WEBUI_URL="https://gpt.benemax.com.br/"
ENV WEBUI_SECRET_KEY="benemax_secret_key_change_me"
ENV WEBUI_AUTH=True
ENV ENABLE_SIGNUP=True

# 2. Gestão de Assets (Seguro)
COPY logobenemax.png /app/benemax_logo.png
RUN cp /app/benemax_logo.png /app/build/favicon.png && \
    cp /app/benemax_logo.png /app/build/logo.png && \
    mkdir -p /app/backend/data/static && \
    cp /app/benemax_logo.png /app/backend/data/static/logo.png

# 3. Injeção de Estilo (Método Ultra-Seguro)
# Em vez de sed complexo, vamos apenas adicionar uma tag de estilo simples
RUN echo "<style> \
    :root { --benemax-blue: #00A3FF; } \
    body { background-color: #050508 !important; color: #FFF !important; } \
    .w-full.max-w-md { background: rgba(20, 20, 25, 0.9) !important; border: 1px solid rgba(255, 255, 255, 0.1) !important; border-radius: 20px !important; } \
    input { background: #1a1a1f !important; color: #FFF !important; border: 1px solid #333 !important; } \
    button[type='submit'] { background: var(--benemax-blue) !important; font-weight: bold !important; } \
    </style>" > /app/style-inject.html && \
    sed -i 's|</head>|'"$(cat /app/style-inject.html)"'</head>|' /app/build/index.html

# 4. Configurações de Porta
EXPOSE 8080

# 5. Inicialização Original (Não mexemos no que funciona)
# O Open WebUI já tem seu entrypoint e CMD configurados na imagem base.
# IMPORTANTE: Se o erro "Index of /" persistir, verifique a configuração do Easypanel, 
# pois isso sugere que o domínio não está chegando no container.
