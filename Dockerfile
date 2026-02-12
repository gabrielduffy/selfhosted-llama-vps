# Usamos a imagem oficial que integra Ollama + Open WebUI
FROM ghcr.io/open-webui/open-webui:ollama

# Configurações de Branding e Persistência
ENV WEBUI_NAME="BenemaxGPT"
ENV WEBUI_URL="https://gpt.benemax.com.br/"
ENV WEBUI_SECRET_KEY="benemax_secret_key_change_me"
ENV WEBUI_AUTH=True

# Configurações para otimizar o uso em CPU
ENV OLLAMA_MODELS="/app/backend/data/ollama/models"
ENV OLLAMA_NUM_PARALLEL=1
ENV OLLAMA_MAX_LOADED_MODELS=1

# Copiamos a logo de referência
COPY logobenemax.png /app/logobenemax_source.png

# ----- ESTRATÉGIA DE BRANDING ESTÁVEL (V11 - CLEAN & FUNCTIONAL) -----

# 1. Preparação de Imagens
RUN mkdir -p /app/build/static && \
    cp /app/logobenemax_source.png /app/build/logo.png && \
    cp /app/logobenemax_source.png /app/build/favicon.png && \
    mkdir -p /app/backend/open_webui/static && \
    cp /app/logobenemax_source.png /app/backend/open_webui/static/logo.png

# 2. CSS que não quebra os campos (Foco em Visibilidade)
RUN echo " \
    @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap'); \
    :root { --font-family: 'Poppins', sans-serif !important; } \
    body { background-color: #0a0a0c !important; color: #ffffff !important; } \
    \
    /* Splash Screen */ \
    #logo-container, .loading-screen { background: #0a0a0c !important; } \
    #logo-container svg, .loading-screen svg { display: none !important; } \
    #logo-container::after, .loading-screen::after { \
    content: ''; display: block; width: 80px; height: 80px; \
    background: url('/logo.png') no-repeat center; background-size: contain; \
    animation: fadeInOut 2s infinite; \
    } \
    @keyframes fadeInOut { 0%, 100% { opacity: 0.5; } 50% { opacity: 1; } } \
    \
    /* Auth Page Fix - Garantindo cliques e visibilidade */ \
    .w-full.max-w-md { \
    background: #16161a !important; \
    border: 1px solid #2d2d35 !important; \
    border-radius: 16px !important; \
    padding: 30px !important; \
    box-shadow: 0 10px 30px rgba(0,0,0,0.5) !important; \
    position: relative !important; \
    z-index: 1 !important; \
    } \
    \
    /* Forçando cor dos textos */ \
    h2, label, span, p, .text-sm { color: #ffffff !important; opacity: 1 !important; } \
    \
    /* Inputs - Estilo Limpo e Clicável */ \
    input { \
    background: #1f1f23 !important; \
    border: 1px solid #3f3f46 !important; \
    color: #ffffff !important; \
    border-radius: 8px !important; \
    margin-bottom: 10px !important; \
    padding: 10px !important; \
    } \
    input:focus { border-color: #00A3FF !important; } \
    \
    /* Logo Benemax no topo */ \
    h2::before { \
    content: ''; display: block; width: 60px; height: 60px; \
    background: url('/logo.png') no-repeat center; background-size: contain; \
    margin: 0 auto 15px; \
    } \
    \
    /* Botão e Link de Cadastro */ \
    button[type='submit'] { \
    background: #00A3FF !important; \
    color: white !important; \
    font-weight: 600 !important; \
    border-radius: 8px !important; \
    margin-top: 15px !important; \
    } \
    a[href*='/auth/signup'] { \
    display: inline-block !important; \
    margin-top: 20px !important; \
    color: #00A3FF !important; \
    font-weight: 600 !important; \
    text-decoration: none !important; \
    border: 1px solid #00A3FF !important; \
    padding: 8px 20px !important; \
    border-radius: 20px !important; \
    } \
    a[href*='/auth/signup']:hover { background: rgba(0, 163, 255, 0.1) !important; } \
    " > /app/build/benemax.css

# 3. Injeção e Tradução
RUN sed -i 's|</head>|<link rel="stylesheet" href="/benemax.css"></head>|' /app/build/index.html && \
    find /app -type f -exec sed -i 's/Open WebUI/BenemaxGPT/g' {} +

# 4. Configuração Final
ENV WEBUI_NAME="BenemaxGPT"
ENV WEBUI_URL="https://gpt.benemax.com.br/"
ENV ENABLE_SIGNUP=True
ENV WEBUI_FAVICON_URL="/favicon.png"
ENV WEBUI_LOGO_URL="/logo.png"

EXPOSE 8080

RUN echo '#!/bin/bash\n\
    ollama serve & \n\
    sleep 5 \n\
    ollama pull llama3.1:8b \n\
    wait' > /usr/bin/start_llama.sh && chmod +x /usr/bin/start_llama.sh
