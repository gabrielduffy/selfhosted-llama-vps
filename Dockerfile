# Usamos a imagem oficial estável
FROM ghcr.io/open-webui/open-webui:ollama

# Configurações de Marca
ENV WEBUI_NAME="BenemaxGPT"
ENV WEBUI_URL="https://gpt.benemax.com.br/"
ENV WEBUI_SECRET_KEY="benemax_secret_key_change_me"
ENV WEBUI_AUTH=True
ENV ENABLE_SIGNUP=True
ENV DEFAULT_USER_ROLE="user"

# Copiamos a logo
COPY logobenemax.png /app/logobenemax_source.png

# ----- V12: REBRANDING CIRÚRGICO E ESTÁVEL -----

# 1. Substituição de Assets (Favicon e Logos)
RUN mkdir -p /app/build/static && \
    cp /app/logobenemax_source.png /app/build/logo.png && \
    cp /app/logobenemax_source.png /app/build/favicon.png && \
    cp /app/logobenemax_source.png /app/build/static/favicon.png && \
    mkdir -p /app/backend/open_webui/static && \
    cp /app/logobenemax_source.png /app/backend/open_webui/static/logo.png

# 2. Injeção de CSS de Alto Contraste (Surgical Style)
RUN echo " \
    <style> \
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap'); \
    body { background-color: #050508 !important; color: #ffffff !important; font-family: 'Inter', sans-serif !important; } \
    \
    /* Preloader Fix */ \
    #logo-container, .loading-screen, #splash-screen { background: #050508 !important; } \
    #logo-container svg, .loading-screen svg { display: none !important; } \
    #logo-container::after { content: ''; display: block; width: 60px; height: 60px; background: url('/logo.png') no-repeat center; background-size: contain; animation: pulse 2s infinite; } \
    @keyframes pulse { 0%, 100% { opacity: 0.5; } 50% { opacity: 1; } } \
    \
    /* Login Card - FUNCIONALIDADE ACIMA DE TUDO */ \
    .w-full.max-w-md { \
    background: #111114 !important; \
    border: 1px solid #333338 !important; \
    border-radius: 20px !important; \
    padding: 35px !important; \
    box-shadow: 0 20px 50px rgba(0,0,0,0.8) !important; \
    z-index: 100 !important; \
    } \
    \
    /* Textos e Labels - CONTRASTE MÁXIMO */ \
    h2, label, span, p, .text-sm { color: #ffffff !important; opacity: 1 !important; font-weight: 600 !important; } \
    \
    /* Inputs - Fundo Escuro com Letra Branca Viva */ \
    input { \
    background: #1c1c21 !important; \
    border: 1px solid #3f3f46 !important; \
    color: #ffffff !important; \
    border-radius: 10px !important; \
    padding: 14px !important; \
    font-size: 16px !important; \
    caret-color: #00A3FF !important; \
    } \
    input::placeholder { color: #666 !important; } \
    input:focus { border-color: #00A3FF !important; outline: none !important; } \
    \
    /* Logo Benemax no formulário */ \
    h2::before { \
    content: ''; display: block; width: 80px; height: 80px; \
    background: url('/logo.png') no-repeat center; background-size: contain; \
    margin: 0 auto 20px; \
    } \
    \
    /* Botão Principal Entrar */ \
    button[type='submit'] { \
    background: #00A3FF !important; \
    color: white !important; \
    font-weight: 700 !important; \
    height: 50px !important; \
    border-radius: 10px !important; \
    margin-top: 10px !important; \
    cursor: pointer !important; \
    } \
    \
    /* BOTÃO DE CADASTRO - VISÍVEL E CLICÁVEL */ \
    .mt-4.text-center, .mt-6.text-center { margin-top: 25px !important; } \
    a[href*='/auth/signup'] { \
    display: block !important; \
    padding: 12px !important; \
    background: rgba(0, 163, 255, 0.1) !important; \
    border: 1px solid #00A3FF !important; \
    color: #00A3FF !important; \
    border-radius: 10px !important; \
    text-align: center !important; \
    font-weight: 700 !important; \
    text-decoration: none !important; \
    } \
    a[href*='/auth/signup']:hover { background: #00A3FF !important; color: white !important; } \
    </style> " > /app/build/style-inj.html

# 3. Injeção e Tradução Segura (Apenas Título e Cabeçalho)
RUN sed -i 's|</head>|$(cat /app/build/style-inj.html)</head>|' /app/build/index.html && \
    sed -i 's/Open WebUI/BenemaxGPT/g' /app/build/index.html

# 4. Configuração Final
ENV OLLAMA_NUM_PARALLEL=1
ENV OLLAMA_MAX_LOADED_MODELS=1

EXPOSE 8080

RUN echo '#!/bin/bash\n\
    ollama serve & \n\
    sleep 5 \n\
    ollama pull llama3.1:8b \n\
    wait' > /usr/bin/start_llama.sh && chmod +x /usr/bin/start_llama.sh
