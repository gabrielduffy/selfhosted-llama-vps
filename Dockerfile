# BenemaxGPT - Versão 16 (RESCUE MODE - 100% FUNCIONAL)
FROM ghcr.io/open-webui/open-webui:ollama

# 1. Configurações de Marca e Ambiente
ENV WEBUI_NAME="BenemaxGPT"
ENV WEBUI_URL="https://gpt.benemax.com.br/"
ENV WEBUI_SECRET_KEY="benemax_secret_key_change_me"
ENV WEBUI_AUTH=True
ENV ENABLE_SIGNUP=True
ENV DEFAULT_USER_ROLE="user"

# 2. Gestão de Assets (Expurgo Total do Branding Original)
COPY logobenemax.png /app/benemax_logo.png

# Substituição massiva de QUALQUER arquivo de imagem original pela logo Benemax
RUN find /app/build -type f \( -name "*logo*" -o -name "*favicon*" -o -name "*apple-touch-icon*" \) -exec cp /app/benemax_logo.png {} \; || true
RUN cp /app/benemax_logo.png /app/build/logo.png && \
    cp /app/benemax_logo.png /app/build/favicon.png && \
    mkdir -p /app/backend/open_webui/static && \
    cp /app/benemax_logo.png /app/backend/open_webui/static/logo.png

# 3. Injeção de CSS Seguro (Apenas cores e visibilidade, sem bloqueio de mouse)
RUN echo ' \
    <style> \
    /* Fundo Escuro e Letra Branca */ \
    body { background-color: #050508 !important; color: white !important; } \
    #logo-container, .loading-screen { background: #050508 !important; } \
    #logo-container svg { display: none !important; } \
    #logo-container::after { content: ""; display: block; width: 60px; height: 60px; background: url("/logo.png") no-repeat center; background-size: contain; } \
    \
    /* Login Card - Sólido e Clicável */ \
    .w-full.max-w-md { \
    background-color: #111114 !important; \
    border: 1px solid #333 !important; \
    color: white !important; \
    z-index: 10 !important; \
    position: relative !important; \
    } \
    \
    /* Texto dos campos - Visibilidade Total */ \
    label, h2, span, p { color: white !important; opacity: 1 !important; } \
    \
    /* Inputs - Claros e Clicáveis */ \
    input { \
    background-color: #1a1a1f !important; \
    color: white !important; \
    border: 1px solid #444 !important; \
    padding: 10px !important; \
    pointer-events: auto !important; \
    opacity: 1 !important; \
    } \
    \
    /* Botões e Cadastro */ \
    button[type="submit"] { background-color: #00A3FF !important; color: white !important; font-weight: bold !important; cursor: pointer !important; } \
    a[href*="/auth/signup"] { \
    display: block !important; \
    margin-top: 20px !important; \
    padding: 10px !important; \
    background-color: rgba(0, 163, 255, 0.2) !important; \
    border: 1px solid #00A3FF !important; \
    color: white !important; \
    text-align: center !important; \
    font-weight: bold !important; \
    text-decoration: none !important; \
    } \
    </style>' > /app/branding.html

# 4. Injeção no HTML e Renomeação Global
RUN sed -i 's|</head>|'"$(cat /app/branding.html)"'</head>|' /app/build/index.html && \
    find /app -type f -exec sed -i 's/Open WebUI/BenemaxGPT/g' {} +

EXPOSE 8080
ENV OLLAMA_NUM_PARALLEL=1
ENV OLLAMA_MAX_LOADED_MODELS=1

RUN echo '#!/bin/bash\n\
    ollama serve & \n\
    sleep 5 \n\
    ollama pull llama3.1:8b \n\
    wait' > /usr/bin/start_llama.sh && chmod +x /usr/bin/start_llama.sh
