# Usamos a imagem oficial que integra Ollama + Open WebUI
FROM ghcr.io/open-webui/open-webui:ollama

# Configurações de Branding e Persistência
ENV WEBUI_NAME="BenemaxGPT"
ENV WEBUI_URL="https://gpt.benemax.com.br/"
ENV WEBUI_SECRET_KEY="benemax_secret_key_change_me"
ENV WEBUI_AUTH=True

# Configurações para otimizar o uso em CPU e Persistência de Modelos
ENV OLLAMA_MODELS="/app/backend/data/ollama/models"
ENV OLLAMA_NUM_PARALLEL=1
ENV OLLAMA_MAX_LOADED_MODELS=1
ENV OLLAMA_INTEL_GPU=false
ENV OLLAMA_AMD_GPU=false

# Copiamos a logo de referência
COPY logobenemax.png /app/logobenemax_source.png

# ----- ESTRATÉGIA RADICAL DE REBRANDING (V10 - THE FINAL FIX) -----

# 1. Preparação das Pastas e Logos no local correto do Frontend
RUN mkdir -p /app/build/static && \
    cp /app/logobenemax_source.png /app/build/logo.png && \
    cp /app/logobenemax_source.png /app/build/favicon.png && \
    mkdir -p /app/backend/open_webui/static && \
    cp /app/logobenemax_source.png /app/backend/open_webui/static/logo.png

# 2. Criação do arquivo CSS mestre Refinado (Resolvendo Interatividade e Visibilidade)
RUN echo " \
    @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap'); \
    * { font-family: 'Poppins', sans-serif !important; } \
    body { background: #050508 !important; color: white !important; margin: 0; } \
    \
    /* Splash Screen / Preloader Fix */ \
    #logo-container, .loading-screen, #splash-screen { background: #050508 !important; visibility: visible !important; opacity: 1 !important; display: flex !important; } \
    #logo-container svg, .loading-screen svg, #splash-screen svg { display: none !important; } \
    #logo-container::after, .loading-screen::after, #splash-screen::after { \
    content: ''; display: block; width: 100px; height: 100px; \
    background: url('/logo.png') no-repeat center; background-size: contain; \
    animation: pulse 2s infinite; \
    } \
    @keyframes pulse { 0% { opacity: 0.6; transform: scale(0.95); } 50% { opacity: 1; transform: scale(1); } 100% { opacity: 0.6; transform: scale(0.95); } } \
    \
    /* Auth Card & Inputs (Resolvendo cliques bloqueados) */ \
    .w-full.max-w-md, [class*='auth-card'] { \
    background: rgba(255, 255, 255, 0.05) !important; \
    backdrop-filter: blur(10px) !important; \
    border: 1px solid rgba(255, 255, 255, 0.1) !important; \
    border-radius: 24px !important; \
    z-index: 10 !important; \
    } \
    input { \
    background: rgba(255, 255, 255, 0.08) !important; \
    color: white !important; \
    border: 1px solid rgba(255, 255, 255, 0.2) !important; \
    pointer-events: auto !important; \
    } \
    \
    /* Logo acima do título */ \
    .text-2xl.font-medium::before { \
    content: ''; display: block; width: 70px; height: 70px; \
    background: url('/logo.png') no-repeat center; background-size: contain; \
    margin: 0 auto 15px; \
    } \
    \
    /* ABA DE CADASTRO - VISIBILIDADE */ \
    a[href*='/auth/signup'] { \
    color: #00A3FF !important; \
    font-weight: 700 !important; \
    text-decoration: underline !important; \
    } \
    " > /app/build/benemax.css

# 3. Injeção e Limpeza total
RUN sed -i 's|</head>|<link rel="stylesheet" href="/benemax.css"></head>|' /app/build/index.html && \
    find /app -type f -exec sed -i 's/Open WebUI/BenemaxGPT/g' {} + && \
    find /app -type f -exec sed -i 's/ (Open WebUI)//g' {} +

# 4. Configurações de Ambiente Final
ENV WEBUI_NAME="BenemaxGPT"
ENV WEBUI_URL="https://gpt.benemax.com.br/"
ENV ENABLE_SIGNUP=True
ENV DEFAULT_USER_ROLE="user"
ENV WEBUI_FAVICON_URL="/favicon.png"
ENV WEBUI_LOGO_URL="/logo.png"
ENV GLOBAL_TITLE_TEMPLATE="BenemaxGPT"

# Expor as portas necessárias
EXPOSE 8080
EXPOSE 11434

# Script para baixar o modelo Llama-3.1 durante o primeiro BOOT
RUN echo '#!/bin/bash\n\
    ollama serve & \n\
    sleep 5 \n\
    ollama pull llama3.1:8b \n\
    wait' > /usr/bin/start_llama.sh && chmod +x /usr/bin/start_llama.sh
