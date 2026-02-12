# Versão Definitiva - BenemaxGPT
FROM ghcr.io/open-webui/open-webui:ollama

# Configurações de Branding
ENV WEBUI_NAME="BenemaxGPT"
ENV WEBUI_URL="https://gpt.benemax.com.br/"
ENV WEBUI_SECRET_KEY="benemax_secret_key_change_me"
ENV WEBUI_AUTH=True
ENV ENABLE_SIGNUP=True

# Copiamos a logo
COPY logobenemax.png /app/logobenemax_source.png

# ----- EXTERMÍNIO DA MARCA ORIGINAL -----

# 1. Substituição física de arquivos (Deleta o original e coloca Benemax)
RUN find /app -name "*favicon*" -exec cp /app/logobenemax_source.png {} \; && \
    find /app -name "*logo*" -exec cp /app/logobenemax_source.png {} \; && \
    cp /app/logobenemax_source.png /app/build/logo.png && \
    cp /app/logobenemax_source.png /app/build/favicon.png

# 2. Injeção Manual de CSS Inquebrável (Resolvendo interatividade e cores)
RUN echo " \
    <style> \
    body { background: #000000 !important; color: #ffffff !important; } \
    #logo-container, .loading-screen { background: #000000 !important; } \
    #logo-container svg, .loading-screen svg { display: none !important; } \
    #logo-container::after, .loading-screen::after { \
    content: ''; display: block; width: 80px; height: 80px; \
    background: url('/logo.png') no-repeat center; background-size: contain; \
    } \
    /* Card de Login Sólido - Sem bloqueio de clique */ \
    .w-full.max-w-md { \
    background: #111111 !important; \
    border: 2px solid #333333 !important; \
    border-radius: 15px !important; \
    padding: 40px !important; \
    z-index: 1000 !important; \
    } \
    /* Inputs Visíveis - Texto BRANCO PURO */ \
    label, span, p, h2 { color: #ffffff !important; font-weight: bold !important; } \
    input { \
    background: #1a1a1a !important; \
    color: #ffffff !important; \
    border: 1px solid #444444 !important; \
    border-radius: 8px !important; \
    padding: 12px !important; \
    width: 100% !important; \
    display: block !important; \
    } \
    input:focus { border-color: #00A3FF !important; } \
    /* Botões */ \
    button[type='submit'] { \
    background: #00A3FF !important; \
    color: white !important; \
    font-weight: bold !important; \
    border-radius: 8px !important; \
    height: 48px !important; \
    width: 100% !important; \
    cursor: pointer !important; \
    } \
    /* Link de Cadastro - Único e Visível */ \
    a[href*='/auth/signup'] { \
    display: block !important; \
    margin-top: 20px !important; \
    padding: 12px !important; \
    background: rgba(0, 163, 255, 0.1) !important; \
    border: 2px solid #00A3FF !important; \
    color: #00A3FF !important; \
    border-radius: 10px !important; \
    text-align: center !important; \
    font-weight: bold !important; \
    text-decoration: none !important; \
    } \
    </style> " > /app/branding.html

# 3. Aplicando a injeção de forma segura
RUN sed -i 's|</head>|'"$(cat /app/branding.html)"'</head>|' /app/build/index.html && \
    find /app -type f -exec sed -i 's/Open WebUI/BenemaxGPT/g' {} +

EXPOSE 8080

RUN echo '#!/bin/bash\n\
    ollama serve & \n\
    sleep 5 \n\
    ollama pull llama3.1:8b \n\
    wait' > /usr/bin/start_llama.sh && chmod +x /usr/bin/start_llama.sh
